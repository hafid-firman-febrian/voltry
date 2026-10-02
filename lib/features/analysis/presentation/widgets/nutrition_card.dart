import 'package:flutter/material.dart';

import '../../../../core/formatting/numbers.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/theme/voltry_radius.dart';
import '../../../../core/widgets/pill_badge.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../domain/nutrition_analysis_model.dart';

/// The AI estimate, shared by the Analyze page and Meal detail.
class NutritionCard extends StatelessWidget {
  const NutritionCard({super.key, required this.analysis});

  final NutritionAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(VoltryRadius.card),
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PillBadge(
            label: 'AI estimate',
            showBolt: true,
            tone: PillTone.coral,
          ),
          const SizedBox(height: 10),
          Text(analysis.foodName, style: text.headline),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(formatNumber(analysis.calories), style: text.display),
              const SizedBox(width: 6),
              Text('kcal', style: text.subtitle.copyWith(color: colors.muted)),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MacroChip(
                label: 'Protein',
                grams: analysis.proteinG,
                tone: StatTone.blue,
              ),
              _MacroChip(
                label: 'Carbs',
                grams: analysis.carbsG,
                tone: StatTone.yellow,
              ),
              _MacroChip(
                label: 'Fat',
                grams: analysis.fatG,
                tone: StatTone.teal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({
    required this.label,
    required this.grams,
    required this.tone,
  });

  final String label;
  final int grams;
  final StatTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = tone.resolve(context.colors);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(VoltryRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          '$label ${formatNumber(grams)} g',
          style: context.textStyles.body.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
