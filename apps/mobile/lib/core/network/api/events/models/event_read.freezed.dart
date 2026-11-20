// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventRead {


/// Create a copy of EventRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventReadCopyWith<EventRead> get copyWith => _$EventReadCopyWithImpl<EventRead>(this as EventRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.cameraUuid, _this.cameraUuid) || other.cameraUuid == _this.cameraUuid)&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.sourceTopic, _this.sourceTopic) || other.sourceTopic == _this.sourceTopic)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.alert, _this.alert) || other.alert == _this.alert)&&(identical(other.viewUuid, _this.viewUuid) || other.viewUuid == _this.viewUuid)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.ongoing, _this.ongoing) || other.ongoing == _this.ongoing)&&(identical(other.durationSeconds, _this.durationSeconds) || other.durationSeconds == _this.durationSeconds)&&(identical(other.cameraTime, _this.cameraTime) || other.cameraTime == _this.cameraTime)&&(identical(other.hasSnapshot, _this.hasSnapshot) || other.hasSnapshot == _this.hasSnapshot)&&(identical(other.hasThumbnail, _this.hasThumbnail) || other.hasThumbnail == _this.hasThumbnail)&&(identical(other.hasClip, _this.hasClip) || other.hasClip == _this.hasClip)&&const DeepCollectionEquality().equals(other.details, _this.details)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.face, _this.face) || other.face == _this.face)&&(identical(other.acknowledgedAt, _this.acknowledgedAt) || other.acknowledgedAt == _this.acknowledgedAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as EventRead;
  return Object.hashAll([runtimeType,_this.uuid,_this.cameraUuid,_this.cameraName,_this.kind,_this.source,_this.sourceTopic,_this.label,_this.alert,_this.viewUuid,_this.startedAt,_this.endedAt,_this.ongoing,_this.durationSeconds,_this.cameraTime,_this.hasSnapshot,_this.hasThumbnail,_this.hasClip,const DeepCollectionEquality().hash(_this.details),_this.createdAt,_this.updatedAt,_this.face,_this.acknowledgedAt,const DeepCollectionEquality().hash(_this.additionalProperties)]);
}

