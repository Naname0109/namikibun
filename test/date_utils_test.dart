import 'package:flutter_test/flutter_test.dart';
import 'package:namikibun/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    group('getLogicalDate', () {
      test('午前4時以降はその日の日付を返す', () {
        final dt = DateTime(2026, 3, 10, 5, 0);
        final result = AppDateUtils.getLogicalDate(dt);
        expect(result, DateTime(2026, 3, 10));
      });

      test('午前4時ちょうどはその日の日付を返す', () {
        final dt = DateTime(2026, 3, 10, 4, 0);
        final result = AppDateUtils.getLogicalDate(dt);
        expect(result, DateTime(2026, 3, 10));
      });

      test('午前4時より前は前日の日付を返す', () {
        final dt = DateTime(2026, 3, 10, 3, 59);
        final result = AppDateUtils.getLogicalDate(dt);
        expect(result, DateTime(2026, 3, 9));
      });

      test('深夜0時は前日の日付を返す', () {
        final dt = DateTime(2026, 3, 10, 0, 0);
        final result = AppDateUtils.getLogicalDate(dt);
        expect(result, DateTime(2026, 3, 9));
      });

      test('月をまたぐ場合も正しく前日を返す', () {
        final dt = DateTime(2026, 4, 1, 2, 0);
        final result = AppDateUtils.getLogicalDate(dt);
        expect(result, DateTime(2026, 3, 31));
      });

      test('年をまたぐ場合も正しく前日を返す', () {
        final dt = DateTime(2026, 1, 1, 1, 0);
        final result = AppDateUtils.getLogicalDate(dt);
        expect(result, DateTime(2025, 12, 31));
      });
    });

    group('formatLogicalDate', () {
      test('午前4時以降はその日の文字列を返す', () {
        final dt = DateTime(2026, 3, 10, 10, 0);
        expect(AppDateUtils.formatLogicalDate(dt), '2026-03-10');
      });

      test('午前4時より前は前日の文字列を返す', () {
        final dt = DateTime(2026, 3, 10, 2, 0);
        expect(AppDateUtils.formatLogicalDate(dt), '2026-03-09');
      });
    });

    group('isSameLogicalDate', () {
      test('同じ日の昼と夜は同じ論理日付', () {
        final a = DateTime(2026, 3, 10, 10, 0);
        final b = DateTime(2026, 3, 10, 22, 0);
        expect(AppDateUtils.isSameLogicalDate(a, b), true);
      });

      test('深夜2時と前日22時は同じ論理日付', () {
        final a = DateTime(2026, 3, 11, 2, 0); // 論理的には3/10
        final b = DateTime(2026, 3, 10, 22, 0); // 論理的には3/10
        expect(AppDateUtils.isSameLogicalDate(a, b), true);
      });

      test('異なる論理日付は異なると判定', () {
        final a = DateTime(2026, 3, 10, 10, 0);
        final b = DateTime(2026, 3, 11, 10, 0);
        expect(AppDateUtils.isSameLogicalDate(a, b), false);
      });
    });

    group('formatDisplayDate', () {
      test('正しい表示形式を返す', () {
        // 2026年3月10日は火曜日
        final dt = DateTime(2026, 3, 10);
        expect(AppDateUtils.formatDisplayDate(dt), '3月10日 火曜日');
      });
    });

    group('formatDate', () {
      test('yyyy-MM-dd形式で返す', () {
        final dt = DateTime(2026, 1, 5);
        expect(AppDateUtils.formatDate(dt), '2026-01-05');
      });
    });

    group('parseDate', () {
      test('yyyy-MM-dd文字列をDateTimeに変換する', () {
        final result = AppDateUtils.parseDate('2026-03-10');
        expect(result.year, 2026);
        expect(result.month, 3);
        expect(result.day, 10);
      });
    });
  });
}
