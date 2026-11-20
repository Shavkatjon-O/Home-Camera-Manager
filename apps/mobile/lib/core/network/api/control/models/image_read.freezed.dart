// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImageRead {


/// Create a copy of ImageRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageReadCopyWith<ImageRead> get copyWith => _$ImageReadCopyWithImpl<ImageRead>(this as ImageRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ImageRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageRead&&(identical(other.cameraUuid, _this.cameraUuid) || other.cameraUuid == _this.cameraUuid)&&(identical(other.supported, _this.supported) || other.supported == _this.supported)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.sourceToken, _this.sourceToken) || other.sourceToken == _this.sourceToken)&&(identical(other.settings, _this.settings) || other.settings == _this.settings)&&(identical(other.options, _this.options) || other.options == _this.options)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as ImageRead;
  return Object.hash(runtimeType,_this.cameraUuid,_this.supported,_this.reason,_this.sourceToken,_this.settings,_this.options,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as ImageRead;
  return 'ImageRead(cameraUuid: ${_this.cameraUuid}, supported: ${_this.supported}, reason: ${_this.reason}, sourceToken: ${_this.sourceToken}, settings: ${_this.settings}, options: ${_this.options}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ImageReadCopyWith<$Res>  {
  factory $ImageReadCopyWith(ImageRead value, $Res Function(ImageRead) _then) = _$ImageReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "camera_uuid", required: true, disallowNullValue: true) String cameraUuid,@JsonKey(required: true, disallowNullValue: true) bool supported,@JsonKey(includeIfNull: false) String? reason,@JsonKey(name: "source_token", includeIfNull: false) String? sourceToken,@JsonKey(includeIfNull: false) ImageSettings? settings,@JsonKey(includeIfNull: false) ImageOptionsRead? options,@JsonKey(readValue: ImageRead._extras, fromJson: ImageRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$ImageSettingsCopyWith<$Res>? get settings;$ImageOptionsReadCopyWith<$Res>? get options;

}
/// @nodoc
class _$ImageReadCopyWithImpl<$Res>
    implements $ImageReadCopyWith<$Res> {
  _$ImageReadCopyWithImpl(this._self, this._then);

  final ImageRead _self;
  final $Res Function(ImageRead) _then;

/// Create a copy of ImageRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cameraUuid = null,Object? supported = null,Object? reason = freezed,Object? sourceToken = freezed,Object? settings = freezed,Object? options = freezed,Object? additionalProperties = null,}) {
  return _then(ImageRead(
cameraUuid: null == cameraUuid ? _self.cameraUuid : cameraUuid // ignore: cast_nullable_to_non_nullable
as String,supported: null == supported ? _self.supported : supported // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,sourceToken: freezed == sourceToken ? _self.sourceToken : sourceToken // ignore: cast_nullable_to_non_nullable
as String?,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as ImageSettings?,options: freezed == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as ImageOptionsRead?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of ImageRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageSettingsCopyWith<$Res>? get settings {
    if (_self.settings == null) {
    return null;
  }

  return $ImageSettingsCopyWith<$Res>(_self.settings!, (value) {
    return _then(_self.copyWith(settings: value));
  });
}/// Create a copy of ImageRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageOptionsReadCopyWith<$Res>? get options {
    if (_self.options == null) {
    return null;
  }

  return $ImageOptionsReadCopyWith<$Res>(_self.options!, (value) {
    return _then(_self.copyWith(options: value));
  });
}
}


/// Adds pattern-matching-related methods to [ImageRead].
extension ImageReadPatterns on ImageRead {
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
