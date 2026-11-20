// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connector_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConnectorRead {


/// Create a copy of ConnectorRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectorReadCopyWith<ConnectorRead> get copyWith => _$ConnectorReadCopyWithImpl<ConnectorRead>(this as ConnectorRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConnectorRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectorRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.online, _this.online) || other.online == _this.online)&&(identical(other.lastSeenAt, _this.lastSeenAt) || other.lastSeenAt == _this.lastSeenAt)&&(identical(other.cameraCount, _this.cameraCount) || other.cameraCount == _this.cameraCount)&&(identical(other.discoveryRequestedAt, _this.discoveryRequestedAt) || other.discoveryRequestedAt == _this.discoveryRequestedAt)&&(identical(other.discoveredAt, _this.discoveredAt) || other.discoveredAt == _this.discoveredAt)&&const DeepCollectionEquality().equals(other.health, _this.health)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as ConnectorRead;
  return Object.hash(runtimeType,_this.uuid,_this.name,_this.version,_this.mode,_this.address,_this.online,_this.lastSeenAt,_this.cameraCount,_this.discoveryRequestedAt,_this.discoveredAt,const DeepCollectionEquality().hash(_this.health),_this.createdAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as ConnectorRead;
  return 'ConnectorRead(uuid: ${_this.uuid}, name: ${_this.name}, version: ${_this.version}, mode: ${_this.mode}, address: ${_this.address}, online: ${_this.online}, lastSeenAt: ${_this.lastSeenAt}, cameraCount: ${_this.cameraCount}, discoveryRequestedAt: ${_this.discoveryRequestedAt}, discoveredAt: ${_this.discoveredAt}, health: ${_this.health}, createdAt: ${_this.createdAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ConnectorReadCopyWith<$Res>  {
  factory $ConnectorReadCopyWith(ConnectorRead value, $Res Function(ConnectorRead) _then) = _$ConnectorReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true) String? version,@JsonKey(required: true, disallowNullValue: true, fromJson: ConnectorRead._read_mode, toJson: ConnectorRead._write_mode) ConnectorMode mode,@JsonKey(required: true) String? address,@JsonKey(required: true, disallowNullValue: true) bool online,@JsonKey(name: "last_seen_at", required: true, fromJson: ConnectorRead._read_lastSeenAt, toJson: ConnectorRead._write_lastSeenAt) DateTime? lastSeenAt,@JsonKey(name: "camera_count", required: true, disallowNullValue: true, fromJson: ConnectorRead._read_cameraCount, toJson: ConnectorRead._write_cameraCount) int cameraCount,@JsonKey(name: "discovery_requested_at", required: true, fromJson: ConnectorRead._read_discoveryRequestedAt, toJson: ConnectorRead._write_discoveryRequestedAt) DateTime? discoveryRequestedAt,@JsonKey(name: "discovered_at", required: true, fromJson: ConnectorRead._read_discoveredAt, toJson: ConnectorRead._write_discoveredAt) DateTime? discoveredAt,@JsonKey(required: true, disallowNullValue: true) Map<String, Object?> health,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: ConnectorRead._read_createdAt, toJson: ConnectorRead._write_createdAt) DateTime createdAt,@JsonKey(readValue: ConnectorRead._extras, fromJson: ConnectorRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$ConnectorReadCopyWithImpl<$Res>
    implements $ConnectorReadCopyWith<$Res> {
  _$ConnectorReadCopyWithImpl(this._self, this._then);

  final ConnectorRead _self;
  final $Res Function(ConnectorRead) _then;

/// Create a copy of ConnectorRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? name = null,Object? version = freezed,Object? mode = null,Object? address = freezed,Object? online = null,Object? lastSeenAt = freezed,Object? cameraCount = null,Object? discoveryRequestedAt = freezed,Object? discoveredAt = freezed,Object? health = null,Object? createdAt = null,Object? additionalProperties = null,}) {
  return _then(ConnectorRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ConnectorMode,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,online: null == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as bool,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cameraCount: null == cameraCount ? _self.cameraCount : cameraCount // ignore: cast_nullable_to_non_nullable
as int,discoveryRequestedAt: freezed == discoveryRequestedAt ? _self.discoveryRequestedAt : discoveryRequestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,discoveredAt: freezed == discoveredAt ? _self.discoveredAt : discoveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [ConnectorRead].
extension ConnectorReadPatterns on ConnectorRead {
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
