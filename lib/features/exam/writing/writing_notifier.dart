import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/attempts/attempt.dart';
import 'package:ielts_simulator/attempts/attempt_repository.dart';
import 'package:ielts_simulator/core/clock.dart';
import 'package:ielts_simulator/features/exam/section_key.dart';

@immutable
class WritingState {
  const WritingState({
    this.endsAt,
    this.taskIndex = 0,
    this.essays = const ['', ''],
    this.submitted = false,
  });

  final DateTime? endsAt;
  final int taskIndex;
  final List<String> essays;
  final bool submitted;

  WritingState copyWith({
    DateTime? endsAt,
    int? taskIndex,
    List<String>? essays,
    bool? submitted,
  }) => WritingState(
    endsAt: endsAt ?? this.endsAt,
    taskIndex: taskIndex ?? this.taskIndex,
    essays: essays ?? this.essays,
    submitted: submitted ?? this.submitted,
  );
}

class WritingNotifier extends Notifier<WritingState> {
  WritingNotifier(this.key);

  final SectionKey key;
  static const duration = Duration(minutes: 60);

  @override
  WritingState build() => const WritingState();

  void start() => state = state.copyWith(endsAt: ref.read(clockProvider).now().add(duration));

  void showTask(int index) => state = state.copyWith(taskIndex: index);

  void edit(int taskIndex, String text) =>
      state = state.copyWith(essays: [...state.essays]..[taskIndex] = text);

  Future<void> submit() async {
    if (state.submitted) return;
    state = state.copyWith(submitted: true);
    await ref
        .read(attemptRepositoryProvider)
        .update(
          key.attemptId,
          (attempt) => attempt.copyWith(
            essays: state.essays,
            finishedSections: [...attempt.finishedSections, ExamSection.writing],
          ),
        );
  }
}

final writingProvider = NotifierProvider.autoDispose
    .family<WritingNotifier, WritingState, SectionKey>(
      WritingNotifier.new,
    );
