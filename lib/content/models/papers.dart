import 'package:ielts_simulator/content/models/json_reader.dart';
import 'package:ielts_simulator/content/models/question_group.dart';

/// Academic or General Training. Listening and Speaking are shared.
enum ExamModule { academic, general }

/// A test listed in `tests/index.json`.
class TestSummary {
  const TestSummary({required this.id, required this.title, required this.ready});

  factory TestSummary.fromJson(Json json) => TestSummary(
    id: json.string('id'),
    title: json.string('title'),
    ready: json.optionalBool('ready') ?? true,
  );

  final String id;
  final String title;

  /// False for tests announced in the index but not yet written.
  final bool ready;
}

/// One line of a listening recording: a voice clip or a timed silence.
sealed class ScriptItem {
  const ScriptItem();

  factory ScriptItem.fromJson(Json json) => json.containsKey('pause')
      ? ScriptPause(seconds: json.integer('pause'), note: json.optionalString('note'))
      : ScriptLine(
          id: json.string('id'),
          speaker: json.string('speaker'),
          text: json.string('text'),
        );
}

final class ScriptLine extends ScriptItem {
  const ScriptLine({required this.id, required this.speaker, required this.text});

  final String id;
  final String speaker;
  final String text;
}

final class ScriptPause extends ScriptItem {
  const ScriptPause({required this.seconds, this.note});

  final int seconds;
  final String? note;
}

class Speaker {
  const Speaker({required this.voice, required this.label});

  factory Speaker.fromJson(Json json) =>
      Speaker(voice: json.string('voice'), label: json.string('label'));

  final String voice;
  final String label;
}

class ListeningPart {
  const ListeningPart({
    required this.number,
    required this.context,
    required this.script,
    required this.groups,
  });

  factory ListeningPart.fromJson(Json json) => ListeningPart(
    number: json.integer('number'),
    context: json.optionalString('context') ?? '',
    script: json.objectList('script').map(ScriptItem.fromJson).toList(),
    groups: json.objectList('groups').map(QuestionGroup.fromJson).toList(),
  );

  final int number;
  final String context;
  final List<ScriptItem> script;
  final List<QuestionGroup> groups;
}

class ListeningPaper {
  const ListeningPaper({required this.testId, required this.speakers, required this.parts});

  factory ListeningPaper.fromJson(Json json) => ListeningPaper(
    testId: json.string('id'),
    speakers: {
      for (final entry in json.object('speakers').entries)
        entry.key: Speaker.fromJson(entry.value! as Json),
    },
    parts: json.objectList('parts').map(ListeningPart.fromJson).toList(),
  );

  final String testId;
  final Map<String, Speaker> speakers;
  final List<ListeningPart> parts;

  List<QuestionGroup> get groups => [for (final part in parts) ...part.groups];
}

class Paragraph {
  const Paragraph({required this.label, required this.text});

  factory Paragraph.fromJson(Json json) =>
      Paragraph(label: json.optionalString('label') ?? '', text: json.string('text'));

  final String label;
  final String text;
}

class ReadingPassage {
  const ReadingPassage({
    required this.number,
    required this.part,
    required this.title,
    required this.paragraphs,
    required this.groups,
    this.subtitle,
    this.imagePath,
  });

  factory ReadingPassage.fromJson(Json json) => ReadingPassage(
    number: json.integer('number'),
    part: json.optionalInteger('part') ?? json.integer('number'),
    title: json.optionalString('title') ?? '',
    subtitle: json.optionalString('subtitle'),
    imagePath: json.optionalString('image'),
    paragraphs: json.objectList('paragraphs').map(Paragraph.fromJson).toList(),
    groups: json.objectList('groups').map(QuestionGroup.fromJson).toList(),
  );

  final int number;
  final int part;
  final String title;
  final String? subtitle;
  final String? imagePath;
  final List<Paragraph> paragraphs;
  final List<QuestionGroup> groups;
}

class ReadingPaper {
  const ReadingPaper({required this.testId, required this.module, required this.passages});

  factory ReadingPaper.fromJson(Json json) => ReadingPaper(
    testId: json.string('id'),
    module: json.string('module') == 'general' ? ExamModule.general : ExamModule.academic,
    passages: json.objectList('passages').map(ReadingPassage.fromJson).toList(),
  );

  final String testId;
  final ExamModule module;
  final List<ReadingPassage> passages;

  List<QuestionGroup> get groups => [for (final passage in passages) ...passage.groups];
}

/// Data for an Academic Task 1 chart, drawn by the app.
enum ChartKind { bar, line, pie, table }

class ChartSeries {
  const ChartSeries({required this.name, required this.values});

  factory ChartSeries.fromJson(Json json) => ChartSeries(
    name: json.string('name'),
    values: [for (final value in json.list('values')) (value! as num).toDouble()],
  );

  final String name;
  final List<double> values;
}

