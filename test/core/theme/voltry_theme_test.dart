import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/theme/voltry_colors.dart';
import 'package:voltry/core/theme/voltry_text.dart';
import 'package:voltry/core/theme/voltry_theme.dart';

void main() {
  final theme = buildVoltryTheme();

  test('maps Candy Sport colors onto the Material color scheme', () {
    expect(theme.colorScheme.primary, const Color(0xFFFF5A5F));
    expect(theme.colorScheme.secondary, const Color(0xFF3A86FF));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFFFF9F4));
  });

  test('exposes the design tokens as theme extensions', () {
    expect(theme.extension<VoltryColors>(), VoltryColors.light);
    expect(theme.extension<VoltryText>(), VoltryText.light);
  });

  test('uses Urbanist with the spec type scale', () {
    final text = theme.extension<VoltryText>()!;
    expect(text.display.fontSize, 38);
    expect(text.display.fontWeight, FontWeight.w900);
    expect(text.headline.fontSize, 24);
    expect(text.label.fontWeight, FontWeight.w800);
    expect(theme.textTheme.bodyMedium!.fontFamily, 'Urbanist');
  });
}
