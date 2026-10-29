import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ielts_simulator/content/models/json_reader.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/core/scoring.dart' as scoring;

/// The four sections of the test, in exam order.
enum ExamSection { listening, reading, writing, speaking }

/// What the candidate chose to sit: the whole test or one section.
enum AttemptKind { full, listening, reading, writing, speaking }

extension AttemptKindSections on AttemptKind {
  /// Sections to sit, in order.
  List<ExamSection> get sections => switch (this) {
    AttemptKind.full => ExamSection.values,
    AttemptKind.listening => const [ExamSection.listening],
    AttemptKind.reading => const [ExamSection.reading],
    AttemptKind.writing => const [ExamSection.writing],
    AttemptKind.speaking => const [ExamSection.speaking],
  };
}

/// Objective result of a Listening or Reading paper.
@immutable
class ObjectiveResult {
  const ObjectiveResult({required this.answers, required this.rawScore, required this.band});

  factory ObjectiveResult.fromJson(Json json) => ObjectiveResult(
    answers: json.intKeyedStrings('answers'),
    rawScore: json.integer('raw'),
    band: (json['band']! as num).toDouble(),
  );

  final Map<int, String> answers;
  final int rawScore;
  final double band;

  Json toJson() => {
    'answers': {for (final entry in answers.entries) '${entry.key}': entry.value},
    'raw': rawScore,
    'band': band,
  };
}

/// One immutable test attempt, persisted as JSON.
@immutable
class Attempt {
  const Attempt({
    required this.id,
    required this.testId,
    required this.module,
    required this.kind,
    required this.startedAt,
    this.finishedSections = const [],
    this.listening,
    this.reading,
    this.essays = const ['', ''],
    this.recordings = const [],
    this.writingTask1Scores = const [],
    this.writingTask2Scores = const [],
    this.speakingScores = const [],
  });

  factory Attempt.fromJson(Json json) => Attempt(
    id: json.string('id'),
    testId: json.string('testId'),
    module: ExamModule.values.byName(json.string('module')),
    kind: AttemptKind.values.byName(json.string('kind')),
    startedAt: DateTime.parse(json.string('startedAt')),
    finishedSections: [
      for (final name in json.stringList('finished')) ExamSection.values.byName(name),
    ],
    listening: switch (json.optionalObject('listening')) {
      final Json result => ObjectiveResult.fromJson(result),
      null => null,
    },
    reading: switch (json.optionalObject('reading')) {
      final Json result => ObjectiveResult.fromJson(result),
      null => null,
    },
    essays: json.stringList('essays'),
    recordings: [for (final item in json.objectList('recordings')) RecordedAnswer.fromJson(item)],
    writingTask1Scores: _doubles(json, 'w1'),
    writingTask2Scores: _doubles(json, 'w2'),
    speakingScores: _doubles(json, 'sp'),
  );

  final String id;
  final String testId;
  final ExamModule module;
  final AttemptKind kind;
  final DateTime startedAt;
  final List<ExamSection> finishedSections;
  final ObjectiveResult? listening;
  final ObjectiveResult? reading;

  /// Task 1 and Task 2 text.
  final List<String> essays;
  final List<RecordedAnswer> recordings;

  /// Self-assessed criterion bands (empty until the candidate rates them).
  final List<double> writingTask1Scores;
  final List<double> writingTask2Scores;
  final List<double> speakingScores;

  double? get writingBand => scoring.writingBand(writingTask1Scores, writingTask2Scores);

  double? get speakingBand => scoring.speakingBand(speakingScores);

  double? get overall =>
      scoring.overallBand([listening?.band, reading?.band, writingBand, speakingBand]);

  bool get isComplete => kind.sections.every(finishedSections.contains);

  /// The next section to sit, or null when every section is done.
  ExamSection? get nextSection =>
      kind.sections.where((section) => !finishedSections.contains(section)).firstOrNull;

  Attempt copyWith({
    List<ExamSection>? finishedSections,
    ObjectiveResult? listening,
    ObjectiveResult? reading,
    List<String>? essays,
    List<RecordedAnswer>? recordings,
    List<double>? writingTask1Scores,
    List<double>? writingTask2Scores,
    List<double>? speakingScores,
  }) => Attempt(
    id: id,
    testId: testId,
    module: module,
    kind: kind,
    startedAt: startedAt,
    finishedSections: finishedSections ?? this.finishedSections,
    listening: listening ?? this.listening,
    reading: reading ?? this.reading,
    essays: essays ?? this.essays,
    recordings: recordings ?? this.recordings,
    writingTask1Scores: writingTask1Scores ?? this.writingTask1Scores,
    writingTask2Scores: writingTask2Scores ?? this.writingTask2Scores,
    speakingScores: speakingScores ?? this.speakingScores,
  );

  Json toJson() => {
    'id': id,
    'testId': testId,
    'module': module.name,
    'kind': kind.name,
    'startedAt': startedAt.toIso8601String(),
    'finished': [for (final section in finishedSections) section.name],
    'listening': listening?.toJson(),
    'reading': reading?.toJson(),
    'essays': essays,
    'recordings': [for (final recording in recordings) recording.toJson()],
    'w1': writingTask1Scores,
    'w2': writingTask2Scores,
    'sp': speakingScores,
  };

  @override
  bool operator ==(Object other) =>
      other is Attempt && jsonEncode(other.toJson()) == jsonEncode(toJson());

  @override
  int get hashCode => Object.hash(id, finishedSections.length, overall);
}

List<double> _doubles(Json json, String key) => [
  for (final value in json.list(key)) (value! as num).toDouble(),
];

/// A spoken answer saved to disk, with the question it answers.
@immutable
class RecordedAnswer {
  const RecordedAnswer({required this.part, required this.question, required this.filePath});

  factory RecordedAnswer.fromJson(Json json) => RecordedAnswer(
    part: json.integer('part'),
    question: json.string('question'),
    filePath: json.string('path'),
  );

  final int part;
  final String question;
  final String filePath;

  Json toJson() => {'part': part, 'question': question, 'path': filePath};
}
