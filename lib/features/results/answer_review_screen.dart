import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/attempts/attempt.dart';
import 'package:ielts_simulator/attempts/attempt_repository.dart';
import 'package:ielts_simulator/content/content_repository.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/features/exam/reading/passage_view.dart';
import 'package:ielts_simulator/features/exam/widgets/question_group_view.dart';
import 'package:ielts_simulator/ui/async_value_view.dart';
import 'package:ielts_simulator/ui/theme.dart';

/// Marked Listening or Reading paper: every question with the candidate's
/// answer, the key, and why — plus the transcript or passage.
class AnswerReviewScreen extends ConsumerWidget {
  const AnswerReviewScreen({required this.attemptId, required this.section, super.key});

  final String attemptId;
  final ExamSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(attemptProvider(attemptId)),
    data: (attempt) {
      if (attempt == null) return const Scaffold();
      final answers =
          (section == ExamSection.listening ? attempt.listening : attempt.reading)?.answers ??
          const {};
      final sheet = AnswerSheet(answers: answers, onAnswer: (_, _) {}, reviewing: true);
      return section == ExamSection.listening
          ? AsyncValueView(
              value: ref.watch(listeningPaperProvider(attempt.testId)),
              data: (paper) => _ListeningReview(paper: paper, sheet: sheet),
            )
          : AsyncValueView(
              value: ref.watch(readingPaperProvider((attempt.testId, attempt.module))),
              data: (paper) => _ReadingReview(paper: paper, sheet: sheet),
            );
    },
  );
}

class _ListeningReview extends StatelessWidget {
  const _ListeningReview({required this.paper, required this.sheet});

  final ListeningPaper paper;
  final AnswerSheet sheet;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: paper.parts.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.reviewListening),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [for (final part in paper.parts) Tab(text: l10n.partShort(part.number))],
          ),
        ),
        body: TabBarView(
          children: [
            for (final part in paper.parts)
              ListView(
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                children: [
                  for (final group in part.groups) QuestionGroupView(group: group, sheet: sheet),
                  _Transcript(part: part, speakers: paper.speakers),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Transcript extends StatelessWidget {
  const _Transcript({required this.part, required this.speakers});

  final ListeningPart part;
  final Map<String, Speaker> speakers;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ExpansionTile(
      title: Text(context.l10n.transcript),
      tilePadding: EdgeInsetsDirectional.zero,
      children: [
        SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final line in part.script.whereType<ScriptLine>())
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${speakers[line.speaker]?.label ?? line.speaker}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: line.text),
                      ],
                    ),
                    style: textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadingReview extends StatelessWidget {
  const _ReadingReview({required this.paper, required this.sheet});

  final ReadingPaper paper;
  final AnswerSheet sheet;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: paper.passages.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.reviewReading),
          bottom: TabBar(
            isScrollable: paper.passages.length > 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              for (final passage in paper.passages) Tab(text: l10n.passageShort(passage.number)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final passage in paper.passages)
              ListView(
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                children: [
                  for (final group in passage.groups) QuestionGroupView(group: group, sheet: sheet),
                  ExpansionTile(
                    title: Text(l10n.showPassage),
                    tilePadding: EdgeInsetsDirectional.zero,
                    children: [SizedBox(height: 600, child: PassageView(passage: passage))],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
