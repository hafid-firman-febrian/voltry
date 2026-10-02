import 'package:intl/intl.dart';

/// Local calendar day (midnight) that [moment] falls on.
DateTime localDay(DateTime moment) {
  final local = moment.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// "Today", "Yesterday", "Sat, 28 Sep", or "Sat, 28 Sep 2025" for other years.
String dayLabel(DateTime day, DateTime now) {
  final target = localDay(day);
  final today = localDay(now);
  // Compare as UTC dates so a daylight-saving shift (a 23h or 25h day)
  // cannot turn yesterday into "0 days ago".
  final daysAgo = DateTime.utc(
    today.year,
    today.month,
    today.day,
  ).difference(DateTime.utc(target.year, target.month, target.day)).inDays;

  if (daysAgo == 0) return 'Today';
  if (daysAgo == 1) return 'Yesterday';
  final pattern = target.year == today.year ? 'EEE, d MMM' : 'EEE, d MMM y';
  return DateFormat(pattern, 'en_US').format(target);
}

/// "Wed, 1 Oct".
String formatShortDate(DateTime moment) =>
    DateFormat('EEE, d MMM', 'en_US').format(moment.toLocal());

/// "12:30 PM".
String formatClock(DateTime moment) =>
    DateFormat('h:mm a', 'en_US').format(moment.toLocal());
