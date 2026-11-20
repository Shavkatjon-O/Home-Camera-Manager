// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_device_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CameraDeviceRead {


/// Create a copy of CameraDeviceRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraDeviceReadCopyWith<CameraDeviceRead> get copyWith => _$CameraDeviceReadCopyWithImpl<CameraDeviceRead>(this as CameraDeviceRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CameraDeviceRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraDeviceRead&&(identical(other.cameraUuid, _this.cameraUuid) || other.cameraUuid == _this.cameraUuid)&&(identical(other.supported, _this.supported) || other.supported == _this.supported)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.endpoint, _this.endpoint) || other.endpoint == _this.endpoint)&&(identical(other.manufacturer, _this.manufacturer) || other.manufacturer == _this.manufacturer)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.firmware, _this.firmware) || other.firmware == _this.firmware)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.hardwareId, _this.hardwareId) || other.hardwareId == _this.hardwareId)&&(identical(other.clock, _this.clock) || other.clock == _this.clock)&&(identical(other.canReboot, _this.canReboot) || other.canReboot == _this.canReboot)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as CameraDeviceRead;
  return Object.hash(runtimeType,_this.cameraUuid,_this.supported,_this.reason,_this.endpoint,_this.manufacturer,_this.model,_this.firmware,_this.serial,_this.hardwareId,_this.clock,_this.canReboot,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as CameraDeviceRead;
  return 'CameraDeviceRead(cameraUuid: ${_this.cameraUuid}, supported: ${_this.supported}, reason: ${_this.reason}, endpoint: ${_this.endpoint}, manufacturer: ${_this.manufacturer}, model: ${_this.model}, firmware: ${_this.firmware}, serial: ${_this.serial}, hardwareId: ${_this.hardwareId}, clock: ${_this.clock}, canReboot: ${_this.canReboot}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $CameraDeviceReadCopyWith<$Res>  {
  factory $CameraDeviceReadCopyWith(CameraDeviceRead value, $Res Function(CameraDeviceRead) _then) = _$CameraDeviceReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "camera_uuid", required: true, disallowNullValue: true) String cameraUuid,@JsonKey(required: true, disallowNullValue: true) bool supported,@JsonKey(includeIfNull: false) String? reason,@JsonKey(includeIfNull: false) String? endpoint,@JsonKey(includeIfNull: false) String? manufacturer,@JsonKey(includeIfNull: false) String? model,@JsonKey(includeIfNull: false) String? firmware,@JsonKey(includeIfNull: false) String? serial,@JsonKey(name: "hardware_id", includeIfNull: false) String? hardwareId,@JsonKey(includeIfNull: false) ClockRead? clock,@JsonKey(name: "can_reboot", disallowNullValue: true, readValue: CameraDeviceRead._presentValue, fromJson: CameraDeviceRead._read_canReboot, toJson: CameraDeviceRead._write_canReboot) bool canReboot,@JsonKey(readValue: CameraDeviceRead._extras, fromJson: CameraDeviceRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$ClockReadCopyWith<$Res>? get clock;

}
/// @nodoc
class _$CameraDeviceReadCopyWithImpl<$Res>
    implements $CameraDeviceReadCopyWith<$Res> {
  _$CameraDeviceReadCopyWithImpl(this._self, this._then);

  final CameraDeviceRead _self;
  final $Res Function(CameraDeviceRead) _then;

/// Create a copy of CameraDeviceRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cameraUuid = null,Object? supported = null,Object? reason = freezed,Object? endpoint = freezed,Object? manufacturer = freezed,Object? model = freezed,Object? firmware = freezed,Object? serial = freezed,Object? hardwareId = freezed,Object? clock = freezed,Object? canReboot = null,Object? additionalProperties = null,}) {
  return _then(CameraDeviceRead(
cameraUuid: null == cameraUuid ? _self.cameraUuid : cameraUuid // ignore: cast_nullable_to_non_nullable
as String,supported: null == supported ? _self.supported : supported // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,endpoint: freezed == endpoint ? _self.endpoint : endpoint // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,firmware: freezed == firmware ? _self.firmware : firmware // ignore: cast_nullable_to_non_nullable
as String?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String?,hardwareId: freezed == hardwareId ? _self.hardwareId : hardwareId // ignore: cast_nullable_to_non_nullable
as String?,clock: freezed == clock ? _self.clock : clock // ignore: cast_nullable_to_non_nullable
as ClockRead?,canReboot: null == canReboot ? _self.canReboot : canReboot // ignore: cast_nullable_to_non_nullable
as bool,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of CameraDeviceRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClockReadCopyWith<$Res>? get clock {
    if (_self.clock == null) {
    return null;
  }

  return $ClockReadCopyWith<$Res>(_self.clock!, (value) {
    return _then(_self.copyWith(clock: value));
  });
}
}


/// Adds pattern-matching-related methods to [CameraDeviceRead].
extension CameraDeviceReadPatterns on CameraDeviceRead {
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
