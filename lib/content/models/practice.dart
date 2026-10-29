import 'package:ielts_simulator/content/models/json_reader.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/content/models/question_group.dart';

/// Skill a practice unit belongs to; drives grouping on the practice screen.
enum PracticeSkill { testOverview, listening, reading, writing, speaking, vocabulary }

PracticeSkill _skillFrom(String raw) => switch (raw) {
  'test-overview' => PracticeSkill.testOverview,
  'listening' => PracticeSkill.listening,
  'reading' => PracticeSkill.reading,
  'writing' => PracticeSkill.writing,
  'speaking' => PracticeSkill.speaking,
  'vocabulary' => PracticeSkill.vocabulary,
  _ => throw FormatException('Unknown practice skill "$raw"'),
};

class PracticeUnitSummary {
  const PracticeUnitSummary({
    required this.id,
    required this.skill,
    required this.title,
    required this.summary,
  });

  factory PracticeUnitSummary.fromJson(Json json) => PracticeUnitSummary(
    id: json.string('id'),
    skill: _skillFrom(json.string('skill')),
    title: json.string('title'),
    summary: json.optionalString('summary') ?? '',
  );

  final String id;
  final PracticeSkill skill;
  final String title;
  final String summary;
}

/// One block of a study guide.
sealed class GuideBlock {
  const GuideBlock();

  factory GuideBlock.fromJson(Json json) {
    if (json['h'] case final String text) return GuideHeading(text);
    if (json['p'] case final String text) return GuideParagraph(text);
    if (json['tip'] case final String text) return GuideTip(text);
    if (json['example'] case final String text) return GuideExample(text);
    return GuideBullets(json.stringList('bullets'));
  }
}

final class GuideHeading extends GuideBlock {
  const GuideHeading(this.text);
  final String text;
}

final class GuideParagraph extends GuideBlock {
  const GuideParagraph(this.text);
  final String text;
}

final class GuideTip extends GuideBlock {
  const GuideTip(this.text);
  final String text;
}

final class GuideExample extends GuideBlock {
  const GuideExample(this.text);
  final String text;
}

final class GuideBullets extends GuideBlock {
  const GuideBullets(this.items);
  final List<String> items;
}

class VocabItem {
  const VocabItem({required this.word, required this.meaning, required this.example});

  factory VocabItem.fromJson(Json json) => VocabItem(
    word: json.string('word'),
    meaning: json.optionalString('meaning') ?? '',
    example: json.optionalString('example') ?? '',
  );

  final String word;
  final String meaning;
  final String example;
}

/// Short exercise attached to a unit: a reading text or listening script.
class PracticeDrill {
  const PracticeDrill({required this.groups, this.passage, this.script = const []});

  factory PracticeDrill.fromJson(Json json) => PracticeDrill(
    passage: switch (json.optionalObject('passage')) {
      final Json passage => ReadingPassage.fromJson({
        'number': 1,
        'groups': const <Object?>[],
        ...passage,
      }),
      null => null,
    },
    script: json.objectList('script').map(ScriptItem.fromJson).toList(),
    groups: json.objectList('groups').map(QuestionGroup.fromJson).toList(),
  );

  final ReadingPassage? passage;
  final List<ScriptItem> script;
  final List<QuestionGroup> groups;
}

class PracticeUnit {
  const PracticeUnit({
    required this.id,
    required this.skill,
    required this.title,
    required this.guide,
    required this.vocab,
    required this.models,
    this.drill,
  });

  factory PracticeUnit.fromJson(Json json) => PracticeUnit(
    id: json.string('id'),
    skill: _skillFrom(json.string('skill')),
    title: json.string('title'),
    guide: json.objectList('guide').map(GuideBlock.fromJson).toList(),
    drill: switch (json.optionalObject('drill')) {
      final Json drill => PracticeDrill.fromJson(drill),
      null => null,
    },
    vocab: json.objectList('vocab').map(VocabItem.fromJson).toList(),
    models: json.objectList('models').map(ModelAnswer.fromJson).toList(),
  );

  final String id;
  final PracticeSkill skill;
  final String title;
  final List<GuideBlock> guide;
  final PracticeDrill? drill;
  final List<VocabItem> vocab;
  final List<ModelAnswer> models;
}

/// A self-check criterion with a short description per band (4–9).
class Criterion {
  const Criterion({required this.id, required this.name, required this.bands});

  factory Criterion.fromJson(Json json) => Criterion(
    id: json.string('id'),
    name: json.string('name'),
    bands: {
      for (final entry in json.object('bands').entries)
        int.parse(entry.key): entry.value! as String,
    },
  );

  final String id;
  final String name;
  final Map<int, String> bands;
}

class Descriptors {
  const Descriptors({required this.writing1, required this.writing2, required this.speaking});

  factory Descriptors.fromJson(Json json) => Descriptors(
    writing1: json.objectList('writing1').map(Criterion.fromJson).toList(),
    writing2: json.objectList('writing2').map(Criterion.fromJson).toList(),
    speaking: json.objectList('speaking').map(Criterion.fromJson).toList(),
  );

  final List<Criterion> writing1;
  final List<Criterion> writing2;
  final List<Criterion> speaking;
}
