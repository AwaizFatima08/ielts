import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ielts_simulator/ads/ad_service.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/attempts/attempt.dart';
import 'package:ielts_simulator/attempts/attempt_repository.dart';
import 'package:ielts_simulator/core/scoring.dart';
import 'package:ielts_simulator/router.dart';
import 'package:ielts_simulator/ui/async_value_view.dart';
import 'package:ielts_simulator/ui/theme.dart';

/// Test report: band per section, overall band, and the next steps to
/// review answers or self-rate Writing and Speaking.
class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({required this.attemptId, this.fresh = false, super.key});

  final String attemptId;

  /// True when arriving straight from finishing a test (not from history).
  final bool fresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(attemptProvider(attemptId)),
    data: (attempt) =>
        attempt == null ? const Scaffold() : _ResultsView(attempt: attempt, fresh: fresh),
  );
}

class _ResultsView extends ConsumerStatefulWidget {
  const _ResultsView({required this.attempt, required this.fresh});

  final Attempt attempt;
  final bool fresh;

  @override
  ConsumerState<_ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends ConsumerState<_ResultsView> {
  @override
  void initState() {
    super.initState();
    if (widget.fresh) unawaited(ref.read(adServiceProvider).showReportInterstitial());
  }

  @override
  Widget build(BuildContext context) {
    final attempt = widget.attempt;
    final l10n = context.l10n;
    final sections = attempt.kind.sections;
    return Scaffold(
      bottomNavigationBar: ref.watch(adServiceProvider).banner(),
      appBar: AppBar(
        title: Text(l10n.resultsTitle),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: l10n.home,
          onPressed: () => context.go(Routes.home),
        ),
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          if (attempt.kind == AttemptKind.full) _OverallCard(band: attempt.overall),
          for (final section in sections) _SectionCard(attempt: attempt, section: section),
          Text(l10n.estimateNote, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _OverallCard extends StatelessWidget {
  const _OverallCard({required this.band});

  final double? band;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(l10n.overallBand, style: Theme.of(context).textTheme.titleMedium),
            Text(
              band == null ? '–' : formatBand(band!),
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (band == null) Text(l10n.overallPending, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.attempt, required this.section});

  final Attempt attempt;
  final ExamSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (title, band, detail, action, route) = switch (section) {
      ExamSection.listening => (
        l10n.listening,
        attempt.listening?.band,
        attempt.listening == null ? null : l10n.rawScore(attempt.listening!.rawScore),
        l10n.reviewAnswers,
        Routes.review(attempt.id, section),
      ),
      ExamSection.reading => (
        l10n.reading,
        attempt.reading?.band,
        attempt.reading == null ? null : l10n.rawScore(attempt.reading!.rawScore),
        l10n.reviewAnswers,
        Routes.review(attempt.id, section),
      ),
      ExamSection.writing => (
        l10n.writing,
        attempt.writingBand,
        l10n.essayWords(countWords(attempt.essays.first), countWords(attempt.essays.last)),
        attempt.writingBand == null ? l10n.rateWriting : l10n.reviewRating,
        Routes.selfCheck(attempt.id, section),
      ),
      ExamSection.speaking => (
        l10n.speaking,
        attempt.speakingBand,
        l10n.recordingsCount(attempt.recordings.length),
        attempt.speakingBand == null ? l10n.rateSpeaking : l10n.reviewRating,
        Routes.selfCheck(attempt.id, section),
      ),
    };
    final finished = attempt.finishedSections.contains(section);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(
                band == null ? '–' : formatBand(band),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(finished ? (detail ?? '') : l10n.notTaken),
                ],
              ),
            ),
            if (finished) TextButton(onPressed: () => context.push(route), child: Text(action)),
          ],
        ),
      ),
    );
  }
}
