import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analysis/presentation/snap_meal_flow.dart';
import '../theme/theme_context.dart';
import '../widgets/voltry_nav_bar.dart';

/// Hosts the Home and History tabs under the floating nav bar, with the
/// camera between them so a meal can be snapped from either tab.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: VoltryNavBar(
        currentIndex: shell.currentIndex,
        // Tapping the active tab again returns it to its first page.
        onSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        centerAction: VoltryNavAction(
          icon: Icons.photo_camera_rounded,
          tooltip: 'Snap a meal',
          onPressed: () => snapMeal(context, ref),
        ),
        items: [
          VoltryNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            color: colors.coral,
            onColor: colors.onCoral,
          ),
          VoltryNavItem(
            icon: Icons.history_rounded,
            label: 'History',
            color: colors.blue,
            onColor: colors.onBlue,
          ),
        ],
      ),
    );
  }
}
