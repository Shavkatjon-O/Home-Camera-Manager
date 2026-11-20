// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recordings_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecordingsRead {


/// Create a copy of RecordingsRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordingsReadCopyWith<RecordingsRead> get copyWith => _$RecordingsReadCopyWithImpl<RecordingsRead>(this as RecordingsRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RecordingsRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordingsRead&&(identical(other.cameraUuid, _this.cameraUuid) || other.cameraUuid == _this.cameraUuid)&&(identical(other.supported, _this.supported) || other.supported == _this.supported)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.recordings, _this.recordings) || other.recordings == _this.recordings)&&(identical(other.dataFrom, _this.dataFrom) || other.dataFrom == _this.dataFrom)&&(identical(other.dataUntil, _this.dataUntil) || other.dataUntil == _this.dataUntil)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&const DeepCollectionEquality().equals(other.segments, _this.segments)&&(identical(other.playback, _this.playback) || other.playback == _this.playback)&&(identical(other.playbackReason, _this.playbackReason) || other.playbackReason == _this.playbackReason)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as RecordingsRead;
  return Object.hash(runtimeType,_this.cameraUuid,_this.supported,_this.reason,_this.recordings,_this.dataFrom,_this.dataUntil,_this.start,_this.end,const DeepCollectionEquality().hash(_this.segments),_this.playback,_this.playbackReason,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as RecordingsRead;
  return 'RecordingsRead(cameraUuid: ${_this.cameraUuid}, supported: ${_this.supported}, reason: ${_this.reason}, recordings: ${_this.recordings}, dataFrom: ${_this.dataFrom}, dataUntil: ${_this.dataUntil}, start: ${_this.start}, end: ${_this.end}, segments: ${_this.segments}, playback: ${_this.playback}, playbackReason: ${_this.playbackReason}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $RecordingsReadCopyWith<$Res>  {
  factory $RecordingsReadCopyWith(RecordingsRead value, $Res Function(RecordingsRead) _then) = _$RecordingsReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "camera_uuid", required: true, disallowNullValue: true) String cameraUuid,@JsonKey(required: true, disallowNullValue: true) bool supported,@JsonKey(includeIfNull: false) String? reason,@JsonKey(includeIfNull: false, fromJson: RecordingsRead._read_recordings, toJson: RecordingsRead._write_recordings) int? recordings,@JsonKey(name: "data_from", includeIfNull: false, fromJson: RecordingsRead._read_dataFrom, toJson: RecordingsRead._write_dataFrom) DateTime? dataFrom,@JsonKey(name: "data_until", includeIfNull: false, fromJson: RecordingsRead._read_dataUntil, toJson: RecordingsRead._write_dataUntil) DateTime? dataUntil,@JsonKey(includeIfNull: false, fromJson: RecordingsRead._read_start, toJson: RecordingsRead._write_start) DateTime? start,@JsonKey(includeIfNull: false, fromJson: RecordingsRead._read_end, toJson: RecordingsRead._write_end) DateTime? end,@JsonKey(disallowNullValue: true, readValue: RecordingsRead._presentValue, fromJson: RecordingsRead._read_segments, toJson: RecordingsRead._write_segments) List<SegmentRead> segments,@JsonKey(disallowNullValue: true, readValue: RecordingsRead._presentValue, fromJson: RecordingsRead._read_playback, toJson: RecordingsRead._write_playback) bool playback,@JsonKey(name: "playback_reason", includeIfNull: false) String? playbackReason,@JsonKey(readValue: RecordingsRead._extras, fromJson: RecordingsRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$RecordingsReadCopyWithImpl<$Res>
    implements $RecordingsReadCopyWith<$Res> {
  _$RecordingsReadCopyWithImpl(this._self, this._then);

  final RecordingsRead _self;
  final $Res Function(RecordingsRead) _then;

/// Create a copy of RecordingsRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cameraUuid = null,Object? supported = null,Object? reason = freezed,Object? recordings = freezed,Object? dataFrom = freezed,Object? dataUntil = freezed,Object? start = freezed,Object? end = freezed,Object? segments = null,Object? playback = null,Object? playbackReason = freezed,Object? additionalProperties = null,}) {
  return _then(RecordingsRead(
cameraUuid: null == cameraUuid ? _self.cameraUuid : cameraUuid // ignore: cast_nullable_to_non_nullable
as String,supported: null == supported ? _self.supported : supported // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,recordings: freezed == recordings ? _self.recordings : recordings // ignore: cast_nullable_to_non_nullable
as int?,dataFrom: freezed == dataFrom ? _self.dataFrom : dataFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dataUntil: freezed == dataUntil ? _self.dataUntil : dataUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime?,segments: null == segments ? _self.segments : segments // ignore: cast_nullable_to_non_nullable
as List<SegmentRead>,playback: null == playback ? _self.playback : playback // ignore: cast_nullable_to_non_nullable
as bool,playbackReason: freezed == playbackReason ? _self.playbackReason : playbackReason // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordingsRead].
extension RecordingsReadPatterns on RecordingsRead {
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
