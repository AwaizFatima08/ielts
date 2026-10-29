import 'package:flutter/material.dart';
import 'package:ielts_simulator/content/models/practice.dart';
import 'package:ielts_simulator/ui/theme.dart';

/// One criterion: pick a band 4–9 and read what that band looks like.
class CriterionRater extends StatelessWidget {
  const CriterionRater({
    required this.criterion,
    required this.band,
    required this.onRate,
    super.key,
  });

  final Criterion criterion;
  final double? band;
  final ValueChanged<double> onRate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bands = criterion.bands.keys.toList()..sort();
    final selected = band?.toInt();
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              criterion.name,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final value in bands)
                  ChoiceChip(
                    label: Text('$value'),
                    selected: selected == value,
                    onSelected: (_) => onRate(value.toDouble()),
                  ),
              ],
            ),
            for (final value in bands.reversed)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: AppSpacing.sm),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$value  ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: criterion.bands[value]),
                    ],
                  ),
                  style: textTheme.bodySmall?.copyWith(
                    color: selected == value ? Theme.of(context).colorScheme.primary : null,
                    fontWeight: selected == value ? FontWeight.w600 : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
