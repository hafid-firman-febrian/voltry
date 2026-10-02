import 'package:flutter/material.dart';

import '../../../../core/formatting/dates.dart';
import '../../../../core/formatting/numbers.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/theme/voltry_radius.dart';
import '../../domain/meal_log_model.dart';
import 'meal_photo.dart';

class MealTile extends StatelessWidget {
  const MealTile({super.key, required this.log, required this.onTap});

  final MealLog log;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final radius = BorderRadius.circular(VoltryRadius.listTile);

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: colors.line),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              MealPhoto(fileName: log.photoFileName, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.foodName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.subtitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatClock(log.createdAt),
                      style: text.bodySmall.copyWith(color: colors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('${formatNumber(log.calories)} kcal', style: text.subtitle),
            ],
          ),
        ),
      ),
    );
  }
}
