// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImageSettings {


/// Create a copy of ImageSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageSettingsCopyWith<ImageSettings> get copyWith => _$ImageSettingsCopyWithImpl<ImageSettings>(this as ImageSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ImageSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageSettings&&(identical(other.brightness, _this.brightness) || other.brightness == _this.brightness)&&(identical(other.contrast, _this.contrast) || other.contrast == _this.contrast)&&(identical(other.saturation, _this.saturation) || other.saturation == _this.saturation)&&(identical(other.sharpness, _this.sharpness) || other.sharpness == _this.sharpness)&&(identical(other.irCutFilter, _this.irCutFilter) || other.irCutFilter == _this.irCutFilter)&&(identical(other.wdrMode, _this.wdrMode) || other.wdrMode == _this.wdrMode)&&(identical(other.wdrLevel, _this.wdrLevel) || other.wdrLevel == _this.wdrLevel)&&(identical(other.backlightMode, _this.backlightMode) || other.backlightMode == _this.backlightMode)&&(identical(other.backlightLevel, _this.backlightLevel) || other.backlightLevel == _this.backlightLevel)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as ImageSettings;
  return Object.hash(runtimeType,_this.brightness,_this.contrast,_this.saturation,_this.sharpness,_this.irCutFilter,_this.wdrMode,_this.wdrLevel,_this.backlightMode,_this.backlightLevel,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as ImageSettings;
  return 'ImageSettings(brightness: ${_this.brightness}, contrast: ${_this.contrast}, saturation: ${_this.saturation}, sharpness: ${_this.sharpness}, irCutFilter: ${_this.irCutFilter}, wdrMode: ${_this.wdrMode}, wdrLevel: ${_this.wdrLevel}, backlightMode: ${_this.backlightMode}, backlightLevel: ${_this.backlightLevel}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ImageSettingsCopyWith<$Res>  {
  factory $ImageSettingsCopyWith(ImageSettings value, $Res Function(ImageSettings) _then) = _$ImageSettingsCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) num? brightness,@JsonKey(includeIfNull: false) num? contrast,@JsonKey(includeIfNull: false) num? saturation,@JsonKey(includeIfNull: false) num? sharpness,@JsonKey(name: "ir_cut_filter", includeIfNull: false) String? irCutFilter,@JsonKey(name: "wdr_mode", includeIfNull: false) String? wdrMode,@JsonKey(name: "wdr_level", includeIfNull: false) num? wdrLevel,@JsonKey(name: "backlight_mode", includeIfNull: false) String? backlightMode,@JsonKey(name: "backlight_level", includeIfNull: false) num? backlightLevel,@JsonKey(readValue: ImageSettings._extras, fromJson: ImageSettings._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$ImageSettingsCopyWithImpl<$Res>
    implements $ImageSettingsCopyWith<$Res> {
  _$ImageSettingsCopyWithImpl(this._self, this._then);

  final ImageSettings _self;
  final $Res Function(ImageSettings) _then;

/// Create a copy of ImageSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? brightness = freezed,Object? contrast = freezed,Object? saturation = freezed,Object? sharpness = freezed,Object? irCutFilter = freezed,Object? wdrMode = freezed,Object? wdrLevel = freezed,Object? backlightMode = freezed,Object? backlightLevel = freezed,Object? additionalProperties = null,}) {
  return _then(ImageSettings(
brightness: freezed == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as num?,contrast: freezed == contrast ? _self.contrast : contrast // ignore: cast_nullable_to_non_nullable
as num?,saturation: freezed == saturation ? _self.saturation : saturation // ignore: cast_nullable_to_non_nullable
as num?,sharpness: freezed == sharpness ? _self.sharpness : sharpness // ignore: cast_nullable_to_non_nullable
as num?,irCutFilter: freezed == irCutFilter ? _self.irCutFilter : irCutFilter // ignore: cast_nullable_to_non_nullable
as String?,wdrMode: freezed == wdrMode ? _self.wdrMode : wdrMode // ignore: cast_nullable_to_non_nullable
as String?,wdrLevel: freezed == wdrLevel ? _self.wdrLevel : wdrLevel // ignore: cast_nullable_to_non_nullable
as num?,backlightMode: freezed == backlightMode ? _self.backlightMode : backlightMode // ignore: cast_nullable_to_non_nullable
as String?,backlightLevel: freezed == backlightLevel ? _self.backlightLevel : backlightLevel // ignore: cast_nullable_to_non_nullable
as num?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageSettings].
extension ImageSettingsPatterns on ImageSettings {
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
