// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideoRead {


/// Create a copy of VideoRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoReadCopyWith<VideoRead> get copyWith => _$VideoReadCopyWithImpl<VideoRead>(this as VideoRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VideoRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoRead&&(identical(other.cameraUuid, _this.cameraUuid) || other.cameraUuid == _this.cameraUuid)&&(identical(other.supported, _this.supported) || other.supported == _this.supported)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.service, _this.service) || other.service == _this.service)&&const DeepCollectionEquality().equals(other.encoders, _this.encoders)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as VideoRead;
  return Object.hash(runtimeType,_this.cameraUuid,_this.supported,_this.reason,_this.service,const DeepCollectionEquality().hash(_this.encoders),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as VideoRead;
  return 'VideoRead(cameraUuid: ${_this.cameraUuid}, supported: ${_this.supported}, reason: ${_this.reason}, service: ${_this.service}, encoders: ${_this.encoders}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $VideoReadCopyWith<$Res>  {
  factory $VideoReadCopyWith(VideoRead value, $Res Function(VideoRead) _then) = _$VideoReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "camera_uuid", required: true, disallowNullValue: true) String cameraUuid,@JsonKey(required: true, disallowNullValue: true) bool supported,@JsonKey(includeIfNull: false) String? reason,@JsonKey(includeIfNull: false) String? service,@JsonKey(disallowNullValue: true, readValue: VideoRead._presentValue, fromJson: VideoRead._read_encoders, toJson: VideoRead._write_encoders) List<EncoderRead> encoders,@JsonKey(readValue: VideoRead._extras, fromJson: VideoRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$VideoReadCopyWithImpl<$Res>
    implements $VideoReadCopyWith<$Res> {
  _$VideoReadCopyWithImpl(this._self, this._then);

  final VideoRead _self;
  final $Res Function(VideoRead) _then;

/// Create a copy of VideoRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cameraUuid = null,Object? supported = null,Object? reason = freezed,Object? service = freezed,Object? encoders = null,Object? additionalProperties = null,}) {
  return _then(VideoRead(
cameraUuid: null == cameraUuid ? _self.cameraUuid : cameraUuid // ignore: cast_nullable_to_non_nullable
as String,supported: null == supported ? _self.supported : supported // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,service: freezed == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as String?,encoders: null == encoders ? _self.encoders : encoders // ignore: cast_nullable_to_non_nullable
as List<EncoderRead>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoRead].
extension VideoReadPatterns on VideoRead {
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
