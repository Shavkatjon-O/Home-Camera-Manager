// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeviceRead {


/// Create a copy of DeviceRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceReadCopyWith<DeviceRead> get copyWith => _$DeviceReadCopyWithImpl<DeviceRead>(this as DeviceRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeviceRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.adapter, _this.adapter) || other.adapter == _this.adapter)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.vendor, _this.vendor) || other.vendor == _this.vendor)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.connector, _this.connector) || other.connector == _this.connector)&&(identical(other.channelCount, _this.channelCount) || other.channelCount == _this.channelCount)&&const DeepCollectionEquality().equals(other.channels, _this.channels)&&(identical(other.capabilities, _this.capabilities) || other.capabilities == _this.capabilities)&&(identical(other.identifiedAt, _this.identifiedAt) || other.identifiedAt == _this.identifiedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as DeviceRead;
  return Object.hash(runtimeType,_this.uuid,_this.kind,_this.adapter,_this.name,_this.vendor,_this.model,_this.connector,_this.channelCount,const DeepCollectionEquality().hash(_this.channels),_this.capabilities,_this.identifiedAt,_this.createdAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as DeviceRead;
  return 'DeviceRead(uuid: ${_this.uuid}, kind: ${_this.kind}, adapter: ${_this.adapter}, name: ${_this.name}, vendor: ${_this.vendor}, model: ${_this.model}, connector: ${_this.connector}, channelCount: ${_this.channelCount}, channels: ${_this.channels}, capabilities: ${_this.capabilities}, identifiedAt: ${_this.identifiedAt}, createdAt: ${_this.createdAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $DeviceReadCopyWith<$Res>  {
  factory $DeviceReadCopyWith(DeviceRead value, $Res Function(DeviceRead) _then) = _$DeviceReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String kind,@JsonKey(required: true, disallowNullValue: true) String adapter,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true) String? vendor,@JsonKey(required: true) String? model,@JsonKey(required: true) String? connector,@JsonKey(name: "channel_count", required: true, disallowNullValue: true, fromJson: DeviceRead._read_channelCount, toJson: DeviceRead._write_channelCount) int channelCount,@JsonKey(required: true, disallowNullValue: true) List<DeviceChannelRead> channels,@JsonKey(required: true, disallowNullValue: true) CapabilitiesRead capabilities,@JsonKey(name: "identified_at", required: true, fromJson: DeviceRead._read_identifiedAt, toJson: DeviceRead._write_identifiedAt) DateTime? identifiedAt,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: DeviceRead._read_createdAt, toJson: DeviceRead._write_createdAt) DateTime createdAt,@JsonKey(readValue: DeviceRead._extras, fromJson: DeviceRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$CapabilitiesReadCopyWith<$Res> get capabilities;

}
/// @nodoc
class _$DeviceReadCopyWithImpl<$Res>
    implements $DeviceReadCopyWith<$Res> {
  _$DeviceReadCopyWithImpl(this._self, this._then);

  final DeviceRead _self;
  final $Res Function(DeviceRead) _then;

/// Create a copy of DeviceRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? kind = null,Object? adapter = null,Object? name = null,Object? vendor = freezed,Object? model = freezed,Object? connector = freezed,Object? channelCount = null,Object? channels = null,Object? capabilities = null,Object? identifiedAt = freezed,Object? createdAt = null,Object? additionalProperties = null,}) {
  return _then(DeviceRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,adapter: null == adapter ? _self.adapter : adapter // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,vendor: freezed == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,connector: freezed == connector ? _self.connector : connector // ignore: cast_nullable_to_non_nullable
as String?,channelCount: null == channelCount ? _self.channelCount : channelCount // ignore: cast_nullable_to_non_nullable
as int,channels: null == channels ? _self.channels : channels // ignore: cast_nullable_to_non_nullable
as List<DeviceChannelRead>,capabilities: null == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as CapabilitiesRead,identifiedAt: freezed == identifiedAt ? _self.identifiedAt : identifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of DeviceRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CapabilitiesReadCopyWith<$Res> get capabilities {
  
  return $CapabilitiesReadCopyWith<$Res>(_self.capabilities, (value) {
    return _then(_self.copyWith(capabilities: value));
  });
}
}


/// Adds pattern-matching-related methods to [DeviceRead].
extension DeviceReadPatterns on DeviceRead {
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
