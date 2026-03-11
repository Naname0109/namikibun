// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mood_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MoodRecord _$MoodRecordFromJson(Map<String, dynamic> json) {
  return _MoodRecord.fromJson(json);
}

/// @nodoc
mixin _$MoodRecord {
  int? get id => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  String get slotId => throw _privateConstructorUsedError;
  int get moodLevel => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String? get photoPath => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this MoodRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MoodRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MoodRecordCopyWith<MoodRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MoodRecordCopyWith<$Res> {
  factory $MoodRecordCopyWith(
    MoodRecord value,
    $Res Function(MoodRecord) then,
  ) = _$MoodRecordCopyWithImpl<$Res, MoodRecord>;
  @useResult
  $Res call({
    int? id,
    String date,
    String slotId,
    int moodLevel,
    String? memo,
    List<String> tags,
    String? photoPath,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class _$MoodRecordCopyWithImpl<$Res, $Val extends MoodRecord>
    implements $MoodRecordCopyWith<$Res> {
  _$MoodRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MoodRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? date = null,
    Object? slotId = null,
    Object? moodLevel = null,
    Object? memo = freezed,
    Object? tags = null,
    Object? photoPath = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            slotId: null == slotId
                ? _value.slotId
                : slotId // ignore: cast_nullable_to_non_nullable
                      as String,
            moodLevel: null == moodLevel
                ? _value.moodLevel
                : moodLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            memo: freezed == memo
                ? _value.memo
                : memo // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            photoPath: freezed == photoPath
                ? _value.photoPath
                : photoPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MoodRecordImplCopyWith<$Res>
    implements $MoodRecordCopyWith<$Res> {
  factory _$$MoodRecordImplCopyWith(
    _$MoodRecordImpl value,
    $Res Function(_$MoodRecordImpl) then,
  ) = __$$MoodRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String date,
    String slotId,
    int moodLevel,
    String? memo,
    List<String> tags,
    String? photoPath,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class __$$MoodRecordImplCopyWithImpl<$Res>
    extends _$MoodRecordCopyWithImpl<$Res, _$MoodRecordImpl>
    implements _$$MoodRecordImplCopyWith<$Res> {
  __$$MoodRecordImplCopyWithImpl(
    _$MoodRecordImpl _value,
    $Res Function(_$MoodRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MoodRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? date = null,
    Object? slotId = null,
    Object? moodLevel = null,
    Object? memo = freezed,
    Object? tags = null,
    Object? photoPath = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$MoodRecordImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        slotId: null == slotId
            ? _value.slotId
            : slotId // ignore: cast_nullable_to_non_nullable
                  as String,
        moodLevel: null == moodLevel
            ? _value.moodLevel
            : moodLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        memo: freezed == memo
            ? _value.memo
            : memo // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        photoPath: freezed == photoPath
            ? _value.photoPath
            : photoPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MoodRecordImpl implements _MoodRecord {
  const _$MoodRecordImpl({
    this.id,
    required this.date,
    required this.slotId,
    required this.moodLevel,
    this.memo,
    final List<String> tags = const [],
    this.photoPath,
    required this.createdAt,
    required this.updatedAt,
  }) : _tags = tags;

  factory _$MoodRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$MoodRecordImplFromJson(json);

  @override
  final int? id;
  @override
  final String date;
  @override
  final String slotId;
  @override
  final int moodLevel;
  @override
  final String? memo;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? photoPath;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'MoodRecord(id: $id, date: $date, slotId: $slotId, moodLevel: $moodLevel, memo: $memo, tags: $tags, photoPath: $photoPath, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MoodRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.slotId, slotId) || other.slotId == slotId) &&
            (identical(other.moodLevel, moodLevel) ||
                other.moodLevel == moodLevel) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.photoPath, photoPath) ||
                other.photoPath == photoPath) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    date,
    slotId,
    moodLevel,
    memo,
    const DeepCollectionEquality().hash(_tags),
    photoPath,
    createdAt,
    updatedAt,
  );

  /// Create a copy of MoodRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MoodRecordImplCopyWith<_$MoodRecordImpl> get copyWith =>
      __$$MoodRecordImplCopyWithImpl<_$MoodRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MoodRecordImplToJson(this);
  }
}

abstract class _MoodRecord implements MoodRecord {
  const factory _MoodRecord({
    final int? id,
    required final String date,
    required final String slotId,
    required final int moodLevel,
    final String? memo,
    final List<String> tags,
    final String? photoPath,
    required final String createdAt,
    required final String updatedAt,
  }) = _$MoodRecordImpl;

  factory _MoodRecord.fromJson(Map<String, dynamic> json) =
      _$MoodRecordImpl.fromJson;

  @override
  int? get id;
  @override
  String get date;
  @override
  String get slotId;
  @override
  int get moodLevel;
  @override
  String? get memo;
  @override
  List<String> get tags;
  @override
  String? get photoPath;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of MoodRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MoodRecordImplCopyWith<_$MoodRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
