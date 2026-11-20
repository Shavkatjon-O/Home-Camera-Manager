// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discovered_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DiscoveredRead {


/// Create a copy of DiscoveredRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoveredReadCopyWith<DiscoveredRead> get copyWith => _$DiscoveredReadCopyWithImpl<DiscoveredRead>(this as DiscoveredRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DiscoveredRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveredRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.host, _this.host) || other.host == _this.host)&&const DeepCollectionEquality().equals(other.openPorts, _this.openPorts)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.manufacturer, _this.manufacturer) || other.manufacturer == _this.manufacturer)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.onvifPort, _this.onvifPort) || other.onvifPort == _this.onvifPort)&&(identical(other.foundBy, _this.foundBy) || other.foundBy == _this.foundBy)&&(identical(other.seenAt, _this.seenAt) || other.seenAt == _this.seenAt)&&(identical(other.camera, _this.camera) || other.camera == _this.camera)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as DiscoveredRead;
  return Object.hash(runtimeType,_this.uuid,_this.host,const DeepCollectionEquality().hash(_this.openPorts),_this.brand,_this.manufacturer,_this.model,_this.onvifPort,_this.foundBy,_this.seenAt,_this.camera,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as DiscoveredRead;
  return 'DiscoveredRead(uuid: ${_this.uuid}, host: ${_this.host}, openPorts: ${_this.openPorts}, brand: ${_this.brand}, manufacturer: ${_this.manufacturer}, model: ${_this.model}, onvifPort: ${_this.onvifPort}, foundBy: ${_this.foundBy}, seenAt: ${_this.seenAt}, camera: ${_this.camera}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $DiscoveredReadCopyWith<$Res>  {
  factory $DiscoveredReadCopyWith(DiscoveredRead value, $Res Function(DiscoveredRead) _then) = _$DiscoveredReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String host,@JsonKey(name: "open_ports", required: true, disallowNullValue: true, fromJson: DiscoveredRead._read_openPorts, toJson: DiscoveredRead._write_openPorts) List<int> openPorts,@JsonKey(required: true, fromJson: DiscoveredRead._read_brand, toJson: DiscoveredRead._write_brand) CameraBrand? brand,@JsonKey(required: true) String? manufacturer,@JsonKey(required: true) String? model,@JsonKey(name: "onvif_port", required: true, fromJson: DiscoveredRead._read_onvifPort, toJson: DiscoveredRead._write_onvifPort) int? onvifPort,@JsonKey(name: "found_by", required: true, disallowNullValue: true, fromJson: DiscoveredRead._read_foundBy, toJson: DiscoveredRead._write_foundBy) FoundBy foundBy,@JsonKey(name: "seen_at", required: true, disallowNullValue: true, fromJson: DiscoveredRead._read_seenAt, toJson: DiscoveredRead._write_seenAt) DateTime seenAt,@JsonKey(required: true) String? camera,@JsonKey(readValue: DiscoveredRead._extras, fromJson: DiscoveredRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$DiscoveredReadCopyWithImpl<$Res>
    implements $DiscoveredReadCopyWith<$Res> {
  _$DiscoveredReadCopyWithImpl(this._self, this._then);

  final DiscoveredRead _self;
  final $Res Function(DiscoveredRead) _then;

/// Create a copy of DiscoveredRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? host = null,Object? openPorts = null,Object? brand = freezed,Object? manufacturer = freezed,Object? model = freezed,Object? onvifPort = freezed,Object? foundBy = null,Object? seenAt = null,Object? camera = freezed,Object? additionalProperties = null,}) {
  return _then(DiscoveredRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,openPorts: null == openPorts ? _self.openPorts : openPorts // ignore: cast_nullable_to_non_nullable
as List<int>,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as CameraBrand?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,onvifPort: freezed == onvifPort ? _self.onvifPort : onvifPort // ignore: cast_nullable_to_non_nullable
as int?,foundBy: null == foundBy ? _self.foundBy : foundBy // ignore: cast_nullable_to_non_nullable
as FoundBy,seenAt: null == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime,camera: freezed == camera ? _self.camera : camera // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [DiscoveredRead].
extension DiscoveredReadPatterns on DiscoveredRead {
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
