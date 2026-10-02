import 'package:flutter/material.dart';

import '../theme/theme_context.dart';
import '../theme/voltry_radius.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(VoltryRadius.cardLarge),
      child: ColoredBox(
        color: colors.coral,
        child: Stack(
          children: [
            Positioned(
              right: -24,
              top: -12,
              child: Icon(
                Icons.bolt_rounded,
                size: 132,
                color: colors.onCoral.withValues(alpha: 0.16),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(padding: const EdgeInsets.all(16), child: child),
            ),
          ],
        ),
      ),
    );
  }
}
