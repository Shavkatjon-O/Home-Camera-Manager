// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outage_brief.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OutageBrief {


/// Create a copy of OutageBrief
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutageBriefCopyWith<OutageBrief> get copyWith => _$OutageBriefCopyWithImpl<OutageBrief>(this as OutageBrief, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OutageBrief;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutageBrief&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.durationSeconds, _this.durationSeconds) || other.durationSeconds == _this.durationSeconds)&&(identical(other.upstreamUuid, _this.upstreamUuid) || other.upstreamUuid == _this.upstreamUuid)&&(identical(other.upstreamName, _this.upstreamName) || other.upstreamName == _this.upstreamName)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as OutageBrief;
  return Object.hash(runtimeType,_this.uuid,_this.startedAt,_this.endedAt,_this.durationSeconds,_this.upstreamUuid,_this.upstreamName,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as OutageBrief;
  return 'OutageBrief(uuid: ${_this.uuid}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt}, durationSeconds: ${_this.durationSeconds}, upstreamUuid: ${_this.upstreamUuid}, upstreamName: ${_this.upstreamName}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $OutageBriefCopyWith<$Res>  {
  factory $OutageBriefCopyWith(OutageBrief value, $Res Function(OutageBrief) _then) = _$OutageBriefCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(name: "started_at", required: true, disallowNullValue: true, fromJson: OutageBrief._read_startedAt, toJson: OutageBrief._write_startedAt) DateTime startedAt,@JsonKey(name: "ended_at", required: true, fromJson: OutageBrief._read_endedAt, toJson: OutageBrief._write_endedAt) DateTime? endedAt,@JsonKey(name: "duration_seconds", required: true, disallowNullValue: true) num durationSeconds,@JsonKey(name: "upstream_uuid", required: true) String? upstreamUuid,@JsonKey(name: "upstream_name", required: true) String? upstreamName,@JsonKey(readValue: OutageBrief._extras, fromJson: OutageBrief._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$OutageBriefCopyWithImpl<$Res>
    implements $OutageBriefCopyWith<$Res> {
  _$OutageBriefCopyWithImpl(this._self, this._then);

  final OutageBrief _self;
  final $Res Function(OutageBrief) _then;

/// Create a copy of OutageBrief
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? startedAt = null,Object? endedAt = freezed,Object? durationSeconds = null,Object? upstreamUuid = freezed,Object? upstreamName = freezed,Object? additionalProperties = null,}) {
  return _then(OutageBrief(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as num,upstreamUuid: freezed == upstreamUuid ? _self.upstreamUuid : upstreamUuid // ignore: cast_nullable_to_non_nullable
as String?,upstreamName: freezed == upstreamName ? _self.upstreamName : upstreamName // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [OutageBrief].
extension OutageBriefPatterns on OutageBrief {
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
