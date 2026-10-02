import 'package:flutter/material.dart';

import '../theme/theme_context.dart';
import '../theme/voltry_colors.dart';
import '../theme/voltry_radius.dart';

enum StatTone { blue, yellow, teal }

extension StatToneColors on StatTone {
  /// (background, foreground) for this tone.
  (Color, Color) resolve(VoltryColors colors) => switch (this) {
    StatTone.blue => (colors.blue, colors.onBlue),
    StatTone.yellow => (colors.yellow, colors.onYellow),
    StatTone.teal => (colors.teal, colors.onTeal),
  };
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String value;
  final String label;
  final StatTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final (background, foreground) = tone.resolve(colors);

    return Container(
      height: 108,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(VoltryRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(icon, size: 16, color: colors.ink),
            ),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.title.copyWith(color: foreground),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall.copyWith(
              color: foreground.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
