import 'package:flutter/foundation.dart';

import '../../../core/formatting/dates.dart';
import 'meal_log_model.dart';

@immutable
class DailySummary {
  const DailySummary({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  static const empty = DailySummary(
    calories: 0,
    proteinG: 0,
    carbsG: 0,
    fatG: 0,
  );

  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;

  @override
  bool operator ==(Object other) =>
      other is DailySummary &&
      other.calories == calories &&
      other.proteinG == proteinG &&
      other.carbsG == carbsG &&
      other.fatG == fatG;

  @override
  int get hashCode => Object.hash(calories, proteinG, carbsG, fatG);
}

@immutable
class DayGroup {
  const DayGroup({required this.day, required this.logs});

  /// Local midnight of the day.
  final DateTime day;

  /// Newest first.
  final List<MealLog> logs;

  DailySummary get summary => summarizeDay(logs);
}

DailySummary summarizeDay(Iterable<MealLog> logs) => logs.fold(
  DailySummary.empty,
  (total, log) => DailySummary(
    calories: total.calories + log.calories,
    proteinG: total.proteinG + log.proteinG,
    carbsG: total.carbsG + log.carbsG,
    fatG: total.fatG + log.fatG,
  ),
);

int newestFirst(MealLog a, MealLog b) => b.createdAt.compareTo(a.createdAt);

/// Logs whose local calendar day equals the local day of [now], newest first.
List<MealLog> logsOnDay(Iterable<MealLog> logs, DateTime now) {
  final today = localDay(now);
  return logs.where((log) => localDay(log.createdAt) == today).toList()
    ..sort(newestFirst);
}

/// Groups logs by local calendar day. Days and the logs inside each day are
/// newest first.
List<DayGroup> groupByDay(Iterable<MealLog> logs) {
  final sorted = logs.toList()..sort(newestFirst);
  final groups = <DayGroup>[];
  for (final log in sorted) {
    final day = localDay(log.createdAt);
    if (groups.isNotEmpty && groups.last.day == day) {
      groups.last.logs.add(log);
    } else {
      groups.add(DayGroup(day: day, logs: [log]));
    }
  }
  return groups;
}
