import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/theme_context.dart';
import '../theme/voltry_radius.dart';

class VoltryNavItem {
  const VoltryNavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color onColor;
}

/// The app's main action, shown as a raised button between the tabs.
class VoltryNavAction {
  const VoltryNavAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
}

class VoltryNavBar extends StatelessWidget {
  const VoltryNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    this.centerAction,
  });

  /// Space a scrollable page must leave at its bottom so the floating bar
  /// never covers the last item.
  static const reservedHeight = 120.0;

  static const _height = 88.0;
  static const _barHeight = 60.0;
  static const _activeSize = 52.0;
  static const _actionSize = 64.0;

  final List<VoltryNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final VoltryNavAction? centerAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(48, 0, 48, 12),
        child: SizedBox(
          height: _height,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(VoltryRadius.pill),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    height: _barHeight,
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(VoltryRadius.pill),
                      border: Border.all(color: colors.line),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final (index, item) in items.indexed) ...[
                    if (centerAction case final action?
                        when index == items.length ~/ 2)
                      Expanded(child: _CenterActionButton(action: action)),
                    Expanded(
                      child: _NavButton(
                        item: item,
                        active: index == currentIndex,
                        onTap: () => onSelected(index),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final VoltryNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // The active circle sits 14px above the bottom so its top edge pokes
    // 6px out of the 60px bar, as in the Candy Sport mockup.
    final Widget icon = active
        ? Container(
            width: VoltryNavBar._activeSize,
            height: VoltryNavBar._activeSize,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: item.color.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(item.icon, color: item.onColor),
          )
        : Icon(item.icon, color: colors.muted);

    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: VoltryNavBar._height,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: active ? 14 : 18),
              child: ExcludeSemantics(child: icon),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterActionButton extends StatelessWidget {
  const _CenterActionButton({required this.action});

  final VoltryNavAction action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // 18px from the bottom puts the 64px circle's top edge 22px above the
    // 60px bar, clearly higher than the active tab's 6px.
    return Semantics(
      button: true,
      child: Tooltip(
        message: action.tooltip,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: action.onPressed,
          child: SizedBox(
            height: VoltryNavBar._height,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Container(
                  width: VoltryNavBar._actionSize,
                  height: VoltryNavBar._actionSize,
                  decoration: BoxDecoration(
                    color: colors.ink,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.ink.withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(action.icon, size: 28, color: colors.surface),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
