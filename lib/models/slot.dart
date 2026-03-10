import 'package:freezed_annotation/freezed_annotation.dart';

part 'slot.freezed.dart';
part 'slot.g.dart';

@freezed
class Slot with _$Slot {
  const factory Slot({
    required String id,
    required String name,
    required int orderIndex,
    @Default(false) bool notifyEnabled,
    String? notifyTime,
    String? startTime,
    String? endTime,
    @Default(false) bool isDeleted,
  }) = _Slot;

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);
}
