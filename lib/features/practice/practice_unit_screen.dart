import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/ads/ad_service.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/content/content_repository.dart';
import 'package:ielts_simulator/content/models/practice.dart';
import 'package:ielts_simulator/features/practice/drill_view.dart';
import 'package:ielts_simulator/ui/async_value_view.dart';
import 'package:ielts_simulator/ui/theme.dart';

class PracticeUnitScreen extends ConsumerWidget {
  const PracticeUnitScreen({required this.unitId, super.key});

  final String unitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(practiceUnitProvider(unitId)),
    data: (unit) => _UnitView(unit: unit),
  );
}

class _UnitView extends ConsumerWidget {
  const _UnitView({required this.unit});

  final PracticeUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tabs = <(String, Widget)>[
      (l10n.guide, _GuideView(blocks: unit.guide)),
      if (unit.drill case final drill?) (l10n.drill, DrillView(unitId: unit.id, drill: drill)),
      if (unit.models.isNotEmpty) (l10n.modelAnswers, _ModelsView(unit: unit)),
      if (unit.vocab.isNotEmpty) (l10n.skillVocabulary, _VocabView(items: unit.vocab)),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(unit.title),
          bottom: tabs.length < 2
              ? null
              : TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [for (final (label, _) in tabs) Tab(text: label)],
                ),
        ),
        bottomNavigationBar: ref.watch(adServiceProvider).banner(),
        body: tabs.length < 2
            ? tabs.first.$2
            : TabBarView(children: [for (final (_, view) in tabs) view]),
      ),
    );
  }
}

class _GuideView extends StatelessWidget {
  const _GuideView({required this.blocks});

  final List<GuideBlock> blocks;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SelectionArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          for (final block in blocks)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
              child: switch (block) {
                GuideHeading(:final text) => Padding(
                  padding: const EdgeInsetsDirectional.only(top: AppSpacing.sm),
                  child: Semantics(
                    header: true,
                    child: Text(
                      text,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GuideParagraph(:final text) => Text(text, style: textTheme.bodyLarge),
                GuideBullets(:final items) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: AppSpacing.sm, bottom: 2),
                        child: Text('•  $item', style: textTheme.bodyLarge),
                      ),
                  ],
                ),
                GuideTip(:final text) => _Callout(
                  icon: Icons.lightbulb,
                  color: scheme.tertiaryContainer,
                  text: text,
                ),
                GuideExample(:final text) => _Callout(
                  icon: Icons.format_quote,
                  color: scheme.surfaceContainerHighest,
                  text: text,
                ),
              },
            ),
        ],
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    ),
  );
}

class _ModelsView extends StatelessWidget {
  const _ModelsView({required this.unit});

  final PracticeUnit unit;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
    children: [
      for (final model in unit.models)
        Card(
          child: ExpansionTile(
            title: Text(model.title),
            subtitle: Text(context.l10n.modelBand(model.band)),
            childrenPadding: const EdgeInsetsDirectional.all(AppSpacing.md),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (model.prompt.isNotEmpty)
                Text(model.prompt, style: const TextStyle(fontStyle: FontStyle.italic)),
              const SizedBox(height: AppSpacing.sm),
              SelectableText(model.answer),
              for (final note in model.notes)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.check, size: 18),
                  title: Text(note),
                ),
            ],
          ),
        ),
    ],
  );
}

class _VocabView extends StatelessWidget {
  const _VocabView({required this.items});

  final List<VocabItem> items;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
    itemCount: items.length,
    separatorBuilder: (_, _) => const Divider(height: 1),
    itemBuilder: (context, index) {
      final item = items[index];
      return ListTile(
        title: Text(item.word, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          [item.meaning, if (item.example.isNotEmpty) '“${item.example}”'].join('\n'),
        ),
      );
    },
  );
}
