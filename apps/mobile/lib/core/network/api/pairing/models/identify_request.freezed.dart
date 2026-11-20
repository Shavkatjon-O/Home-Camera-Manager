// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identify_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IdentifyRequest {


/// Create a copy of IdentifyRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdentifyRequestCopyWith<IdentifyRequest> get copyWith => _$IdentifyRequestCopyWithImpl<IdentifyRequest>(this as IdentifyRequest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as IdentifyRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdentifyRequest&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.port, _this.port) || other.port == _this.port)&&(identical(other.rtspPort, _this.rtspPort) || other.rtspPort == _this.rtspPort)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.adapter, _this.adapter) || other.adapter == _this.adapter)&&(identical(other.rtspUrl, _this.rtspUrl) || other.rtspUrl == _this.rtspUrl)&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&(identical(other.connector, _this.connector) || other.connector == _this.connector)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as IdentifyRequest;
  return Object.hash(runtimeType,_this.host,_this.port,_this.rtspPort,_this.username,_this.password,_this.adapter,_this.rtspUrl,_this.deviceId,_this.connector,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as IdentifyRequest;
  return 'IdentifyRequest(host: ${_this.host}, port: ${_this.port}, rtspPort: ${_this.rtspPort}, username: ${_this.username}, password: ${_this.password}, adapter: ${_this.adapter}, rtspUrl: ${_this.rtspUrl}, deviceId: ${_this.deviceId}, connector: ${_this.connector}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $IdentifyRequestCopyWith<$Res>  {
  factory $IdentifyRequestCopyWith(IdentifyRequest value, $Res Function(IdentifyRequest) _then) = _$IdentifyRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? host,@JsonKey(includeIfNull: false, fromJson: IdentifyRequest._read_port, toJson: IdentifyRequest._write_port) int? port,@JsonKey(name: "rtsp_port", includeIfNull: false, fromJson: IdentifyRequest._read_rtspPort, toJson: IdentifyRequest._write_rtspPort) int? rtspPort,@JsonKey(includeIfNull: false) String? username,@JsonKey(includeIfNull: false) String? password,@JsonKey(includeIfNull: false) String? adapter,@JsonKey(name: "rtsp_url", includeIfNull: false) String? rtspUrl,@JsonKey(name: "device_id", includeIfNull: false) String? deviceId,@JsonKey(includeIfNull: false) String? connector,@JsonKey(readValue: IdentifyRequest._extras, fromJson: IdentifyRequest._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$IdentifyRequestCopyWithImpl<$Res>
    implements $IdentifyRequestCopyWith<$Res> {
  _$IdentifyRequestCopyWithImpl(this._self, this._then);

  final IdentifyRequest _self;
  final $Res Function(IdentifyRequest) _then;

/// Create a copy of IdentifyRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? host = freezed,Object? port = freezed,Object? rtspPort = freezed,Object? username = freezed,Object? password = freezed,Object? adapter = freezed,Object? rtspUrl = freezed,Object? deviceId = freezed,Object? connector = freezed,Object? additionalProperties = null,}) {
  return _then(IdentifyRequest(
host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String?,port: freezed == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int?,rtspPort: freezed == rtspPort ? _self.rtspPort : rtspPort // ignore: cast_nullable_to_non_nullable
as int?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,adapter: freezed == adapter ? _self.adapter : adapter // ignore: cast_nullable_to_non_nullable
as String?,rtspUrl: freezed == rtspUrl ? _self.rtspUrl : rtspUrl // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,connector: freezed == connector ? _self.connector : connector // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [IdentifyRequest].
extension IdentifyRequestPatterns on IdentifyRequest {
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
