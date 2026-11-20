// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_channel_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeviceChannelRead {


/// Create a copy of DeviceChannelRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceChannelReadCopyWith<DeviceChannelRead> get copyWith => _$DeviceChannelReadCopyWithImpl<DeviceChannelRead>(this as DeviceChannelRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeviceChannelRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceChannelRead&&(identical(other.camera, _this.camera) || other.camera == _this.camera)&&(identical(other.channel, _this.channel) || other.channel == _this.channel)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as DeviceChannelRead;
  return Object.hash(runtimeType,_this.camera,_this.channel,_this.name,_this.enabled,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as DeviceChannelRead;
  return 'DeviceChannelRead(camera: ${_this.camera}, channel: ${_this.channel}, name: ${_this.name}, enabled: ${_this.enabled}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $DeviceChannelReadCopyWith<$Res>  {
  factory $DeviceChannelReadCopyWith(DeviceChannelRead value, $Res Function(DeviceChannelRead) _then) = _$DeviceChannelReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String camera,@JsonKey(required: true, disallowNullValue: true, fromJson: DeviceChannelRead._read_channel, toJson: DeviceChannelRead._write_channel) int channel,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true, disallowNullValue: true) bool enabled,@JsonKey(readValue: DeviceChannelRead._extras, fromJson: DeviceChannelRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$DeviceChannelReadCopyWithImpl<$Res>
    implements $DeviceChannelReadCopyWith<$Res> {
  _$DeviceChannelReadCopyWithImpl(this._self, this._then);

  final DeviceChannelRead _self;
  final $Res Function(DeviceChannelRead) _then;

/// Create a copy of DeviceChannelRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? camera = null,Object? channel = null,Object? name = null,Object? enabled = null,Object? additionalProperties = null,}) {
  return _then(DeviceChannelRead(
camera: null == camera ? _self.camera : camera // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceChannelRead].
extension DeviceChannelReadPatterns on DeviceChannelRead {
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
