import 'package:flutter/material.dart';

import '../theme/theme_context.dart';
import '../theme/voltry_radius.dart';

enum PillTone { onColor, coral }

class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.label,
    this.showBolt = false,
    this.tone = PillTone.onColor,
  });

  final String label;
  final bool showBolt;
  final PillTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground) = switch (tone) {
      PillTone.onColor => (
        colors.surface.withValues(alpha: 0.22),
        colors.onCoral,
      ),
      PillTone.coral => (colors.coral, colors.onCoral),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(VoltryRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showBolt) ...[
              Icon(Icons.bolt_rounded, size: 13, color: foreground),
              const SizedBox(width: 3),
            ],
            Text(
              label.toUpperCase(),
              style: context.textStyles.label.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
