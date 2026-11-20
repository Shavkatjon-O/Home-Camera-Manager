// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encoder_options_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EncoderOptionsRead {


/// Create a copy of EncoderOptionsRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncoderOptionsReadCopyWith<EncoderOptionsRead> get copyWith => _$EncoderOptionsReadCopyWithImpl<EncoderOptionsRead>(this as EncoderOptionsRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EncoderOptionsRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncoderOptionsRead&&(identical(other.encoding, _this.encoding) || other.encoding == _this.encoding)&&const DeepCollectionEquality().equals(other.resolutions, _this.resolutions)&&const DeepCollectionEquality().equals(other.fpsValues, _this.fpsValues)&&(identical(other.fps, _this.fps) || other.fps == _this.fps)&&(identical(other.bitrate, _this.bitrate) || other.bitrate == _this.bitrate)&&(identical(other.gop, _this.gop) || other.gop == _this.gop)&&(identical(other.quality, _this.quality) || other.quality == _this.quality)&&const DeepCollectionEquality().equals(other.profiles, _this.profiles)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as EncoderOptionsRead;
  return Object.hash(runtimeType,_this.encoding,const DeepCollectionEquality().hash(_this.resolutions),const DeepCollectionEquality().hash(_this.fpsValues),_this.fps,_this.bitrate,_this.gop,_this.quality,const DeepCollectionEquality().hash(_this.profiles),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as EncoderOptionsRead;
  return 'EncoderOptionsRead(encoding: ${_this.encoding}, resolutions: ${_this.resolutions}, fpsValues: ${_this.fpsValues}, fps: ${_this.fps}, bitrate: ${_this.bitrate}, gop: ${_this.gop}, quality: ${_this.quality}, profiles: ${_this.profiles}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $EncoderOptionsReadCopyWith<$Res>  {
  factory $EncoderOptionsReadCopyWith(EncoderOptionsRead value, $Res Function(EncoderOptionsRead) _then) = _$EncoderOptionsReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String encoding,@JsonKey(required: true, disallowNullValue: true) List<ResolutionRead> resolutions,@JsonKey(name: "fps_values", required: true, disallowNullValue: true) List<num> fpsValues,@JsonKey(required: true) RangeRead? fps,@JsonKey(required: true) RangeRead? bitrate,@JsonKey(required: true) RangeRead? gop,@JsonKey(required: true) RangeRead? quality,@JsonKey(required: true, disallowNullValue: true) List<String> profiles,@JsonKey(readValue: EncoderOptionsRead._extras, fromJson: EncoderOptionsRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$RangeReadCopyWith<$Res>? get fps;$RangeReadCopyWith<$Res>? get bitrate;$RangeReadCopyWith<$Res>? get gop;$RangeReadCopyWith<$Res>? get quality;

}
/// @nodoc
class _$EncoderOptionsReadCopyWithImpl<$Res>
    implements $EncoderOptionsReadCopyWith<$Res> {
  _$EncoderOptionsReadCopyWithImpl(this._self, this._then);

  final EncoderOptionsRead _self;
  final $Res Function(EncoderOptionsRead) _then;

/// Create a copy of EncoderOptionsRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? encoding = null,Object? resolutions = null,Object? fpsValues = null,Object? fps = freezed,Object? bitrate = freezed,Object? gop = freezed,Object? quality = freezed,Object? profiles = null,Object? additionalProperties = null,}) {
  return _then(EncoderOptionsRead(
encoding: null == encoding ? _self.encoding : encoding // ignore: cast_nullable_to_non_nullable
as String,resolutions: null == resolutions ? _self.resolutions : resolutions // ignore: cast_nullable_to_non_nullable
as List<ResolutionRead>,fpsValues: null == fpsValues ? _self.fpsValues : fpsValues // ignore: cast_nullable_to_non_nullable
as List<num>,fps: freezed == fps ? _self.fps : fps // ignore: cast_nullable_to_non_nullable
as RangeRead?,bitrate: freezed == bitrate ? _self.bitrate : bitrate // ignore: cast_nullable_to_non_nullable
as RangeRead?,gop: freezed == gop ? _self.gop : gop // ignore: cast_nullable_to_non_nullable
as RangeRead?,quality: freezed == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as RangeRead?,profiles: null == profiles ? _self.profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<String>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of EncoderOptionsRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RangeReadCopyWith<$Res>? get fps {
    if (_self.fps == null) {
    return null;
  }

  return $RangeReadCopyWith<$Res>(_self.fps!, (value) {
    return _then(_self.copyWith(fps: value));
  });
}/// Create a copy of EncoderOptionsRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RangeReadCopyWith<$Res>? get bitrate {
    if (_self.bitrate == null) {
    return null;
  }

  return $RangeReadCopyWith<$Res>(_self.bitrate!, (value) {
    return _then(_self.copyWith(bitrate: value));
  });
}/// Create a copy of EncoderOptionsRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RangeReadCopyWith<$Res>? get gop {
    if (_self.gop == null) {
    return null;
  }

  return $RangeReadCopyWith<$Res>(_self.gop!, (value) {
    return _then(_self.copyWith(gop: value));
  });
}/// Create a copy of EncoderOptionsRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RangeReadCopyWith<$Res>? get quality {
    if (_self.quality == null) {
    return null;
  }

  return $RangeReadCopyWith<$Res>(_self.quality!, (value) {
    return _then(_self.copyWith(quality: value));
  });
}
}


/// Adds pattern-matching-related methods to [EncoderOptionsRead].
extension EncoderOptionsReadPatterns on EncoderOptionsRead {
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
