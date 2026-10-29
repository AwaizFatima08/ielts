import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/content/content_repository.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/features/exam/listening/listening_notifier.dart';
import 'package:ielts_simulator/features/exam/section_key.dart';
import 'package:ielts_simulator/features/exam/widgets/exam_chrome.dart';
import 'package:ielts_simulator/features/exam/widgets/question_group_view.dart';
import 'package:ielts_simulator/ui/async_value_view.dart';
import 'package:ielts_simulator/ui/theme.dart';

class ListeningScreen extends ConsumerWidget {
  const ListeningScreen({required this.sectionKey, super.key});

  final SectionKey sectionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(listeningPaperProvider(sectionKey.testId)),
    data: (paper) => _ListeningView(sectionKey: sectionKey, paper: paper),
  );
}

class _ListeningView extends ConsumerWidget {
  const _ListeningView({required this.sectionKey, required this.paper});

  final SectionKey sectionKey;
  final ListeningPaper paper;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(listeningProvider(sectionKey));
    final notifier = ref.read(listeningProvider(sectionKey).notifier);
    if (state.phase == ListeningPhase.ready) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.listening)),
        body: SectionIntro(
          title: l10n.listening,
          lines: [
            l10n.listeningIntro1,
            l10n.listeningIntro2,
            l10n.listeningIntro3,
            l10n.listeningIntro4,
          ],
          onStart: notifier.start,
        ),
      );
    }
    final part = paper.parts[state.viewedPart];
    final checkEndsAt = state.checkEndsAt;
    final view = Scaffold(
      appBar: AppBar(
        title: Text(l10n.listeningPart(part.number)),
        actions: [
          if (checkEndsAt != null) CountdownChip(endsAt: checkEndsAt),
          TextButton(
            onPressed: () async {
              final unanswered =
                  40 - state.answers.values.where((value) => value.isNotEmpty).length;
              if (await confirmSubmit(context, unanswered: unanswered)) await notifier.submit();
            },
            child: Text(l10n.submit, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          _PlaybackBanner(state: state, onSkip: notifier.skipWait),
          Expanded(
            child: ListView(
              key: PageStorageKey('listening-${part.number}'),
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              children: [
                for (final group in part.groups)
                  QuestionGroupView(
                    group: group,
                    sheet: AnswerSheet(answers: state.answers, onAnswer: notifier.answer),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: QuestionNavigator(
        parts: [
          for (final part in paper.parts)
            NavigatorPart(
              label: l10n.partShort(part.number),
              numbers: [for (final group in part.groups) ...group.numbers],
            ),
        ],
        currentPart: state.viewedPart,
        answers: state.answers,
        flagged: state.flagged,
        onSelectPart: notifier.viewPart,
        onToggleFlag: notifier.toggleFlag,
      ),
    );
    return ExamExitGuard(
      child: checkEndsAt == null
          ? view
          : TimeUpListener(endsAt: checkEndsAt, onTimeUp: notifier.submit, child: view),
    );
  }
}

class _PlaybackBanner extends StatelessWidget {
  const _PlaybackBanner({required this.state, required this.onSkip});

  final ListeningState state;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final message = switch (state.phase) {
      ListeningPhase.checking => l10n.listeningCheckTime,
      _ when state.pauseNote != null => l10n.listeningPause(state.pauseNote!),
      _ => l10n.listeningPlaying(state.partIndex + 1),
    };
    return Material(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(state.phase == ListeningPhase.checking ? Icons.edit_note : Icons.volume_up),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Semantics(liveRegion: true, child: Text(message))),
                if (kDebugMode && state.phase == ListeningPhase.playing)
                  TextButton(onPressed: onSkip, child: const Text('skip ›')),
              ],
            ),
            if (state.audioMissing)
              Text(l10n.audioPending, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
