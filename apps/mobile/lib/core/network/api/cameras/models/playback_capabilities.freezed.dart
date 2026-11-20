// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_capabilities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlaybackCapabilities {


/// Create a copy of PlaybackCapabilities
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackCapabilitiesCopyWith<PlaybackCapabilities> get copyWith => _$PlaybackCapabilitiesCopyWithImpl<PlaybackCapabilities>(this as PlaybackCapabilities, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlaybackCapabilities;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackCapabilities&&(identical(other.recordings, _this.recordings) || other.recordings == _this.recordings)&&(identical(other.replay, _this.replay) || other.replay == _this.replay)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as PlaybackCapabilities;
  return Object.hash(runtimeType,_this.recordings,_this.replay,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as PlaybackCapabilities;
  return 'PlaybackCapabilities(recordings: ${_this.recordings}, replay: ${_this.replay}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $PlaybackCapabilitiesCopyWith<$Res>  {
  factory $PlaybackCapabilitiesCopyWith(PlaybackCapabilities value, $Res Function(PlaybackCapabilities) _then) = _$PlaybackCapabilitiesCopyWithImpl;
@useResult
$Res call({
@JsonKey(disallowNullValue: true, readValue: PlaybackCapabilities._presentValue, fromJson: PlaybackCapabilities._read_recordings, toJson: PlaybackCapabilities._write_recordings) bool recordings,@JsonKey(disallowNullValue: true, readValue: PlaybackCapabilities._presentValue, fromJson: PlaybackCapabilities._read_replay, toJson: PlaybackCapabilities._write_replay) bool replay,@JsonKey(readValue: PlaybackCapabilities._extras, fromJson: PlaybackCapabilities._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$PlaybackCapabilitiesCopyWithImpl<$Res>
    implements $PlaybackCapabilitiesCopyWith<$Res> {
  _$PlaybackCapabilitiesCopyWithImpl(this._self, this._then);

  final PlaybackCapabilities _self;
  final $Res Function(PlaybackCapabilities) _then;

/// Create a copy of PlaybackCapabilities
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recordings = null,Object? replay = null,Object? additionalProperties = null,}) {
  return _then(PlaybackCapabilities(
recordings: null == recordings ? _self.recordings : recordings // ignore: cast_nullable_to_non_nullable
as bool,replay: null == replay ? _self.replay : replay // ignore: cast_nullable_to_non_nullable
as bool,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaybackCapabilities].
extension PlaybackCapabilitiesPatterns on PlaybackCapabilities {
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
