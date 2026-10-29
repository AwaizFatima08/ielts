import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/attempts/attempt.dart';
import 'package:ielts_simulator/attempts/attempt_repository.dart';
import 'package:ielts_simulator/content/content_repository.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/content/models/question_group.dart';
import 'package:ielts_simulator/core/clock.dart';
import 'package:ielts_simulator/core/scoring.dart';
import 'package:ielts_simulator/features/exam/section_key.dart';
import 'package:ielts_simulator/services/audio_service.dart';

enum ListeningPhase { ready, playing, checking, submitted }

@immutable
class ListeningState {
  const ListeningState({
    this.phase = ListeningPhase.ready,
    this.partIndex = 0,
    this.viewedPart = 0,
    this.answers = const {},
    this.flagged = const {},
    this.pauseNote,
    this.audioMissing = false,
    this.checkEndsAt,
  });

  final ListeningPhase phase;

  /// Part the recording is on; the candidate may look at another one.
  final int partIndex;
  final int viewedPart;
  final Map<int, String> answers;
  final Set<int> flagged;

  /// Shown during silent reading time, e.g. "Look at questions 1 to 5".
  final String? pauseNote;

  /// True once a clip was missing (homidev audio not generated yet).
  final bool audioMissing;
  final DateTime? checkEndsAt;

  ListeningState copyWith({
    ListeningPhase? phase,
    int? partIndex,
    int? viewedPart,
    Map<int, String>? answers,
    Set<int>? flagged,
    String? Function()? pauseNote,
    bool? audioMissing,
    DateTime? checkEndsAt,
  }) => ListeningState(
    phase: phase ?? this.phase,
    partIndex: partIndex ?? this.partIndex,
    viewedPart: viewedPart ?? this.viewedPart,
    answers: answers ?? this.answers,
    flagged: flagged ?? this.flagged,
    pauseNote: pauseNote == null ? this.pauseNote : pauseNote(),
    audioMissing: audioMissing ?? this.audioMissing,
    checkEndsAt: checkEndsAt ?? this.checkEndsAt,
  );
}

/// Time to wait for a clip that has not been generated yet (~150 wpm).
Duration estimatedSpeech(String text) =>
    Duration(milliseconds: (countWords(text) * 400).clamp(1500, 30000));

/// Asset path of the homidev voice clip for a script line.
String clipPath(String testId, String clipId) => 'assets/audio/$testId/listening/$clipId.ogg';

class ListeningNotifier extends Notifier<ListeningState> {
  ListeningNotifier(this.key);

  final SectionKey key;
  static const checkTime = Duration(minutes: 2);
  bool _cancelled = false;
  Timer? _waitTimer;
  Completer<void>? _waiting;

  ListeningPaper get _paper => ref.read(listeningPaperProvider(key.testId)).requireValue;

  @override
  ListeningState build() {
    ref.onDispose(() {
      _cancelled = true;
      _waitTimer?.cancel();
      if (_waiting case final waiting? when !waiting.isCompleted) waiting.complete();
    });
    return const ListeningState();
  }

  Future<void> start() async {
    if (state.phase != ListeningPhase.ready) return;
    state = state.copyWith(phase: ListeningPhase.playing);
    final audio = ref.read(audioServiceProvider);
    for (final (index, part) in _paper.parts.indexed) {
      if (_cancelled) return;
      state = state.copyWith(partIndex: index, viewedPart: index);
      for (final item in part.script) {
        if (_cancelled) return;
        await _playItem(audio, item);
      }
    }
    if (_cancelled) return;
    state = state.copyWith(
      phase: ListeningPhase.checking,
      pauseNote: () => null,
      checkEndsAt: ref.read(clockProvider).now().add(checkTime),
    );
  }

  Future<void> _playItem(AudioService audio, ScriptItem item) async {
    switch (item) {
      case ScriptPause(:final seconds, :final note):
        state = state.copyWith(pauseNote: () => note);
        await _wait(Duration(seconds: seconds));
        state = state.copyWith(pauseNote: () => null);
      case ScriptLine(:final id, :final text):
        final path = clipPath(key.testId, id);
        if (await audio.hasAsset(path)) {
          await audio.playAsset(path);
        } else {
          state = state.copyWith(audioMissing: true);
          await _wait(estimatedSpeech(text));
        }
    }
  }

  Future<void> _wait(Duration duration) {
    final waiting = _waiting = Completer<void>();
    _waitTimer = Timer(duration, () {
      if (!waiting.isCompleted) waiting.complete();
    });
    return waiting.future;
  }

  /// Debug builds only: skip the current pause or missing clip.
  void skipWait() {
    if (!kDebugMode) return;
    _waitTimer?.cancel();
    if (_waiting case final waiting? when !waiting.isCompleted) waiting.complete();
  }

  void answer(int number, String value) =>
      state = state.copyWith(answers: {...state.answers, number: value});

  void toggleFlag(int number) => state = state.copyWith(
    flagged: state.flagged.contains(number)
        ? ({...state.flagged}..remove(number))
        : {...state.flagged, number},
  );

  void viewPart(int index) => state = state.copyWith(viewedPart: index);

  /// Marks the paper and saves it to the attempt (persist first).
  Future<void> submit() async {
    if (state.phase == ListeningPhase.submitted) return;
    _cancelled = true;
    _waitTimer?.cancel();
    await ref.read(audioServiceProvider).stop();
    final raw = scoreGroups(_paper.groups, state.answers);
    final result = ObjectiveResult(answers: state.answers, rawScore: raw, band: listeningBand(raw));
    await ref
        .read(attemptRepositoryProvider)
        .update(
          key.attemptId,
          (attempt) => attempt.copyWith(
            listening: result,
            finishedSections: [...attempt.finishedSections, ExamSection.listening],
          ),
        );
    state = state.copyWith(phase: ListeningPhase.submitted);
  }
}

final listeningProvider = NotifierProvider.autoDispose
    .family<ListeningNotifier, ListeningState, SectionKey>(
      ListeningNotifier.new,
    );
