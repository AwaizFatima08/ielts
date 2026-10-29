import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/content/content_repository.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/core/scoring.dart';
import 'package:ielts_simulator/features/exam/section_key.dart';
import 'package:ielts_simulator/features/exam/widgets/exam_chrome.dart';
import 'package:ielts_simulator/features/exam/writing/task_chart.dart';
import 'package:ielts_simulator/features/exam/writing/writing_notifier.dart';
import 'package:ielts_simulator/ui/async_value_view.dart';
import 'package:ielts_simulator/ui/theme.dart';

class WritingScreen extends ConsumerWidget {
  const WritingScreen({required this.sectionKey, super.key});

  final SectionKey sectionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(writingPaperProvider((sectionKey.testId, sectionKey.module))),
    data: (paper) => _WritingView(sectionKey: sectionKey, paper: paper),
  );
}

class _WritingView extends ConsumerWidget {
  const _WritingView({required this.sectionKey, required this.paper});

  final SectionKey sectionKey;
  final WritingPaper paper;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(writingProvider(sectionKey));
    final notifier = ref.read(writingProvider(sectionKey).notifier);
    final endsAt = state.endsAt;
    final title = paper.module == ExamModule.academic ? l10n.writingAcademic : l10n.writingGeneral;
    if (endsAt == null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SectionIntro(
          title: title,
          lines: [l10n.writingIntro1, l10n.writingIntro2, l10n.writingIntro3],
          onStart: notifier.start,
        ),
      );
    }
    final task = paper.tasks[state.taskIndex];
    return ExamExitGuard(
      child: TimeUpListener(
        endsAt: endsAt,
        onTimeUp: notifier.submit,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.writingTask(task.number)),
            actions: [
              CountdownChip(endsAt: endsAt),
              TextButton(
                onPressed: () async {
                  if (await confirmSubmit(context, unanswered: 0)) await notifier.submit();
                },
                child: Text(l10n.submit, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final prompt = _TaskPrompt(task: task);
              final editor = _EssayEditor(
                key: ValueKey('essay-${task.number}'),
                text: state.essays[state.taskIndex],
                minWords: task.minWords,
                onChanged: (text) => notifier.edit(state.taskIndex, text),
              );
              return constraints.maxWidth >= 840
                  ? Row(
                      children: [
                        Expanded(child: SingleChildScrollView(child: prompt)),
                        const VerticalDivider(width: 1),
                        Expanded(child: editor),
                      ],
                    )
                  : Column(
                      children: [
                        Flexible(child: SingleChildScrollView(child: prompt)),
                        const Divider(height: 1),
                        Expanded(flex: 2, child: editor),
                      ],
                    );
            },
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: state.taskIndex,
            onDestinationSelected: notifier.showTask,
            height: 60,
            destinations: [
              for (final task in paper.tasks)
                NavigationDestination(
                  icon: const Icon(Icons.edit_document),
                  label: l10n.taskWordCount(task.number, countWords(state.essays[task.number - 1])),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskPrompt extends StatelessWidget {
  const _TaskPrompt({required this.task});

  final WritingTask task;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.writingTimeAdvice(task.minutes), style: textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.prompt,
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                for (final bullet in task.bullets)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: AppSpacing.md,
                      top: AppSpacing.xs,
                    ),
                    child: Text('•  $bullet', style: textTheme.bodyLarge),
                  ),
                if (task.instructions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: AppSpacing.sm),
                    child: Text(task.instructions, style: textTheme.bodyLarge),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.writingMinWords(task.minWords), style: textTheme.bodyMedium),
          if (task.chart case final ChartSpec chart?)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: AppSpacing.md),
              child: TaskChart(spec: chart),
            ),
          if (task.imagePath case final String path?)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: AppSpacing.md),
              child: ColoredBox(color: Colors.white, child: SvgPicture.asset(path)),
            ),
        ],
      ),
    );
  }
}

class _EssayEditor extends StatefulWidget {
  const _EssayEditor({
    required this.text,
    required this.minWords,
    required this.onChanged,
    super.key,
  });

  final String text;
  final int minWords;
  final ValueChanged<String> onChanged;

  @override
  State<_EssayEditor> createState() => _EssayEditorState();
}

class _EssayEditorState extends State<_EssayEditor> {
  late final TextEditingController _controller = TextEditingController(text: widget.text);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final words = countWords(widget.text);
    final enough = words >= widget.minWords;
    return Padding(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              expands: true,
              maxLines: null,
              autocorrect: false,
              enableSuggestions: false,
              spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(hintText: context.l10n.essayHint),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(top: AppSpacing.xs),
              child: Text(
                context.l10n.wordCount(words),
                style: TextStyle(
                  color: enough
                      ? AppColors.correct
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
