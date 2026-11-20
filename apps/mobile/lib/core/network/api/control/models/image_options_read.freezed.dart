// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_options_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImageOptionsRead {


/// Create a copy of ImageOptionsRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageOptionsReadCopyWith<ImageOptionsRead> get copyWith => _$ImageOptionsReadCopyWithImpl<ImageOptionsRead>(this as ImageOptionsRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ImageOptionsRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageOptionsRead&&const DeepCollectionEquality().equals(other.levels, _this.levels)&&const DeepCollectionEquality().equals(other.irCutFilterModes, _this.irCutFilterModes)&&const DeepCollectionEquality().equals(other.wdrModes, _this.wdrModes)&&(identical(other.wdrLevel, _this.wdrLevel) || other.wdrLevel == _this.wdrLevel)&&const DeepCollectionEquality().equals(other.backlightModes, _this.backlightModes)&&(identical(other.backlightLevel, _this.backlightLevel) || other.backlightLevel == _this.backlightLevel)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as ImageOptionsRead;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.levels),const DeepCollectionEquality().hash(_this.irCutFilterModes),const DeepCollectionEquality().hash(_this.wdrModes),_this.wdrLevel,const DeepCollectionEquality().hash(_this.backlightModes),_this.backlightLevel,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as ImageOptionsRead;
  return 'ImageOptionsRead(levels: ${_this.levels}, irCutFilterModes: ${_this.irCutFilterModes}, wdrModes: ${_this.wdrModes}, wdrLevel: ${_this.wdrLevel}, backlightModes: ${_this.backlightModes}, backlightLevel: ${_this.backlightLevel}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ImageOptionsReadCopyWith<$Res>  {
  factory $ImageOptionsReadCopyWith(ImageOptionsRead value, $Res Function(ImageOptionsRead) _then) = _$ImageOptionsReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) Map<String, RangeRead> levels,@JsonKey(name: "ir_cut_filter_modes", required: true, disallowNullValue: true) List<String> irCutFilterModes,@JsonKey(name: "wdr_modes", required: true, disallowNullValue: true) List<String> wdrModes,@JsonKey(name: "wdr_level", required: true) RangeRead? wdrLevel,@JsonKey(name: "backlight_modes", required: true, disallowNullValue: true) List<String> backlightModes,@JsonKey(name: "backlight_level", required: true) RangeRead? backlightLevel,@JsonKey(readValue: ImageOptionsRead._extras, fromJson: ImageOptionsRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$RangeReadCopyWith<$Res>? get wdrLevel;$RangeReadCopyWith<$Res>? get backlightLevel;

}
/// @nodoc
class _$ImageOptionsReadCopyWithImpl<$Res>
    implements $ImageOptionsReadCopyWith<$Res> {
  _$ImageOptionsReadCopyWithImpl(this._self, this._then);

  final ImageOptionsRead _self;
  final $Res Function(ImageOptionsRead) _then;

/// Create a copy of ImageOptionsRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? levels = null,Object? irCutFilterModes = null,Object? wdrModes = null,Object? wdrLevel = freezed,Object? backlightModes = null,Object? backlightLevel = freezed,Object? additionalProperties = null,}) {
  return _then(ImageOptionsRead(
levels: null == levels ? _self.levels : levels // ignore: cast_nullable_to_non_nullable
as Map<String, RangeRead>,irCutFilterModes: null == irCutFilterModes ? _self.irCutFilterModes : irCutFilterModes // ignore: cast_nullable_to_non_nullable
as List<String>,wdrModes: null == wdrModes ? _self.wdrModes : wdrModes // ignore: cast_nullable_to_non_nullable
as List<String>,wdrLevel: freezed == wdrLevel ? _self.wdrLevel : wdrLevel // ignore: cast_nullable_to_non_nullable
as RangeRead?,backlightModes: null == backlightModes ? _self.backlightModes : backlightModes // ignore: cast_nullable_to_non_nullable
as List<String>,backlightLevel: freezed == backlightLevel ? _self.backlightLevel : backlightLevel // ignore: cast_nullable_to_non_nullable
as RangeRead?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of ImageOptionsRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RangeReadCopyWith<$Res>? get wdrLevel {
    if (_self.wdrLevel == null) {
    return null;
  }

  return $RangeReadCopyWith<$Res>(_self.wdrLevel!, (value) {
    return _then(_self.copyWith(wdrLevel: value));
  });
}/// Create a copy of ImageOptionsRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RangeReadCopyWith<$Res>? get backlightLevel {
    if (_self.backlightLevel == null) {
    return null;
  }

  return $RangeReadCopyWith<$Res>(_self.backlightLevel!, (value) {
    return _then(_self.copyWith(backlightLevel: value));
  });
}
}


/// Adds pattern-matching-related methods to [ImageOptionsRead].
extension ImageOptionsReadPatterns on ImageOptionsRead {
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
