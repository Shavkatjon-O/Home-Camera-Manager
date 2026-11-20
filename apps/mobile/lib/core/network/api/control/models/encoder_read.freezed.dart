// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encoder_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EncoderRead {


/// Create a copy of EncoderRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncoderReadCopyWith<EncoderRead> get copyWith => _$EncoderReadCopyWithImpl<EncoderRead>(this as EncoderRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EncoderRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncoderRead&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.profiles, _this.profiles)&&(identical(other.encoding, _this.encoding) || other.encoding == _this.encoding)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.fps, _this.fps) || other.fps == _this.fps)&&(identical(other.bitrate, _this.bitrate) || other.bitrate == _this.bitrate)&&(identical(other.gop, _this.gop) || other.gop == _this.gop)&&(identical(other.quality, _this.quality) || other.quality == _this.quality)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&const DeepCollectionEquality().equals(other.options, _this.options)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as EncoderRead;
  return Object.hash(runtimeType,_this.token,_this.name,const DeepCollectionEquality().hash(_this.profiles),_this.encoding,_this.width,_this.height,_this.fps,_this.bitrate,_this.gop,_this.quality,_this.profile,const DeepCollectionEquality().hash(_this.options),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as EncoderRead;
  return 'EncoderRead(token: ${_this.token}, name: ${_this.name}, profiles: ${_this.profiles}, encoding: ${_this.encoding}, width: ${_this.width}, height: ${_this.height}, fps: ${_this.fps}, bitrate: ${_this.bitrate}, gop: ${_this.gop}, quality: ${_this.quality}, profile: ${_this.profile}, options: ${_this.options}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $EncoderReadCopyWith<$Res>  {
  factory $EncoderReadCopyWith(EncoderRead value, $Res Function(EncoderRead) _then) = _$EncoderReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String token,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true, disallowNullValue: true) List<String> profiles,@JsonKey(required: true) String? encoding,@JsonKey(required: true, fromJson: EncoderRead._read_width, toJson: EncoderRead._write_width) int? width,@JsonKey(required: true, fromJson: EncoderRead._read_height, toJson: EncoderRead._write_height) int? height,@JsonKey(required: true) num? fps,@JsonKey(required: true, fromJson: EncoderRead._read_bitrate, toJson: EncoderRead._write_bitrate) int? bitrate,@JsonKey(required: true, fromJson: EncoderRead._read_gop, toJson: EncoderRead._write_gop) int? gop,@JsonKey(required: true) num? quality,@JsonKey(required: true) String? profile,@JsonKey(required: true, disallowNullValue: true) List<EncoderOptionsRead> options,@JsonKey(readValue: EncoderRead._extras, fromJson: EncoderRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$EncoderReadCopyWithImpl<$Res>
    implements $EncoderReadCopyWith<$Res> {
  _$EncoderReadCopyWithImpl(this._self, this._then);

  final EncoderRead _self;
  final $Res Function(EncoderRead) _then;

/// Create a copy of EncoderRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? name = null,Object? profiles = null,Object? encoding = freezed,Object? width = freezed,Object? height = freezed,Object? fps = freezed,Object? bitrate = freezed,Object? gop = freezed,Object? quality = freezed,Object? profile = freezed,Object? options = null,Object? additionalProperties = null,}) {
  return _then(EncoderRead(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profiles: null == profiles ? _self.profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<String>,encoding: freezed == encoding ? _self.encoding : encoding // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,fps: freezed == fps ? _self.fps : fps // ignore: cast_nullable_to_non_nullable
as num?,bitrate: freezed == bitrate ? _self.bitrate : bitrate // ignore: cast_nullable_to_non_nullable
as int?,gop: freezed == gop ? _self.gop : gop // ignore: cast_nullable_to_non_nullable
as int?,quality: freezed == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as num?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String?,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<EncoderOptionsRead>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [EncoderRead].
extension EncoderReadPatterns on EncoderRead {
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
