// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AudioRead {


/// Create a copy of AudioRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudioReadCopyWith<AudioRead> get copyWith => _$AudioReadCopyWithImpl<AudioRead>(this as AudioRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AudioRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudioRead&&(identical(other.cameraUuid, _this.cameraUuid) || other.cameraUuid == _this.cameraUuid)&&(identical(other.supported, _this.supported) || other.supported == _this.supported)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.codec, _this.codec) || other.codec == _this.codec)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as AudioRead;
  return Object.hash(runtimeType,_this.cameraUuid,_this.supported,_this.reason,_this.codec,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as AudioRead;
  return 'AudioRead(cameraUuid: ${_this.cameraUuid}, supported: ${_this.supported}, reason: ${_this.reason}, codec: ${_this.codec}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $AudioReadCopyWith<$Res>  {
  factory $AudioReadCopyWith(AudioRead value, $Res Function(AudioRead) _then) = _$AudioReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "camera_uuid", required: true, disallowNullValue: true) String cameraUuid,@JsonKey(required: true, disallowNullValue: true) bool supported,@JsonKey(includeIfNull: false) String? reason,@JsonKey(includeIfNull: false) String? codec,@JsonKey(readValue: AudioRead._extras, fromJson: AudioRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$AudioReadCopyWithImpl<$Res>
    implements $AudioReadCopyWith<$Res> {
  _$AudioReadCopyWithImpl(this._self, this._then);

  final AudioRead _self;
  final $Res Function(AudioRead) _then;

/// Create a copy of AudioRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cameraUuid = null,Object? supported = null,Object? reason = freezed,Object? codec = freezed,Object? additionalProperties = null,}) {
  return _then(AudioRead(
cameraUuid: null == cameraUuid ? _self.cameraUuid : cameraUuid // ignore: cast_nullable_to_non_nullable
as String,supported: null == supported ? _self.supported : supported // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,codec: freezed == codec ? _self.codec : codec // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [AudioRead].
extension AudioReadPatterns on AudioRead {
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
