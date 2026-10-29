import 'package:ielts_simulator/content/models/json_reader.dart';
import 'package:ielts_simulator/core/scoring.dart';

/// A lettered/numbered option in a multiple-choice or matching group.
class ChoiceOption {
  const ChoiceOption({required this.key, required this.text});

  factory ChoiceOption.fromJson(Json json) =>
      ChoiceOption(key: json.string('key'), text: json.string('text'));

  final String key;
  final String text;
}

/// A set of questions sharing one instruction, as printed on the paper.
sealed class QuestionGroup {
  const QuestionGroup({
    required this.from,
    required this.to,
    required this.instructions,
    required this.explanations,
    this.title,
    this.imagePath,
  });

  factory QuestionGroup.fromJson(Json json) {
    final type = json.string('type');
    return switch (type) {
      'gap' => GapGroup.fromJson(json),
      'mcq' => ChoiceGroup.fromJson(json),
      'multi' => MultiChoiceGroup.fromJson(json),
      'tfng' => JudgementGroup.fromJson(json),
      'matching' => MatchingGroup.fromJson(json),
      _ => throw FormatException('Unknown question group type "$type"'),
    };
  }

  final int from;
  final int to;
  final String instructions;
  final String? title;
  final String? imagePath;

  /// Explanation per question number, shown on the review screen.
  final Map<int, String> explanations;

  /// Question numbers covered by this group, in order.
  List<int> get numbers => [for (var n = from; n <= to; n++) n];

  /// Accepted answers per question number, used for marking and review.
  Map<int, List<String>> get acceptedAnswers;

  /// Marks for [answers] (question number → given answer) in this group.
  int score(Map<int, String> answers);
}

/// Common header fields every group carries.
({int from, int to, String instructions, String? title, String? image, Map<int, String> explain})
_header(Json json) => (
  from: json.integer('from'),
  to: json.integer('to'),
  instructions: json.string('instructions'),
  title: json.optionalString('title'),
  image: json.optionalString('image'),
  explain: json.intKeyedStrings('explain'),
);

/// Layout of a [GapGroup] on the page.
enum GapLayout { form, notes, sentences, summary, flowchart, table, short }

/// Completion tasks: forms, notes, tables, summaries, flow-charts, short answers.
final class GapGroup extends QuestionGroup {
  const GapGroup({
    required super.from,
    required super.to,
    required super.instructions,
    required super.explanations,
    required this.layout,
    required this.lines,
    required this.tableHeader,
    required this.tableRows,
    required this.answers,
    required this.wordBank,
    this.limit,
    super.title,
    super.imagePath,
  });

  factory GapGroup.fromJson(Json json) {
    final header = _header(json);
    final table = json.optionalObject('table');
    return GapGroup(
      from: header.from,
      to: header.to,
      instructions: header.instructions,
      explanations: header.explain,
      title: header.title,
      imagePath: header.image,
      limit: json.optionalString('limit'),
      layout: GapLayout.values.byName(json.string('layout')),
      lines: json.stringList('lines'),
      tableHeader: table?.stringList('header') ?? const [],
      tableRows: [
        for (final row in table?.list('rows') ?? const <Object?>[])
          [for (final cell in row! as List<Object?>) cell! as String],
      ],
      answers: json.intKeyedStringLists('answers'),
      wordBank: json.objectList('options').map(ChoiceOption.fromJson).toList(),
    );
  }

  final GapLayout layout;
  final String? limit;
  final List<String> lines;
  final List<String> tableHeader;
  final List<List<String>> tableRows;
  final Map<int, List<String>> answers;

  /// Optional list of choices (summary with a word bank); answers are keys.
  final List<ChoiceOption> wordBank;

  @override
  Map<int, List<String>> get acceptedAnswers => answers;

  @override
  int score(Map<int, String> answers) => _countCorrect(this, answers);
}

/// Single-answer multiple choice.
final class ChoiceGroup extends QuestionGroup {
  const ChoiceGroup({
    required super.from,
    required super.to,
    required super.instructions,
    required super.explanations,
    required this.questions,
    super.title,
    super.imagePath,
  });

  factory ChoiceGroup.fromJson(Json json) {
    final header = _header(json);
    return ChoiceGroup(
      from: header.from,
      to: header.to,
      instructions: header.instructions,
      explanations: header.explain,
      title: header.title,
      imagePath: header.image,
      questions: json.objectList('questions').map(ChoiceQuestion.fromJson).toList(),
    );
  }

  final List<ChoiceQuestion> questions;

  @override
  Map<int, List<String>> get acceptedAnswers => {
    for (final question in questions) question.number: [question.answer],
  };

  @override
  int score(Map<int, String> answers) => _countCorrect(this, answers);
}

class ChoiceQuestion {
  const ChoiceQuestion({
    required this.number,
    required this.stem,
    required this.options,
    required this.answer,
  });

  factory ChoiceQuestion.fromJson(Json json) => ChoiceQuestion(
    number: json.integer('n'),
    stem: json.string('stem'),
    options: json.objectList('options').map(ChoiceOption.fromJson).toList(),
    answer: json.string('answer'),
  );

  final int number;
  final String stem;
  final List<ChoiceOption> options;
  final String answer;
}

/// "Choose TWO letters": each correct letter scores one mark, in any order.
/// Answers are stored per question number, one letter each.
final class MultiChoiceGroup extends QuestionGroup {
  const MultiChoiceGroup({
    required super.from,
    required super.to,
    required super.instructions,
    required super.explanations,
    required this.stem,
    required this.options,
    required this.correctKeys,
    super.title,
    super.imagePath,
  });

