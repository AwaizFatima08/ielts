import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/content/models/question_group.dart';
import 'package:ielts_simulator/features/exam/widgets/choice_views.dart';
import 'package:ielts_simulator/features/exam/widgets/gap_group_view.dart';
import 'package:ielts_simulator/ui/theme.dart';

/// The candidate's answers for a paper plus how to change them.
@immutable
class AnswerSheet {
  const AnswerSheet({required this.answers, required this.onAnswer, this.reviewing = false});

  final Map<int, String> answers;
  final void Function(int number, String value) onAnswer;

  /// When true, inputs are locked and marking is shown under each question.
  final bool reviewing;

  String answerFor(int number) => answers[number] ?? '';
}

/// Renders any [QuestionGroup] with its heading, instructions and image.
class QuestionGroupView extends StatelessWidget {
  const QuestionGroupView({required this.group, required this.sheet, super.key});

  final QuestionGroup group;
  final AnswerSheet sheet;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GroupHeading(group: group),
        if (group.imagePath case final String path?) _GroupImage(path: path),
        switch (group) {
          final GapGroup gap => GapGroupView(group: gap, sheet: sheet),
          final ChoiceGroup choice => ChoiceGroupView(group: choice, sheet: sheet),
          final MultiChoiceGroup multi => MultiChoiceGroupView(group: multi, sheet: sheet),
          final JudgementGroup judgement => JudgementGroupView(group: judgement, sheet: sheet),
          final MatchingGroup matching => MatchingGroupView(group: matching, sheet: sheet),
        },
      ],
    ),
  );
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading({required this.group});

  final QuestionGroup group;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final limit = switch (group) {
      // Papers usually repeat the limit in the instructions already.
      GapGroup(:final limit?)
          when !group.instructions.toUpperCase().contains(limit.toUpperCase()) =>
        limit,
      _ => null,
    };
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              group.from == group.to
                  ? context.l10n.questionNumber(group.from)
                  : context.l10n.questionsRange(group.from, group.to),
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(group.instructions, style: textTheme.bodyMedium),
          if (limit != null)
            Text(
              context.l10n.wordLimit(limit),
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          if (group.title case final String title?)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: AppSpacing.sm),
              child: Text(
                title,
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupImage extends StatelessWidget {
  const _GroupImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
    child: InteractiveViewer(
      maxScale: 4,
      child: ColoredBox(
        color: Colors.white,
        child: path.endsWith('.svg') ? SvgPicture.asset(path) : Image.asset(path),
      ),
    ),
  );
}
