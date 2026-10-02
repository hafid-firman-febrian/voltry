import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/formatting/numbers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/calorie_ring.dart';
import '../../../../core/widgets/circle_icon_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/hero_card.dart';
import '../../../../core/widgets/pill_badge.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/voltry_nav_bar.dart';
import '../../../analysis/presentation/snap_meal_flow.dart';
import '../../../calorie_target/domain/calorie_target_rules.dart';
import '../../../calorie_target/presentation/controllers/calorie_target_controller.dart';
import '../../../calorie_target/presentation/widgets/calorie_target_dialog.dart';
import '../../domain/daily_summary.dart';
import '../../domain/meal_log_model.dart';
import '../controllers/meal_logs_controller.dart';
import '../widgets/meal_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(mealLogsControllerProvider);
    final now = ref.watch(clockProvider)();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch (logs) {
          AsyncData(:final value) => _HomeContent(
            today: logsOnDay(value, now),
            now: now,
          ),
          AsyncError(:final error) => ErrorView(
            message: errorMessage(error),
            onRetry: () => ref.invalidate(mealLogsControllerProvider),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.today, required this.now});

  final List<MealLog> today;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.textStyles;
    final summary = summarizeDay(today);
    final target = ref.watch(calorieTargetControllerProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        VoltryNavBar.reservedHeight,
      ),
      children: [
        Text('Today', style: text.title),
        Text(
          formatShortDate(now),
          style: text.bodySmall.copyWith(color: colors.muted),
        ),
        const SizedBox(height: 16),
        _CalorieHero(
          consumed: summary.calories,
          target: target,
          onEditTarget: () => editCalorieTarget(context, ref),
          onSnap: () => snapMeal(context, ref),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.egg_alt_outlined,
                value: '${formatNumber(summary.proteinG)} g',
                label: 'Protein',
                tone: StatTone.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                icon: Icons.bakery_dining_outlined,
                value: '${formatNumber(summary.carbsG)} g',
                label: 'Carbs',
                tone: StatTone.yellow,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                icon: Icons.water_drop_outlined,
                value: '${formatNumber(summary.fatG)} g',
                label: 'Fat',
                tone: StatTone.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text("Today's meals", style: text.subtitle),
        const SizedBox(height: 10),
        if (today.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Snap your first meal of the day.',
              textAlign: TextAlign.center,
              style: text.body.copyWith(color: colors.muted),
            ),
          )
        else
          for (final log in today)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MealTile(
                log: log,
                onTap: () => context.push(AppRoutes.meal(log.id)),
              ),
            ),
      ],
    );
  }
}

class _CalorieHero extends StatelessWidget {
  const _CalorieHero({
    required this.consumed,
    required this.target,
    required this.onEditTarget,
    required this.onSnap,
  });

  final int consumed;
  final int target;
  final VoidCallback onEditTarget;
  final VoidCallback onSnap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final progress = targetProgress(consumed: consumed, target: target);
    final soft = colors.onCoral.withValues(alpha: 0.85);

    return HeroCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PillBadge(label: 'Today', showBolt: true),
                    const SizedBox(height: 10),
                    Text(
                      formatNumber(consumed),
                      style: text.display.copyWith(color: colors.onCoral),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progress.isOver
                          ? '${formatNumber(progress.overBy)} kcal over'
                          : 'of ${formatNumber(target)} kcal',
                      style: text.body.copyWith(color: soft),
                    ),
                  ],
                ),
              ),
              CalorieRing(
                progress: progress.fraction,
                label: '${progress.percent}%',
                caption: 'of target',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleIconButton(
                icon: Icons.edit_outlined,
                tooltip: 'Edit daily target',
                onPressed: onEditTarget,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Snap a meal to log it',
                  style: text.bodySmall.copyWith(color: soft),
                ),
              ),
              CircleIconButton(
                icon: Icons.photo_camera_rounded,
                tooltip: 'Snap a meal',
                onPressed: onSnap,
                size: 56,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
