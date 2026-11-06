import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/date_formatter.dart';

void main() {
  group('formatPostDate', () {
    test('returns "Baru saja" for a just-now date', () {
      final now = DateTime(2026, 11, 6, 10, 0, 0);
      final result = formatPostDate(
        now,
        now: now.add(const Duration(seconds: 30)),
      );
      expect(result, 'Baru saja');
    });

    test('returns minutes for under an hour', () {
      final now = DateTime(2026, 11, 6, 10, 0, 0);
      final result = formatPostDate(
        now.subtract(const Duration(minutes: 5)),
        now: now,
      );
      expect(result, '5 menit lalu');
    });

    test('returns hours for under 24 hours', () {
      final now = DateTime(2026, 11, 6, 10, 0, 0);
      final result = formatPostDate(
        now.subtract(const Duration(hours: 3)),
        now: now,
      );
      expect(result, '3 jam lalu');
    });

    test('returns days for under 7 days', () {
      final now = DateTime(2026, 11, 6, 10, 0, 0);
      final result = formatPostDate(
        now.subtract(const Duration(days: 5)),
        now: now,
      );
      expect(result, '5 hari lalu');
    });

    test('returns full date for more than 7 days', () {
      final date = DateTime(2026, 11, 6);
      final result = formatPostDate(date, now: DateTime(2026, 11, 20));
      expect(result, '6 November 2026');
    });

    test('returns empty string for null', () {
      expect(formatPostDate(null), '');
    });

    test('returns full date when the reference date is later', () {
      final date = DateTime(2020, 1, 2);
      final result = formatPostDate(date, now: DateTime(2021, 1, 1));
      expect(result, '2 Januari 2020');
    });
  });

  group('formatFullDate', () {
    test('formats a known date in Indonesian month names', () {
      expect(formatFullDate(DateTime(2026, 11, 6)), '6 November 2026');
      expect(formatFullDate(DateTime(2026, 3, 1)), '1 Maret 2026');
    });
  });
}
