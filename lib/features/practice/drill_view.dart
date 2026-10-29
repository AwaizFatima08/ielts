import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/content/models/practice.dart';
import 'package:ielts_simulator/content/models/question_group.dart';
import 'package:ielts_simulator/features/exam/reading/passage_view.dart';
import 'package:ielts_simulator/features/exam/widgets/question_group_view.dart';
import 'package:ielts_simulator/services/audio_service.dart';
import 'package:ielts_simulator/ui/theme.dart';

@immutable
class DrillState {
  const DrillState({this.answers = const {}, this.checked = false, this.showTranscript = false});

  final Map<int, String> answers;
  final bool checked;
  final bool showTranscript;

  DrillState copyWith({Map<int, String>? answers, bool? checked, bool? showTranscript}) =>
      DrillState(
        answers: answers ?? this.answers,
        checked: checked ?? this.checked,
        showTranscript: showTranscript ?? this.showTranscript,
      );
}

class DrillNotifier extends Notifier<DrillState> {
  DrillNotifier(this.unitId);

  final String unitId;

  @override
  DrillState build() => const DrillState();

  void answer(int number, String value) =>
      state = state.copyWith(answers: {...state.answers, number: value});

  void check() => state = state.copyWith(checked: true, showTranscript: true);

  void reset() => state = const DrillState();

  void toggleTranscript() => state = state.copyWith(showTranscript: !state.showTranscript);
}

final drillProvider = NotifierProvider.autoDispose.family<DrillNotifier, DrillState, String>(
  DrillNotifier.new,
);

/// Asset path of a practice listening clip.
String practiceClipPath(String unitId, String clipId) =>
    'assets/audio/practice/$unitId/$clipId.ogg';

/// A short untimed exercise: reading text or listening clip, questions,
/// then instant marking with explanations.
class DrillView extends ConsumerWidget {
  const DrillView({required this.unitId, required this.drill, super.key});

  final String unitId;
  final PracticeDrill drill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(drillProvider(unitId));
    final notifier = ref.read(drillProvider(unitId).notifier);
    final total = drill.groups.fold(0, (sum, group) => sum + group.numbers.length);
    final sheet = AnswerSheet(
      answers: state.answers,
      onAnswer: notifier.answer,
      reviewing: state.checked,
    );
    return ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: [
        if (drill.passage case final passage?)
          Card(
            child: SizedBox(height: 360, child: PassageView(passage: passage)),
          ),
        if (drill.script.isNotEmpty)
          _ListeningControls(
            unitId: unitId,
            script: drill.script,
            state: state,
            onTranscript: notifier.toggleTranscript,
          ),
        for (final group in drill.groups) QuestionGroupView(group: group, sheet: sheet),
        if (state.checked)
          Text(
            l10n.drillScore(scoreGroups(drill.groups, state.answers), total),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        const SizedBox(height: AppSpacing.sm),
        if (state.checked)
          OutlinedButton(onPressed: notifier.reset, child: Text(l10n.tryAgain))
        else
          FilledButton(onPressed: notifier.check, child: Text(l10n.checkAnswers)),
      ],
    );
  }
}

class _ListeningControls extends ConsumerWidget {
  const _ListeningControls({
    required this.unitId,
    required this.script,
    required this.state,
    required this.onTranscript,
  });

  final String unitId;
  final List<ScriptItem> script;
  final DrillState state;
  final VoidCallback onTranscript;

  Future<void> _play(AudioService audio) async {
    for (final line in script.whereType<ScriptLine>()) {
      final path = practiceClipPath(unitId, line.id);
      if (!await audio.hasAsset(path)) return;
      await audio.playAsset(path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final audio = ref.watch(audioServiceProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () => _play(audio),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.play),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(onPressed: audio.stop, child: Text(l10n.stop)),
                const Spacer(),
                TextButton(
                  onPressed: onTranscript,
                  child: Text(state.showTranscript ? l10n.hideTranscript : l10n.transcript),
                ),
              ],
            ),
            Text(l10n.drillAudioHint, style: Theme.of(context).textTheme.bodySmall),
            if (state.showTranscript)
              for (final line in script.whereType<ScriptLine>())
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: AppSpacing.xs),
                  child: Text('${line.speaker}: ${line.text}'),
                ),
          ],
        ),
      ),
    );
  }
}