  factory MultiChoiceGroup.fromJson(Json json) {
    final header = _header(json);
    return MultiChoiceGroup(
      from: header.from,
      to: header.to,
      instructions: header.instructions,
      explanations: header.explain,
      title: header.title,
      imagePath: header.image,
      stem: json.string('stem'),
      options: json.objectList('options').map(ChoiceOption.fromJson).toList(),
      correctKeys: json.stringList('answers'),
    );
  }

  final String stem;
  final List<ChoiceOption> options;
  final List<String> correctKeys;

  /// How many letters the candidate must choose.
  int get picks => to - from + 1;

  /// The letters currently chosen, read from the per-number answers.
  List<String> chosenKeys(Map<int, String> answers) => [
    for (final number in numbers)
      if ((answers[number] ?? '').isNotEmpty) answers[number]!,
  ];

  @override
  Map<int, List<String>> get acceptedAnswers => {
    for (final (index, number) in numbers.indexed) number: [correctKeys[index]],
  };

  @override
  int score(Map<int, String> answers) {
    final chosen = chosenKeys(answers).toSet();
    return chosen.intersection(correctKeys.toSet()).length;
  }

  /// Per-question correctness for review: the i-th chosen letter is marked
  /// right when it is any correct letter not already credited.
  Map<int, bool> correctness(Map<int, String> answers) {
    final remaining = correctKeys.toSet();
    return {
      for (final number in numbers) number: remaining.remove(answers[number] ?? ''),
    };
  }
}

/// TRUE/FALSE/NOT GIVEN or YES/NO/NOT GIVEN.
enum JudgementVariant { tfng, ynng }

final class JudgementGroup extends QuestionGroup {
  const JudgementGroup({
    required super.from,
    required super.to,
    required super.instructions,
    required super.explanations,
    required this.variant,
    required this.statements,
    super.title,
    super.imagePath,
  });

  factory JudgementGroup.fromJson(Json json) {
    final header = _header(json);
    return JudgementGroup(
      from: header.from,
      to: header.to,
      instructions: header.instructions,
      explanations: header.explain,
      title: header.title,
      imagePath: header.image,
      variant: JudgementVariant.values.byName(json.string('variant')),
      statements: json.objectList('questions').map(Statement.fromJson).toList(),
    );
  }

  final JudgementVariant variant;
  final List<Statement> statements;

  List<String> get choices => switch (variant) {
    JudgementVariant.tfng => const ['TRUE', 'FALSE', 'NOT GIVEN'],
    JudgementVariant.ynng => const ['YES', 'NO', 'NOT GIVEN'],
  };

  @override
  Map<int, List<String>> get acceptedAnswers => {
    for (final statement in statements) statement.number: [statement.answer],
  };

  @override
  int score(Map<int, String> answers) => _countCorrect(this, answers);
}

/// A numbered statement or item with a single expected answer key.
class Statement {
  const Statement({required this.number, required this.text, required this.answer});

  factory Statement.fromJson(Json json) => Statement(
    number: json.integer('n'),
    text: json.string('text'),
    answer: json.string('answer'),
  );

  final int number;
  final String text;
  final String answer;
}

/// Matching headings, information, features, sentence endings, map labels.
final class MatchingGroup extends QuestionGroup {
  const MatchingGroup({
    required super.from,
    required super.to,
    required super.instructions,
    required super.explanations,
    required this.options,
    required this.items,
    required this.allowsReuse,
    this.optionsTitle,
    super.title,
    super.imagePath,
  });

  factory MatchingGroup.fromJson(Json json) {
    final header = _header(json);
    return MatchingGroup(
      from: header.from,
      to: header.to,
      instructions: header.instructions,
      explanations: header.explain,
      title: header.title,
      imagePath: header.image,
      optionsTitle: json.optionalString('optionsTitle'),
      allowsReuse: json.optionalBool('reuse') ?? false,
      options: json.objectList('options').map(ChoiceOption.fromJson).toList(),
      items: json.objectList('items').map(Statement.fromJson).toList(),
    );
  }

  final String? optionsTitle;
  final bool allowsReuse;
  final List<ChoiceOption> options;
  final List<Statement> items;

  @override
  Map<int, List<String>> get acceptedAnswers => {
    for (final item in items) item.number: [item.answer],
  };

  @override
  int score(Map<int, String> answers) => _countCorrect(this, answers);
}

int _countCorrect(QuestionGroup group, Map<int, String> answers) => group.acceptedAnswers.entries
    .where((entry) => isGroupAnswerCorrect(answers[entry.key] ?? '', entry.value))
    .length;

/// Case- and punctuation-insensitive comparison used by every group.
bool isGroupAnswerCorrect(String given, List<String> accepted) => isAnswerCorrect(given, accepted);

/// Total marks across [groups].
int scoreGroups(List<QuestionGroup> groups, Map<int, String> answers) =>
    groups.fold(0, (total, group) => total + group.score(answers));

/// Whether question [number] in [group] was answered correctly.
bool isQuestionCorrect(QuestionGroup group, int number, Map<int, String> answers) =>
    switch (group) {
      MultiChoiceGroup() => group.correctness(answers)[number] ?? false,
      _ => isGroupAnswerCorrect(answers[number] ?? '', group.acceptedAnswers[number] ?? const []),
    };
