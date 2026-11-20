// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_capabilities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MediaCapabilities {


/// Create a copy of MediaCapabilities
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaCapabilitiesCopyWith<MediaCapabilities> get copyWith => _$MediaCapabilitiesCopyWithImpl<MediaCapabilities>(this as MediaCapabilities, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MediaCapabilities;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaCapabilities&&(identical(other.main, _this.main) || other.main == _this.main)&&(identical(other.sub, _this.sub) || other.sub == _this.sub)&&(identical(other.snapshot, _this.snapshot) || other.snapshot == _this.snapshot)&&(identical(other.audio, _this.audio) || other.audio == _this.audio)&&const DeepCollectionEquality().equals(other.codecs, _this.codecs)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as MediaCapabilities;
  return Object.hash(runtimeType,_this.main,_this.sub,_this.snapshot,_this.audio,const DeepCollectionEquality().hash(_this.codecs),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as MediaCapabilities;
  return 'MediaCapabilities(main: ${_this.main}, sub: ${_this.sub}, snapshot: ${_this.snapshot}, audio: ${_this.audio}, codecs: ${_this.codecs}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $MediaCapabilitiesCopyWith<$Res>  {
  factory $MediaCapabilitiesCopyWith(MediaCapabilities value, $Res Function(MediaCapabilities) _then) = _$MediaCapabilitiesCopyWithImpl;
@useResult
$Res call({
@JsonKey(disallowNullValue: true, readValue: MediaCapabilities._presentValue, fromJson: MediaCapabilities._read_main, toJson: MediaCapabilities._write_main) bool main,@JsonKey(disallowNullValue: true, readValue: MediaCapabilities._presentValue, fromJson: MediaCapabilities._read_sub, toJson: MediaCapabilities._write_sub) bool sub,@JsonKey(disallowNullValue: true, readValue: MediaCapabilities._presentValue, fromJson: MediaCapabilities._read_snapshot, toJson: MediaCapabilities._write_snapshot) bool snapshot,@JsonKey(disallowNullValue: true, readValue: MediaCapabilities._presentValue, fromJson: MediaCapabilities._read_audio, toJson: MediaCapabilities._write_audio) bool audio,@JsonKey(disallowNullValue: true, readValue: MediaCapabilities._presentValue, fromJson: MediaCapabilities._read_codecs, toJson: MediaCapabilities._write_codecs) List<String> codecs,@JsonKey(readValue: MediaCapabilities._extras, fromJson: MediaCapabilities._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$MediaCapabilitiesCopyWithImpl<$Res>
    implements $MediaCapabilitiesCopyWith<$Res> {
  _$MediaCapabilitiesCopyWithImpl(this._self, this._then);

  final MediaCapabilities _self;
  final $Res Function(MediaCapabilities) _then;

/// Create a copy of MediaCapabilities
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? main = null,Object? sub = null,Object? snapshot = null,Object? audio = null,Object? codecs = null,Object? additionalProperties = null,}) {
  return _then(MediaCapabilities(
main: null == main ? _self.main : main // ignore: cast_nullable_to_non_nullable
as bool,sub: null == sub ? _self.sub : sub // ignore: cast_nullable_to_non_nullable
as bool,snapshot: null == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as bool,audio: null == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as bool,codecs: null == codecs ? _self.codecs : codecs // ignore: cast_nullable_to_non_nullable
as List<String>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaCapabilities].
extension MediaCapabilitiesPatterns on MediaCapabilities {
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
