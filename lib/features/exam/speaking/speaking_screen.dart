import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/content/content_repository.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/features/exam/section_key.dart';
import 'package:ielts_simulator/features/exam/speaking/speaking_notifier.dart';
import 'package:ielts_simulator/features/exam/widgets/exam_chrome.dart';
import 'package:ielts_simulator/ui/async_value_view.dart';
import 'package:ielts_simulator/ui/theme.dart';

class SpeakingScreen extends ConsumerWidget {
  const SpeakingScreen({required this.sectionKey, super.key});

  final SectionKey sectionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(speakingPaperProvider(sectionKey.testId)),
    data: (paper) => _SpeakingView(sectionKey: sectionKey, paper: paper),
  );
}

class _SpeakingView extends ConsumerWidget {
  const _SpeakingView({required this.sectionKey, required this.paper});

  final SectionKey sectionKey;
  final SpeakingPaper paper;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(speakingProvider(sectionKey));
    final notifier = ref.read(speakingProvider(sectionKey).notifier);
    if (!state.started) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.speaking)),
        body: SectionIntro(
          title: l10n.speaking,
          lines: [
            l10n.speakingIntro1,
            l10n.speakingIntro2,
            l10n.speakingIntro3,
            l10n.speakingIntro4,
          ],
          onStart: notifier.start,
        ),
      );
    }
    final steps = speakingSteps(paper);
    final step = steps[state.stepIndex.clamp(0, steps.length - 1)];
    return ExamExitGuard(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.speakingPart(step.part))),
        body: Column(
          children: [
            LinearProgressIndicator(value: (state.stepIndex + 1) / steps.length),
            if (!state.micAvailable)
              MaterialBanner(content: Text(l10n.micDenied), actions: const [SizedBox.shrink()]),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                children: [
                  switch (step) {
                    QuestionStep() => _QuestionCard(step: step),
                    PrepStep(:final card) => _CueCardView(
                      card: card,
                      notes: state.notes,
                      onNotes: notifier.editNotes,
                    ),
                    LongTurnStep(:final card) => _CueCardView(card: card, notes: state.notes),
                  },
                ],
              ),
            ),
            _TurnBar(
              secondsLeft: state.secondsLeft,
              recording: step.records && state.micAvailable,
              isPrep: step is PrepStep,
              onNext: state.finished ? null : notifier.next,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.step});

  final QuestionStep step;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (step.topic case final String topic?)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
            child: Text(context.l10n.speakingTopic(topic), style: textTheme.titleMedium),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(child: Icon(Icons.record_voice_over)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(step.question, style: textTheme.headlineSmall),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CueCardView extends StatelessWidget {
  const _CueCardView({required this.card, required this.notes, this.onNotes});

  final CueCard card;
  final String notes;

  /// Null during the long turn: notes are read-only then.
  final ValueChanged<String>? onNotes;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.prompt,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(context.l10n.cueCardYouShouldSay, style: textTheme.bodyLarge),
                for (final bullet in card.bullets)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: AppSpacing.md,
                      top: AppSpacing.xs,
                    ),
                    child: Text(bullet, style: textTheme.bodyLarge),
                  ),
                if (card.closing.isNotEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: AppSpacing.xs),
                    child: Text(card.closing, style: textTheme.bodyLarge),
                  ),
              ],
            ),
          ),
        ),
        TextFormField(
          initialValue: notes,
          readOnly: onNotes == null,
          onChanged: onNotes,
          minLines: 4,
          maxLines: 8,
          decoration: InputDecoration(labelText: context.l10n.cueCardNotes),
        ),
      ],
    );
  }
}

class _TurnBar extends StatelessWidget {
  const _TurnBar({
    required this.secondsLeft,
    required this.recording,
    required this.isPrep,
    required this.onNext,
  });

  final int secondsLeft;
  final bool recording;
  final bool isPrep;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                isPrep ? Icons.edit_note : (recording ? Icons.fiber_manual_record : Icons.mic_off),
                color: recording ? AppColors.accent : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  isPrep
                      ? l10n.prepTimeLeft(formatCountdown(Duration(seconds: secondsLeft)))
                      : l10n.answerTimeLeft(formatCountdown(Duration(seconds: secondsLeft))),
                ),
              ),
              FilledButton(onPressed: onNext, child: Text(isPrep ? l10n.startSpeaking : l10n.next)),
            ],
          ),
        ),
      ),
    );
  }
}