class ChartSpec {
  const ChartSpec({
    required this.kind,
    required this.title,
    required this.xLabels,
    required this.series,
    this.yLabel,
    this.unit,
  });

  factory ChartSpec.fromJson(Json json) => ChartSpec(
    kind: ChartKind.values.byName(json.string('kind')),
    title: json.optionalString('title') ?? '',
    xLabels: json.stringList('xLabels'),
    yLabel: json.optionalString('yLabel'),
    unit: json.optionalString('unit'),
    series: json.objectList('series').map(ChartSeries.fromJson).toList(),
  );

  final ChartKind kind;
  final String title;
  final List<String> xLabels;
  final String? yLabel;
  final String? unit;
  final List<ChartSeries> series;
}

class WritingTask {
  const WritingTask({
    required this.number,
    required this.minutes,
    required this.minWords,
    required this.prompt,
    required this.instructions,
    required this.bullets,
    required this.modelAnswer,
    required this.modelBand,
    required this.tips,
    this.chart,
    this.imagePath,
  });

  factory WritingTask.fromJson(Json json) => WritingTask(
    number: json.integer('number'),
    minutes: json.integer('minutes'),
    minWords: json.integer('minWords'),
    prompt: json.string('prompt'),
    instructions: json.optionalString('instructions') ?? '',
    bullets: json.stringList('bullets'),
    chart: switch (json.optionalObject('chart')) {
      final Json chart => ChartSpec.fromJson(chart),
      null => null,
    },
    imagePath: json.optionalString('image'),
    modelAnswer: json.optionalString('modelAnswer') ?? '',
    modelBand: json.optionalInteger('modelBand') ?? 8,
    tips: json.stringList('tips'),
  );

  final int number;
  final int minutes;
  final int minWords;
  final String prompt;
  final String instructions;
  final List<String> bullets;
  final ChartSpec? chart;
  final String? imagePath;
  final String modelAnswer;
  final int modelBand;
  final List<String> tips;
}

class WritingPaper {
  const WritingPaper({required this.testId, required this.module, required this.tasks});

  factory WritingPaper.fromJson(Json json) => WritingPaper(
    testId: json.string('id'),
    module: json.string('module') == 'general' ? ExamModule.general : ExamModule.academic,
    tasks: json.objectList('tasks').map(WritingTask.fromJson).toList(),
  );

  final String testId;
  final ExamModule module;
  final List<WritingTask> tasks;
}

class SpeakingTopic {
  const SpeakingTopic({required this.topic, required this.questions});

  factory SpeakingTopic.fromJson(Json json) =>
      SpeakingTopic(topic: json.string('topic'), questions: json.stringList('questions'));

  final String topic;
  final List<String> questions;
}

class CueCard {
  const CueCard({
    required this.prompt,
    required this.bullets,
    required this.closing,
    required this.roundOff,
  });

  factory CueCard.fromJson(Json json) => CueCard(
    prompt: json.string('cueCard'),
    bullets: json.stringList('bullets'),
    closing: json.optionalString('closing') ?? '',
    roundOff: json.stringList('roundOff'),
  );

  final String prompt;
  final List<String> bullets;
  final String closing;
  final List<String> roundOff;
}

class ModelAnswer {
  const ModelAnswer({
    required this.title,
    required this.prompt,
    required this.answer,
    required this.band,
    required this.notes,
  });

  /// Accepts both the speaking shape (`part`, `question`) and the practice
  /// shape (`title`, `prompt`, `notes`).
  factory ModelAnswer.fromJson(Json json) => ModelAnswer(
    title:
        json.optionalString('title') ??
        (json.containsKey('part') ? 'Part ${json.integer('part')}' : ''),
    prompt: json.optionalString('prompt') ?? json.optionalString('question') ?? '',
    answer: json.string('answer'),
    band: json.optionalInteger('band') ?? 8,
    notes: json.stringList('notes'),
  );

  final String title;
  final String prompt;
  final String answer;
  final int band;
  final List<String> notes;
}

class SpeakingPaper {
  const SpeakingPaper({
    required this.testId,
    required this.part1,
    required this.cueCard,
    required this.part3,
    required this.modelAnswers,
    required this.usefulLanguage,
  });

  factory SpeakingPaper.fromJson(Json json) => SpeakingPaper(
    testId: json.string('id'),
    part1: json.objectList('part1').map(SpeakingTopic.fromJson).toList(),
    cueCard: CueCard.fromJson(json.object('part2')),
    part3: json.objectList('part3').map(SpeakingTopic.fromJson).toList(),
    modelAnswers: json.objectList('modelAnswers').map(ModelAnswer.fromJson).toList(),
    usefulLanguage: json.stringList('usefulLanguage'),
  );

  final String testId;
  final List<SpeakingTopic> part1;
  final CueCard cueCard;
  final List<SpeakingTopic> part3;
  final List<ModelAnswer> modelAnswers;
  final List<String> usefulLanguage;
}
