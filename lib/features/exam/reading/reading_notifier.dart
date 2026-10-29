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

@immutable
class ReadingState {
  const ReadingState({
    this.endsAt,
    this.passageIndex = 0,
    this.showPassage = true,
    this.answers = const {},
    this.flagged = const {},
    this.submitted = false,
  });

  /// Null until the candidate presses Start.
  final DateTime? endsAt;
  final int passageIndex;

  /// Phone layout only: passage or questions on screen.
  final bool showPassage;
  final Map<int, String> answers;
  final Set<int> flagged;
  final bool submitted;

  ReadingState copyWith({
    DateTime? endsAt,
    int? passageIndex,
    bool? showPassage,
    Map<int, String>? answers,
    Set<int>? flagged,
    bool? submitted,
  }) => ReadingState(
    endsAt: endsAt ?? this.endsAt,
    passageIndex: passageIndex ?? this.passageIndex,
    showPassage: showPassage ?? this.showPassage,
    answers: answers ?? this.answers,
    flagged: flagged ?? this.flagged,
    submitted: submitted ?? this.submitted,
  );
}

class ReadingNotifier extends Notifier<ReadingState> {
  ReadingNotifier(this.key);

  final SectionKey key;
  static const duration = Duration(minutes: 60);

  ReadingPaper get _paper => ref.read(readingPaperProvider((key.testId, key.module))).requireValue;

  @override
  ReadingState build() => const ReadingState();

  void start() => state = state.copyWith(endsAt: ref.read(clockProvider).now().add(duration));

  void answer(int number, String value) =>
      state = state.copyWith(answers: {...state.answers, number: value});

  void toggleFlag(int number) => state = state.copyWith(
    flagged: state.flagged.contains(number)
        ? ({...state.flagged}..remove(number))
        : {...state.flagged, number},
  );

  void showPassage(int index) => state = state.copyWith(passageIndex: index);

  void setShowPassage({required bool visible}) => state = state.copyWith(showPassage: visible);

  Future<void> submit() async {
    if (state.submitted) return;
    state = state.copyWith(submitted: true);
    final raw = scoreGroups(_paper.groups, state.answers);
    final module = key.module == ExamModule.general
        ? ReadingModule.general
        : ReadingModule.academic;
    final result = ObjectiveResult(
      answers: state.answers,
      rawScore: raw,
      band: readingBand(raw, module),
    );
    await ref
        .read(attemptRepositoryProvider)
        .update(
          key.attemptId,
          (attempt) => attempt.copyWith(
            reading: result,
            finishedSections: [...attempt.finishedSections, ExamSection.reading],
          ),
        );
  }
}

final readingProvider = NotifierProvider.autoDispose
    .family<ReadingNotifier, ReadingState, SectionKey>(
      ReadingNotifier.new,
    );
