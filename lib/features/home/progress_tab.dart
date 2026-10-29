import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/attempts/attempt.dart';
import 'package:ielts_simulator/attempts/attempt_repository.dart';
import 'package:ielts_simulator/core/scoring.dart';
import 'package:ielts_simulator/router.dart';
import 'package:ielts_simulator/ui/async_value_view.dart';
import 'package:ielts_simulator/ui/theme.dart';
import 'package:intl/intl.dart';

/// History of attempts, newest first.
class ProgressTab extends ConsumerWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncBody(
    value: ref.watch(attemptsProvider),
    data: (attempts) => attempts.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
              child: Text(context.l10n.noAttempts, textAlign: TextAlign.center),
            ),
          )
        : ListView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            children: [for (final attempt in attempts) _AttemptTile(attempt: attempt)],
          ),
  );
}

class _AttemptTile extends StatelessWidget {
  const _AttemptTile({required this.attempt});

  final Attempt attempt;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final number = int.tryParse(attempt.testId.substring(1)) ?? 0;
    final date = DateFormat.yMMMd().add_Hm().format(attempt.startedAt);
    final bands = [
      if (attempt.listening case final result?) 'L ${formatBand(result.band)}',
      if (attempt.reading case final result?) 'R ${formatBand(result.band)}',
      if (attempt.writingBand case final band?) 'W ${formatBand(band)}',
      if (attempt.speakingBand case final band?) 'S ${formatBand(band)}',
    ].join(' · ');
    return Card(
      child: ListTile(
        title: Text('${l10n.testTitle(number)} — ${l10n.attemptKind(attempt.kind.name)}'),
        subtitle: Text(
          [date, if (bands.isNotEmpty) bands, if (!attempt.isComplete) l10n.unfinished].join('\n'),
        ),
        isThreeLine: bands.isNotEmpty || !attempt.isComplete,
        trailing: attempt.overall == null
            ? const Icon(Icons.chevron_right)
            : CircleAvatar(child: Text(formatBand(attempt.overall!))),
        onTap: () => context.push(
          attempt.isComplete ? Routes.results(attempt.id) : Routes.run(attempt.id),
        ),
      ),
    );
  }
}
