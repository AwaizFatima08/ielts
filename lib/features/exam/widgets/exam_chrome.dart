import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/core/clock.dart';
import 'package:ielts_simulator/ui/theme.dart';

/// Time left until the given end time, ticking once a second and stopping at zero.
final countdownProvider = StreamProvider.autoDispose.family<Duration, DateTime>((
  ref,
  endsAt,
) async* {
  final clock = ref.watch(clockProvider);
  while (true) {
    final left = endsAt.difference(clock.now());
    if (left <= Duration.zero) {
      yield Duration.zero;
      return;
    }
    yield left;
    await Future<void>.delayed(const Duration(seconds: 1));
  }
});

/// "mm:ss" or "h:mm:ss" for a countdown.
String formatCountdown(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}

/// Timer chip for the exam app bar; red in the last five minutes.
class CountdownChip extends ConsumerWidget {
  const CountdownChip({required this.endsAt, super.key});

  final DateTime endsAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final left = ref.watch(countdownProvider(endsAt)).value;
    if (left == null) return const SizedBox.shrink();
    final urgent = left < const Duration(minutes: 5);
    return Semantics(
      liveRegion: urgent,
      label: context.l10n.timeLeft(left.inMinutes),
      child: Chip(
        avatar: Icon(Icons.timer_outlined, size: 18, color: urgent ? Colors.white : null),
        backgroundColor: urgent ? AppColors.accent : null,
        label: Text(
          formatCountdown(left),
          style: TextStyle(
            fontFeatures: const [FontFeature.tabularFigures()],
            color: urgent ? Colors.white : null,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Fires [onTimeUp] once when the countdown reaches zero.
class TimeUpListener extends ConsumerWidget {
  const TimeUpListener({
    required this.endsAt,
    required this.onTimeUp,
    required this.child,
    super.key,
  });

  final DateTime endsAt;
  final VoidCallback onTimeUp;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(countdownProvider(endsAt), (previous, next) {
      if (next.value == Duration.zero && previous?.value != Duration.zero) onTimeUp();
    });
    return child;
  }
}

/// One part of a paper in the bottom navigator.
@immutable
class NavigatorPart {
  const NavigatorPart({required this.label, required this.numbers});

  final String label;
  final List<int> numbers;
}

/// Bottom bar: parts, numbered question buttons (filled when answered,
/// orange when flagged — long-press to flag), as in the computer test.
class QuestionNavigator extends StatelessWidget {
  const QuestionNavigator({
    required this.parts,
    required this.currentPart,
    required this.answers,
    required this.flagged,
    required this.onSelectPart,
    required this.onToggleFlag,
    super.key,
  });

  final List<NavigatorPart> parts;
  final int currentPart;
  final Map<int, String> answers;
  final Set<int> flagged;
  final ValueChanged<int> onSelectPart;
  final ValueChanged<int> onToggleFlag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      color: scheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.sm),
            children: [
              for (final (index, part) in parts.indexed)
                _PartButtons(
                  part: part,
                  selected: index == currentPart,
                  answers: answers,
                  flagged: flagged,
                  onSelect: () => onSelectPart(index),
                  onToggleFlag: onToggleFlag,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartButtons extends StatelessWidget {
  const _PartButtons({
    required this.part,
    required this.selected,
    required this.answers,
    required this.flagged,
    required this.onSelect,
    required this.onToggleFlag,
  });

  final NavigatorPart part;
  final bool selected;
  final Map<int, String> answers;
  final Set<int> flagged;
  final VoidCallback onSelect;
  final ValueChanged<int> onToggleFlag;

  @override
  Widget build(BuildContext context) {
    final answered = part.numbers.where((number) => (answers[number] ?? '').isNotEmpty).length;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.md),
      child: Row(
        children: [
          TextButton(
            onPressed: onSelect,
            style: TextButton.styleFrom(
              backgroundColor: selected ? Theme.of(context).colorScheme.primaryContainer : null,
            ),
            child: Text('${part.label}  $answered/${part.numbers.length}'),
          ),
          if (selected)
            for (final number in part.numbers)
              _NumberButton(
                number: number,
                answered: (answers[number] ?? '').isNotEmpty,
                flagged: flagged.contains(number),
                onLongPress: () => onToggleFlag(number),
              ),
        ],
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  const _NumberButton({
    required this.number,
    required this.answered,
    required this.flagged,
    required this.onLongPress,
  });

  final int number;
  final bool answered;
  final bool flagged;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = flagged ? AppColors.flagged : (answered ? scheme.primary : scheme.surface);
    final foreground = flagged || answered ? Colors.white : scheme.onSurface;
    return Semantics(
      button: true,
      label: context.l10n.navigatorQuestion(number, answered ? 1 : 0, flagged ? 1 : 0),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          width: 34,
          height: 34,
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: scheme.outline),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text('$number', style: TextStyle(color: foreground, fontSize: 13)),
        ),
      ),
    );
  }
}

/// Confirms ending a section early; returns true to submit.
Future<bool> confirmSubmit(BuildContext context, {required int unanswered}) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.submitTitle),
      content: Text(l10n.submitBody(unanswered)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.keepWorking)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.submit)),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Warns before leaving a running section (progress in it is lost).
class ExamExitGuard extends StatelessWidget {
  const ExamExitGuard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop) return;
      final navigator = Navigator.of(context);
      final l10n = context.l10n;
      final leave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.leaveTitle),
          content: Text(l10n.leaveBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.stay)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.leave)),
          ],
        ),
      );
      if (leave ?? false) navigator.pop();
    },
    child: child,
  );
}

/// Instructions screen shown before each section starts.
class SectionIntro extends StatelessWidget {
  const SectionIntro({
    required this.title,
    required this.lines,
    required this.onStart,
    super.key,
  });

  final String title;
  final List<String> lines;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
          shrinkWrap: true,
          children: [
            Text(title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            Text(context.l10n.instructionsToCandidates, style: textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            for (final line in lines)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
                child: Text('•  $line', style: textTheme.bodyLarge),
              ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow),
              label: Text(context.l10n.start),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keeps the screen's async callbacks honest: runs [action] and ignores the
/// result only after it completes.
void runGuarded(Future<void> Function() action) => unawaited(action());
