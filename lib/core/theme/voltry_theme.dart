import 'package:flutter/material.dart';

import 'voltry_colors.dart';
import 'voltry_radius.dart';
import 'voltry_text.dart';

ThemeData buildVoltryTheme() {
  const colors = VoltryColors.light;
  const text = VoltryText.light;

  final scheme = ColorScheme.fromSeed(seedColor: colors.coral).copyWith(
    primary: colors.coral,
    onPrimary: colors.onCoral,
    secondary: colors.blue,
    onSecondary: colors.onBlue,
    tertiary: colors.teal,
    onTertiary: colors.onTeal,
    surface: colors.surface,
    onSurface: colors.ink,
    error: colors.danger,
    outline: colors.line,
  );

  OutlineInputBorder pillBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(VoltryRadius.pill),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.background,
    fontFamily: VoltryText.fontFamily,
    textTheme: TextTheme(
      displayLarge: text.display,
      headlineMedium: text.headline,
      titleLarge: text.title,
      titleMedium: text.subtitle,
      bodyMedium: text.body,
      bodySmall: text.bodySmall,
      labelSmall: text.label,
    ),
    extensions: const [colors, text],
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.ink,
      surfaceTintColor: colors.background,
      elevation: 0,
      titleTextStyle: text.title,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: text.body.copyWith(color: colors.muted),
      suffixStyle: text.body.copyWith(color: colors.muted),
      errorStyle: text.bodySmall.copyWith(color: colors.danger),
      border: pillBorder(colors.line),
      enabledBorder: pillBorder(colors.line),
      focusedBorder: pillBorder(colors.coral, width: 1.5),
      errorBorder: pillBorder(colors.danger),
      focusedErrorBorder: pillBorder(colors.danger, width: 1.5),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.ink,
      contentTextStyle: text.body.copyWith(color: colors.surface),
      actionTextColor: colors.yellow,
      shape: const StadiumBorder(),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      showDragHandle: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      titleTextStyle: text.title,
      contentTextStyle: text.body,
    ),
  );
}
