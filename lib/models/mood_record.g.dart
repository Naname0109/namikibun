// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MoodRecordImpl _$$MoodRecordImplFromJson(Map<String, dynamic> json) =>
    _$MoodRecordImpl(
      id: (json['id'] as num?)?.toInt(),
      date: json['date'] as String,
      slotId: json['slotId'] as String,
      moodLevel: (json['moodLevel'] as num).toInt(),
      memo: json['memo'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      photoPath: json['photoPath'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$MoodRecordImplToJson(_$MoodRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'slotId': instance.slotId,
      'moodLevel': instance.moodLevel,
      'memo': instance.memo,
      'tags': instance.tags,
      'photoPath': instance.photoPath,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
