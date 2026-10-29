import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/content/content_repository.dart';
import 'package:ielts_simulator/content/models/practice.dart';
import 'package:ielts_simulator/router.dart';
import 'package:ielts_simulator/ui/async_value_view.dart';
import 'package:ielts_simulator/ui/theme.dart';

/// Study guides and drills, grouped by skill.
class PracticeTab extends ConsumerWidget {
  const PracticeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncBody(
    value: ref.watch(practiceUnitsProvider),
    data: (units) => ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: [
        for (final skill in PracticeSkill.values)
          if (units.any((unit) => unit.skill == skill))
            _SkillSection(
              skill: skill,
              units: [
                for (final unit in units)
                  if (unit.skill == skill) unit,
              ],
            ),
      ],
    ),
  );
}

class _SkillSection extends StatelessWidget {
  const _SkillSection({required this.skill, required this.units});

  final PracticeSkill skill;
  final List<PracticeUnitSummary> units;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (title, icon) = switch (skill) {
      PracticeSkill.testOverview => (l10n.skillOverview, Icons.info_outline),
      PracticeSkill.listening => (l10n.listening, Icons.headphones),
      PracticeSkill.reading => (l10n.reading, Icons.menu_book),
      PracticeSkill.writing => (l10n.writing, Icons.edit),
      PracticeSkill.speaking => (l10n.speaking, Icons.mic),
      PracticeSkill.vocabulary => (l10n.skillVocabulary, Icons.translate),
    };
    return Card(
      child: ExpansionTile(
        initiallyExpanded: skill == PracticeSkill.testOverview,
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(l10n.unitCount(units.length)),
        children: [
          for (final unit in units)
            ListTile(
              title: Text(unit.title),
              subtitle: unit.summary.isEmpty ? null : Text(unit.summary),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.practice(unit.id)),
            ),
        ],
      ),
    );
  }
}
