import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ielts_simulator/attempts/attempt.dart';
import 'package:ielts_simulator/features/exam/exam_run_screen.dart';
import 'package:ielts_simulator/features/home/home_screen.dart';
import 'package:ielts_simulator/features/practice/practice_unit_screen.dart';
import 'package:ielts_simulator/features/results/answer_review_screen.dart';
import 'package:ielts_simulator/features/results/results_screen.dart';
import 'package:ielts_simulator/features/results/self_check_screen.dart';
import 'package:ielts_simulator/features/tests/test_detail_screen.dart';

abstract final class Routes {
  static const home = '/';
  static String test(String testId) => '/test/$testId';
  static String run(String attemptId) => '/attempt/$attemptId/run';
  static String results(String attemptId, {bool fresh = false}) =>
      '/attempt/$attemptId${fresh ? '?fresh=1' : ''}';
  static String review(String attemptId, ExamSection section) =>
      '/attempt/$attemptId/review/${section.name}';
  static String selfCheck(String attemptId, ExamSection section) =>
      '/attempt/$attemptId/rate/${section.name}';
  static String practice(String unitId) => '/practice/$unitId';
}

final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    routes: [
      GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/test/:testId',
        builder: (context, state) => TestDetailScreen(testId: state.pathParameters['testId']!),
      ),
      GoRoute(
        path: '/attempt/:id',
        builder: (context, state) => ResultsScreen(
          attemptId: state.pathParameters['id']!,
          fresh: state.uri.queryParameters['fresh'] == '1',
        ),
        routes: [
          GoRoute(
            path: 'run',
            builder: (context, state) => ExamRunScreen(attemptId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'review/:section',
            builder: (context, state) => AnswerReviewScreen(
              attemptId: state.pathParameters['id']!,
              section: ExamSection.values.byName(state.pathParameters['section']!),
            ),
          ),
          GoRoute(
            path: 'rate/:section',
            builder: (context, state) => SelfCheckScreen(
              attemptId: state.pathParameters['id']!,
              section: ExamSection.values.byName(state.pathParameters['section']!),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/practice/:unitId',
        builder: (context, state) => PracticeUnitScreen(unitId: state.pathParameters['unitId']!),
      ),
    ],
  ),
);
