import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/attempts/attempt.dart';
import 'package:ielts_simulator/content/content_repository.dart';
import 'package:ielts_simulator/services/audio_service.dart';
import 'package:ielts_simulator/ui/theme.dart';

/// The candidate's recorded answers with play buttons, then model answers.
class SpeakingPlayback extends ConsumerWidget {
  const SpeakingPlayback({required this.attempt, super.key});

  final Attempt attempt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final audio = ref.watch(audioServiceProvider);
    final paper = ref.watch(speakingPaperProvider(attempt.testId)).value;
    return ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: [
        if (attempt.recordings.isEmpty) Text(l10n.noRecordings),
        for (final recording in attempt.recordings)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${recording.part}')),
              title: Text(recording.question),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l10n.play,
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () async {
                      await audio.stop();
                      await audio.playFile(recording.filePath);
                    },
                  ),
                  IconButton(
                    tooltip: l10n.stop,
                    icon: const Icon(Icons.stop),
                    onPressed: audio.stop,
                  ),
                ],
              ),
            ),
          ),
        if (paper != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(l10n.modelAnswers, style: Theme.of(context).textTheme.titleMedium),
          for (final model in paper.modelAnswers)
            ExpansionTile(
              tilePadding: EdgeInsetsDirectional.zero,
              title: Text('${model.title}: ${model.prompt}'),
              children: [SelectableText(model.answer)],
            ),
          if (paper.usefulLanguage.isNotEmpty)
            ExpansionTile(
              tilePadding: EdgeInsetsDirectional.zero,
              title: Text(l10n.usefulLanguage),
              children: [
                for (final phrase in paper.usefulLanguage)
                  ListTile(dense: true, title: Text(phrase)),
              ],
            ),
        ],
      ],
    );
  }
}
