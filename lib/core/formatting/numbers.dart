import 'package:intl/intl.dart';

final _thousands = NumberFormat.decimalPattern('en_US');

/// 1450 → "1,450".
String formatNumber(int value) => _thousands.format(value);
