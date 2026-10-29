import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/features/home/module_picker.dart';
import 'package:ielts_simulator/features/home/progress_tab.dart';
import 'package:ielts_simulator/features/home/tests_tab.dart';
import 'package:ielts_simulator/features/practice/practice_tab.dart';
import 'package:ielts_simulator/settings/settings_repository.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0; // ephemeral UI state: which tab is showing

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final module = ref.watch(moduleProvider);
    if (module case AsyncData(value: null)) return const ModulePickerScreen();
    final current = module.value ?? ExamModule.academic;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          ActionChip(
            avatar: const Icon(Icons.swap_horiz, size: 18),
            label: Text(current == ExamModule.academic ? l10n.academicShort : l10n.generalShort),
            tooltip: l10n.changeModule,
            onPressed: () => ref
                .read(moduleProvider.notifier)
                .choose(current == ExamModule.academic ? ExamModule.general : ExamModule.academic),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: switch (_tab) {
        0 => const TestsTab(),
        1 => const PracticeTab(),
        _ => const ProgressTab(),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.timer_outlined), label: l10n.tabTests),
          NavigationDestination(icon: const Icon(Icons.school_outlined), label: l10n.tabPractice),
          NavigationDestination(icon: const Icon(Icons.insights_outlined), label: l10n.tabProgress),
        ],
      ),
    );
  }
}
