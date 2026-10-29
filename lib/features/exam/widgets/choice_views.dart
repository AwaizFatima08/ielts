import 'package:flutter/material.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/content/models/question_group.dart';
import 'package:ielts_simulator/features/exam/widgets/question_group_view.dart';
import 'package:ielts_simulator/features/exam/widgets/review_note.dart';
import 'package:ielts_simulator/ui/theme.dart';

/// Boxed list of options ("List of Headings", word bank, features).
class OptionsBox extends StatelessWidget {
  const OptionsBox({required this.options, this.title, super.key});

  final List<ChoiceOption> options;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
      padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
      decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title case final String heading?)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
              child: Text(
                heading,
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          for (final option in options)
            if (option.text.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 2),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${option.key}   ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: option.text),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// Dropdown of option keys for one question (matching, word banks).
class OptionDropdown extends StatelessWidget {
  const OptionDropdown({required this.number, required this.keys, required this.sheet, super.key});

  final int number;
  final List<String> keys;
  final AnswerSheet sheet;

  @override
  Widget build(BuildContext context) {
    final current = sheet.answerFor(number);
    return Semantics(
      label: context.l10n.questionNumber(number),
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outline)),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.sm),
          child: DropdownButton<String>(
            value: keys.contains(current) ? current : null,
            hint: Text('$number'),
            underline: const SizedBox.shrink(),
            isDense: true,
            onChanged: sheet.reviewing ? null : (value) => sheet.onAnswer(number, value ?? ''),
            items: [
              for (final key in keys) DropdownMenuItem(value: key, child: Text(key)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionReview extends StatelessWidget {
  const _QuestionReview({required this.group, required this.sheet, required this.number});

  final QuestionGroup group;
  final AnswerSheet sheet;
  final int number;

  @override
  Widget build(BuildContext context) => sheet.reviewing
      ? ReviewNote(
          isCorrect: isQuestionCorrect(group, number, sheet.answers),
          given: sheet.answerFor(number),
          accepted: group.acceptedAnswers[number] ?? const [],
          explanation: group.explanations[number],
        )
      : const SizedBox.shrink();
}

class _NumberedText extends StatelessWidget {
  const _NumberedText({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: '$number   ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(text: text),
      ],
    ),
    style: Theme.of(context).textTheme.bodyLarge,
  );
}

/// Single-answer multiple choice.
class ChoiceGroupView extends StatelessWidget {
  const ChoiceGroupView({required this.group, required this.sheet, super.key});

  final ChoiceGroup group;
  final AnswerSheet sheet;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final question in group.questions)
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NumberedText(number: question.number, text: question.stem),
              RadioGroup<String>(
                groupValue: sheet.answerFor(question.number),
                onChanged: (value) {
                  if (!sheet.reviewing) sheet.onAnswer(question.number, value ?? '');
                },
                child: Column(
                  children: [
                    for (final option in question.options)
                      RadioListTile<String>(
                        value: option.key,
                        dense: true,
                        enabled: !sheet.reviewing,
                        title: Text('${option.key}   ${option.text}'),
                      ),
                  ],
                ),
              ),
              _QuestionReview(group: group, sheet: sheet, number: question.number),
            ],
          ),
        ),
    ],
  );
}

/// "Choose TWO letters": the chosen letters fill the group's numbers in order.
class MultiChoiceGroupView extends StatelessWidget {
  const MultiChoiceGroupView({required this.group, required this.sheet, super.key});

  final MultiChoiceGroup group;
  final AnswerSheet sheet;

  void _toggle(String key) {
    final chosen = group.chosenKeys(sheet.answers);
    final next = chosen.contains(key) ? (chosen..remove(key)) : [...chosen, key];
    if (next.length > group.picks) return;
    for (final (index, number) in group.numbers.indexed) {
      sheet.onAnswer(number, index < next.length ? next[index] : '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chosen = group.chosenKeys(sheet.answers);
    final full = chosen.length >= group.picks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(group.stem, style: Theme.of(context).textTheme.bodyLarge),
        for (final option in group.options)
          CheckboxListTile(
            value: chosen.contains(option.key),
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            enabled: !sheet.reviewing && (!full || chosen.contains(option.key)),
            onChanged: (_) => _toggle(option.key),
            title: Text('${option.key}   ${option.text}'),
          ),
        for (final number in group.numbers)
          _QuestionReview(group: group, sheet: sheet, number: number),
      ],
    );
  }
}

/// TRUE / FALSE / NOT GIVEN and YES / NO / NOT GIVEN.
class JudgementGroupView extends StatelessWidget {
  const JudgementGroupView({required this.group, required this.sheet, super.key});

  final JudgementGroup group;
  final AnswerSheet sheet;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final statement in group.statements)
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NumberedText(number: statement.number, text: statement.text),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final choice in group.choices)
                    ChoiceChip(
                      label: Text(choice),
                      selected: sheet.answerFor(statement.number) == choice,
                      onSelected: sheet.reviewing
                          ? null
                          : (selected) => sheet.onAnswer(statement.number, selected ? choice : ''),
                    ),
                ],
              ),
              _QuestionReview(group: group, sheet: sheet, number: statement.number),
            ],
          ),
        ),
    ],
  );
}

/// Headings, information, features, sentence endings, map labels.
class MatchingGroupView extends StatelessWidget {
  const MatchingGroupView({required this.group, required this.sheet, super.key});

  final MatchingGroup group;
  final AnswerSheet sheet;

  @override
  Widget build(BuildContext context) {
    final keys = [for (final option in group.options) option.key];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionsBox(options: group.options, title: group.optionsTitle),
        for (final item in group.items)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _NumberedText(number: item.number, text: item.text),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OptionDropdown(number: item.number, keys: keys, sheet: sheet),
                  ],
                ),
                _QuestionReview(group: group, sheet: sheet, number: item.number),
              ],
            ),
          ),
      ],
    );
  }
}
