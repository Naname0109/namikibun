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

  const MonthlyStats({
    required this.slotAverages,
    required this.slotNames,
    required this.dailyAverages,
    this.bestRecord,
    this.worstRecord,
    required this.totalRecordDays,
  });
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

  return MonthlyStats(
    slotAverages: slotAverages,
    slotNames: slotNames,
    dailyAverages: dailyAverages,
    bestRecord: best,
    worstRecord: worst,
    totalRecordDays: dailyCounts.length,
  );
});
