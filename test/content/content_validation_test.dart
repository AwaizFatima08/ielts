import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ielts_simulator/content/models/json_reader.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/content/models/practice.dart';
import 'package:ielts_simulator/content/models/question_group.dart';

/// Checks every bundled paper the way an editor would before release:
/// numbering, answer keys, word limits and that gap answers really occur
/// in the recording or text.
Json _read(String path) => jsonDecode(File(path).readAsStringSync()) as Json;

final _blank = RegExp(r'\{\{(\d+)\}\}');

String _flatten(String text) => text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9£$%.:,\- ]'), ' ');

/// (max words, number allowed) from a limit such as
/// "NO MORE THAN TWO WORDS AND/OR A NUMBER".
(int, bool) _parseLimit(String limit) {
  final upper = limit.toUpperCase();
  final words = upper.contains('THREE')
      ? 3
      : upper.contains('TWO')
      ? 2
      : upper.contains('ONE WORD')
      ? 1
      : 0;
  return (words, upper.contains('NUMBER'));
}

List<String> _problemsInGroup(QuestionGroup group, String sourceText) {
  final problems = <String>[];
  final accepted = group.acceptedAnswers;
  for (final number in group.numbers) {
    if ((accepted[number] ?? const []).isEmpty) problems.add('Q$number has no answer');
    if (!group.explanations.containsKey(number)) problems.add('Q$number has no explanation');
  }
  switch (group) {
    case GapGroup():
      final text = [
        ...group.lines,
        for (final row in group.tableRows) ...row,
      ].join('\n');
      final blanks = [for (final match in _blank.allMatches(text)) int.parse(match.group(1)!)];
      if (blanks.toSet().length != blanks.length) problems.add('repeated blank in ${group.from}');
      if (blanks.toSet().difference(group.numbers.toSet()).isNotEmpty ||
          group.numbers.toSet().difference(blanks.toSet()).isNotEmpty) {
        problems.add('blanks $blanks do not match ${group.from}-${group.to}');
      }
      final keys = {for (final option in group.wordBank) option.key};
      final (maxWords, allowNumber) = _parseLimit(group.limit ?? '');
      for (final entry in group.answers.entries) {
        for (final answer in entry.value) {
          if (keys.isNotEmpty) {
            if (!keys.contains(answer)) {
              problems.add('Q${entry.key} key "$answer" not in word bank');
            }
            continue;
          }
          final tokens = answer.trim().split(RegExp(r'\s+'));
          final numbers = tokens.where((token) => RegExp(r'\d').hasMatch(token)).length;
          final words = tokens.length - numbers;
          final allowedWords = maxWords == 0 ? 99 : maxWords;
          if (words > allowedWords ||
              (numbers > 0 && !allowNumber && words + numbers > allowedWords)) {
            problems.add('Q${entry.key} "$answer" breaks limit "${group.limit}"');
          }
        }
        // Numbers are often spoken as words ("nine thirty" → 9:30), so only
        // word answers must appear verbatim in the source.
        final spokenNumber = entry.value.every((answer) => RegExp(r'\d').hasMatch(answer));
        if (keys.isEmpty &&
            !spokenNumber &&
            !entry.value.any((answer) => _flatten(sourceText).contains(_flatten(answer).trim()))) {
          problems.add('Q${entry.key} none of ${entry.value} occurs in the source');
        }
      }
    case ChoiceGroup():
      for (final question in group.questions) {
        if (!question.options.any((option) => option.key == question.answer)) {
          problems.add('Q${question.number} answer ${question.answer} not an option');
        }
      }
    case MultiChoiceGroup():
      if (group.correctKeys.length != group.picks) {
        problems.add('Q${group.from} wrong answer count');
      }
      for (final key in group.correctKeys) {
        if (!group.options.any((option) => option.key == key)) {
          problems.add('Q${group.from} bad key $key');
        }
      }
    case JudgementGroup():
      for (final statement in group.statements) {
        if (!group.choices.contains(statement.answer)) {
          problems.add('Q${statement.number} answer ${statement.answer} invalid');
        }
      }
    case MatchingGroup():
      final keys = {for (final option in group.options) option.key};
      for (final item in group.items) {
        if (!keys.contains(item.answer)) {
          problems.add('Q${item.number} answer ${item.answer} not an option');
        }
      }
      final used = [for (final item in group.items) item.answer];
      if (!group.allowsReuse && used.toSet().length != used.length) {
        problems.add('Q${group.from} reuses options but reuse is false');
      }
  }
  return problems;
}

