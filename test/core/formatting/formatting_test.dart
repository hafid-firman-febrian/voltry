import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/formatting/dates.dart';
import 'package:voltry/core/formatting/numbers.dart';

void main() {
  group('formatNumber', () {
    test('adds thousands separators', () {
      expect(formatNumber(950), '950');
      expect(formatNumber(1450), '1,450');
    });
  });

  group('localDay', () {
    test('drops the time of day', () {
      expect(localDay(DateTime(2026, 10, 1, 23, 59)), DateTime(2026, 10, 1));
    });

    test('converts UTC moments to the local calendar day', () {
      final utc = DateTime.utc(2026, 10, 1, 12);
      final local = utc.toLocal();
      expect(localDay(utc), DateTime(local.year, local.month, local.day));
    });
  });

  group('dayLabel', () {
    final now = DateTime(2026, 10, 1, 9);

    test('names today and yesterday', () {
      expect(dayLabel(DateTime(2026, 10, 1, 0, 5), now), 'Today');
      expect(dayLabel(DateTime(2026, 9, 30, 23, 55), now), 'Yesterday');
    });

    test('uses weekday, day and month for older days in the same year', () {
      expect(dayLabel(DateTime(2026, 9, 26, 12), now), 'Sat, 26 Sep');
    });

    test('adds the year for days in another year', () {
      expect(dayLabel(DateTime(2025, 12, 31, 12), now), 'Wed, 31 Dec 2025');
    });
  });

  test('formatShortDate and formatClock use English formats', () {
    final moment = DateTime(2026, 10, 1, 12, 30);
    expect(formatShortDate(moment), 'Thu, 1 Oct');
    expect(formatClock(moment), '12:30 PM');
  });
}
