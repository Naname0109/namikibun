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
    final dateString = AppDateUtils.formatLogicalDate(date);
    return await DatabaseService().getMoodRecordsByDate(dateString);
  }

  Future<void> addRecord(MoodRecord record) async {
    await DatabaseService().insertMoodRecord(record);
    ref.invalidateSelf();
  }

  Future<void> updateRecord(MoodRecord record) async {
    await DatabaseService().updateMoodRecord(record);
    ref.invalidateSelf();
  }

  Future<void> deleteRecord(int id) async {
    await DatabaseService().deleteMoodRecord(id);
    ref.invalidateSelf();
  }
}
