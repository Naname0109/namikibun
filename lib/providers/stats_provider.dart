import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/models/mood_record.dart';
import 'package:namikibun/services/database_service.dart';
import 'package:namikibun/utils/date_utils.dart';

/// 統計画面の表示月（カレンダーとは独立）
final selectedStatsMonthProvider = StateProvider<DateTime>((ref) {
  final now = AppDateUtils.getLogicalToday();
  return DateTime(now.year, now.month);
});

/// 統計データモデル
class MonthlyStats {
  final Map<String, double> slotAverages; // slotId -> 平均気分
  final Map<String, String> slotNames; // slotId -> スロット名
  final Map<String, double> dailyAverages; // date -> 日別平均気分
  final MoodRecord? bestRecord; // 最高気分のレコード
  final MoodRecord? worstRecord; // 最低気分のレコード
  final int totalRecordDays; // 記録日数
  final Map<String, int> tagCounts; // tag -> 使用回数
  final Map<String, double> tagAverages; // tag -> 平均気分

  const MonthlyStats({
    required this.slotAverages,
    required this.slotNames,
    required this.dailyAverages,
    this.bestRecord,
    this.worstRecord,
    required this.totalRecordDays,
    this.tagCounts = const {},
    this.tagAverages = const {},
  });
}

/// 統計プラス詳細分析モデル
class DetailedStats {
  final double? thisMonthAverage;
  final double? lastMonthAverage;
  final Map<String, double> tagCorrelations; // tag -> 全体平均との差分
  final Map<int, double> weekdayPattern; // weekday(1-7) -> 平均気分

  const DetailedStats({
    this.thisMonthAverage,
    this.lastMonthAverage,
    this.tagCorrelations = const {},
    this.weekdayPattern = const {},
  });
}

/// 週間統計データモデル
class WeeklyStats {
  final double thisWeekAverage;
  final double? lastWeekAverage;
  final int thisWeekRecordCount;
  final Map<String, double> dailyAverages; // date -> 平均気分

  const WeeklyStats({
    required this.thisWeekAverage,
    this.lastWeekAverage,
    required this.thisWeekRecordCount,
    required this.dailyAverages,
  });

  /// 先週比の変化（正=改善、負=悪化）
  double? get weekOverWeekChange {
    if (lastWeekAverage == null) return null;
    return thisWeekAverage - lastWeekAverage!;
  }
}

/// 月間統計Provider
final monthlyStatsProvider = FutureProvider<MonthlyStats>((ref) async {
  final month = ref.watch(selectedStatsMonthProvider);
  final startDate = DateTime(month.year, month.month, 1);
  final endDate = DateTime(month.year, month.month + 1, 0);

  final startStr = AppDateUtils.formatDate(startDate);
  final endStr = AppDateUtils.formatDate(endDate);

  final db = DatabaseService();
  final records = await db.getMoodRecordsByDateRange(startStr, endStr);
  final slots = await db.getActiveSlots();

  // スロット名マップ
  final slotNames = <String, String>{};
  for (final slot in slots) {
    slotNames[slot.id] = slot.name;
  }

  // スロット別の平均気分
  final slotSums = <String, int>{};
  final slotCounts = <String, int>{};
  for (final record in records) {
    slotSums[record.slotId] =
        (slotSums[record.slotId] ?? 0) + record.moodLevel;
    slotCounts[record.slotId] = (slotCounts[record.slotId] ?? 0) + 1;
  }
  final slotAverages = <String, double>{};
  for (final slotId in slotSums.keys) {
    slotAverages[slotId] = slotSums[slotId]! / slotCounts[slotId]!;
  }

  // 日別の平均気分
  final dailySums = <String, int>{};
  final dailyCounts = <String, int>{};
  for (final record in records) {
    dailySums[record.date] =
        (dailySums[record.date] ?? 0) + record.moodLevel;
    dailyCounts[record.date] = (dailyCounts[record.date] ?? 0) + 1;
  }
  final dailyAverages = <String, double>{};
  for (final date in dailySums.keys) {
    dailyAverages[date] = dailySums[date]! / dailyCounts[date]!;
  }

  // ハイライト（最高/最低）
  MoodRecord? best;
  MoodRecord? worst;
  for (final record in records) {
    if (best == null || record.moodLevel > best.moodLevel) {
      best = record;
    }
    if (worst == null || record.moodLevel < worst.moodLevel) {
      worst = record;
    }
  }

  // タグ分析
  final tagCounts = <String, int>{};
  final tagMoodSums = <String, int>{};
  final tagMoodCounts = <String, int>{};
  for (final record in records) {
    for (final tag in record.tags) {
      tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      tagMoodSums[tag] = (tagMoodSums[tag] ?? 0) + record.moodLevel;
      tagMoodCounts[tag] = (tagMoodCounts[tag] ?? 0) + 1;
    }
  }
  final tagAverages = <String, double>{};
  for (final tag in tagMoodSums.keys) {
    tagAverages[tag] = tagMoodSums[tag]! / tagMoodCounts[tag]!;
  }

  return MonthlyStats(
    slotAverages: slotAverages,
    slotNames: slotNames,
    dailyAverages: dailyAverages,
    bestRecord: best,
    worstRecord: worst,
    totalRecordDays: dailyCounts.length,
    tagCounts: tagCounts,
    tagAverages: tagAverages,
  );
});

