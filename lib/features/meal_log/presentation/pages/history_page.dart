import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/formatting/numbers.dart';
import '../../../../core/providers/today_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/theme/voltry_radius.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/show_message.dart';
import '../../../../core/widgets/voltry_nav_bar.dart';
import '../../domain/daily_summary.dart';
import '../../domain/meal_log_model.dart';
import '../controllers/meal_logs_controller.dart';
import '../widgets/meal_tile.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(mealLogsControllerProvider);
    final today = ref.watch(todayProvider);
    final text = context.textStyles;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch (logs) {
          AsyncData(:final value) => ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              VoltryNavBar.reservedHeight,
            ),
            children: [
              Text('History', style: text.title),
              if (value.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Text(
                    'No meals yet. Snap your first meal from Home.',
                    textAlign: TextAlign.center,
                    style: text.body.copyWith(color: context.colors.muted),
                  ),
                ),
              for (final group in groupByDay(value)) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    '${dayLabel(group.day, today)} · ${formatNumber(group.summary.calories)} kcal',
                    style: text.subtitle,
                  ),
                ),
                for (final log in group.logs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Dismissible(
                      key: ValueKey(log.id),
                      direction: DismissDirection.endToStart,
                      background: const _DeleteBackground(),
                      onDismissed: (_) => _delete(context, ref, log),
                      child: MealTile(
                        log: log,
                        onTap: () => context.push(AppRoutes.meal(log.id)),
                      ),
                    ),
                  ),
              ],
            ],
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

  Future<void> _delete(BuildContext context, WidgetRef ref, MealLog log) async {
    final controller = ref.read(mealLogsControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await controller.delete(log);
    } on AppException catch (error) {
      if (context.mounted) showMessage(context, errorMessage(error));
      return;
    }

    messenger.hideCurrentSnackBar();
    final reason = await messenger
        .showSnackBar(
          SnackBar(
            content: const Text('Meal deleted'),
            // A SnackBar with an action stays up until dismissed unless
            // persist is false, and the photo is only purged once it closes.
            persist: false,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => _undo(messenger, controller, log),
            ),
          ),
        )
        .closed;
    if (reason != SnackBarClosedReason.action) {
      await controller.purgePhoto(log);
    }
  }

  Future<void> _undo(
    ScaffoldMessengerState messenger,
    MealLogsController controller,
    MealLog log,
  ) async {
    try {
      await controller.restore(log);
    } on AppException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(error))));
    }
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.danger,
        borderRadius: BorderRadius.circular(VoltryRadius.listTile),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Icon(Icons.delete_outline_rounded, color: colors.surface),
        ),
      ),
    );
  }
}
