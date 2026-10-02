import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../formatting/dates.dart';
import 'core_providers.dart';

final todayProvider = NotifierProvider<TodayController, DateTime>(
  TodayController.new,
);

/// The local calendar day (midnight) the app treats as "today". It moves on
/// at local midnight and whenever the app returns to the foreground, so a
/// Home left open or suspended overnight never keeps yesterday's totals.
class TodayController extends Notifier<DateTime> {
  Timer? _midnight;

  @override
  DateTime build() {
    final lifecycle = AppLifecycleListener(onResume: refresh);
    ref.onDispose(() {
      lifecycle.dispose();
      _midnight?.cancel();
    });
    return _startDay(ref.watch(clockProvider)());
  }

  void refresh() => state = _startDay(ref.read(clockProvider)());

  DateTime _startDay(DateTime now) {
    final today = localDay(now);
    // DateTime(y, m, d + 1) is the next local midnight even across a
    // daylight-saving change, unlike adding Duration(days: 1).
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    _midnight?.cancel();
    _midnight = Timer(tomorrow.difference(now.toLocal()), refresh);
    return today;
  }
}