void _expectNumbered(List<QuestionGroup> groups, int total) {
  final numbers = [for (final group in groups) ...group.numbers];
  expect(numbers, List.generate(total, (index) => index + 1), reason: 'question numbering');
}

String _scriptText(List<ScriptItem> script) =>
    script.whereType<ScriptLine>().map((line) => line.text).join('\n');

void main() {
  final testDirs = Directory('assets/content/tests').listSync().whereType<Directory>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final directory in testDirs) {
    final id = directory.uri.pathSegments.where((segment) => segment.isNotEmpty).last;

    group('test $id', () {
      test('listening', () {
        final paper = ListeningPaper.fromJson(_read('${directory.path}/listening.json'));
        expect(paper.parts, hasLength(4));
        _expectNumbered(paper.groups, 40);
        final ids = <String>{};
        for (final part in paper.parts) {
          for (final line in part.script.whereType<ScriptLine>()) {
            expect(ids.add(line.id), isTrue, reason: 'duplicate clip ${line.id}');
            expect(paper.speakers, contains(line.speaker), reason: 'unknown speaker in ${line.id}');
          }
          final problems = [
            for (final group in part.groups) ..._problemsInGroup(group, _scriptText(part.script)),
          ];
          expect(problems, isEmpty, reason: 'part ${part.number}');
          for (final group in part.groups) {
            if (group.imagePath case final String image?) {
              expect(File(image).existsSync(), isTrue, reason: image);
            }
          }
        }
      });

      for (final module in ExamModule.values) {
        test('reading ${module.name}', () {
          final paper = ReadingPaper.fromJson(
            _read('${directory.path}/reading_${module.name}.json'),
          );
          _expectNumbered(paper.groups, 40);
          for (final passage in paper.passages) {
            final text = passage.paragraphs.map((paragraph) => paragraph.text).join('\n');
            final problems = [for (final group in passage.groups) ..._problemsInGroup(group, text)];
            expect(problems, isEmpty, reason: 'passage ${passage.number}');
          }
        });

        test('writing ${module.name}', () {
          final paper = WritingPaper.fromJson(
            _read('${directory.path}/writing_${module.name}.json'),
          );
          expect(paper.tasks.map((task) => task.number), [1, 2]);
          for (final task in paper.tasks) {
            expect(
              task.modelAnswer.split(RegExp(r'\s+')).length,
              greaterThanOrEqualTo(task.minWords),
            );
          }
          if (module == ExamModule.academic) {
            expect(paper.tasks.first.chart ?? paper.tasks.first.imagePath, isNotNull);
          }
        });
      }

      test('speaking', () {
        final paper = SpeakingPaper.fromJson(_read('${directory.path}/speaking.json'));
        expect(paper.part1, isNotEmpty);
        expect(paper.cueCard.bullets, isNotEmpty);
        expect(paper.part3, isNotEmpty);
      });
    });
  }

  group('practice', () {
    final index = _read('assets/content/practice/index.json');
    final units = index.objectList('units').map(PracticeUnitSummary.fromJson).toList();

    for (final summary in units) {
      test(summary.id, () {
        final unit = PracticeUnit.fromJson(_read('assets/content/practice/${summary.id}.json'));
        expect(unit.guide, isNotEmpty);
        if (unit.drill case final drill?) {
          final source =
              drill.passage?.paragraphs.map((paragraph) => paragraph.text).join('\n') ??
              _scriptText(drill.script);
          final total = drill.groups.fold(0, (sum, group) => sum + group.numbers.length);
          _expectNumbered(drill.groups, total);
          expect([for (final group in drill.groups) ..._problemsInGroup(group, source)], isEmpty);
        }
      });
    }

    test('descriptors cover every criterion with bands 4-9', () {
      final descriptors = Descriptors.fromJson(_read('assets/content/descriptors.json'));
      for (final criterion in [
        ...descriptors.writing1,
        ...descriptors.writing2,
        ...descriptors.speaking,
      ]) {
        expect(criterion.bands.keys.toSet(), {4, 5, 6, 7, 8, 9}, reason: criterion.id);
      }
      expect(descriptors.writing1, hasLength(4));
      expect(descriptors.writing2, hasLength(4));
      expect(descriptors.speaking, hasLength(4));
    });
  });
}
