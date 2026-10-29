import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/settings/settings_repository.dart';
import 'package:ielts_simulator/ui/theme.dart';

/// First-launch choice between Academic and General Training.
class ModulePickerScreen extends ConsumerWidget {
  const ModulePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    void choose(ExamModule module) => ref.read(moduleProvider.notifier).choose(module);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
              children: [
                Text(
                  l10n.appTitle,
                  style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.pickModuleBody, style: textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.school, size: 36),
                    title: Text(l10n.moduleAcademic),
                    subtitle: Text(l10n.moduleAcademicHint),
                    onTap: () => choose(ExamModule.academic),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.work, size: 36),
                    title: Text(l10n.moduleGeneral),
                    subtitle: Text(l10n.moduleGeneralHint),
                    onTap: () => choose(ExamModule.general),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.disclaimer, style: textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
