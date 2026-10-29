import 'package:flutter/material.dart';
import 'package:ielts_simulator/app.dart';
import 'package:ielts_simulator/ui/theme.dart';

/// Marking shown under a question in review mode: right/wrong, the
/// accepted answer and why.
class ReviewNote extends StatelessWidget {
  const ReviewNote({
    required this.isCorrect,
    required this.given,
    required this.accepted,
    required this.explanation,
    super.key,
  });

  final bool isCorrect;
  final String given;
  final List<String> accepted;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = isCorrect ? AppColors.correct : AppColors.incorrect;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: AppSpacing.xs, bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: color, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  isCorrect
                      ? l10n.reviewCorrect
                      : l10n.reviewIncorrect(
                          given.isEmpty ? l10n.reviewBlank : given,
                          accepted.join(' / '),
                        ),
                  style: textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (explanation case final String text?)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 22, top: 2),
              child: Text(text, style: textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}