/// 週間統計Provider
final weeklyStatsProvider = FutureProvider<WeeklyStats>((ref) async {
  final today = AppDateUtils.getLogicalToday();

  // 今週の月曜日を計算
  final weekday = today.weekday; // 1=月, 7=日
  final thisWeekStart = today.subtract(Duration(days: weekday - 1));
  final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
  final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

  final db = DatabaseService();

  // 今週のレコード
  final thisWeekRecords = await db.getMoodRecordsByDateRange(
    AppDateUtils.formatDate(thisWeekStart),
    AppDateUtils.formatDate(today),
  );

  // 先週のレコード
  final lastWeekRecords = await db.getMoodRecordsByDateRange(
    AppDateUtils.formatDate(lastWeekStart),
    AppDateUtils.formatDate(lastWeekEnd),
  );

  // 今週の平均
  double thisWeekAvg = 0;
  if (thisWeekRecords.isNotEmpty) {
    thisWeekAvg = thisWeekRecords.map((r) => r.moodLevel).reduce((a, b) => a + b) /
        thisWeekRecords.length;
  }

  // 先週の平均
  double? lastWeekAvg;
  if (lastWeekRecords.isNotEmpty) {
    lastWeekAvg = lastWeekRecords.map((r) => r.moodLevel).reduce((a, b) => a + b) /
        lastWeekRecords.length;
  }

  // 今週の日別平均
  final dailySums = <String, int>{};
  final dailyCounts = <String, int>{};
  for (final record in thisWeekRecords) {
    dailySums[record.date] = (dailySums[record.date] ?? 0) + record.moodLevel;
    dailyCounts[record.date] = (dailyCounts[record.date] ?? 0) + 1;
  }
  final dailyAverages = <String, double>{};
  for (final date in dailySums.keys) {
    dailyAverages[date] = dailySums[date]! / dailyCounts[date]!;
  }

  return WeeklyStats(
    thisWeekAverage: thisWeekAvg,
    lastWeekAverage: lastWeekAvg,
    thisWeekRecordCount: thisWeekRecords.length,
    dailyAverages: dailyAverages,
  );
});

/// 統計プラス詳細分析Provider
final detailedStatsProvider = FutureProvider<DetailedStats>((ref) async {
  final month = ref.watch(selectedStatsMonthProvider);
  final db = DatabaseService();

  // 今月の範囲
  final thisStart = DateTime(month.year, month.month, 1);
  final thisEnd = DateTime(month.year, month.month + 1, 0);
  final thisStartStr = AppDateUtils.formatDate(thisStart);
  final thisEndStr = AppDateUtils.formatDate(thisEnd);

  // 先月の範囲
  final lastStart = DateTime(month.year, month.month - 1, 1);
  final lastEnd = DateTime(month.year, month.month, 0);
  final lastStartStr = AppDateUtils.formatDate(lastStart);
  final lastEndStr = AppDateUtils.formatDate(lastEnd);

  // 月別比較
  final thisMonthAvg = await db.getMonthAverage(thisStartStr, thisEndStr);
  final lastMonthAvg = await db.getMonthAverage(lastStartStr, lastEndStr);

  // 曜日別パターン
  final weekdayPattern = await db.getWeekdayAverages(thisStartStr, thisEndStr);

  // タグ相関（全体平均との差分）
  final records = await db.getMoodRecordsByDateRange(thisStartStr, thisEndStr);
  final overallAvg = thisMonthAvg ?? 3.0;

  final tagMoodSums = <String, int>{};
  final tagMoodCounts = <String, int>{};
  for (final record in records) {
    for (final tag in record.tags) {
      tagMoodSums[tag] = (tagMoodSums[tag] ?? 0) + record.moodLevel;
      tagMoodCounts[tag] = (tagMoodCounts[tag] ?? 0) + 1;
    }
  }
  final tagCorrelations = <String, double>{};
  for (final tag in tagMoodSums.keys) {
    final tagAvg = tagMoodSums[tag]! / tagMoodCounts[tag]!;
    tagCorrelations[tag] = tagAvg - overallAvg;
  }

  return DetailedStats(
    thisMonthAverage: thisMonthAvg,
    lastMonthAverage: lastMonthAvg,
    tagCorrelations: tagCorrelations,
    weekdayPattern: weekdayPattern,
  );
});
