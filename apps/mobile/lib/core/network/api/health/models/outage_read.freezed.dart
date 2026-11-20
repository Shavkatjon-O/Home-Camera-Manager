// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outage_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OutageRead {


/// Create a copy of OutageRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutageReadCopyWith<OutageRead> get copyWith => _$OutageReadCopyWithImpl<OutageRead>(this as OutageRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OutageRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutageRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.targetKind, _this.targetKind) || other.targetKind == _this.targetKind)&&(identical(other.targetUuid, _this.targetUuid) || other.targetUuid == _this.targetUuid)&&(identical(other.targetName, _this.targetName) || other.targetName == _this.targetName)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.ongoing, _this.ongoing) || other.ongoing == _this.ongoing)&&(identical(other.durationSeconds, _this.durationSeconds) || other.durationSeconds == _this.durationSeconds)&&(identical(other.failedSamples, _this.failedSamples) || other.failedSamples == _this.failedSamples)&&(identical(other.upstreamUuid, _this.upstreamUuid) || other.upstreamUuid == _this.upstreamUuid)&&(identical(other.upstreamName, _this.upstreamName) || other.upstreamName == _this.upstreamName)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as OutageRead;
  return Object.hash(runtimeType,_this.uuid,_this.targetKind,_this.targetUuid,_this.targetName,_this.startedAt,_this.endedAt,_this.ongoing,_this.durationSeconds,_this.failedSamples,_this.upstreamUuid,_this.upstreamName,_this.createdAt,_this.updatedAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as OutageRead;
  return 'OutageRead(uuid: ${_this.uuid}, targetKind: ${_this.targetKind}, targetUuid: ${_this.targetUuid}, targetName: ${_this.targetName}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt}, ongoing: ${_this.ongoing}, durationSeconds: ${_this.durationSeconds}, failedSamples: ${_this.failedSamples}, upstreamUuid: ${_this.upstreamUuid}, upstreamName: ${_this.upstreamName}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $OutageReadCopyWith<$Res>  {
  factory $OutageReadCopyWith(OutageRead value, $Res Function(OutageRead) _then) = _$OutageReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(name: "target_kind", required: true, disallowNullValue: true, fromJson: OutageRead._read_targetKind, toJson: OutageRead._write_targetKind) TargetKind targetKind,@JsonKey(name: "target_uuid", required: true, disallowNullValue: true) String targetUuid,@JsonKey(name: "target_name", required: true) String? targetName,@JsonKey(name: "started_at", required: true, disallowNullValue: true, fromJson: OutageRead._read_startedAt, toJson: OutageRead._write_startedAt) DateTime startedAt,@JsonKey(name: "ended_at", required: true, fromJson: OutageRead._read_endedAt, toJson: OutageRead._write_endedAt) DateTime? endedAt,@JsonKey(required: true, disallowNullValue: true) bool ongoing,@JsonKey(name: "duration_seconds", required: true, disallowNullValue: true) num durationSeconds,@JsonKey(name: "failed_samples", required: true, disallowNullValue: true, fromJson: OutageRead._read_failedSamples, toJson: OutageRead._write_failedSamples) int failedSamples,@JsonKey(name: "upstream_uuid", required: true) String? upstreamUuid,@JsonKey(name: "upstream_name", required: true) String? upstreamName,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: OutageRead._read_createdAt, toJson: OutageRead._write_createdAt) DateTime createdAt,@JsonKey(name: "updated_at", required: true, disallowNullValue: true, fromJson: OutageRead._read_updatedAt, toJson: OutageRead._write_updatedAt) DateTime updatedAt,@JsonKey(readValue: OutageRead._extras, fromJson: OutageRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$OutageReadCopyWithImpl<$Res>
    implements $OutageReadCopyWith<$Res> {
  _$OutageReadCopyWithImpl(this._self, this._then);

  final OutageRead _self;
  final $Res Function(OutageRead) _then;

/// Create a copy of OutageRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? targetKind = null,Object? targetUuid = null,Object? targetName = freezed,Object? startedAt = null,Object? endedAt = freezed,Object? ongoing = null,Object? durationSeconds = null,Object? failedSamples = null,Object? upstreamUuid = freezed,Object? upstreamName = freezed,Object? createdAt = null,Object? updatedAt = null,Object? additionalProperties = null,}) {
  return _then(OutageRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,targetKind: null == targetKind ? _self.targetKind : targetKind // ignore: cast_nullable_to_non_nullable
as TargetKind,targetUuid: null == targetUuid ? _self.targetUuid : targetUuid // ignore: cast_nullable_to_non_nullable
as String,targetName: freezed == targetName ? _self.targetName : targetName // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ongoing: null == ongoing ? _self.ongoing : ongoing // ignore: cast_nullable_to_non_nullable
as bool,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as num,failedSamples: null == failedSamples ? _self.failedSamples : failedSamples // ignore: cast_nullable_to_non_nullable
as int,upstreamUuid: freezed == upstreamUuid ? _self.upstreamUuid : upstreamUuid // ignore: cast_nullable_to_non_nullable
as String?,upstreamName: freezed == upstreamName ? _self.upstreamName : upstreamName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [OutageRead].
extension OutageReadPatterns on OutageRead {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({required TResult orElse(),}){
final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({required TResult orElse(),}) {final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  return null;

}
}

}

// dart format on
