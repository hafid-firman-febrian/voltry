import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 40,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  // 40 instead of the spec's 38 so the touch target is a little easier to hit.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.surface,
        shape: CircleBorder(side: BorderSide(color: colors.line)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: Icon(
              icon,
              size: size / 2,
              color: enabled ? colors.ink : colors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
