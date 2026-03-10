// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SlotImpl _$$SlotImplFromJson(Map<String, dynamic> json) => _$SlotImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  orderIndex: (json['orderIndex'] as num).toInt(),
  notifyEnabled: json['notifyEnabled'] as bool? ?? false,
  notifyTime: json['notifyTime'] as String?,
  startTime: json['startTime'] as String?,
  endTime: json['endTime'] as String?,
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$$SlotImplToJson(_$SlotImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'orderIndex': instance.orderIndex,
      'notifyEnabled': instance.notifyEnabled,
      'notifyTime': instance.notifyTime,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'isDeleted': instance.isDeleted,
    };
