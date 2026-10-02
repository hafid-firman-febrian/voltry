import 'package:flutter/material.dart';

@immutable
class VoltryColors extends ThemeExtension<VoltryColors> {
  const VoltryColors({
    required this.coral,
    required this.blue,
    required this.yellow,
    required this.teal,
    required this.ink,
    required this.background,
    required this.surface,
    required this.muted,
    required this.line,
    required this.danger,
    required this.onCoral,
    required this.onBlue,
    required this.onYellow,
    required this.onTeal,
  });

  final Color coral;
  final Color blue;
  final Color yellow;
  final Color teal;
  final Color ink;
  final Color background;
  final Color surface;
  final Color muted;
  final Color line;
  final Color danger;
  final Color onCoral;
  final Color onBlue;
  final Color onYellow;
  final Color onTeal;

  static const light = VoltryColors(
    coral: Color(0xFFFF5A5F),
    blue: Color(0xFF3A86FF),
    yellow: Color(0xFFFFD23F),
    teal: Color(0xFF2EC4B6),
    ink: Color(0xFF1F1A17),
    background: Color(0xFFFFF9F4),
    surface: Color(0xFFFFFFFF),
    muted: Color(0xFF9A8F86),
    line: Color(0xFFEADFD6),
    danger: Color(0xFFE5484D),
    onCoral: Color(0xFFFFFFFF),
    onBlue: Color(0xFFFFFFFF),
    onYellow: Color(0xFF1F1A17),
    onTeal: Color(0xFF10302D),
  );

  // Voltry ships a single light theme, so there is nothing to copy or
  // interpolate between.
  @override
  VoltryColors copyWith() => this;

  @override
  VoltryColors lerp(covariant ThemeExtension<VoltryColors>? other, double t) =>
      other is VoltryColors && t >= 0.5 ? other : this;
}
