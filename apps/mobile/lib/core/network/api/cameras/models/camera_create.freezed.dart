// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_create.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CameraCreate {


/// Create a copy of CameraCreate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraCreateCopyWith<CameraCreate> get copyWith => _$CameraCreateCopyWithImpl<CameraCreate>(this as CameraCreate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CameraCreate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraCreate&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.deviceHost, _this.deviceHost) || other.deviceHost == _this.deviceHost)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.rtspPort, _this.rtspPort) || other.rtspPort == _this.rtspPort)&&(identical(other.onvifPort, _this.onvifPort) || other.onvifPort == _this.onvifPort)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.mainPath, _this.mainPath) || other.mainPath == _this.mainPath)&&(identical(other.subPath, _this.subPath) || other.subPath == _this.subPath)&&(identical(other.lenses, _this.lenses) || other.lenses == _this.lenses)&&(identical(other.ptzEnabled, _this.ptzEnabled) || other.ptzEnabled == _this.ptzEnabled)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.connector, _this.connector) || other.connector == _this.connector)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as CameraCreate;
  return Object.hash(runtimeType,_this.name,_this.brand,_this.host,_this.deviceHost,_this.location,_this.rtspPort,_this.onvifPort,_this.username,_this.password,_this.mainPath,_this.subPath,_this.lenses,_this.ptzEnabled,_this.enabled,_this.connector,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as CameraCreate;
  return 'CameraCreate(name: ${_this.name}, brand: ${_this.brand}, host: ${_this.host}, deviceHost: ${_this.deviceHost}, location: ${_this.location}, rtspPort: ${_this.rtspPort}, onvifPort: ${_this.onvifPort}, username: ${_this.username}, password: ${_this.password}, mainPath: ${_this.mainPath}, subPath: ${_this.subPath}, lenses: ${_this.lenses}, ptzEnabled: ${_this.ptzEnabled}, enabled: ${_this.enabled}, connector: ${_this.connector}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $CameraCreateCopyWith<$Res>  {
  factory $CameraCreateCopyWith(CameraCreate value, $Res Function(CameraCreate) _then) = _$CameraCreateCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true, disallowNullValue: true, fromJson: CameraCreate._read_brand, toJson: CameraCreate._write_brand) CameraBrand brand,@JsonKey(required: true, disallowNullValue: true) String host,@JsonKey(name: "device_host", includeIfNull: false) String? deviceHost,@JsonKey(includeIfNull: false) String? location,@JsonKey(name: "rtsp_port", includeIfNull: false, fromJson: CameraCreate._read_rtspPort, toJson: CameraCreate._write_rtspPort) int? rtspPort,@JsonKey(name: "onvif_port", includeIfNull: false, fromJson: CameraCreate._read_onvifPort, toJson: CameraCreate._write_onvifPort) int? onvifPort,@JsonKey(includeIfNull: false) String? username,@JsonKey(includeIfNull: false) String? password,@JsonKey(name: "main_path", includeIfNull: false) String? mainPath,@JsonKey(name: "sub_path", includeIfNull: false) String? subPath,@JsonKey(disallowNullValue: true, readValue: CameraCreate._presentValue, fromJson: CameraCreate._read_lenses, toJson: CameraCreate._write_lenses) int lenses,@JsonKey(name: "ptz_enabled", includeIfNull: false) bool? ptzEnabled,@JsonKey(disallowNullValue: true, readValue: CameraCreate._presentValue, fromJson: CameraCreate._read_enabled, toJson: CameraCreate._write_enabled) bool enabled,@JsonKey(includeIfNull: false) String? connector,@JsonKey(readValue: CameraCreate._extras, fromJson: CameraCreate._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$CameraCreateCopyWithImpl<$Res>
    implements $CameraCreateCopyWith<$Res> {
  _$CameraCreateCopyWithImpl(this._self, this._then);

  final CameraCreate _self;
  final $Res Function(CameraCreate) _then;

/// Create a copy of CameraCreate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? brand = null,Object? host = null,Object? deviceHost = freezed,Object? location = freezed,Object? rtspPort = freezed,Object? onvifPort = freezed,Object? username = freezed,Object? password = freezed,Object? mainPath = freezed,Object? subPath = freezed,Object? lenses = null,Object? ptzEnabled = freezed,Object? enabled = null,Object? connector = freezed,Object? additionalProperties = null,}) {
  return _then(CameraCreate(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as CameraBrand,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,deviceHost: freezed == deviceHost ? _self.deviceHost : deviceHost // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,rtspPort: freezed == rtspPort ? _self.rtspPort : rtspPort // ignore: cast_nullable_to_non_nullable
as int?,onvifPort: freezed == onvifPort ? _self.onvifPort : onvifPort // ignore: cast_nullable_to_non_nullable
as int?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,mainPath: freezed == mainPath ? _self.mainPath : mainPath // ignore: cast_nullable_to_non_nullable
as String?,subPath: freezed == subPath ? _self.subPath : subPath // ignore: cast_nullable_to_non_nullable
as String?,lenses: null == lenses ? _self.lenses : lenses // ignore: cast_nullable_to_non_nullable
as int,ptzEnabled: freezed == ptzEnabled ? _self.ptzEnabled : ptzEnabled // ignore: cast_nullable_to_non_nullable
as bool?,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,connector: freezed == connector ? _self.connector : connector // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [CameraCreate].
extension CameraCreatePatterns on CameraCreate {
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
