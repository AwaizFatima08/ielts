import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/attempts/attempt.dart';
import 'package:ielts_simulator/attempts/attempt_repository.dart';
import 'package:ielts_simulator/content/content_repository.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/core/result.dart';
import 'package:ielts_simulator/features/exam/section_key.dart';
import 'package:ielts_simulator/services/recorder_service.dart';

/// One examiner turn in the Speaking test.
sealed class SpeakingStep {
  const SpeakingStep({required this.part, required this.seconds});

  final int part;
  final int seconds;

  bool get records => true;
}

/// A question the candidate answers aloud (Parts 1 and 3, round-off).
final class QuestionStep extends SpeakingStep {
  const QuestionStep({
    required super.part,
    required super.seconds,
    required this.question,
    this.topic,
  });

  final String question;

  /// Set on the first question of a new topic.
  final String? topic;
}

/// Part 2: one minute to make notes on the cue card.
final class PrepStep extends SpeakingStep {
  const PrepStep({required this.card}) : super(part: 2, seconds: 60);

  final CueCard card;

  @override
  bool get records => false;
}

/// Part 2: speak for up to two minutes.
final class LongTurnStep extends SpeakingStep {
  const LongTurnStep({required this.card}) : super(part: 2, seconds: 120);

  final CueCard card;
}

/// Builds the examiner's script from a paper, in test order.
List<SpeakingStep> speakingSteps(SpeakingPaper paper) => [
  for (final topic in paper.part1)
    for (final (index, question) in topic.questions.indexed)
      QuestionStep(
        part: 1,
        seconds: 40,
        question: question,
        topic: index == 0 ? topic.topic : null,
      ),
  PrepStep(card: paper.cueCard),
  LongTurnStep(card: paper.cueCard),
  for (final question in paper.cueCard.roundOff)
    QuestionStep(part: 2, seconds: 30, question: question),
  for (final topic in paper.part3)
    for (final (index, question) in topic.questions.indexed)
      QuestionStep(
        part: 3,
        seconds: 60,
        question: question,
        topic: index == 0 ? topic.topic : null,
      ),
];

@immutable
class SpeakingState {
  const SpeakingState({
    this.started = false,
    this.stepIndex = 0,
    this.secondsLeft = 0,
    this.recordings = const [],
    this.notes = '',
    this.micAvailable = true,
    this.finished = false,
  });

  final bool started;
  final int stepIndex;
  final int secondsLeft;
  final List<RecordedAnswer> recordings;

  /// Part 2 preparation notes.
  final String notes;
  final bool micAvailable;
  final bool finished;

  SpeakingState copyWith({
    bool? started,
    int? stepIndex,
    int? secondsLeft,
    List<RecordedAnswer>? recordings,
    String? notes,
    bool? micAvailable,
    bool? finished,
  }) => SpeakingState(
    started: started ?? this.started,
    stepIndex: stepIndex ?? this.stepIndex,
    secondsLeft: secondsLeft ?? this.secondsLeft,
    recordings: recordings ?? this.recordings,
    notes: notes ?? this.notes,
    micAvailable: micAvailable ?? this.micAvailable,
    finished: finished ?? this.finished,
  );
}

class SpeakingNotifier extends Notifier<SpeakingState> {
  SpeakingNotifier(this.key);

  final SectionKey key;
  Timer? _ticker;
  String? _recordingPath;
  bool _advancing = false;

  List<SpeakingStep> get steps =>
      speakingSteps(ref.read(speakingPaperProvider(key.testId)).requireValue);

  @override
  SpeakingState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const SpeakingState();
  }

  Future<void> start() async {
    final allowed = await ref.read(recorderServiceProvider).requestPermission();
    state = state.copyWith(started: true, micAvailable: allowed);
    await _enter(0);
  }

  Future<void> _enter(int index) async {
    if (index >= steps.length) return _finish();
    final step = steps[index];
    state = state.copyWith(stepIndex: index, secondsLeft: step.seconds);
    if (step.records && state.micAvailable) {
      final started = await ref.read(recorderServiceProvider).start('${key.attemptId}_s$index');
      _recordingPath = switch (started) {
        Ok(:final value) => value,
        Err() => null,
      };
    }
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (state.secondsLeft <= 1) {
      unawaited(next());
    } else {
      state = state.copyWith(secondsLeft: state.secondsLeft - 1);
    }
  }

  /// Ends the current turn (candidate taps Next or time runs out).
  Future<void> next() async {
    if (_advancing || state.finished) return;
    _advancing = true;
    _ticker?.cancel();
    final step = steps[state.stepIndex];
    if (_recordingPath != null) {
      final path = await ref.read(recorderServiceProvider).stop();
      _recordingPath = null;
      if (path != null) {
        final question = switch (step) {
          QuestionStep(:final question) => question,
          PrepStep(:final card) || LongTurnStep(:final card) => card.prompt,
        };
        state = state.copyWith(
          recordings: [
            ...state.recordings,
            RecordedAnswer(part: step.part, question: question, filePath: path),
          ],
        );
      }
    }
    _advancing = false;
    await _enter(state.stepIndex + 1);
  }

  void editNotes(String notes) => state = state.copyWith(notes: notes);

  Future<void> _finish() async {
    state = state.copyWith(finished: true);
    await ref
        .read(attemptRepositoryProvider)
        .update(
          key.attemptId,
          (attempt) => attempt.copyWith(
            recordings: state.recordings,
            finishedSections: [...attempt.finishedSections, ExamSection.speaking],
          ),
        );
  }
}

final speakingProvider = NotifierProvider.autoDispose
    .family<SpeakingNotifier, SpeakingState, SectionKey>(
      SpeakingNotifier.new,
    );
