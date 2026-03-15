import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/l10n/app_localizations.dart';

/// 日付境界（午前4時）を考慮した日付ユーティリティ
class AppDateUtils {
  AppDateUtils._();

  /// DateTimeから論理日付を取得する
  /// 午前4時より前の場合は前日の日付を返す
  static DateTime getLogicalDate(DateTime dateTime) {
    if (dateTime.hour < AppConstants.dateBoundaryHour) {
      return DateTime(dateTime.year, dateTime.month, dateTime.day - 1);
    }
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// 現在の論理日付を取得する
  static DateTime getLogicalToday() {
    return getLogicalDate(DateTime.now());
  }

  /// 論理日付を yyyy-MM-dd 形式の文字列に変換する
  static String formatLogicalDate(DateTime dateTime) {
    final logicalDate = getLogicalDate(dateTime);
    return '${logicalDate.year.toString().padLeft(4, '0')}-'
        '${logicalDate.month.toString().padLeft(2, '0')}-'
        '${logicalDate.day.toString().padLeft(2, '0')}';
  }

  /// 現在の論理日付を yyyy-MM-dd 形式で取得する
  static String getLogicalTodayString() {
    return formatLogicalDate(DateTime.now());
  }

  /// yyyy-MM-dd 文字列を DateTime に変換する
  static DateTime parseDate(String dateString) {
    return DateTime.parse(dateString);
  }

  /// 2つの日付が同じ論理日付かどうかを判定する
  static bool isSameLogicalDate(DateTime a, DateTime b) {
    final logicalA = getLogicalDate(a);
    final logicalB = getLogicalDate(b);
    return logicalA.year == logicalB.year &&
        logicalA.month == logicalB.month &&
        logicalA.day == logicalB.day;
  }

  /// ローカライズされた曜日名リスト（月〜日）
  static List<String> weekdays(AppLocalizations l10n) => [
    l10n.weekdayMon,
    l10n.weekdayTue,
    l10n.weekdayWed,
    l10n.weekdayThu,
    l10n.weekdayFri,
    l10n.weekdaySat,
    l10n.weekdaySun,
  ];

  /// ローカライズされた表示用文字列を返す
  static String formatDisplayDate(DateTime date, AppLocalizations l10n) {
    final weekday = weekdays(l10n)[date.weekday - 1];
    return l10n.displayDate(date.month, date.day, weekday);
  }

  /// DateTimeを yyyy-MM-dd 文字列に変換する（論理日付変換なし）
  static String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
