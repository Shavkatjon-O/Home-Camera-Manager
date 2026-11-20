// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'control_capabilities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ControlCapabilities {


/// Create a copy of ControlCapabilities
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ControlCapabilitiesCopyWith<ControlCapabilities> get copyWith => _$ControlCapabilitiesCopyWithImpl<ControlCapabilities>(this as ControlCapabilities, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ControlCapabilities;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ControlCapabilities&&(identical(other.ptz, _this.ptz) || other.ptz == _this.ptz)&&(identical(other.zoom, _this.zoom) || other.zoom == _this.zoom)&&(identical(other.presets, _this.presets) || other.presets == _this.presets)&&(identical(other.home, _this.home) || other.home == _this.home)&&(identical(other.light, _this.light) || other.light == _this.light)&&(identical(other.siren, _this.siren) || other.siren == _this.siren)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as ControlCapabilities;
  return Object.hash(runtimeType,_this.ptz,_this.zoom,_this.presets,_this.home,_this.light,_this.siren,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as ControlCapabilities;
  return 'ControlCapabilities(ptz: ${_this.ptz}, zoom: ${_this.zoom}, presets: ${_this.presets}, home: ${_this.home}, light: ${_this.light}, siren: ${_this.siren}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ControlCapabilitiesCopyWith<$Res>  {
  factory $ControlCapabilitiesCopyWith(ControlCapabilities value, $Res Function(ControlCapabilities) _then) = _$ControlCapabilitiesCopyWithImpl;
@useResult
$Res call({
@JsonKey(disallowNullValue: true, readValue: ControlCapabilities._presentValue, fromJson: ControlCapabilities._read_ptz, toJson: ControlCapabilities._write_ptz) bool ptz,@JsonKey(disallowNullValue: true, readValue: ControlCapabilities._presentValue, fromJson: ControlCapabilities._read_zoom, toJson: ControlCapabilities._write_zoom) bool zoom,@JsonKey(disallowNullValue: true, readValue: ControlCapabilities._presentValue, fromJson: ControlCapabilities._read_presets, toJson: ControlCapabilities._write_presets) bool presets,@JsonKey(disallowNullValue: true, readValue: ControlCapabilities._presentValue, fromJson: ControlCapabilities._read_home, toJson: ControlCapabilities._write_home) bool home,@JsonKey(disallowNullValue: true, readValue: ControlCapabilities._presentValue, fromJson: ControlCapabilities._read_light, toJson: ControlCapabilities._write_light) bool light,@JsonKey(disallowNullValue: true, readValue: ControlCapabilities._presentValue, fromJson: ControlCapabilities._read_siren, toJson: ControlCapabilities._write_siren) bool siren,@JsonKey(readValue: ControlCapabilities._extras, fromJson: ControlCapabilities._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$ControlCapabilitiesCopyWithImpl<$Res>
    implements $ControlCapabilitiesCopyWith<$Res> {
  _$ControlCapabilitiesCopyWithImpl(this._self, this._then);

  final ControlCapabilities _self;
  final $Res Function(ControlCapabilities) _then;

/// Create a copy of ControlCapabilities
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ptz = null,Object? zoom = null,Object? presets = null,Object? home = null,Object? light = null,Object? siren = null,Object? additionalProperties = null,}) {
  return _then(ControlCapabilities(
ptz: null == ptz ? _self.ptz : ptz // ignore: cast_nullable_to_non_nullable
as bool,zoom: null == zoom ? _self.zoom : zoom // ignore: cast_nullable_to_non_nullable
as bool,presets: null == presets ? _self.presets : presets // ignore: cast_nullable_to_non_nullable
as bool,home: null == home ? _self.home : home // ignore: cast_nullable_to_non_nullable
as bool,light: null == light ? _self.light : light // ignore: cast_nullable_to_non_nullable
as bool,siren: null == siren ? _self.siren : siren // ignore: cast_nullable_to_non_nullable
as bool,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [ControlCapabilities].
extension ControlCapabilitiesPatterns on ControlCapabilities {
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
