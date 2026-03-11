import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/models/mood_record.dart';
import 'package:namikibun/services/database_service.dart';
import 'package:namikibun/utils/date_utils.dart';

/// 選択中の日付
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return AppDateUtils.getLogicalToday();
});

/// 選択日付の気分記録一覧
final moodRecordsProvider =
    AsyncNotifierProvider<MoodRecordsNotifier, List<MoodRecord>>(
  MoodRecordsNotifier.new,
);

class MoodRecordsNotifier extends AsyncNotifier<List<MoodRecord>> {
  @override
  Future<List<MoodRecord>> build() async {
    final date = ref.watch(selectedDateProvider);
    final dateString = AppDateUtils.formatDate(date);
    return await DatabaseService().getMoodRecordsByDate(dateString);
  }

  Future<void> addRecord(MoodRecord record) async {
    await DatabaseService().insertMoodRecord(record);
    ref.invalidateSelf();
    // カレンダーキャッシュも無効化
    ref.invalidate(calendarRecordsProvider);
    ref.invalidate(consecutiveRecordDaysProvider);
  }

  Future<void> updateRecord(MoodRecord record) async {
    await DatabaseService().updateMoodRecord(record);
    ref.invalidateSelf();
    ref.invalidate(calendarRecordsProvider);
  }

  Future<void> deleteRecord(int id) async {
    // 写真ファイルも削除
    final records = state.valueOrNull ?? [];
    final record = records.where((r) => r.id == id).firstOrNull;
    if (record?.photoPath != null) {
      final file = File(record!.photoPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await DatabaseService().deleteMoodRecord(id);
    ref.invalidateSelf();
    ref.invalidate(calendarRecordsProvider);
    ref.invalidate(consecutiveRecordDaysProvider);
  }
}

/// カレンダー表示月
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = AppDateUtils.getLogicalToday();
  return DateTime(now.year, now.month);
});

/// カレンダー用: 表示月の全記録を日付ごとにグルーピング（スロットorder_index順）
final calendarRecordsProvider =
    FutureProvider<Map<String, List<MoodRecord>>>((ref) async {
  final month = ref.watch(selectedMonthProvider);
  final startDate = DateTime(month.year, month.month, 1);
  final endDate = DateTime(month.year, month.month + 1, 0); // 月末

  final startStr = AppDateUtils.formatDate(startDate);
  final endStr = AppDateUtils.formatDate(endDate);

  final db = DatabaseService();
  final records = await db.getMoodRecordsByDateRange(startStr, endStr);
  final slots = await db.getActiveSlots();

  // slotIdからorder_indexへのマップ
  final slotOrder = <String, int>{};
  for (final slot in slots) {
    slotOrder[slot.id] = slot.orderIndex;
  }

  final grouped = <String, List<MoodRecord>>{};
  for (final record in records) {
    grouped.putIfAbsent(record.date, () => []).add(record);
  }

  // 各日の記録をスロットのorder_index順にソート
  for (final entry in grouped.entries) {
    entry.value.sort((a, b) =>
        (slotOrder[a.slotId] ?? 0).compareTo(slotOrder[b.slotId] ?? 0));
  }

  return grouped;
});

/// 連続記録日数
final consecutiveRecordDaysProvider = FutureProvider<int>((ref) async {
  final todayStr = AppDateUtils.getLogicalTodayString();
  return await DatabaseService().getConsecutiveRecordDays(todayStr);
});
