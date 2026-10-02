import 'package:flutter/material.dart';

@immutable
class VoltryText extends ThemeExtension<VoltryText> {
  const VoltryText({
    required this.display,
    required this.headline,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.bodySmall,
    required this.label,
  });

  static const fontFamily = 'Urbanist';
  static const _ink = Color(0xFF1F1A17);

  final TextStyle display;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle subtitle;
  final TextStyle body;
  final TextStyle bodySmall;
  final TextStyle label;

  static const light = VoltryText(
    display: TextStyle(
      fontFamily: fontFamily,
      fontSize: 38,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.14,
      height: 1,
      color: _ink,
    ),
    headline: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.48,
      height: 1.05,
      color: _ink,
    ),
    title: TextStyle(
      fontFamily: fontFamily,
      fontSize: 19,
      fontWeight: FontWeight.w800,
      height: 1.2,
      color: _ink,
    ),
    subtitle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: _ink,
    ),
    body: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.4,
      color: _ink,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.35,
      color: _ink,
    ),
    label: TextStyle(
      fontFamily: fontFamily,
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
      color: _ink,
    ),
  );

  // Single light theme: see VoltryColors.
  @override
  VoltryText copyWith() => this;

  @override
  VoltryText lerp(covariant ThemeExtension<VoltryText>? other, double t) =>
      other is VoltryText && t >= 0.5 ? other : this;
}