@override
String toString() {
  final _this = this as EventRead;
  return 'EventRead(uuid: ${_this.uuid}, cameraUuid: ${_this.cameraUuid}, cameraName: ${_this.cameraName}, kind: ${_this.kind}, source: ${_this.source}, sourceTopic: ${_this.sourceTopic}, label: ${_this.label}, alert: ${_this.alert}, viewUuid: ${_this.viewUuid}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt}, ongoing: ${_this.ongoing}, durationSeconds: ${_this.durationSeconds}, cameraTime: ${_this.cameraTime}, hasSnapshot: ${_this.hasSnapshot}, hasThumbnail: ${_this.hasThumbnail}, hasClip: ${_this.hasClip}, details: ${_this.details}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, face: ${_this.face}, acknowledgedAt: ${_this.acknowledgedAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $EventReadCopyWith<$Res>  {
  factory $EventReadCopyWith(EventRead value, $Res Function(EventRead) _then) = _$EventReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(name: "camera_uuid", required: true, disallowNullValue: true) String cameraUuid,@JsonKey(name: "camera_name", required: true) String? cameraName,@JsonKey(required: true, disallowNullValue: true, fromJson: EventRead._read_kind, toJson: EventRead._write_kind) EventKind kind,@JsonKey(required: true, disallowNullValue: true, fromJson: EventRead._read_source, toJson: EventRead._write_source) EventSource source,@JsonKey(name: "source_topic", required: true, disallowNullValue: true) String sourceTopic,@JsonKey(required: true) String? label,@JsonKey(required: true, disallowNullValue: true) bool alert,@JsonKey(name: "view_uuid", required: true) String? viewUuid,@JsonKey(name: "started_at", required: true, disallowNullValue: true, fromJson: EventRead._read_startedAt, toJson: EventRead._write_startedAt) DateTime startedAt,@JsonKey(name: "ended_at", required: true, fromJson: EventRead._read_endedAt, toJson: EventRead._write_endedAt) DateTime? endedAt,@JsonKey(required: true, disallowNullValue: true) bool ongoing,@JsonKey(name: "duration_seconds", required: true, disallowNullValue: true) num durationSeconds,@JsonKey(name: "camera_time", required: true, fromJson: EventRead._read_cameraTime, toJson: EventRead._write_cameraTime) DateTime? cameraTime,@JsonKey(name: "has_snapshot", required: true, disallowNullValue: true) bool hasSnapshot,@JsonKey(name: "has_thumbnail", required: true, disallowNullValue: true) bool hasThumbnail,@JsonKey(name: "has_clip", required: true, disallowNullValue: true) bool hasClip,@JsonKey(required: true, disallowNullValue: true) Map<String, Object?> details,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: EventRead._read_createdAt, toJson: EventRead._write_createdAt) DateTime createdAt,@JsonKey(name: "updated_at", required: true, disallowNullValue: true, fromJson: EventRead._read_updatedAt, toJson: EventRead._write_updatedAt) DateTime updatedAt,@JsonKey(includeIfNull: false) FaceRead? face,@JsonKey(name: "acknowledged_at", includeIfNull: false, fromJson: EventRead._read_acknowledgedAt, toJson: EventRead._write_acknowledgedAt) DateTime? acknowledgedAt,@JsonKey(readValue: EventRead._extras, fromJson: EventRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$FaceReadCopyWith<$Res>? get face;

}
/// @nodoc
class _$EventReadCopyWithImpl<$Res>
    implements $EventReadCopyWith<$Res> {
  _$EventReadCopyWithImpl(this._self, this._then);

  final EventRead _self;
  final $Res Function(EventRead) _then;

/// Create a copy of EventRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? cameraUuid = null,Object? cameraName = freezed,Object? kind = null,Object? source = null,Object? sourceTopic = null,Object? label = freezed,Object? alert = null,Object? viewUuid = freezed,Object? startedAt = null,Object? endedAt = freezed,Object? ongoing = null,Object? durationSeconds = null,Object? cameraTime = freezed,Object? hasSnapshot = null,Object? hasThumbnail = null,Object? hasClip = null,Object? details = null,Object? createdAt = null,Object? updatedAt = null,Object? face = freezed,Object? acknowledgedAt = freezed,Object? additionalProperties = null,}) {
  return _then(EventRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,cameraUuid: null == cameraUuid ? _self.cameraUuid : cameraUuid // ignore: cast_nullable_to_non_nullable
as String,cameraName: freezed == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as EventKind,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as EventSource,sourceTopic: null == sourceTopic ? _self.sourceTopic : sourceTopic // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,alert: null == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as bool,viewUuid: freezed == viewUuid ? _self.viewUuid : viewUuid // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ongoing: null == ongoing ? _self.ongoing : ongoing // ignore: cast_nullable_to_non_nullable
as bool,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as num,cameraTime: freezed == cameraTime ? _self.cameraTime : cameraTime // ignore: cast_nullable_to_non_nullable
as DateTime?,hasSnapshot: null == hasSnapshot ? _self.hasSnapshot : hasSnapshot // ignore: cast_nullable_to_non_nullable
as bool,hasThumbnail: null == hasThumbnail ? _self.hasThumbnail : hasThumbnail // ignore: cast_nullable_to_non_nullable
as bool,hasClip: null == hasClip ? _self.hasClip : hasClip // ignore: cast_nullable_to_non_nullable
as bool,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,face: freezed == face ? _self.face : face // ignore: cast_nullable_to_non_nullable
as FaceRead?,acknowledgedAt: freezed == acknowledgedAt ? _self.acknowledgedAt : acknowledgedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of EventRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FaceReadCopyWith<$Res>? get face {
    if (_self.face == null) {
    return null;
  }

  return $FaceReadCopyWith<$Res>(_self.face!, (value) {
    return _then(_self.copyWith(face: value));
  });
}
}


/// Adds pattern-matching-related methods to [EventRead].
extension EventReadPatterns on EventRead {
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
