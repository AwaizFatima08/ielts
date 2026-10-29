import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/attempts/attempt.dart';
import 'package:ielts_simulator/attempts/attempt_repository.dart';
import 'package:ielts_simulator/content/models/practice.dart';
import 'package:ielts_simulator/core/result.dart';

/// Ratings being edited: criterion slot → band. Writing slots are
/// `"1:<id>"` / `"2:<id>"` (task number); Speaking slots are `"<id>"`.
typedef Ratings = Map<String, double>;

typedef SelfCheckKey = ({String attemptId, ExamSection section});

class SelfCheckNotifier extends Notifier<Ratings> {
  SelfCheckNotifier(this.key);

  final SelfCheckKey key;

  @override
  Ratings build() => const {};

  /// Loads saved ratings into the editor once the criteria are known.
  void load(Attempt attempt, Descriptors descriptors) {
    if (state.isNotEmpty) return;
    state = switch (key.section) {
      ExamSection.writing => {
        for (final (index, criterion) in descriptors.writing1.indexed)
          if (index < attempt.writingTask1Scores.length)
            '1:${criterion.id}': attempt.writingTask1Scores[index],
        for (final (index, criterion) in descriptors.writing2.indexed)
          if (index < attempt.writingTask2Scores.length)
            '2:${criterion.id}': attempt.writingTask2Scores[index],
      },
      _ => {
        for (final (index, criterion) in descriptors.speaking.indexed)
          if (index < attempt.speakingScores.length) criterion.id: attempt.speakingScores[index],
      },
    };
  }

  void rate(String slot, double band) => state = {...state, slot: band};

  /// True when every criterion has a band.
  bool isComplete(Descriptors descriptors) => switch (key.section) {
    ExamSection.writing =>
      descriptors.writing1.every((criterion) => state.containsKey('1:${criterion.id}')) &&
          descriptors.writing2.every((criterion) => state.containsKey('2:${criterion.id}')),
    _ => descriptors.speaking.every((criterion) => state.containsKey(criterion.id)),
  };

  Future<Result<void, StorageFailure>> save(Descriptors descriptors) => ref
      .read(attemptRepositoryProvider)
      .update(
        key.attemptId,
        (attempt) => key.section == ExamSection.writing
            ? attempt.copyWith(
                writingTask1Scores: [
                  for (final criterion in descriptors.writing1) state['1:${criterion.id}']!,
                ],
                writingTask2Scores: [
                  for (final criterion in descriptors.writing2) state['2:${criterion.id}']!,
                ],
              )
            : attempt.copyWith(
                speakingScores: [
                  for (final criterion in descriptors.speaking) state[criterion.id]!,
                ],
              ),
      );
}

final selfCheckProvider = NotifierProvider.autoDispose
    .family<SelfCheckNotifier, Ratings, SelfCheckKey>(SelfCheckNotifier.new);
