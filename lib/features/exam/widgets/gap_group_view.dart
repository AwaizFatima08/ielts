import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ielts_simulator/content/models/question_group.dart';
import 'package:ielts_simulator/features/exam/widgets/answer_field.dart';
import 'package:ielts_simulator/features/exam/widgets/choice_views.dart';
import 'package:ielts_simulator/features/exam/widgets/question_group_view.dart';
import 'package:ielts_simulator/features/exam/widgets/review_note.dart';
import 'package:ielts_simulator/ui/theme.dart';

const _minColumnWidth = 200.0;

final _blank = RegExp(r'\{\{(\d+)\}\}');

/// Question numbers referenced in a line of a completion task.
List<int> blanksIn(String line) => [
  for (final match in _blank.allMatches(line)) int.parse(match.group(1)!),
];

/// Form, note, table, summary, sentence and flow-chart completion.
class GapGroupView extends StatelessWidget {
  const GapGroupView({required this.group, required this.sheet, super.key});

  final GapGroup group;
  final AnswerSheet sheet;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (group.wordBank.isNotEmpty) OptionsBox(options: group.wordBank),
      if (group.layout == GapLayout.table)
        _GapTable(group: group, sheet: sheet)
      else
        DecoratedBox(
          decoration: BoxDecoration(
            border: group.layout == GapLayout.form || group.layout == GapLayout.notes
                ? Border.all(color: Theme.of(context).dividerColor)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (index, line) in group.lines.indexed)
                  _GapLine(
                    line: line,
                    group: group,
                    sheet: sheet,
                    showArrow: group.layout == GapLayout.flowchart && index > 0,
                  ),
              ],
            ),
          ),
        ),
      if (sheet.reviewing && group.layout == GapLayout.table)
        for (final number in group.numbers) _GapReview(group: group, sheet: sheet, number: number),
    ],
  );
}

class _GapLine extends StatelessWidget {
  const _GapLine({
    required this.line,
    required this.group,
    required this.sheet,
    required this.showArrow,
  });

  final String line;
  final GapGroup group;
  final AnswerSheet sheet;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isHeading = line.startsWith('# ');
    final isBullet = line.startsWith('- ');
    final text = isHeading || isBullet ? line.substring(2) : line;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showArrow) const Center(child: Icon(Icons.arrow_downward, size: 18)),
          GapText(
            text: isBullet ? '•  $text' : text,
            group: group,
            sheet: sheet,
            style: isHeading
                ? textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
                : textTheme.bodyLarge,
          ),
          if (sheet.reviewing)
            for (final number in blanksIn(text))
              _GapReview(group: group, sheet: sheet, number: number),
        ],
      ),
    );
  }
}

/// Text with inline answer boxes in place of each `{{n}}` blank.
class GapText extends StatelessWidget {
  const GapText({
    required this.text,
    required this.group,
    required this.sheet,
    this.style,
    super.key,
  });

  final String text;
  final GapGroup group;
  final AnswerSheet sheet;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _blank.allMatches(text)) {
      spans.add(TextSpan(text: text.substring(cursor, match.start)));
      final number = int.parse(match.group(1)!);
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 2, vertical: 2),
            child: group.wordBank.isEmpty
                ? AnswerField(
                    number: number,
                    value: sheet.answerFor(number),
                    readOnly: sheet.reviewing,
                    onChanged: (value) => sheet.onAnswer(number, value),
                  )
                : OptionDropdown(
                    number: number,
                    keys: [for (final option in group.wordBank) option.key],
                    sheet: sheet,
                  ),
          ),
        ),
      );
      cursor = match.end;
    }
    spans.add(TextSpan(text: text.substring(cursor)));
    return Text.rich(TextSpan(children: spans), style: style);
  }
}

class _GapTable extends StatelessWidget {
  const _GapTable({required this.group, required this.sheet});

  final GapGroup group;
  final AnswerSheet sheet;

  @override
  Widget build(BuildContext context) {
    final border = TableBorder.all(color: Theme.of(context).dividerColor);
    final headerStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold);
    final columns = group.tableHeader.isNotEmpty ? group.tableHeader.length : 2;
    // Fill the available width, but never squeeze a column below what an
    // answer box needs; narrow screens scroll sideways instead.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: math.max(constraints.maxWidth, columns * _minColumnWidth),
          child: Table(
            border: border,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              if (group.tableHeader.isNotEmpty)
                TableRow(
                  children: [
                    for (final cell in group.tableHeader)
                      Padding(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
                        child: Text(cell, style: headerStyle),
                      ),
                  ],
                ),
              for (final row in group.tableRows)
                TableRow(
                  children: [
                    for (final cell in row)
                      Padding(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
                        child: GapText(text: cell, group: group, sheet: sheet),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GapReview extends StatelessWidget {
  const _GapReview({required this.group, required this.sheet, required this.number});

  final GapGroup group;
  final AnswerSheet sheet;
  final int number;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(start: AppSpacing.sm),
    child: ReviewNote(
      isCorrect: isQuestionCorrect(group, number, sheet.answers),
      given: sheet.answerFor(number),
      accepted: group.acceptedAnswers[number] ?? const [],
      explanation: group.explanations[number],
    ),
  );
}
