import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme_context.dart';
import '../widgets/voltry_nav_bar.dart';

/// Hosts the Home and History tabs under the floating nav bar.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: VoltryNavBar(
        currentIndex: shell.currentIndex,
        // Tapping the active tab again returns it to its first page.
        onSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
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
