// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CameraRead {


/// Create a copy of CameraRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraReadCopyWith<CameraRead> get copyWith => _$CameraReadCopyWithImpl<CameraRead>(this as CameraRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CameraRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.deviceHost, _this.deviceHost) || other.deviceHost == _this.deviceHost)&&(identical(other.rtspPort, _this.rtspPort) || other.rtspPort == _this.rtspPort)&&(identical(other.onvifPort, _this.onvifPort) || other.onvifPort == _this.onvifPort)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.hasPassword, _this.hasPassword) || other.hasPassword == _this.hasPassword)&&(identical(other.mainPath, _this.mainPath) || other.mainPath == _this.mainPath)&&(identical(other.subPath, _this.subPath) || other.subPath == _this.subPath)&&(identical(other.lenses, _this.lenses) || other.lenses == _this.lenses)&&(identical(other.ptzEnabled, _this.ptzEnabled) || other.ptzEnabled == _this.ptzEnabled)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.streams, _this.streams) || other.streams == _this.streams)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.connector, _this.connector) || other.connector == _this.connector)&&(identical(other.device, _this.device) || other.device == _this.device)&&(identical(other.channel, _this.channel) || other.channel == _this.channel)&&(identical(other.capabilities, _this.capabilities) || other.capabilities == _this.capabilities)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as CameraRead;
  return Object.hashAll([runtimeType,_this.uuid,_this.name,_this.brand,_this.host,_this.deviceHost,_this.rtspPort,_this.onvifPort,_this.username,_this.hasPassword,_this.mainPath,_this.subPath,_this.lenses,_this.ptzEnabled,_this.location,_this.position,_this.enabled,_this.status,_this.streams,_this.createdAt,_this.updatedAt,_this.connector,_this.device,_this.channel,_this.capabilities,const DeepCollectionEquality().hash(_this.additionalProperties)]);
}

