import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/attempts/attempt.dart';
import 'package:ielts_simulator/attempts/attempt_repository.dart';
import 'package:ielts_simulator/content/content_repository.dart';
import 'package:ielts_simulator/content/models/practice.dart';
import 'package:ielts_simulator/core/result.dart';
import 'package:ielts_simulator/core/scoring.dart';
import 'package:ielts_simulator/features/results/criterion_rater.dart';
import 'package:ielts_simulator/features/results/self_check_notifier.dart';
import 'package:ielts_simulator/features/results/speaking_playback.dart';
import 'package:ielts_simulator/ui/async_value_view.dart';
import 'package:ielts_simulator/ui/theme.dart';

/// Self-assessment for Writing or Speaking against plain-English criteria,
/// next to a Band 8 model answer.
class SelfCheckScreen extends ConsumerWidget {
  const SelfCheckScreen({required this.attemptId, required this.section, super.key});

  final String attemptId;
  final ExamSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueView(
      value: ref.watch(attemptProvider(attemptId)),
      data: (attempt) => attempt == null
          ? const Scaffold()
          : AsyncValueView(
              value: ref.watch(descriptorsProvider),
              data: (descriptors) =>
                  _SelfCheckView(attempt: attempt, descriptors: descriptors, section: section),
            ),
    );
  }
}

class _SelfCheckView extends ConsumerWidget {
  const _SelfCheckView({required this.attempt, required this.descriptors, required this.section});

  final Attempt attempt;
  final Descriptors descriptors;
  final ExamSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final key = (attemptId: attempt.id, section: section);
    final ratings = ref.watch(selfCheckProvider(key));
    final notifier = ref.read(selfCheckProvider(key).notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) => notifier.load(attempt, descriptors));
    final complete = notifier.isComplete(descriptors);
    final isWriting = section == ExamSection.writing;
    final tabs = isWriting
        ? [
            _WritingTaskPane(
              attempt: attempt,
              task: 1,
              criteria: descriptors.writing1,
              ratings: ratings,
              onRate: notifier.rate,
            ),
            _WritingTaskPane(
              attempt: attempt,
              task: 2,
              criteria: descriptors.writing2,
              ratings: ratings,
              onRate: notifier.rate,
            ),
          ]
        : [
            SpeakingPlayback(attempt: attempt),
            _CriteriaPane(
              criteria: descriptors.speaking,
              ratings: ratings,
              onRate: notifier.rate,
              slotPrefix: '',
            ),
          ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isWriting ? l10n.rateWriting : l10n.rateSpeaking),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: isWriting
                ? [Tab(text: l10n.writingTask(1)), Tab(text: l10n.writingTask(2))]
                : [Tab(text: l10n.yourRecordings), Tab(text: l10n.criteria)],
          ),
        ),
        body: TabBarView(children: tabs),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: FilledButton(
              onPressed: complete
                  ? () async {
                      final router = GoRouter.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      final failed = l10n.saveError;
                      switch (await notifier.save(descriptors)) {
                        case Ok():
                          router.pop();
                        case Err():
                          messenger.showSnackBar(SnackBar(content: Text(failed)));
                      }
                    }
                  : null,
              child: Text(complete ? l10n.saveRating : l10n.rateAllCriteria),
            ),
          ),
        ),
      ),
    );
  }
}

class _WritingTaskPane extends ConsumerWidget {
  const _WritingTaskPane({
    required this.attempt,
    required this.task,
    required this.criteria,
    required this.ratings,
    required this.onRate,
  });

  final Attempt attempt;
  final int task;
  final List<Criterion> criteria;
  final Ratings ratings;
  final void Function(String slot, double band) onRate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final essay = attempt.essays[task - 1];
    final paper = ref.watch(writingPaperProvider((attempt.testId, attempt.module))).value;
    final model = paper?.tasks.where((item) => item.number == task).firstOrNull;
    final words = countWords(essay);
    return ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: [
        Text(l10n.yourAnswer, style: Theme.of(context).textTheme.titleMedium),
        Text(
          l10n.wordCount(words),
          style: TextStyle(
            color: words < (model?.minWords ?? 0) ? AppColors.incorrect : AppColors.correct,
          ),
        ),
        if (words < (model?.minWords ?? 0)) Text(l10n.underLength(model!.minWords)),
        const SizedBox(height: AppSpacing.sm),
        SelectableText(essay.isEmpty ? l10n.noText : essay),
        if (model != null)
          ExpansionTile(
            tilePadding: EdgeInsetsDirectional.zero,
            title: Text(l10n.modelAnswer(model.modelBand)),
            children: [
              SelectableText(model.modelAnswer),
              for (final tip in model.tips)
                ListTile(leading: const Icon(Icons.lightbulb_outline), title: Text(tip)),
            ],
          ),
        const Divider(),
        _CriteriaList(criteria: criteria, ratings: ratings, onRate: onRate, slotPrefix: '$task:'),
      ],
    );
  }
}

class _CriteriaPane extends StatelessWidget {
  const _CriteriaPane({
    required this.criteria,
    required this.ratings,
    required this.onRate,
    required this.slotPrefix,
  });

  final List<Criterion> criteria;
  final Ratings ratings;
  final void Function(String slot, double band) onRate;
  final String slotPrefix;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
    children: [
      _CriteriaList(criteria: criteria, ratings: ratings, onRate: onRate, slotPrefix: slotPrefix),
    ],
  );
}

class _CriteriaList extends StatelessWidget {
  const _CriteriaList({
    required this.criteria,
    required this.ratings,
    required this.onRate,
    required this.slotPrefix,
  });

  final List<Criterion> criteria;
  final Ratings ratings;
  final void Function(String slot, double band) onRate;
  final String slotPrefix;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(context.l10n.selfCheckHelp, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: AppSpacing.sm),
      for (final criterion in criteria)
        CriterionRater(
          criterion: criterion,
          band: ratings['$slotPrefix${criterion.id}'],
          onRate: (band) => onRate('$slotPrefix${criterion.id}', band),
        ),
    ],
  );
}
