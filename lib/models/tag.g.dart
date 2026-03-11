// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TagImpl _$$TagImplFromJson(Map<String, dynamic> json) => _$TagImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  colorHex: json['colorHex'] as String,
  isDefault: json['isDefault'] as bool? ?? false,
  orderIndex: (json['orderIndex'] as num).toInt(),
);

Map<String, dynamic> _$$TagImplToJson(_$TagImpl instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'colorHex': instance.colorHex,
  'isDefault': instance.isDefault,
  'orderIndex': instance.orderIndex,
};
