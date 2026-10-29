import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/attempts/attempt_repository.dart';
import 'package:ielts_simulator/content/content_repository.dart';
import 'package:ielts_simulator/core/scoring.dart';
import 'package:ielts_simulator/router.dart';
import 'package:ielts_simulator/ui/async_value_view.dart';
import 'package:ielts_simulator/ui/theme.dart';

/// The ten simulated tests, with the best overall band reached so far.
class TestsTab extends ConsumerWidget {
  const TestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final attempts = ref.watch(attemptsProvider).value ?? const [];
    return AsyncBody(
      value: ref.watch(testsProvider),
      data: (tests) => ListView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          Text(l10n.testsIntro, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          for (final (index, test) in tests.indexed)
            Card(
              child: ListTile(
                enabled: test.ready,
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(l10n.testTitle(index + 1)),
                subtitle: Text(
                  !test.ready
                      ? l10n.comingSoon
                      : switch (attempts
                            .where(
                              (attempt) => attempt.testId == test.id && attempt.overall != null,
                            )
                            .map((attempt) => attempt.overall!)
                            .fold<double?>(
                              null,
                              (best, band) => best == null || band > best ? band : best,
                            )) {
                          final double best => l10n.bestBand(formatBand(best)),
                          null => l10n.notAttempted,
                        },
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.test(test.id)),
              ),
            ),
        ],
      ),
    );
  }
}
