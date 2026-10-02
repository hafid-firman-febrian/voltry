import 'package:flutter/material.dart';

import 'voltry_colors.dart';
import 'voltry_text.dart';

extension VoltryThemeContext on BuildContext {
  VoltryColors get colors => Theme.of(this).extension<VoltryColors>()!;
  VoltryText get textStyles => Theme.of(this).extension<VoltryText>()!;
}
