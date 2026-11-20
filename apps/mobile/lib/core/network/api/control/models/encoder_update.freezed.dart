// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encoder_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EncoderUpdate {


/// Create a copy of EncoderUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncoderUpdateCopyWith<EncoderUpdate> get copyWith => _$EncoderUpdateCopyWithImpl<EncoderUpdate>(this as EncoderUpdate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EncoderUpdate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncoderUpdate&&(identical(other.encoding, _this.encoding) || other.encoding == _this.encoding)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.fps, _this.fps) || other.fps == _this.fps)&&(identical(other.bitrate, _this.bitrate) || other.bitrate == _this.bitrate)&&(identical(other.gop, _this.gop) || other.gop == _this.gop)&&(identical(other.quality, _this.quality) || other.quality == _this.quality)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as EncoderUpdate;
  return Object.hash(runtimeType,_this.encoding,_this.width,_this.height,_this.fps,_this.bitrate,_this.gop,_this.quality,_this.profile,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as EncoderUpdate;
  return 'EncoderUpdate(encoding: ${_this.encoding}, width: ${_this.width}, height: ${_this.height}, fps: ${_this.fps}, bitrate: ${_this.bitrate}, gop: ${_this.gop}, quality: ${_this.quality}, profile: ${_this.profile}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $EncoderUpdateCopyWith<$Res>  {
  factory $EncoderUpdateCopyWith(EncoderUpdate value, $Res Function(EncoderUpdate) _then) = _$EncoderUpdateCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? encoding,@JsonKey(includeIfNull: false, fromJson: EncoderUpdate._read_width, toJson: EncoderUpdate._write_width) int? width,@JsonKey(includeIfNull: false, fromJson: EncoderUpdate._read_height, toJson: EncoderUpdate._write_height) int? height,@JsonKey(includeIfNull: false) num? fps,@JsonKey(includeIfNull: false, fromJson: EncoderUpdate._read_bitrate, toJson: EncoderUpdate._write_bitrate) int? bitrate,@JsonKey(includeIfNull: false, fromJson: EncoderUpdate._read_gop, toJson: EncoderUpdate._write_gop) int? gop,@JsonKey(includeIfNull: false) num? quality,@JsonKey(includeIfNull: false) String? profile,@JsonKey(readValue: EncoderUpdate._extras, fromJson: EncoderUpdate._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$EncoderUpdateCopyWithImpl<$Res>
    implements $EncoderUpdateCopyWith<$Res> {
  _$EncoderUpdateCopyWithImpl(this._self, this._then);

  final EncoderUpdate _self;
  final $Res Function(EncoderUpdate) _then;

/// Create a copy of EncoderUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? encoding = freezed,Object? width = freezed,Object? height = freezed,Object? fps = freezed,Object? bitrate = freezed,Object? gop = freezed,Object? quality = freezed,Object? profile = freezed,Object? additionalProperties = null,}) {
  return _then(EncoderUpdate(
encoding: freezed == encoding ? _self.encoding : encoding // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,fps: freezed == fps ? _self.fps : fps // ignore: cast_nullable_to_non_nullable
as num?,bitrate: freezed == bitrate ? _self.bitrate : bitrate // ignore: cast_nullable_to_non_nullable
as int?,gop: freezed == gop ? _self.gop : gop // ignore: cast_nullable_to_non_nullable
as int?,quality: freezed == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as num?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [EncoderUpdate].
extension EncoderUpdatePatterns on EncoderUpdate {
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
