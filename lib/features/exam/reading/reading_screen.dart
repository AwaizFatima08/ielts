import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/content/content_repository.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/features/exam/reading/passage_view.dart';
import 'package:ielts_simulator/features/exam/reading/reading_notifier.dart';
import 'package:ielts_simulator/features/exam/section_key.dart';
import 'package:ielts_simulator/features/exam/widgets/exam_chrome.dart';
import 'package:ielts_simulator/features/exam/widgets/question_group_view.dart';
import 'package:ielts_simulator/ui/async_value_view.dart';
import 'package:ielts_simulator/ui/theme.dart';

class ReadingScreen extends ConsumerWidget {
  const ReadingScreen({required this.sectionKey, super.key});

  final SectionKey sectionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(readingPaperProvider((sectionKey.testId, sectionKey.module))),
    data: (paper) => _ReadingView(sectionKey: sectionKey, paper: paper),
  );
}

class _ReadingView extends ConsumerWidget {
  const _ReadingView({required this.sectionKey, required this.paper});

  final SectionKey sectionKey;
  final ReadingPaper paper;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(readingProvider(sectionKey));
    final notifier = ref.read(readingProvider(sectionKey).notifier);
    final endsAt = state.endsAt;
    final title = paper.module == ExamModule.academic ? l10n.readingAcademic : l10n.readingGeneral;
    if (endsAt == null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SectionIntro(
          title: title,
          lines: [l10n.readingIntro1, l10n.readingIntro2, l10n.readingIntro3],
          onStart: notifier.start,
        ),
      );
    }
    final passage = paper.passages[state.passageIndex];
    final sheet = AnswerSheet(answers: state.answers, onAnswer: notifier.answer);
    final questions = ListView(
      key: PageStorageKey('questions-${passage.number}'),
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: [for (final group in passage.groups) QuestionGroupView(group: group, sheet: sheet)],
    );
    final text = PassageView(key: PageStorageKey('passage-${passage.number}'), passage: passage);
    return ExamExitGuard(
      child: TimeUpListener(
        endsAt: endsAt,
        onTimeUp: notifier.submit,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.readingPassageTitle(passage.number)),
            actions: [
              CountdownChip(endsAt: endsAt),
              TextButton(
                onPressed: () async {
                  final unanswered =
                      40 - state.answers.values.where((value) => value.isNotEmpty).length;
                  if (await confirmSubmit(context, unanswered: unanswered)) await notifier.submit();
                },
                child: Text(l10n.submit, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth >= 700
                ? Row(
                    children: [
                      Expanded(child: text),
                      const VerticalDivider(width: 1),
                      Expanded(child: questions),
                    ],
                  )
                : Column(
                    children: [
                      _PhoneToggle(
                        showPassage: state.showPassage,
                        onChanged: (visible) => notifier.setShowPassage(visible: visible),
                      ),
                      Expanded(child: state.showPassage ? text : questions),
                    ],
                  ),
          ),
          bottomNavigationBar: QuestionNavigator(
            parts: [
              for (final passage in paper.passages)
                NavigatorPart(
                  label: paper.module == ExamModule.academic
                      ? l10n.passageShort(passage.number)
                      : l10n.sectionText(passage.part, passage.number),
                  numbers: [for (final group in passage.groups) ...group.numbers],
                ),
            ],
            currentPart: state.passageIndex,
            answers: state.answers,
            flagged: state.flagged,
            onSelectPart: notifier.showPassage,
            onToggleFlag: notifier.toggleFlag,
          ),
        ),
      ),
    );
  }
}

class _PhoneToggle extends StatelessWidget {
  const _PhoneToggle({required this.showPassage, required this.onChanged});

  final bool showPassage;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
    child: SegmentedButton<bool>(
      segments: [
        ButtonSegment(
          value: true,
          label: Text(context.l10n.passageTab),
          icon: const Icon(Icons.article_outlined),
        ),
        ButtonSegment(
          value: false,
          label: Text(context.l10n.questionsTab),
          icon: const Icon(Icons.quiz_outlined),
        ),
      ],
      selected: {showPassage},
      onSelectionChanged: (selection) => onChanged(selection.first),
    ),
  );
}
