// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ViewUpdate {


/// Create a copy of ViewUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ViewUpdateCopyWith<ViewUpdate> get copyWith => _$ViewUpdateCopyWithImpl<ViewUpdate>(this as ViewUpdate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ViewUpdate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewUpdate&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.fps, _this.fps) || other.fps == _this.fps)&&(identical(other.tamper, _this.tamper) || other.tamper == _this.tamper)&&(identical(other.faces, _this.faces) || other.faces == _this.faces)&&(identical(other.moving, _this.moving) || other.moving == _this.moving)&&(identical(other.appearance, _this.appearance) || other.appearance == _this.appearance)&&(identical(other.falls, _this.falls) || other.falls == _this.falls)&&(identical(other.plates, _this.plates) || other.plates == _this.plates)&&(identical(other.follow, _this.follow) || other.follow == _this.follow)&&(identical(other.stream, _this.stream) || other.stream == _this.stream)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as ViewUpdate;
  return Object.hash(runtimeType,_this.name,_this.profile,_this.enabled,_this.fps,_this.tamper,_this.faces,_this.moving,_this.appearance,_this.falls,_this.plates,_this.follow,_this.stream,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as ViewUpdate;
  return 'ViewUpdate(name: ${_this.name}, profile: ${_this.profile}, enabled: ${_this.enabled}, fps: ${_this.fps}, tamper: ${_this.tamper}, faces: ${_this.faces}, moving: ${_this.moving}, appearance: ${_this.appearance}, falls: ${_this.falls}, plates: ${_this.plates}, follow: ${_this.follow}, stream: ${_this.stream}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ViewUpdateCopyWith<$Res>  {
  factory $ViewUpdateCopyWith(ViewUpdate value, $Res Function(ViewUpdate) _then) = _$ViewUpdateCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false, fromJson: ViewUpdate._read_profile, toJson: ViewUpdate._write_profile) Profile? profile,@JsonKey(includeIfNull: false) bool? enabled,@JsonKey(includeIfNull: false) num? fps,@JsonKey(includeIfNull: false) bool? tamper,@JsonKey(includeIfNull: false) bool? faces,@JsonKey(includeIfNull: false) bool? moving,@JsonKey(includeIfNull: false) bool? appearance,@JsonKey(includeIfNull: false) bool? falls,@JsonKey(includeIfNull: false) bool? plates,@JsonKey(includeIfNull: false) bool? follow,@JsonKey(includeIfNull: false, fromJson: ViewUpdate._read_stream, toJson: ViewUpdate._write_stream) ViewStream? stream,@JsonKey(readValue: ViewUpdate._extras, fromJson: ViewUpdate._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$ViewUpdateCopyWithImpl<$Res>
    implements $ViewUpdateCopyWith<$Res> {
  _$ViewUpdateCopyWithImpl(this._self, this._then);

  final ViewUpdate _self;
  final $Res Function(ViewUpdate) _then;

/// Create a copy of ViewUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? profile = freezed,Object? enabled = freezed,Object? fps = freezed,Object? tamper = freezed,Object? faces = freezed,Object? moving = freezed,Object? appearance = freezed,Object? falls = freezed,Object? plates = freezed,Object? follow = freezed,Object? stream = freezed,Object? additionalProperties = null,}) {
  return _then(ViewUpdate(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile?,enabled: freezed == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool?,fps: freezed == fps ? _self.fps : fps // ignore: cast_nullable_to_non_nullable
as num?,tamper: freezed == tamper ? _self.tamper : tamper // ignore: cast_nullable_to_non_nullable
as bool?,faces: freezed == faces ? _self.faces : faces // ignore: cast_nullable_to_non_nullable
as bool?,moving: freezed == moving ? _self.moving : moving // ignore: cast_nullable_to_non_nullable
as bool?,appearance: freezed == appearance ? _self.appearance : appearance // ignore: cast_nullable_to_non_nullable
as bool?,falls: freezed == falls ? _self.falls : falls // ignore: cast_nullable_to_non_nullable
as bool?,plates: freezed == plates ? _self.plates : plates // ignore: cast_nullable_to_non_nullable
as bool?,follow: freezed == follow ? _self.follow : follow // ignore: cast_nullable_to_non_nullable
as bool?,stream: freezed == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as ViewStream?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [ViewUpdate].
extension ViewUpdatePatterns on ViewUpdate {
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