@override
String toString() {
  final _this = this as CameraRead;
  return 'CameraRead(uuid: ${_this.uuid}, name: ${_this.name}, brand: ${_this.brand}, host: ${_this.host}, deviceHost: ${_this.deviceHost}, rtspPort: ${_this.rtspPort}, onvifPort: ${_this.onvifPort}, username: ${_this.username}, hasPassword: ${_this.hasPassword}, mainPath: ${_this.mainPath}, subPath: ${_this.subPath}, lenses: ${_this.lenses}, ptzEnabled: ${_this.ptzEnabled}, location: ${_this.location}, position: ${_this.position}, enabled: ${_this.enabled}, status: ${_this.status}, streams: ${_this.streams}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, connector: ${_this.connector}, device: ${_this.device}, channel: ${_this.channel}, capabilities: ${_this.capabilities}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $CameraReadCopyWith<$Res>  {
  factory $CameraReadCopyWith(CameraRead value, $Res Function(CameraRead) _then) = _$CameraReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true, disallowNullValue: true, fromJson: CameraRead._read_brand, toJson: CameraRead._write_brand) CameraBrand brand,@JsonKey(required: true, disallowNullValue: true) String host,@JsonKey(name: "device_host", required: true) String? deviceHost,@JsonKey(name: "rtsp_port", required: true, disallowNullValue: true, fromJson: CameraRead._read_rtspPort, toJson: CameraRead._write_rtspPort) int rtspPort,@JsonKey(name: "onvif_port", required: true, fromJson: CameraRead._read_onvifPort, toJson: CameraRead._write_onvifPort) int? onvifPort,@JsonKey(required: true) String? username,@JsonKey(name: "has_password", required: true, disallowNullValue: true) bool hasPassword,@JsonKey(name: "main_path", required: true, disallowNullValue: true) String mainPath,@JsonKey(name: "sub_path", required: true) String? subPath,@JsonKey(required: true, disallowNullValue: true, fromJson: CameraRead._read_lenses, toJson: CameraRead._write_lenses) int lenses,@JsonKey(name: "ptz_enabled", required: true, disallowNullValue: true) bool ptzEnabled,@JsonKey(required: true) String? location,@JsonKey(required: true, disallowNullValue: true, fromJson: CameraRead._read_position, toJson: CameraRead._write_position) int position,@JsonKey(required: true, disallowNullValue: true) bool enabled,@JsonKey(required: true, disallowNullValue: true) CameraStatus status,@JsonKey(required: true, disallowNullValue: true) CameraStreams streams,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: CameraRead._read_createdAt, toJson: CameraRead._write_createdAt) DateTime createdAt,@JsonKey(name: "updated_at", required: true, disallowNullValue: true, fromJson: CameraRead._read_updatedAt, toJson: CameraRead._write_updatedAt) DateTime updatedAt,@JsonKey(includeIfNull: false) String? connector,@JsonKey(includeIfNull: false) String? device,@JsonKey(includeIfNull: false, fromJson: CameraRead._read_channel, toJson: CameraRead._write_channel) int? channel,@JsonKey(includeIfNull: false) CapabilitiesRead? capabilities,@JsonKey(readValue: CameraRead._extras, fromJson: CameraRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$CameraStatusCopyWith<$Res> get status;$CameraStreamsCopyWith<$Res> get streams;$CapabilitiesReadCopyWith<$Res>? get capabilities;

}
/// @nodoc
class _$CameraReadCopyWithImpl<$Res>
    implements $CameraReadCopyWith<$Res> {
  _$CameraReadCopyWithImpl(this._self, this._then);

  final CameraRead _self;
  final $Res Function(CameraRead) _then;

/// Create a copy of CameraRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? name = null,Object? brand = null,Object? host = null,Object? deviceHost = freezed,Object? rtspPort = null,Object? onvifPort = freezed,Object? username = freezed,Object? hasPassword = null,Object? mainPath = null,Object? subPath = freezed,Object? lenses = null,Object? ptzEnabled = null,Object? location = freezed,Object? position = null,Object? enabled = null,Object? status = null,Object? streams = null,Object? createdAt = null,Object? updatedAt = null,Object? connector = freezed,Object? device = freezed,Object? channel = freezed,Object? capabilities = freezed,Object? additionalProperties = null,}) {
  return _then(CameraRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as CameraBrand,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,deviceHost: freezed == deviceHost ? _self.deviceHost : deviceHost // ignore: cast_nullable_to_non_nullable
as String?,rtspPort: null == rtspPort ? _self.rtspPort : rtspPort // ignore: cast_nullable_to_non_nullable
as int,onvifPort: freezed == onvifPort ? _self.onvifPort : onvifPort // ignore: cast_nullable_to_non_nullable
as int?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,mainPath: null == mainPath ? _self.mainPath : mainPath // ignore: cast_nullable_to_non_nullable
as String,subPath: freezed == subPath ? _self.subPath : subPath // ignore: cast_nullable_to_non_nullable
as String?,lenses: null == lenses ? _self.lenses : lenses // ignore: cast_nullable_to_non_nullable
as int,ptzEnabled: null == ptzEnabled ? _self.ptzEnabled : ptzEnabled // ignore: cast_nullable_to_non_nullable
as bool,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CameraStatus,streams: null == streams ? _self.streams : streams // ignore: cast_nullable_to_non_nullable
as CameraStreams,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,connector: freezed == connector ? _self.connector : connector // ignore: cast_nullable_to_non_nullable
as String?,device: freezed == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as String?,channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as int?,capabilities: freezed == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as CapabilitiesRead?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of CameraRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CameraStatusCopyWith<$Res> get status {
  
  return $CameraStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of CameraRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CameraStreamsCopyWith<$Res> get streams {
  
  return $CameraStreamsCopyWith<$Res>(_self.streams, (value) {
    return _then(_self.copyWith(streams: value));
  });
}/// Create a copy of CameraRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CapabilitiesReadCopyWith<$Res>? get capabilities {
    if (_self.capabilities == null) {
    return null;
  }

  return $CapabilitiesReadCopyWith<$Res>(_self.capabilities!, (value) {
    return _then(_self.copyWith(capabilities: value));
  });
}
}


/// Adds pattern-matching-related methods to [CameraRead].
extension CameraReadPatterns on CameraRead {
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
