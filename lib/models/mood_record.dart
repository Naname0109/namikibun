import 'package:freezed_annotation/freezed_annotation.dart';

part 'mood_record.freezed.dart';
part 'mood_record.g.dart';

@freezed
class MoodRecord with _$MoodRecord {
  const factory MoodRecord({
    int? id,
    required String date,
    required String slotId,
    required int moodLevel,
    String? memo,
    @Default([]) List<String> tags,
    required String createdAt,
    required String updatedAt,
  }) = _MoodRecord;

  factory MoodRecord.fromJson(Map<String, dynamic> json) =>
      _$MoodRecordFromJson(json);
}
