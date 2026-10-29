/// Pure IELTS scoring rules. Every function here is total and side-effect free.
library;

/// Which raw-score table converts a Reading paper.
enum ReadingModule { academic, general }

/// Normalises a typed answer for comparison: case, outer punctuation and
/// repeated spaces are ignored, as an IELTS marker would.
String normaliseAnswer(String raw) {
  final lower = raw.toLowerCase().trim();
  final noOuterPunctuation = lower.replaceAll(RegExp(r'^[\s.,;:!?"]+|[\s.,;:!?"]+$'), '');
  return noOuterPunctuation.replaceAll(RegExp(r'\s+'), ' ');
}

/// True when [given] matches any of the [accepted] answers.
bool isAnswerCorrect(String given, List<String> accepted) {
  final candidate = normaliseAnswer(given);
  if (candidate.isEmpty) return false;
  return accepted.any((answer) => normaliseAnswer(answer) == candidate);
}

/// Counts the words in a piece of writing the way IELTS does: anything
/// separated by whitespace, with hyphenated words counted once.
int countWords(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 0;
  return trimmed.split(RegExp(r'\s+')).length;
}

const _listeningBands = <(int, double)>[
  (39, 9),
  (37, 8.5),
  (35, 8),
  (32, 7.5),
  (30, 7),
  (26, 6.5),
  (23, 6),
  (18, 5.5),
  (16, 5),
  (13, 4.5),
  (10, 4),
  (8, 3.5),
  (6, 3),
  (4, 2.5),
  (2, 2),
  (1, 1),
];

const _academicReadingBands = <(int, double)>[
  (39, 9),
  (37, 8.5),
  (35, 8),
  (33, 7.5),
  (30, 7),
  (27, 6.5),
  (23, 6),
  (19, 5.5),
  (15, 5),
  (13, 4.5),
  (10, 4),
  (8, 3.5),
  (6, 3),
  (4, 2.5),
  (2, 2),
  (1, 1),
];

const _generalReadingBands = <(int, double)>[
  (40, 9),
  (39, 8.5),
  (37, 8),
  (36, 7.5),
  (34, 7),
  (32, 6.5),
  (30, 6),
  (27, 5.5),
  (23, 5),
  (19, 4.5),
  (15, 4),
  (12, 3.5),
  (9, 3),
  (6, 2.5),
  (3, 2),
  (1, 1),
];

double _lookup(List<(int, double)> table, int rawScore) {
  for (final (minimum, band) in table) {
    if (rawScore >= minimum) return band;
  }
  return 0;
}

/// Band for a Listening raw score out of 40.
double listeningBand(int rawScore) => _lookup(_listeningBands, rawScore);

/// Band for a Reading raw score out of 40.
double readingBand(int rawScore, ReadingModule module) => switch (module) {
  ReadingModule.academic => _lookup(_academicReadingBands, rawScore),
  ReadingModule.general => _lookup(_generalReadingBands, rawScore),
};

/// Rounds to IELTS half bands: .25 rounds up to .5, .75 up to the next whole.
double roundToHalfBand(double value) => (value * 2 + 0.5).floorToDouble() / 2;

/// Writing band: Task 2 counts twice as much as Task 1. Criteria are averaged
/// per task first. Returns null when either task has no criteria.
double? writingBand(List<double> task1Criteria, List<double> task2Criteria) {
  if (task1Criteria.isEmpty || task2Criteria.isEmpty) return null;
  final task1 = _mean(task1Criteria);
  final task2 = _mean(task2Criteria);
  return _roundDownToHalf((task1 + 2 * task2) / 3);
}

/// Speaking band: mean of the four criteria, rounded down to a half band.
double? speakingBand(List<double> criteria) =>
    criteria.isEmpty ? null : _roundDownToHalf(_mean(criteria));

/// Overall band: mean of the four section bands rounded to the nearest half.
/// Returns null until all four sections are known.
double? overallBand(List<double?> sectionBands) {
  if (sectionBands.length != 4 || sectionBands.any((band) => band == null)) {
    return null;
  }
  return roundToHalfBand(_mean(sectionBands.whereType<double>().toList()));
}

double _mean(List<double> values) => values.reduce((sum, value) => sum + value) / values.length;

double _roundDownToHalf(double value) => (value * 2).floorToDouble() / 2;

/// Formats a band for display: 7 → "7.0", 6.5 → "6.5".
String formatBand(double band) => band.toStringAsFixed(1);
