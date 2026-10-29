import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/attempts/attempt.dart';
import 'package:ielts_simulator/attempts/attempt_repository.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/core/result.dart';
import 'package:ielts_simulator/router.dart';
import 'package:ielts_simulator/settings/settings_repository.dart';
import 'package:ielts_simulator/ui/theme.dart';

/// Starts a full test or one section of test [testId].
class TestDetailScreen extends ConsumerWidget {
  const TestDetailScreen({required this.testId, super.key});

  final String testId;

  Future<void> _start(BuildContext context, WidgetRef ref, AttemptKind kind) async {
    final module = ref.read(moduleProvider).value ?? ExamModule.academic;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.saveError;
    final result = await ref
        .read(attemptRepositoryProvider)
        .start(testId: testId, module: module, kind: kind);
    switch (result) {
      case Ok(:final value):
        await router.push(Routes.run(value.id));
      case Err():
        messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final module = ref.watch(moduleProvider).value ?? ExamModule.academic;
    final number = int.tryParse(testId.substring(1)) ?? 0;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.testTitle(number))),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          Text(
            module == ExamModule.academic ? l10n.moduleAcademic : l10n.moduleGeneral,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: ListTile(
              leading: const Icon(Icons.assignment_turned_in, size: 36),
              title: Text(l10n.fullTest, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(l10n.fullTestSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _start(context, ref, AttemptKind.full),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.singleSection, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          for (final (kind, icon, title, subtitle) in [
            (AttemptKind.listening, Icons.headphones, l10n.listening, l10n.listeningSubtitle),
            (AttemptKind.reading, Icons.menu_book, l10n.reading, l10n.readingSubtitle),
            (AttemptKind.writing, Icons.edit, l10n.writing, l10n.writingSubtitle),
            (AttemptKind.speaking, Icons.mic, l10n.speaking, l10n.speakingSubtitle),
          ])
            Card(
              child: ListTile(
                leading: Icon(icon),
                title: Text(title),
                subtitle: Text(subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _start(context, ref, kind),
              ),
            ),
        ],
      ),
    );
  }
}
