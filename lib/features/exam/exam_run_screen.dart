import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ielts_simulator/attempts/attempt.dart';
import 'package:ielts_simulator/attempts/attempt_repository.dart';
import 'package:ielts_simulator/features/exam/listening/listening_screen.dart';
import 'package:ielts_simulator/features/exam/reading/reading_screen.dart';
import 'package:ielts_simulator/features/exam/speaking/speaking_screen.dart';
import 'package:ielts_simulator/features/exam/writing/writing_screen.dart';
import 'package:ielts_simulator/router.dart';
import 'package:ielts_simulator/ui/async_value_view.dart';

/// Runs an attempt section by section. Each section saves itself as
/// finished; the attempt stream then moves this screen to the next one.
class ExamRunScreen extends ConsumerWidget {
  const ExamRunScreen({required this.attemptId, super.key});

  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(attemptProvider(attemptId), (previous, next) {
      if (next.value case final Attempt attempt when attempt.nextSection == null) {
        context.go(Routes.results(attemptId, fresh: true));
      }
    });
    return AsyncValueView(
      value: ref.watch(attemptProvider(attemptId)),
      data: (attempt) {
        if (attempt == null) return const Scaffold();
        final key = (
          attemptId: attempt.id,
          testId: attempt.testId,
          module: attempt.module,
        );
        return switch (attempt.nextSection) {
          ExamSection.listening => ListeningScreen(key: ValueKey(key), sectionKey: key),
          ExamSection.reading => ReadingScreen(key: ValueKey(key), sectionKey: key),
          ExamSection.writing => WritingScreen(key: ValueKey(key), sectionKey: key),
          ExamSection.speaking => SpeakingScreen(key: ValueKey(key), sectionKey: key),
          null => const Scaffold(body: Center(child: CircularProgressIndicator())),
        };
      },
    );
  }
}
