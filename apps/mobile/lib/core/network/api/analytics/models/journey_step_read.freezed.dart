// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journey_step_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JourneyStepRead {


/// Create a copy of JourneyStepRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JourneyStepReadCopyWith<JourneyStepRead> get copyWith => _$JourneyStepReadCopyWithImpl<JourneyStepRead>(this as JourneyStepRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as JourneyStepRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JourneyStepRead&&(identical(other.viewUuid, _this.viewUuid) || other.viewUuid == _this.viewUuid)&&(identical(other.viewName, _this.viewName) || other.viewName == _this.viewName)&&(identical(other.cameraUuid, _this.cameraUuid) || other.cameraUuid == _this.cameraUuid)&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName)&&(identical(other.track, _this.track) || other.track == _this.track)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.similarity, _this.similarity) || other.similarity == _this.similarity)&&(identical(other.eventUuid, _this.eventUuid) || other.eventUuid == _this.eventUuid)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as JourneyStepRead;
  return Object.hash(runtimeType,_this.viewUuid,_this.viewName,_this.cameraUuid,_this.cameraName,_this.track,_this.startedAt,_this.endedAt,_this.similarity,_this.eventUuid,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as JourneyStepRead;
  return 'JourneyStepRead(viewUuid: ${_this.viewUuid}, viewName: ${_this.viewName}, cameraUuid: ${_this.cameraUuid}, cameraName: ${_this.cameraName}, track: ${_this.track}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt}, similarity: ${_this.similarity}, eventUuid: ${_this.eventUuid}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $JourneyStepReadCopyWith<$Res>  {
  factory $JourneyStepReadCopyWith(JourneyStepRead value, $Res Function(JourneyStepRead) _then) = _$JourneyStepReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "view_uuid", required: true, disallowNullValue: true) String viewUuid,@JsonKey(name: "view_name", required: true) String? viewName,@JsonKey(name: "camera_uuid", required: true, disallowNullValue: true) String cameraUuid,@JsonKey(name: "camera_name", required: true) String? cameraName,@JsonKey(required: true, disallowNullValue: true, fromJson: JourneyStepRead._read_track, toJson: JourneyStepRead._write_track) int track,@JsonKey(name: "started_at", required: true, disallowNullValue: true, fromJson: JourneyStepRead._read_startedAt, toJson: JourneyStepRead._write_startedAt) DateTime startedAt,@JsonKey(name: "ended_at", required: true, disallowNullValue: true, fromJson: JourneyStepRead._read_endedAt, toJson: JourneyStepRead._write_endedAt) DateTime endedAt,@JsonKey(required: true) num? similarity,@JsonKey(name: "event_uuid", includeIfNull: false) String? eventUuid,@JsonKey(readValue: JourneyStepRead._extras, fromJson: JourneyStepRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$JourneyStepReadCopyWithImpl<$Res>
    implements $JourneyStepReadCopyWith<$Res> {
  _$JourneyStepReadCopyWithImpl(this._self, this._then);

  final JourneyStepRead _self;
  final $Res Function(JourneyStepRead) _then;

/// Create a copy of JourneyStepRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? viewUuid = null,Object? viewName = freezed,Object? cameraUuid = null,Object? cameraName = freezed,Object? track = null,Object? startedAt = null,Object? endedAt = null,Object? similarity = freezed,Object? eventUuid = freezed,Object? additionalProperties = null,}) {
  return _then(JourneyStepRead(
viewUuid: null == viewUuid ? _self.viewUuid : viewUuid // ignore: cast_nullable_to_non_nullable
as String,viewName: freezed == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String?,cameraUuid: null == cameraUuid ? _self.cameraUuid : cameraUuid // ignore: cast_nullable_to_non_nullable
as String,cameraName: freezed == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String?,track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime,similarity: freezed == similarity ? _self.similarity : similarity // ignore: cast_nullable_to_non_nullable
as num?,eventUuid: freezed == eventUuid ? _self.eventUuid : eventUuid // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [JourneyStepRead].
extension JourneyStepReadPatterns on JourneyStepRead {
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
