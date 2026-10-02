import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/providers/today_provider.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/theme/voltry_radius.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/show_message.dart';
import '../../../analysis/presentation/widgets/nutrition_card.dart';
import '../../domain/meal_log_model.dart';
import '../controllers/meal_logs_controller.dart';
import '../widgets/meal_photo.dart';

class MealDetailPage extends ConsumerWidget {
  const MealDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(mealLogsControllerProvider);
    final today = ref.watch(todayProvider);
    final colors = context.colors;
    final text = context.textStyles;

    return Scaffold(
      appBar: AppBar(title: const Text('Meal')),
      body: SafeArea(
        child: switch (logs) {
          AsyncData(:final value) => switch (value
              .where((log) => log.id == id)
              .firstOrNull) {
            null => Center(
              child: Text(
                'This meal is no longer in your history.',
                style: text.body.copyWith(color: colors.muted),
              ),
            ),
            final log => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: MealPhoto(
                    fileName: log.photoFileName,
                    radius: VoltryRadius.cardLarge,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${dayLabel(log.createdAt, today)} · ${formatClock(log.createdAt)}',
                  style: text.bodySmall.copyWith(color: colors.muted),
                ),
                const SizedBox(height: 8),
                NutritionCard(analysis: log.nutrition),
                const SizedBox(height: 16),
                SecondaryButton(
                  label: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  destructive: true,
                  onPressed: () => _confirmDelete(context, ref, log),
                ),
              ],
            ),
          },
          AsyncError(:final error) => ErrorView(
            message: errorMessage(error),
            onRetry: () => ref.invalidate(mealLogsControllerProvider),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MealLog log,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this meal?'),
        content: const Text('It will be removed from your history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.colors.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(mealLogsControllerProvider.notifier)
          .deletePermanently(log);
      if (context.mounted) context.pop();
    } on AppException catch (error) {
      if (context.mounted) showMessage(context, errorMessage(error));
    }
  }
}
