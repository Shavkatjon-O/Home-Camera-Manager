// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'network_device_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NetworkDeviceRead {


/// Create a copy of NetworkDeviceRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkDeviceReadCopyWith<NetworkDeviceRead> get copyWith => _$NetworkDeviceReadCopyWithImpl<NetworkDeviceRead>(this as NetworkDeviceRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NetworkDeviceRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkDeviceRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.probePort, _this.probePort) || other.probePort == _this.probePort)&&(identical(other.parentUuid, _this.parentUuid) || other.parentUuid == _this.parentUuid)&&(identical(other.parentName, _this.parentName) || other.parentName == _this.parentName)&&(identical(other.link, _this.link) || other.link == _this.link)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as NetworkDeviceRead;
  return Object.hash(runtimeType,_this.uuid,_this.name,_this.kind,_this.host,_this.probePort,_this.parentUuid,_this.parentName,_this.link,_this.notes,_this.enabled,_this.createdAt,_this.updatedAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as NetworkDeviceRead;
  return 'NetworkDeviceRead(uuid: ${_this.uuid}, name: ${_this.name}, kind: ${_this.kind}, host: ${_this.host}, probePort: ${_this.probePort}, parentUuid: ${_this.parentUuid}, parentName: ${_this.parentName}, link: ${_this.link}, notes: ${_this.notes}, enabled: ${_this.enabled}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $NetworkDeviceReadCopyWith<$Res>  {
  factory $NetworkDeviceReadCopyWith(NetworkDeviceRead value, $Res Function(NetworkDeviceRead) _then) = _$NetworkDeviceReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true, disallowNullValue: true, fromJson: NetworkDeviceRead._read_kind, toJson: NetworkDeviceRead._write_kind) DeviceKind kind,@JsonKey(required: true, disallowNullValue: true) String host,@JsonKey(name: "probe_port", required: true, disallowNullValue: true, fromJson: NetworkDeviceRead._read_probePort, toJson: NetworkDeviceRead._write_probePort) int probePort,@JsonKey(name: "parent_uuid", required: true) String? parentUuid,@JsonKey(name: "parent_name", required: true) String? parentName,@JsonKey(required: true, fromJson: NetworkDeviceRead._read_link, toJson: NetworkDeviceRead._write_link) LinkKind? link,@JsonKey(required: true) String? notes,@JsonKey(required: true, disallowNullValue: true) bool enabled,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: NetworkDeviceRead._read_createdAt, toJson: NetworkDeviceRead._write_createdAt) DateTime createdAt,@JsonKey(name: "updated_at", required: true, disallowNullValue: true, fromJson: NetworkDeviceRead._read_updatedAt, toJson: NetworkDeviceRead._write_updatedAt) DateTime updatedAt,@JsonKey(readValue: NetworkDeviceRead._extras, fromJson: NetworkDeviceRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$NetworkDeviceReadCopyWithImpl<$Res>
    implements $NetworkDeviceReadCopyWith<$Res> {
  _$NetworkDeviceReadCopyWithImpl(this._self, this._then);

  final NetworkDeviceRead _self;
  final $Res Function(NetworkDeviceRead) _then;

/// Create a copy of NetworkDeviceRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? name = null,Object? kind = null,Object? host = null,Object? probePort = null,Object? parentUuid = freezed,Object? parentName = freezed,Object? link = freezed,Object? notes = freezed,Object? enabled = null,Object? createdAt = null,Object? updatedAt = null,Object? additionalProperties = null,}) {
  return _then(NetworkDeviceRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DeviceKind,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,probePort: null == probePort ? _self.probePort : probePort // ignore: cast_nullable_to_non_nullable
as int,parentUuid: freezed == parentUuid ? _self.parentUuid : parentUuid // ignore: cast_nullable_to_non_nullable
as String?,parentName: freezed == parentName ? _self.parentName : parentName // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as LinkKind?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [NetworkDeviceRead].
extension NetworkDeviceReadPatterns on NetworkDeviceRead {
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
