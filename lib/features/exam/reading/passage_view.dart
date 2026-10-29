import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ielts_simulator/content/models/papers.dart';
import 'package:ielts_simulator/ui/theme.dart';

/// A reading text with its title and lettered paragraphs. Text is
/// selectable so candidates can mark it with the system selection tools.
class PassageView extends StatelessWidget {
  const PassageView({required this.passage, super.key});

  final ReadingPassage passage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SelectionArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          if (passage.title.isNotEmpty)
            Semantics(
              header: true,
              child: Text(
                passage.title,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          if (passage.subtitle case final String subtitle?)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: AppSpacing.xs),
              child: Text(
                subtitle,
                style: textTheme.titleSmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          if (passage.imagePath case final String path?)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.md),
              child: path.endsWith('.svg') ? SvgPicture.asset(path) : Image.asset(path),
            ),
          const SizedBox(height: AppSpacing.md),
          for (final paragraph in passage.paragraphs) _ParagraphView(paragraph: paragraph),
        ],
      ),
    );
  }
}

class _ParagraphView extends StatelessWidget {
  const _ParagraphView({required this.paragraph});

  final Paragraph paragraph;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
      child: paragraph.label.isEmpty
          ? Text(paragraph.text, style: style)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(paragraph.label, style: style?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Expanded(child: Text(paragraph.text, style: style)),
              ],
            ),
    );
  }
}
