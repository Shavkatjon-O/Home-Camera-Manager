// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Connector {

 String get id; String get siteId; String get name; ConnectorState get state; String? get version; DateTime? get lastSeenAt; String get mode; int get cameraCount;
/// Create a copy of Connector
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectorCopyWith<Connector> get copyWith => _$ConnectorCopyWithImpl<Connector>(this as Connector, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Connector;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Connector&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.siteId, _this.siteId) || other.siteId == _this.siteId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.lastSeenAt, _this.lastSeenAt) || other.lastSeenAt == _this.lastSeenAt)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.cameraCount, _this.cameraCount) || other.cameraCount == _this.cameraCount));
}


@override
int get hashCode {
  final _this = this as Connector;
  return Object.hash(runtimeType,_this.id,_this.siteId,_this.name,_this.state,_this.version,_this.lastSeenAt,_this.mode,_this.cameraCount);
}

@override
String toString() {
  final _this = this as Connector;
  return 'Connector(id: ${_this.id}, siteId: ${_this.siteId}, name: ${_this.name}, state: ${_this.state}, version: ${_this.version}, lastSeenAt: ${_this.lastSeenAt}, mode: ${_this.mode}, cameraCount: ${_this.cameraCount})';
}


}

/// @nodoc
abstract mixin class $ConnectorCopyWith<$Res>  {
  factory $ConnectorCopyWith(Connector value, $Res Function(Connector) _then) = _$ConnectorCopyWithImpl;
@useResult
$Res call({
 String id, String siteId, String name, ConnectorState state, String? version, DateTime? lastSeenAt, String mode, int cameraCount
});




}
/// @nodoc
class _$ConnectorCopyWithImpl<$Res>
    implements $ConnectorCopyWith<$Res> {
  _$ConnectorCopyWithImpl(this._self, this._then);

  final Connector _self;
  final $Res Function(Connector) _then;

/// Create a copy of Connector
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? siteId = null,Object? name = null,Object? state = null,Object? version = freezed,Object? lastSeenAt = freezed,Object? mode = null,Object? cameraCount = null,}) {
  return _then(Connector(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ConnectorState,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,cameraCount: null == cameraCount ? _self.cameraCount : cameraCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Connector].
extension ConnectorPatterns on Connector {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Connector value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Connector() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Connector value)  $default,){
final _that = this;
switch (_that) {
case _Connector():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Connector value)?  $default,){
final _that = this;
switch (_that) {
case _Connector() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String siteId,  String name,  ConnectorState state,  String? version,  DateTime? lastSeenAt,  String mode,  int cameraCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Connector() when $default != null:
return $default(_that.id,_that.siteId,_that.name,_that.state,_that.version,_that.lastSeenAt,_that.mode,_that.cameraCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String siteId,  String name,  ConnectorState state,  String? version,  DateTime? lastSeenAt,  String mode,  int cameraCount)  $default,) {final _that = this;
switch (_that) {
case _Connector():
return $default(_that.id,_that.siteId,_that.name,_that.state,_that.version,_that.lastSeenAt,_that.mode,_that.cameraCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String siteId,  String name,  ConnectorState state,  String? version,  DateTime? lastSeenAt,  String mode,  int cameraCount)?  $default,) {final _that = this;
switch (_that) {
case _Connector() when $default != null:
return $default(_that.id,_that.siteId,_that.name,_that.state,_that.version,_that.lastSeenAt,_that.mode,_that.cameraCount);case _:
  return null;

}
}

}

/// @nodoc


class _Connector implements Connector {
  const _Connector({required this.id, required this.siteId, required this.name, required this.state, this.version, this.lastSeenAt, this.mode = 'direct', this.cameraCount = 0});
  

@override final  String id;
@override final  String siteId;
@override final  String name;
@override final  ConnectorState state;
@override final  String? version;
@override final  DateTime? lastSeenAt;
@override@JsonKey() final  String mode;
@override@JsonKey() final  int cameraCount;

/// Create a copy of Connector
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectorCopyWith<_Connector> get copyWith => __$ConnectorCopyWithImpl<_Connector>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Connector&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.name, name) || other.name == name)&&(identical(other.state, state) || other.state == state)&&(identical(other.version, version) || other.version == version)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.cameraCount, cameraCount) || other.cameraCount == cameraCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,siteId,name,state,version,lastSeenAt,mode,cameraCount);
}

@override
String toString() {
    return 'Connector(id: $id, siteId: $siteId, name: $name, state: $state, version: $version, lastSeenAt: $lastSeenAt, mode: $mode, cameraCount: $cameraCount)';
}


}

/// @nodoc
abstract mixin class _$ConnectorCopyWith<$Res> implements $ConnectorCopyWith<$Res> {
  factory _$ConnectorCopyWith(_Connector value, $Res Function(_Connector) _then) = __$ConnectorCopyWithImpl;
@override @useResult
$Res call({
 String id, String siteId, String name, ConnectorState state, String? version, DateTime? lastSeenAt, String mode, int cameraCount
});




}
/// @nodoc
class __$ConnectorCopyWithImpl<$Res>
    implements _$ConnectorCopyWith<$Res> {
  __$ConnectorCopyWithImpl(this._self, this._then);

  final _Connector _self;
  final $Res Function(_Connector) _then;

/// Create a copy of Connector
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? siteId = null,Object? name = null,Object? state = null,Object? version = freezed,Object? lastSeenAt = freezed,Object? mode = null,Object? cameraCount = null,}) {
  return _then(_Connector(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ConnectorState,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,cameraCount: null == cameraCount ? _self.cameraCount : cameraCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ConnectorCode {

 String get code; String? get connectorName;
/// Create a copy of ConnectorCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectorCodeCopyWith<ConnectorCode> get copyWith => _$ConnectorCodeCopyWithImpl<ConnectorCode>(this as ConnectorCode, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConnectorCode;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectorCode&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.connectorName, _this.connectorName) || other.connectorName == _this.connectorName));
}


@override
int get hashCode {
  final _this = this as ConnectorCode;
  return Object.hash(runtimeType,_this.code,_this.connectorName);
}

@override
String toString() {
  final _this = this as ConnectorCode;
  return 'ConnectorCode(code: ${_this.code}, connectorName: ${_this.connectorName})';
}


}

/// @nodoc
abstract mixin class $ConnectorCodeCopyWith<$Res>  {
  factory $ConnectorCodeCopyWith(ConnectorCode value, $Res Function(ConnectorCode) _then) = _$ConnectorCodeCopyWithImpl;
@useResult
$Res call({
 String code, String? connectorName
});




}
/// @nodoc
class _$ConnectorCodeCopyWithImpl<$Res>
    implements $ConnectorCodeCopyWith<$Res> {
  _$ConnectorCodeCopyWithImpl(this._self, this._then);

  final ConnectorCode _self;
  final $Res Function(ConnectorCode) _then;

/// Create a copy of ConnectorCode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? connectorName = freezed,}) {
  return _then(ConnectorCode(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,connectorName: freezed == connectorName ? _self.connectorName : connectorName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConnectorCode].
extension ConnectorCodePatterns on ConnectorCode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectorCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectorCode() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectorCode value)  $default,){
final _that = this;
switch (_that) {
case _ConnectorCode():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectorCode value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectorCode() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String? connectorName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectorCode() when $default != null:
return $default(_that.code,_that.connectorName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String? connectorName)  $default,) {final _that = this;
switch (_that) {
case _ConnectorCode():
return $default(_that.code,_that.connectorName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String? connectorName)?  $default,) {final _that = this;
switch (_that) {
case _ConnectorCode() when $default != null:
return $default(_that.code,_that.connectorName);case _:
  return null;

}
}

}

/// @nodoc


class _ConnectorCode implements ConnectorCode {
  const _ConnectorCode({required this.code, this.connectorName});
  

@override final  String code;
@override final  String? connectorName;

/// Create a copy of ConnectorCode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectorCodeCopyWith<_ConnectorCode> get copyWith => __$ConnectorCodeCopyWithImpl<_ConnectorCode>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectorCode&&(identical(other.code, code) || other.code == code)&&(identical(other.connectorName, connectorName) || other.connectorName == connectorName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code,connectorName);
}

@override
String toString() {
    return 'ConnectorCode(code: $code, connectorName: $connectorName)';
}


}

/// @nodoc
abstract mixin class _$ConnectorCodeCopyWith<$Res> implements $ConnectorCodeCopyWith<$Res> {
  factory _$ConnectorCodeCopyWith(_ConnectorCode value, $Res Function(_ConnectorCode) _then) = __$ConnectorCodeCopyWithImpl;
@override @useResult
$Res call({
 String code, String? connectorName
});




}
/// @nodoc
class __$ConnectorCodeCopyWithImpl<$Res>
    implements _$ConnectorCodeCopyWith<$Res> {
  __$ConnectorCodeCopyWithImpl(this._self, this._then);

  final _ConnectorCode _self;
  final $Res Function(_ConnectorCode) _then;

/// Create a copy of ConnectorCode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? connectorName = freezed,}) {
  return _then(_ConnectorCode(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,connectorName: freezed == connectorName ? _self.connectorName : connectorName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$DiscoveredCamera {

 String get id; String get host; List<int> get ports; CameraBrand? get brand; String? get manufacturer; String? get model; int? get onvifPort; bool get ptz; bool get nvr; String get foundBy; int? get rtspPort; String? get mainPath; String? get cameraId;
/// Create a copy of DiscoveredCamera
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoveredCameraCopyWith<DiscoveredCamera> get copyWith => _$DiscoveredCameraCopyWithImpl<DiscoveredCamera>(this as DiscoveredCamera, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DiscoveredCamera;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveredCamera&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.host, _this.host) || other.host == _this.host)&&const DeepCollectionEquality().equals(other.ports, _this.ports)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.manufacturer, _this.manufacturer) || other.manufacturer == _this.manufacturer)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.onvifPort, _this.onvifPort) || other.onvifPort == _this.onvifPort)&&(identical(other.ptz, _this.ptz) || other.ptz == _this.ptz)&&(identical(other.nvr, _this.nvr) || other.nvr == _this.nvr)&&(identical(other.foundBy, _this.foundBy) || other.foundBy == _this.foundBy)&&(identical(other.rtspPort, _this.rtspPort) || other.rtspPort == _this.rtspPort)&&(identical(other.mainPath, _this.mainPath) || other.mainPath == _this.mainPath)&&(identical(other.cameraId, _this.cameraId) || other.cameraId == _this.cameraId));
}


@override
int get hashCode {
  final _this = this as DiscoveredCamera;
  return Object.hash(runtimeType,_this.id,_this.host,const DeepCollectionEquality().hash(_this.ports),_this.brand,_this.manufacturer,_this.model,_this.onvifPort,_this.ptz,_this.nvr,_this.foundBy,_this.rtspPort,_this.mainPath,_this.cameraId);
}

@override
String toString() {
  final _this = this as DiscoveredCamera;
  return 'DiscoveredCamera(id: ${_this.id}, host: ${_this.host}, ports: ${_this.ports}, brand: ${_this.brand}, manufacturer: ${_this.manufacturer}, model: ${_this.model}, onvifPort: ${_this.onvifPort}, ptz: ${_this.ptz}, nvr: ${_this.nvr}, foundBy: ${_this.foundBy}, rtspPort: ${_this.rtspPort}, mainPath: ${_this.mainPath}, cameraId: ${_this.cameraId})';
}


}

/// @nodoc
abstract mixin class $DiscoveredCameraCopyWith<$Res>  {
  factory $DiscoveredCameraCopyWith(DiscoveredCamera value, $Res Function(DiscoveredCamera) _then) = _$DiscoveredCameraCopyWithImpl;
@useResult
$Res call({
 String id, String host, List<int> ports, CameraBrand? brand, String? manufacturer, String? model, int? onvifPort, bool ptz, bool nvr, String foundBy, int? rtspPort, String? mainPath, String? cameraId
});




}
/// @nodoc
class _$DiscoveredCameraCopyWithImpl<$Res>
    implements $DiscoveredCameraCopyWith<$Res> {
  _$DiscoveredCameraCopyWithImpl(this._self, this._then);

  final DiscoveredCamera _self;
  final $Res Function(DiscoveredCamera) _then;

/// Create a copy of DiscoveredCamera
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? host = null,Object? ports = null,Object? brand = freezed,Object? manufacturer = freezed,Object? model = freezed,Object? onvifPort = freezed,Object? ptz = null,Object? nvr = null,Object? foundBy = null,Object? rtspPort = freezed,Object? mainPath = freezed,Object? cameraId = freezed,}) {
  return _then(DiscoveredCamera(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,ports: null == ports ? _self.ports : ports // ignore: cast_nullable_to_non_nullable
as List<int>,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as CameraBrand?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,onvifPort: freezed == onvifPort ? _self.onvifPort : onvifPort // ignore: cast_nullable_to_non_nullable
as int?,ptz: null == ptz ? _self.ptz : ptz // ignore: cast_nullable_to_non_nullable
as bool,nvr: null == nvr ? _self.nvr : nvr // ignore: cast_nullable_to_non_nullable
as bool,foundBy: null == foundBy ? _self.foundBy : foundBy // ignore: cast_nullable_to_non_nullable
as String,rtspPort: freezed == rtspPort ? _self.rtspPort : rtspPort // ignore: cast_nullable_to_non_nullable
as int?,mainPath: freezed == mainPath ? _self.mainPath : mainPath // ignore: cast_nullable_to_non_nullable
as String?,cameraId: freezed == cameraId ? _self.cameraId : cameraId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DiscoveredCamera].
extension DiscoveredCameraPatterns on DiscoveredCamera {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiscoveredCamera value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiscoveredCamera() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiscoveredCamera value)  $default,){
final _that = this;
switch (_that) {
case _DiscoveredCamera():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiscoveredCamera value)?  $default,){
final _that = this;
switch (_that) {
case _DiscoveredCamera() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String host,  List<int> ports,  CameraBrand? brand,  String? manufacturer,  String? model,  int? onvifPort,  bool ptz,  bool nvr,  String foundBy,  int? rtspPort,  String? mainPath,  String? cameraId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscoveredCamera() when $default != null:
return $default(_that.id,_that.host,_that.ports,_that.brand,_that.manufacturer,_that.model,_that.onvifPort,_that.ptz,_that.nvr,_that.foundBy,_that.rtspPort,_that.mainPath,_that.cameraId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String host,  List<int> ports,  CameraBrand? brand,  String? manufacturer,  String? model,  int? onvifPort,  bool ptz,  bool nvr,  String foundBy,  int? rtspPort,  String? mainPath,  String? cameraId)  $default,) {final _that = this;
switch (_that) {
case _DiscoveredCamera():
return $default(_that.id,_that.host,_that.ports,_that.brand,_that.manufacturer,_that.model,_that.onvifPort,_that.ptz,_that.nvr,_that.foundBy,_that.rtspPort,_that.mainPath,_that.cameraId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String host,  List<int> ports,  CameraBrand? brand,  String? manufacturer,  String? model,  int? onvifPort,  bool ptz,  bool nvr,  String foundBy,  int? rtspPort,  String? mainPath,  String? cameraId)?  $default,) {final _that = this;
switch (_that) {
case _DiscoveredCamera() when $default != null:
return $default(_that.id,_that.host,_that.ports,_that.brand,_that.manufacturer,_that.model,_that.onvifPort,_that.ptz,_that.nvr,_that.foundBy,_that.rtspPort,_that.mainPath,_that.cameraId);case _:
  return null;

}
}

}

/// @nodoc


class _DiscoveredCamera implements DiscoveredCamera {
  const _DiscoveredCamera({required this.id, required this.host, required  List<int> ports, this.brand, this.manufacturer, this.model, this.onvifPort, this.ptz = false, this.nvr = false, this.foundBy = 'probe', this.rtspPort, this.mainPath, this.cameraId}): _ports = ports;
  

@override final  String id;
@override final  String host;
 final  List<int> _ports;
@override List<int> get ports {
  if (_ports is EqualUnmodifiableListView) return _ports;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ports);
}

@override final  CameraBrand? brand;
@override final  String? manufacturer;
@override final  String? model;
@override final  int? onvifPort;
@override@JsonKey() final  bool ptz;
@override@JsonKey() final  bool nvr;
@override@JsonKey() final  String foundBy;
@override final  int? rtspPort;
@override final  String? mainPath;
@override final  String? cameraId;

/// Create a copy of DiscoveredCamera
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscoveredCameraCopyWith<_DiscoveredCamera> get copyWith => __$DiscoveredCameraCopyWithImpl<_DiscoveredCamera>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscoveredCamera&&(identical(other.id, id) || other.id == id)&&(identical(other.host, host) || other.host == host)&&const DeepCollectionEquality().equals(other.ports, _ports)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.model, model) || other.model == model)&&(identical(other.onvifPort, onvifPort) || other.onvifPort == onvifPort)&&(identical(other.ptz, ptz) || other.ptz == ptz)&&(identical(other.nvr, nvr) || other.nvr == nvr)&&(identical(other.foundBy, foundBy) || other.foundBy == foundBy)&&(identical(other.rtspPort, rtspPort) || other.rtspPort == rtspPort)&&(identical(other.mainPath, mainPath) || other.mainPath == mainPath)&&(identical(other.cameraId, cameraId) || other.cameraId == cameraId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,host,const DeepCollectionEquality().hash(_ports),brand,manufacturer,model,onvifPort,ptz,nvr,foundBy,rtspPort,mainPath,cameraId);
}

@override
String toString() {
    return 'DiscoveredCamera(id: $id, host: $host, ports: $ports, brand: $brand, manufacturer: $manufacturer, model: $model, onvifPort: $onvifPort, ptz: $ptz, nvr: $nvr, foundBy: $foundBy, rtspPort: $rtspPort, mainPath: $mainPath, cameraId: $cameraId)';
}


}

/// @nodoc
abstract mixin class _$DiscoveredCameraCopyWith<$Res> implements $DiscoveredCameraCopyWith<$Res> {
  factory _$DiscoveredCameraCopyWith(_DiscoveredCamera value, $Res Function(_DiscoveredCamera) _then) = __$DiscoveredCameraCopyWithImpl;
@override @useResult
$Res call({
 String id, String host, List<int> ports, CameraBrand? brand, String? manufacturer, String? model, int? onvifPort, bool ptz, bool nvr, String foundBy, int? rtspPort, String? mainPath, String? cameraId
});




}
/// @nodoc
class __$DiscoveredCameraCopyWithImpl<$Res>
    implements _$DiscoveredCameraCopyWith<$Res> {
  __$DiscoveredCameraCopyWithImpl(this._self, this._then);

  final _DiscoveredCamera _self;
  final $Res Function(_DiscoveredCamera) _then;

/// Create a copy of DiscoveredCamera
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? host = null,Object? ports = null,Object? brand = freezed,Object? manufacturer = freezed,Object? model = freezed,Object? onvifPort = freezed,Object? ptz = null,Object? nvr = null,Object? foundBy = null,Object? rtspPort = freezed,Object? mainPath = freezed,Object? cameraId = freezed,}) {
  return _then(_DiscoveredCamera(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,ports: null == ports ? _self._ports : ports // ignore: cast_nullable_to_non_nullable
as List<int>,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as CameraBrand?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,onvifPort: freezed == onvifPort ? _self.onvifPort : onvifPort // ignore: cast_nullable_to_non_nullable
as int?,ptz: null == ptz ? _self.ptz : ptz // ignore: cast_nullable_to_non_nullable
as bool,nvr: null == nvr ? _self.nvr : nvr // ignore: cast_nullable_to_non_nullable
as bool,foundBy: null == foundBy ? _self.foundBy : foundBy // ignore: cast_nullable_to_non_nullable
as String,rtspPort: freezed == rtspPort ? _self.rtspPort : rtspPort // ignore: cast_nullable_to_non_nullable
as int?,mainPath: freezed == mainPath ? _self.mainPath : mainPath // ignore: cast_nullable_to_non_nullable
as String?,cameraId: freezed == cameraId ? _self.cameraId : cameraId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$StreamTest {

 bool get ok; String? get error; String? get codec; int? get width; int? get height; int get lenses; MediaSource? get preview;
/// Create a copy of StreamTest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreamTestCopyWith<StreamTest> get copyWith => _$StreamTestCopyWithImpl<StreamTest>(this as StreamTest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StreamTest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreamTest&&(identical(other.ok, _this.ok) || other.ok == _this.ok)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.codec, _this.codec) || other.codec == _this.codec)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.lenses, _this.lenses) || other.lenses == _this.lenses)&&(identical(other.preview, _this.preview) || other.preview == _this.preview));
}


@override
int get hashCode {
  final _this = this as StreamTest;
  return Object.hash(runtimeType,_this.ok,_this.error,_this.codec,_this.width,_this.height,_this.lenses,_this.preview);
}

@override
String toString() {
  final _this = this as StreamTest;
  return 'StreamTest(ok: ${_this.ok}, error: ${_this.error}, codec: ${_this.codec}, width: ${_this.width}, height: ${_this.height}, lenses: ${_this.lenses}, preview: ${_this.preview})';
}


}

/// @nodoc
abstract mixin class $StreamTestCopyWith<$Res>  {
  factory $StreamTestCopyWith(StreamTest value, $Res Function(StreamTest) _then) = _$StreamTestCopyWithImpl;
@useResult
$Res call({
 bool ok, String? error, String? codec, int? width, int? height, int lenses, MediaSource? preview
});




}
/// @nodoc
class _$StreamTestCopyWithImpl<$Res>
    implements $StreamTestCopyWith<$Res> {
  _$StreamTestCopyWithImpl(this._self, this._then);

  final StreamTest _self;
  final $Res Function(StreamTest) _then;

/// Create a copy of StreamTest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ok = null,Object? error = freezed,Object? codec = freezed,Object? width = freezed,Object? height = freezed,Object? lenses = null,Object? preview = freezed,}) {
  return _then(StreamTest(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,codec: freezed == codec ? _self.codec : codec // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,lenses: null == lenses ? _self.lenses : lenses // ignore: cast_nullable_to_non_nullable
as int,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as MediaSource?,
  ));
}

}


/// Adds pattern-matching-related methods to [StreamTest].
extension StreamTestPatterns on StreamTest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreamTest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreamTest() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreamTest value)  $default,){
final _that = this;
switch (_that) {
case _StreamTest():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreamTest value)?  $default,){
final _that = this;
switch (_that) {
case _StreamTest() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool ok,  String? error,  String? codec,  int? width,  int? height,  int lenses,  MediaSource? preview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreamTest() when $default != null:
return $default(_that.ok,_that.error,_that.codec,_that.width,_that.height,_that.lenses,_that.preview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool ok,  String? error,  String? codec,  int? width,  int? height,  int lenses,  MediaSource? preview)  $default,) {final _that = this;
switch (_that) {
case _StreamTest():
return $default(_that.ok,_that.error,_that.codec,_that.width,_that.height,_that.lenses,_that.preview);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool ok,  String? error,  String? codec,  int? width,  int? height,  int lenses,  MediaSource? preview)?  $default,) {final _that = this;
switch (_that) {
case _StreamTest() when $default != null:
return $default(_that.ok,_that.error,_that.codec,_that.width,_that.height,_that.lenses,_that.preview);case _:
  return null;

}
}

}

/// @nodoc


class _StreamTest implements StreamTest {
  const _StreamTest({required this.ok, this.error, this.codec, this.width, this.height, this.lenses = 1, this.preview});
  

@override final  bool ok;
@override final  String? error;
@override final  String? codec;
@override final  int? width;
@override final  int? height;
@override@JsonKey() final  int lenses;
@override final  MediaSource? preview;

/// Create a copy of StreamTest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreamTestCopyWith<_StreamTest> get copyWith => __$StreamTestCopyWithImpl<_StreamTest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreamTest&&(identical(other.ok, ok) || other.ok == ok)&&(identical(other.error, error) || other.error == error)&&(identical(other.codec, codec) || other.codec == codec)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.lenses, lenses) || other.lenses == lenses)&&(identical(other.preview, preview) || other.preview == preview));
}


@override
int get hashCode {
    return Object.hash(runtimeType,ok,error,codec,width,height,lenses,preview);
}

@override
String toString() {
    return 'StreamTest(ok: $ok, error: $error, codec: $codec, width: $width, height: $height, lenses: $lenses, preview: $preview)';
}


}

/// @nodoc
abstract mixin class _$StreamTestCopyWith<$Res> implements $StreamTestCopyWith<$Res> {
  factory _$StreamTestCopyWith(_StreamTest value, $Res Function(_StreamTest) _then) = __$StreamTestCopyWithImpl;
@override @useResult
$Res call({
 bool ok, String? error, String? codec, int? width, int? height, int lenses, MediaSource? preview
});




}
/// @nodoc
class __$StreamTestCopyWithImpl<$Res>
    implements _$StreamTestCopyWith<$Res> {
  __$StreamTestCopyWithImpl(this._self, this._then);

  final _StreamTest _self;
  final $Res Function(_StreamTest) _then;

/// Create a copy of StreamTest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ok = null,Object? error = freezed,Object? codec = freezed,Object? width = freezed,Object? height = freezed,Object? lenses = null,Object? preview = freezed,}) {
  return _then(_StreamTest(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,codec: freezed == codec ? _self.codec : codec // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,lenses: null == lenses ? _self.lenses : lenses // ignore: cast_nullable_to_non_nullable
as int,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as MediaSource?,
  ));
}


}

/// @nodoc
mixin _$CameraCapabilities {

 bool get ptz; bool get zoom; bool get presets; bool get home; bool get light; bool get siren; bool get audio; bool get twoWayAudio; bool get playback; bool get settings; bool get reboot;
/// Create a copy of CameraCapabilities
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraCapabilitiesCopyWith<CameraCapabilities> get copyWith => _$CameraCapabilitiesCopyWithImpl<CameraCapabilities>(this as CameraCapabilities, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CameraCapabilities;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraCapabilities&&(identical(other.ptz, _this.ptz) || other.ptz == _this.ptz)&&(identical(other.zoom, _this.zoom) || other.zoom == _this.zoom)&&(identical(other.presets, _this.presets) || other.presets == _this.presets)&&(identical(other.home, _this.home) || other.home == _this.home)&&(identical(other.light, _this.light) || other.light == _this.light)&&(identical(other.siren, _this.siren) || other.siren == _this.siren)&&(identical(other.audio, _this.audio) || other.audio == _this.audio)&&(identical(other.twoWayAudio, _this.twoWayAudio) || other.twoWayAudio == _this.twoWayAudio)&&(identical(other.playback, _this.playback) || other.playback == _this.playback)&&(identical(other.settings, _this.settings) || other.settings == _this.settings)&&(identical(other.reboot, _this.reboot) || other.reboot == _this.reboot));
}


@override
int get hashCode {
  final _this = this as CameraCapabilities;
  return Object.hash(runtimeType,_this.ptz,_this.zoom,_this.presets,_this.home,_this.light,_this.siren,_this.audio,_this.twoWayAudio,_this.playback,_this.settings,_this.reboot);
}

@override
String toString() {
  final _this = this as CameraCapabilities;
  return 'CameraCapabilities(ptz: ${_this.ptz}, zoom: ${_this.zoom}, presets: ${_this.presets}, home: ${_this.home}, light: ${_this.light}, siren: ${_this.siren}, audio: ${_this.audio}, twoWayAudio: ${_this.twoWayAudio}, playback: ${_this.playback}, settings: ${_this.settings}, reboot: ${_this.reboot})';
}


}

/// @nodoc
abstract mixin class $CameraCapabilitiesCopyWith<$Res>  {
  factory $CameraCapabilitiesCopyWith(CameraCapabilities value, $Res Function(CameraCapabilities) _then) = _$CameraCapabilitiesCopyWithImpl;
@useResult
$Res call({
 bool ptz, bool zoom, bool presets, bool home, bool light, bool siren, bool audio, bool twoWayAudio, bool playback, bool settings, bool reboot
});




}
/// @nodoc
class _$CameraCapabilitiesCopyWithImpl<$Res>
    implements $CameraCapabilitiesCopyWith<$Res> {
  _$CameraCapabilitiesCopyWithImpl(this._self, this._then);

  final CameraCapabilities _self;
  final $Res Function(CameraCapabilities) _then;

/// Create a copy of CameraCapabilities
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ptz = null,Object? zoom = null,Object? presets = null,Object? home = null,Object? light = null,Object? siren = null,Object? audio = null,Object? twoWayAudio = null,Object? playback = null,Object? settings = null,Object? reboot = null,}) {
  return _then(CameraCapabilities(
ptz: null == ptz ? _self.ptz : ptz // ignore: cast_nullable_to_non_nullable
as bool,zoom: null == zoom ? _self.zoom : zoom // ignore: cast_nullable_to_non_nullable
as bool,presets: null == presets ? _self.presets : presets // ignore: cast_nullable_to_non_nullable
as bool,home: null == home ? _self.home : home // ignore: cast_nullable_to_non_nullable
as bool,light: null == light ? _self.light : light // ignore: cast_nullable_to_non_nullable
as bool,siren: null == siren ? _self.siren : siren // ignore: cast_nullable_to_non_nullable
as bool,audio: null == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as bool,twoWayAudio: null == twoWayAudio ? _self.twoWayAudio : twoWayAudio // ignore: cast_nullable_to_non_nullable
as bool,playback: null == playback ? _self.playback : playback // ignore: cast_nullable_to_non_nullable
as bool,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as bool,reboot: null == reboot ? _self.reboot : reboot // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CameraCapabilities].
extension CameraCapabilitiesPatterns on CameraCapabilities {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CameraCapabilities value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CameraCapabilities() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CameraCapabilities value)  $default,){
final _that = this;
switch (_that) {
case _CameraCapabilities():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CameraCapabilities value)?  $default,){
final _that = this;
switch (_that) {
case _CameraCapabilities() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool ptz,  bool zoom,  bool presets,  bool home,  bool light,  bool siren,  bool audio,  bool twoWayAudio,  bool playback,  bool settings,  bool reboot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CameraCapabilities() when $default != null:
return $default(_that.ptz,_that.zoom,_that.presets,_that.home,_that.light,_that.siren,_that.audio,_that.twoWayAudio,_that.playback,_that.settings,_that.reboot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool ptz,  bool zoom,  bool presets,  bool home,  bool light,  bool siren,  bool audio,  bool twoWayAudio,  bool playback,  bool settings,  bool reboot)  $default,) {final _that = this;
switch (_that) {
case _CameraCapabilities():
return $default(_that.ptz,_that.zoom,_that.presets,_that.home,_that.light,_that.siren,_that.audio,_that.twoWayAudio,_that.playback,_that.settings,_that.reboot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool ptz,  bool zoom,  bool presets,  bool home,  bool light,  bool siren,  bool audio,  bool twoWayAudio,  bool playback,  bool settings,  bool reboot)?  $default,) {final _that = this;
switch (_that) {
case _CameraCapabilities() when $default != null:
return $default(_that.ptz,_that.zoom,_that.presets,_that.home,_that.light,_that.siren,_that.audio,_that.twoWayAudio,_that.playback,_that.settings,_that.reboot);case _:
  return null;

}
}

}

/// @nodoc


class _CameraCapabilities implements CameraCapabilities {
  const _CameraCapabilities({this.ptz = false, this.zoom = false, this.presets = false, this.home = false, this.light = false, this.siren = false, this.audio = false, this.twoWayAudio = false, this.playback = false, this.settings = false, this.reboot = false});
  

@override@JsonKey() final  bool ptz;
@override@JsonKey() final  bool zoom;
@override@JsonKey() final  bool presets;
@override@JsonKey() final  bool home;
@override@JsonKey() final  bool light;
@override@JsonKey() final  bool siren;
@override@JsonKey() final  bool audio;
@override@JsonKey() final  bool twoWayAudio;
@override@JsonKey() final  bool playback;
@override@JsonKey() final  bool settings;
@override@JsonKey() final  bool reboot;

/// Create a copy of CameraCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CameraCapabilitiesCopyWith<_CameraCapabilities> get copyWith => __$CameraCapabilitiesCopyWithImpl<_CameraCapabilities>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CameraCapabilities&&(identical(other.ptz, ptz) || other.ptz == ptz)&&(identical(other.zoom, zoom) || other.zoom == zoom)&&(identical(other.presets, presets) || other.presets == presets)&&(identical(other.home, home) || other.home == home)&&(identical(other.light, light) || other.light == light)&&(identical(other.siren, siren) || other.siren == siren)&&(identical(other.audio, audio) || other.audio == audio)&&(identical(other.twoWayAudio, twoWayAudio) || other.twoWayAudio == twoWayAudio)&&(identical(other.playback, playback) || other.playback == playback)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.reboot, reboot) || other.reboot == reboot));
}


@override
int get hashCode {
    return Object.hash(runtimeType,ptz,zoom,presets,home,light,siren,audio,twoWayAudio,playback,settings,reboot);
}

@override
String toString() {
    return 'CameraCapabilities(ptz: $ptz, zoom: $zoom, presets: $presets, home: $home, light: $light, siren: $siren, audio: $audio, twoWayAudio: $twoWayAudio, playback: $playback, settings: $settings, reboot: $reboot)';
}


}

/// @nodoc
abstract mixin class _$CameraCapabilitiesCopyWith<$Res> implements $CameraCapabilitiesCopyWith<$Res> {
  factory _$CameraCapabilitiesCopyWith(_CameraCapabilities value, $Res Function(_CameraCapabilities) _then) = __$CameraCapabilitiesCopyWithImpl;
@override @useResult
$Res call({
 bool ptz, bool zoom, bool presets, bool home, bool light, bool siren, bool audio, bool twoWayAudio, bool playback, bool settings, bool reboot
});




}
/// @nodoc
class __$CameraCapabilitiesCopyWithImpl<$Res>
    implements _$CameraCapabilitiesCopyWith<$Res> {
  __$CameraCapabilitiesCopyWithImpl(this._self, this._then);

  final _CameraCapabilities _self;
  final $Res Function(_CameraCapabilities) _then;

/// Create a copy of CameraCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ptz = null,Object? zoom = null,Object? presets = null,Object? home = null,Object? light = null,Object? siren = null,Object? audio = null,Object? twoWayAudio = null,Object? playback = null,Object? settings = null,Object? reboot = null,}) {
  return _then(_CameraCapabilities(
ptz: null == ptz ? _self.ptz : ptz // ignore: cast_nullable_to_non_nullable
as bool,zoom: null == zoom ? _self.zoom : zoom // ignore: cast_nullable_to_non_nullable
as bool,presets: null == presets ? _self.presets : presets // ignore: cast_nullable_to_non_nullable
as bool,home: null == home ? _self.home : home // ignore: cast_nullable_to_non_nullable
as bool,light: null == light ? _self.light : light // ignore: cast_nullable_to_non_nullable
as bool,siren: null == siren ? _self.siren : siren // ignore: cast_nullable_to_non_nullable
as bool,audio: null == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as bool,twoWayAudio: null == twoWayAudio ? _self.twoWayAudio : twoWayAudio // ignore: cast_nullable_to_non_nullable
as bool,playback: null == playback ? _self.playback : playback // ignore: cast_nullable_to_non_nullable
as bool,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as bool,reboot: null == reboot ? _self.reboot : reboot // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$Camera {

 String get id; String get siteId; String get name; CameraBrand get brand; String? get connectorId; String? get model; int get lenses; CameraCapabilities get capabilities; bool get enabled; int get position; bool? get online; DateTime? get checkedAt; String? get error; bool get hasSub; double get aspect;
/// Create a copy of Camera
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraCopyWith<Camera> get copyWith => _$CameraCopyWithImpl<Camera>(this as Camera, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Camera;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Camera&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.siteId, _this.siteId) || other.siteId == _this.siteId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.connectorId, _this.connectorId) || other.connectorId == _this.connectorId)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.lenses, _this.lenses) || other.lenses == _this.lenses)&&(identical(other.capabilities, _this.capabilities) || other.capabilities == _this.capabilities)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.online, _this.online) || other.online == _this.online)&&(identical(other.checkedAt, _this.checkedAt) || other.checkedAt == _this.checkedAt)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.hasSub, _this.hasSub) || other.hasSub == _this.hasSub)&&(identical(other.aspect, _this.aspect) || other.aspect == _this.aspect));
}


@override
int get hashCode {
  final _this = this as Camera;
  return Object.hash(runtimeType,_this.id,_this.siteId,_this.name,_this.brand,_this.connectorId,_this.model,_this.lenses,_this.capabilities,_this.enabled,_this.position,_this.online,_this.checkedAt,_this.error,_this.hasSub,_this.aspect);
}

@override
String toString() {
  final _this = this as Camera;
  return 'Camera(id: ${_this.id}, siteId: ${_this.siteId}, name: ${_this.name}, brand: ${_this.brand}, connectorId: ${_this.connectorId}, model: ${_this.model}, lenses: ${_this.lenses}, capabilities: ${_this.capabilities}, enabled: ${_this.enabled}, position: ${_this.position}, online: ${_this.online}, checkedAt: ${_this.checkedAt}, error: ${_this.error}, hasSub: ${_this.hasSub}, aspect: ${_this.aspect})';
}


}

/// @nodoc
abstract mixin class $CameraCopyWith<$Res>  {
  factory $CameraCopyWith(Camera value, $Res Function(Camera) _then) = _$CameraCopyWithImpl;
@useResult
$Res call({
 String id, String siteId, String name, CameraBrand brand, String? connectorId, String? model, int lenses, CameraCapabilities capabilities, bool enabled, int position, bool? online, DateTime? checkedAt, String? error, bool hasSub, double aspect
});


$CameraCapabilitiesCopyWith<$Res> get capabilities;

}
/// @nodoc
class _$CameraCopyWithImpl<$Res>
    implements $CameraCopyWith<$Res> {
  _$CameraCopyWithImpl(this._self, this._then);

  final Camera _self;
  final $Res Function(Camera) _then;

/// Create a copy of Camera
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? siteId = null,Object? name = null,Object? brand = null,Object? connectorId = freezed,Object? model = freezed,Object? lenses = null,Object? capabilities = null,Object? enabled = null,Object? position = null,Object? online = freezed,Object? checkedAt = freezed,Object? error = freezed,Object? hasSub = null,Object? aspect = null,}) {
  return _then(Camera(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as CameraBrand,connectorId: freezed == connectorId ? _self.connectorId : connectorId // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,lenses: null == lenses ? _self.lenses : lenses // ignore: cast_nullable_to_non_nullable
as int,capabilities: null == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as CameraCapabilities,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,online: freezed == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as bool?,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,hasSub: null == hasSub ? _self.hasSub : hasSub // ignore: cast_nullable_to_non_nullable
as bool,aspect: null == aspect ? _self.aspect : aspect // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of Camera
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CameraCapabilitiesCopyWith<$Res> get capabilities {
  
  return $CameraCapabilitiesCopyWith<$Res>(_self.capabilities, (value) {
    return _then(_self.copyWith(capabilities: value));
  });
}
}


/// Adds pattern-matching-related methods to [Camera].
extension CameraPatterns on Camera {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Camera value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Camera() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Camera value)  $default,){
final _that = this;
switch (_that) {
case _Camera():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Camera value)?  $default,){
final _that = this;
switch (_that) {
case _Camera() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String siteId,  String name,  CameraBrand brand,  String? connectorId,  String? model,  int lenses,  CameraCapabilities capabilities,  bool enabled,  int position,  bool? online,  DateTime? checkedAt,  String? error,  bool hasSub,  double aspect)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Camera() when $default != null:
return $default(_that.id,_that.siteId,_that.name,_that.brand,_that.connectorId,_that.model,_that.lenses,_that.capabilities,_that.enabled,_that.position,_that.online,_that.checkedAt,_that.error,_that.hasSub,_that.aspect);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String siteId,  String name,  CameraBrand brand,  String? connectorId,  String? model,  int lenses,  CameraCapabilities capabilities,  bool enabled,  int position,  bool? online,  DateTime? checkedAt,  String? error,  bool hasSub,  double aspect)  $default,) {final _that = this;
switch (_that) {
case _Camera():
return $default(_that.id,_that.siteId,_that.name,_that.brand,_that.connectorId,_that.model,_that.lenses,_that.capabilities,_that.enabled,_that.position,_that.online,_that.checkedAt,_that.error,_that.hasSub,_that.aspect);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String siteId,  String name,  CameraBrand brand,  String? connectorId,  String? model,  int lenses,  CameraCapabilities capabilities,  bool enabled,  int position,  bool? online,  DateTime? checkedAt,  String? error,  bool hasSub,  double aspect)?  $default,) {final _that = this;
switch (_that) {
case _Camera() when $default != null:
return $default(_that.id,_that.siteId,_that.name,_that.brand,_that.connectorId,_that.model,_that.lenses,_that.capabilities,_that.enabled,_that.position,_that.online,_that.checkedAt,_that.error,_that.hasSub,_that.aspect);case _:
  return null;

}
}

}

/// @nodoc


class _Camera extends Camera {
  const _Camera({required this.id, required this.siteId, required this.name, required this.brand, this.connectorId, this.model, this.lenses = 1, this.capabilities = const CameraCapabilities(), this.enabled = true, this.position = 0, this.online, this.checkedAt, this.error, this.hasSub = true, this.aspect = 16 / 9}): super._();
  

@override final  String id;
@override final  String siteId;
@override final  String name;
@override final  CameraBrand brand;
@override final  String? connectorId;
@override final  String? model;
@override@JsonKey() final  int lenses;
@override@JsonKey() final  CameraCapabilities capabilities;
@override@JsonKey() final  bool enabled;
@override@JsonKey() final  int position;
@override final  bool? online;
@override final  DateTime? checkedAt;
@override final  String? error;
@override@JsonKey() final  bool hasSub;
@override@JsonKey() final  double aspect;

/// Create a copy of Camera
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CameraCopyWith<_Camera> get copyWith => __$CameraCopyWithImpl<_Camera>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Camera&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.connectorId, connectorId) || other.connectorId == connectorId)&&(identical(other.model, model) || other.model == model)&&(identical(other.lenses, lenses) || other.lenses == lenses)&&(identical(other.capabilities, capabilities) || other.capabilities == capabilities)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.position, position) || other.position == position)&&(identical(other.online, online) || other.online == online)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.error, error) || other.error == error)&&(identical(other.hasSub, hasSub) || other.hasSub == hasSub)&&(identical(other.aspect, aspect) || other.aspect == aspect));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,siteId,name,brand,connectorId,model,lenses,capabilities,enabled,position,online,checkedAt,error,hasSub,aspect);
}

@override
String toString() {
    return 'Camera(id: $id, siteId: $siteId, name: $name, brand: $brand, connectorId: $connectorId, model: $model, lenses: $lenses, capabilities: $capabilities, enabled: $enabled, position: $position, online: $online, checkedAt: $checkedAt, error: $error, hasSub: $hasSub, aspect: $aspect)';
}


}

/// @nodoc
abstract mixin class _$CameraCopyWith<$Res> implements $CameraCopyWith<$Res> {
  factory _$CameraCopyWith(_Camera value, $Res Function(_Camera) _then) = __$CameraCopyWithImpl;
@override @useResult
$Res call({
 String id, String siteId, String name, CameraBrand brand, String? connectorId, String? model, int lenses, CameraCapabilities capabilities, bool enabled, int position, bool? online, DateTime? checkedAt, String? error, bool hasSub, double aspect
});


@override $CameraCapabilitiesCopyWith<$Res> get capabilities;

}
/// @nodoc
class __$CameraCopyWithImpl<$Res>
    implements _$CameraCopyWith<$Res> {
  __$CameraCopyWithImpl(this._self, this._then);

  final _Camera _self;
  final $Res Function(_Camera) _then;

/// Create a copy of Camera
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? siteId = null,Object? name = null,Object? brand = null,Object? connectorId = freezed,Object? model = freezed,Object? lenses = null,Object? capabilities = null,Object? enabled = null,Object? position = null,Object? online = freezed,Object? checkedAt = freezed,Object? error = freezed,Object? hasSub = null,Object? aspect = null,}) {
  return _then(_Camera(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as CameraBrand,connectorId: freezed == connectorId ? _self.connectorId : connectorId // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,lenses: null == lenses ? _self.lenses : lenses // ignore: cast_nullable_to_non_nullable
as int,capabilities: null == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as CameraCapabilities,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,online: freezed == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as bool?,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,hasSub: null == hasSub ? _self.hasSub : hasSub // ignore: cast_nullable_to_non_nullable
as bool,aspect: null == aspect ? _self.aspect : aspect // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of Camera
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CameraCapabilitiesCopyWith<$Res> get capabilities {
  
  return $CameraCapabilitiesCopyWith<$Res>(_self.capabilities, (value) {
    return _then(_self.copyWith(capabilities: value));
  });
}
}

/// @nodoc
mixin _$CameraTile {

 Camera get camera; int get lens; String? get viewId;
/// Create a copy of CameraTile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraTileCopyWith<CameraTile> get copyWith => _$CameraTileCopyWithImpl<CameraTile>(this as CameraTile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CameraTile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraTile&&(identical(other.camera, _this.camera) || other.camera == _this.camera)&&(identical(other.lens, _this.lens) || other.lens == _this.lens)&&(identical(other.viewId, _this.viewId) || other.viewId == _this.viewId));
}


@override
int get hashCode {
  final _this = this as CameraTile;
  return Object.hash(runtimeType,_this.camera,_this.lens,_this.viewId);
}

@override
String toString() {
  final _this = this as CameraTile;
  return 'CameraTile(camera: ${_this.camera}, lens: ${_this.lens}, viewId: ${_this.viewId})';
}


}

/// @nodoc
abstract mixin class $CameraTileCopyWith<$Res>  {
  factory $CameraTileCopyWith(CameraTile value, $Res Function(CameraTile) _then) = _$CameraTileCopyWithImpl;
@useResult
$Res call({
 Camera camera, int lens, String? viewId
});


$CameraCopyWith<$Res> get camera;

}
/// @nodoc
class _$CameraTileCopyWithImpl<$Res>
    implements $CameraTileCopyWith<$Res> {
  _$CameraTileCopyWithImpl(this._self, this._then);

  final CameraTile _self;
  final $Res Function(CameraTile) _then;

/// Create a copy of CameraTile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? camera = null,Object? lens = null,Object? viewId = freezed,}) {
  return _then(CameraTile(
camera: null == camera ? _self.camera : camera // ignore: cast_nullable_to_non_nullable
as Camera,lens: null == lens ? _self.lens : lens // ignore: cast_nullable_to_non_nullable
as int,viewId: freezed == viewId ? _self.viewId : viewId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CameraTile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CameraCopyWith<$Res> get camera {
  
  return $CameraCopyWith<$Res>(_self.camera, (value) {
    return _then(_self.copyWith(camera: value));
  });
}
}


/// Adds pattern-matching-related methods to [CameraTile].
extension CameraTilePatterns on CameraTile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CameraTile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CameraTile() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CameraTile value)  $default,){
final _that = this;
switch (_that) {
case _CameraTile():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CameraTile value)?  $default,){
final _that = this;
switch (_that) {
case _CameraTile() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Camera camera,  int lens,  String? viewId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CameraTile() when $default != null:
return $default(_that.camera,_that.lens,_that.viewId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Camera camera,  int lens,  String? viewId)  $default,) {final _that = this;
switch (_that) {
case _CameraTile():
return $default(_that.camera,_that.lens,_that.viewId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Camera camera,  int lens,  String? viewId)?  $default,) {final _that = this;
switch (_that) {
case _CameraTile() when $default != null:
return $default(_that.camera,_that.lens,_that.viewId);case _:
  return null;

}
}

}

/// @nodoc


class _CameraTile extends CameraTile {
  const _CameraTile({required this.camera, required this.lens, this.viewId}): super._();
  

@override final  Camera camera;
@override final  int lens;
@override final  String? viewId;

/// Create a copy of CameraTile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CameraTileCopyWith<_CameraTile> get copyWith => __$CameraTileCopyWithImpl<_CameraTile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CameraTile&&(identical(other.camera, camera) || other.camera == camera)&&(identical(other.lens, lens) || other.lens == lens)&&(identical(other.viewId, viewId) || other.viewId == viewId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,camera,lens,viewId);
}

@override
String toString() {
    return 'CameraTile(camera: $camera, lens: $lens, viewId: $viewId)';
}


}

/// @nodoc
abstract mixin class _$CameraTileCopyWith<$Res> implements $CameraTileCopyWith<$Res> {
  factory _$CameraTileCopyWith(_CameraTile value, $Res Function(_CameraTile) _then) = __$CameraTileCopyWithImpl;
@override @useResult
$Res call({
 Camera camera, int lens, String? viewId
});


@override $CameraCopyWith<$Res> get camera;

}
/// @nodoc
class __$CameraTileCopyWithImpl<$Res>
    implements _$CameraTileCopyWith<$Res> {
  __$CameraTileCopyWithImpl(this._self, this._then);

  final _CameraTile _self;
  final $Res Function(_CameraTile) _then;

/// Create a copy of CameraTile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? camera = null,Object? lens = null,Object? viewId = freezed,}) {
  return _then(_CameraTile(
camera: null == camera ? _self.camera : camera // ignore: cast_nullable_to_non_nullable
as Camera,lens: null == lens ? _self.lens : lens // ignore: cast_nullable_to_non_nullable
as int,viewId: freezed == viewId ? _self.viewId : viewId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CameraTile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CameraCopyWith<$Res> get camera {
  
  return $CameraCopyWith<$Res>(_self.camera, (value) {
    return _then(_self.copyWith(camera: value));
  });
}
}

/// @nodoc
mixin _$PtzPreset {

 String get token; String get name;
/// Create a copy of PtzPreset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PtzPresetCopyWith<PtzPreset> get copyWith => _$PtzPresetCopyWithImpl<PtzPreset>(this as PtzPreset, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PtzPreset;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PtzPreset&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as PtzPreset;
  return Object.hash(runtimeType,_this.token,_this.name);
}

@override
String toString() {
  final _this = this as PtzPreset;
  return 'PtzPreset(token: ${_this.token}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $PtzPresetCopyWith<$Res>  {
  factory $PtzPresetCopyWith(PtzPreset value, $Res Function(PtzPreset) _then) = _$PtzPresetCopyWithImpl;
@useResult
$Res call({
 String token, String name
});




}
/// @nodoc
class _$PtzPresetCopyWithImpl<$Res>
    implements $PtzPresetCopyWith<$Res> {
  _$PtzPresetCopyWithImpl(this._self, this._then);

  final PtzPreset _self;
  final $Res Function(PtzPreset) _then;

/// Create a copy of PtzPreset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? name = null,}) {
  return _then(PtzPreset(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PtzPreset].
extension PtzPresetPatterns on PtzPreset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PtzPreset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PtzPreset() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PtzPreset value)  $default,){
final _that = this;
switch (_that) {
case _PtzPreset():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PtzPreset value)?  $default,){
final _that = this;
switch (_that) {
case _PtzPreset() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PtzPreset() when $default != null:
return $default(_that.token,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String name)  $default,) {final _that = this;
switch (_that) {
case _PtzPreset():
return $default(_that.token,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String name)?  $default,) {final _that = this;
switch (_that) {
case _PtzPreset() when $default != null:
return $default(_that.token,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _PtzPreset implements PtzPreset {
  const _PtzPreset({required this.token, required this.name});
  

@override final  String token;
@override final  String name;

/// Create a copy of PtzPreset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PtzPresetCopyWith<_PtzPreset> get copyWith => __$PtzPresetCopyWithImpl<_PtzPreset>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PtzPreset&&(identical(other.token, token) || other.token == token)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,token,name);
}

@override
String toString() {
    return 'PtzPreset(token: $token, name: $name)';
}


}

/// @nodoc
abstract mixin class _$PtzPresetCopyWith<$Res> implements $PtzPresetCopyWith<$Res> {
  factory _$PtzPresetCopyWith(_PtzPreset value, $Res Function(_PtzPreset) _then) = __$PtzPresetCopyWithImpl;
@override @useResult
$Res call({
 String token, String name
});




}
/// @nodoc
class __$PtzPresetCopyWithImpl<$Res>
    implements _$PtzPresetCopyWith<$Res> {
  __$PtzPresetCopyWithImpl(this._self, this._then);

  final _PtzPreset _self;
  final $Res Function(_PtzPreset) _then;

/// Create a copy of PtzPreset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? name = null,}) {
  return _then(_PtzPreset(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CameraControls {

 List<PtzPreset> get presets; bool get light;
/// Create a copy of CameraControls
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraControlsCopyWith<CameraControls> get copyWith => _$CameraControlsCopyWithImpl<CameraControls>(this as CameraControls, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CameraControls;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraControls&&const DeepCollectionEquality().equals(other.presets, _this.presets)&&(identical(other.light, _this.light) || other.light == _this.light));
}


@override
int get hashCode {
  final _this = this as CameraControls;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.presets),_this.light);
}

@override
String toString() {
  final _this = this as CameraControls;
  return 'CameraControls(presets: ${_this.presets}, light: ${_this.light})';
}


}

/// @nodoc
abstract mixin class $CameraControlsCopyWith<$Res>  {
  factory $CameraControlsCopyWith(CameraControls value, $Res Function(CameraControls) _then) = _$CameraControlsCopyWithImpl;
@useResult
$Res call({
 List<PtzPreset> presets, bool light
});




}
/// @nodoc
class _$CameraControlsCopyWithImpl<$Res>
    implements $CameraControlsCopyWith<$Res> {
  _$CameraControlsCopyWithImpl(this._self, this._then);

  final CameraControls _self;
  final $Res Function(CameraControls) _then;

/// Create a copy of CameraControls
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? presets = null,Object? light = null,}) {
  return _then(CameraControls(
presets: null == presets ? _self.presets : presets // ignore: cast_nullable_to_non_nullable
as List<PtzPreset>,light: null == light ? _self.light : light // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CameraControls].
extension CameraControlsPatterns on CameraControls {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CameraControls value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CameraControls() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CameraControls value)  $default,){
final _that = this;
switch (_that) {
case _CameraControls():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CameraControls value)?  $default,){
final _that = this;
switch (_that) {
case _CameraControls() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PtzPreset> presets,  bool light)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CameraControls() when $default != null:
return $default(_that.presets,_that.light);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PtzPreset> presets,  bool light)  $default,) {final _that = this;
switch (_that) {
case _CameraControls():
return $default(_that.presets,_that.light);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PtzPreset> presets,  bool light)?  $default,) {final _that = this;
switch (_that) {
case _CameraControls() when $default != null:
return $default(_that.presets,_that.light);case _:
  return null;

}
}

}

/// @nodoc


class _CameraControls implements CameraControls {
  const _CameraControls({ List<PtzPreset> presets = const <PtzPreset>[], this.light = false}): _presets = presets;
  

 final  List<PtzPreset> _presets;
@override@JsonKey() List<PtzPreset> get presets {
  if (_presets is EqualUnmodifiableListView) return _presets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_presets);
}

@override@JsonKey() final  bool light;

/// Create a copy of CameraControls
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CameraControlsCopyWith<_CameraControls> get copyWith => __$CameraControlsCopyWithImpl<_CameraControls>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CameraControls&&const DeepCollectionEquality().equals(other.presets, _presets)&&(identical(other.light, light) || other.light == light));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_presets),light);
}

@override
String toString() {
    return 'CameraControls(presets: $presets, light: $light)';
}


}

/// @nodoc
abstract mixin class _$CameraControlsCopyWith<$Res> implements $CameraControlsCopyWith<$Res> {
  factory _$CameraControlsCopyWith(_CameraControls value, $Res Function(_CameraControls) _then) = __$CameraControlsCopyWithImpl;
@override @useResult
$Res call({
 List<PtzPreset> presets, bool light
});




}
/// @nodoc
class __$CameraControlsCopyWithImpl<$Res>
    implements _$CameraControlsCopyWith<$Res> {
  __$CameraControlsCopyWithImpl(this._self, this._then);

  final _CameraControls _self;
  final $Res Function(_CameraControls) _then;

/// Create a copy of CameraControls
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? presets = null,Object? light = null,}) {
  return _then(_CameraControls(
presets: null == presets ? _self._presets : presets // ignore: cast_nullable_to_non_nullable
as List<PtzPreset>,light: null == light ? _self.light : light // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$CameraDevice {

 String? get manufacturer; String? get model; String? get firmware; double? get clockOffsetSeconds; String? get timezone; bool get canReboot;
/// Create a copy of CameraDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraDeviceCopyWith<CameraDevice> get copyWith => _$CameraDeviceCopyWithImpl<CameraDevice>(this as CameraDevice, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CameraDevice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraDevice&&(identical(other.manufacturer, _this.manufacturer) || other.manufacturer == _this.manufacturer)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.firmware, _this.firmware) || other.firmware == _this.firmware)&&(identical(other.clockOffsetSeconds, _this.clockOffsetSeconds) || other.clockOffsetSeconds == _this.clockOffsetSeconds)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.canReboot, _this.canReboot) || other.canReboot == _this.canReboot));
}


@override
int get hashCode {
  final _this = this as CameraDevice;
  return Object.hash(runtimeType,_this.manufacturer,_this.model,_this.firmware,_this.clockOffsetSeconds,_this.timezone,_this.canReboot);
}

@override
String toString() {
  final _this = this as CameraDevice;
  return 'CameraDevice(manufacturer: ${_this.manufacturer}, model: ${_this.model}, firmware: ${_this.firmware}, clockOffsetSeconds: ${_this.clockOffsetSeconds}, timezone: ${_this.timezone}, canReboot: ${_this.canReboot})';
}


}

/// @nodoc
abstract mixin class $CameraDeviceCopyWith<$Res>  {
  factory $CameraDeviceCopyWith(CameraDevice value, $Res Function(CameraDevice) _then) = _$CameraDeviceCopyWithImpl;
@useResult
$Res call({
 String? manufacturer, String? model, String? firmware, double? clockOffsetSeconds, String? timezone, bool canReboot
});




}
/// @nodoc
class _$CameraDeviceCopyWithImpl<$Res>
    implements $CameraDeviceCopyWith<$Res> {
  _$CameraDeviceCopyWithImpl(this._self, this._then);

  final CameraDevice _self;
  final $Res Function(CameraDevice) _then;

/// Create a copy of CameraDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? manufacturer = freezed,Object? model = freezed,Object? firmware = freezed,Object? clockOffsetSeconds = freezed,Object? timezone = freezed,Object? canReboot = null,}) {
  return _then(CameraDevice(
manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,firmware: freezed == firmware ? _self.firmware : firmware // ignore: cast_nullable_to_non_nullable
as String?,clockOffsetSeconds: freezed == clockOffsetSeconds ? _self.clockOffsetSeconds : clockOffsetSeconds // ignore: cast_nullable_to_non_nullable
as double?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,canReboot: null == canReboot ? _self.canReboot : canReboot // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CameraDevice].
extension CameraDevicePatterns on CameraDevice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CameraDevice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CameraDevice() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CameraDevice value)  $default,){
final _that = this;
switch (_that) {
case _CameraDevice():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CameraDevice value)?  $default,){
final _that = this;
switch (_that) {
case _CameraDevice() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? manufacturer,  String? model,  String? firmware,  double? clockOffsetSeconds,  String? timezone,  bool canReboot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CameraDevice() when $default != null:
return $default(_that.manufacturer,_that.model,_that.firmware,_that.clockOffsetSeconds,_that.timezone,_that.canReboot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? manufacturer,  String? model,  String? firmware,  double? clockOffsetSeconds,  String? timezone,  bool canReboot)  $default,) {final _that = this;
switch (_that) {
case _CameraDevice():
return $default(_that.manufacturer,_that.model,_that.firmware,_that.clockOffsetSeconds,_that.timezone,_that.canReboot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? manufacturer,  String? model,  String? firmware,  double? clockOffsetSeconds,  String? timezone,  bool canReboot)?  $default,) {final _that = this;
switch (_that) {
case _CameraDevice() when $default != null:
return $default(_that.manufacturer,_that.model,_that.firmware,_that.clockOffsetSeconds,_that.timezone,_that.canReboot);case _:
  return null;

}
}

}

/// @nodoc


class _CameraDevice implements CameraDevice {
  const _CameraDevice({this.manufacturer, this.model, this.firmware, this.clockOffsetSeconds, this.timezone, this.canReboot = false});
  

@override final  String? manufacturer;
@override final  String? model;
@override final  String? firmware;
@override final  double? clockOffsetSeconds;
@override final  String? timezone;
@override@JsonKey() final  bool canReboot;

/// Create a copy of CameraDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CameraDeviceCopyWith<_CameraDevice> get copyWith => __$CameraDeviceCopyWithImpl<_CameraDevice>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CameraDevice&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.model, model) || other.model == model)&&(identical(other.firmware, firmware) || other.firmware == firmware)&&(identical(other.clockOffsetSeconds, clockOffsetSeconds) || other.clockOffsetSeconds == clockOffsetSeconds)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.canReboot, canReboot) || other.canReboot == canReboot));
}


@override
int get hashCode {
    return Object.hash(runtimeType,manufacturer,model,firmware,clockOffsetSeconds,timezone,canReboot);
}

@override
String toString() {
    return 'CameraDevice(manufacturer: $manufacturer, model: $model, firmware: $firmware, clockOffsetSeconds: $clockOffsetSeconds, timezone: $timezone, canReboot: $canReboot)';
}


}

/// @nodoc
abstract mixin class _$CameraDeviceCopyWith<$Res> implements $CameraDeviceCopyWith<$Res> {
  factory _$CameraDeviceCopyWith(_CameraDevice value, $Res Function(_CameraDevice) _then) = __$CameraDeviceCopyWithImpl;
@override @useResult
$Res call({
 String? manufacturer, String? model, String? firmware, double? clockOffsetSeconds, String? timezone, bool canReboot
});




}
/// @nodoc
class __$CameraDeviceCopyWithImpl<$Res>
    implements _$CameraDeviceCopyWith<$Res> {
  __$CameraDeviceCopyWithImpl(this._self, this._then);

  final _CameraDevice _self;
  final $Res Function(_CameraDevice) _then;

/// Create a copy of CameraDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? manufacturer = freezed,Object? model = freezed,Object? firmware = freezed,Object? clockOffsetSeconds = freezed,Object? timezone = freezed,Object? canReboot = null,}) {
  return _then(_CameraDevice(
manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,firmware: freezed == firmware ? _self.firmware : firmware // ignore: cast_nullable_to_non_nullable
as String?,clockOffsetSeconds: freezed == clockOffsetSeconds ? _self.clockOffsetSeconds : clockOffsetSeconds // ignore: cast_nullable_to_non_nullable
as double?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,canReboot: null == canReboot ? _self.canReboot : canReboot // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$VideoEncoder {

 String get token; String get name; String? get encoding; int? get width; int? get height; double? get fps; int? get bitrate;
/// Create a copy of VideoEncoder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoEncoderCopyWith<VideoEncoder> get copyWith => _$VideoEncoderCopyWithImpl<VideoEncoder>(this as VideoEncoder, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VideoEncoder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoEncoder&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.encoding, _this.encoding) || other.encoding == _this.encoding)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.fps, _this.fps) || other.fps == _this.fps)&&(identical(other.bitrate, _this.bitrate) || other.bitrate == _this.bitrate));
}


@override
int get hashCode {
  final _this = this as VideoEncoder;
  return Object.hash(runtimeType,_this.token,_this.name,_this.encoding,_this.width,_this.height,_this.fps,_this.bitrate);
}

@override
String toString() {
  final _this = this as VideoEncoder;
  return 'VideoEncoder(token: ${_this.token}, name: ${_this.name}, encoding: ${_this.encoding}, width: ${_this.width}, height: ${_this.height}, fps: ${_this.fps}, bitrate: ${_this.bitrate})';
}


}

/// @nodoc
abstract mixin class $VideoEncoderCopyWith<$Res>  {
  factory $VideoEncoderCopyWith(VideoEncoder value, $Res Function(VideoEncoder) _then) = _$VideoEncoderCopyWithImpl;
@useResult
$Res call({
 String token, String name, String? encoding, int? width, int? height, double? fps, int? bitrate
});




}
/// @nodoc
class _$VideoEncoderCopyWithImpl<$Res>
    implements $VideoEncoderCopyWith<$Res> {
  _$VideoEncoderCopyWithImpl(this._self, this._then);

  final VideoEncoder _self;
  final $Res Function(VideoEncoder) _then;

/// Create a copy of VideoEncoder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? name = null,Object? encoding = freezed,Object? width = freezed,Object? height = freezed,Object? fps = freezed,Object? bitrate = freezed,}) {
  return _then(VideoEncoder(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,encoding: freezed == encoding ? _self.encoding : encoding // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,fps: freezed == fps ? _self.fps : fps // ignore: cast_nullable_to_non_nullable
as double?,bitrate: freezed == bitrate ? _self.bitrate : bitrate // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoEncoder].
extension VideoEncoderPatterns on VideoEncoder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoEncoder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoEncoder() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoEncoder value)  $default,){
final _that = this;
switch (_that) {
case _VideoEncoder():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoEncoder value)?  $default,){
final _that = this;
switch (_that) {
case _VideoEncoder() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String name,  String? encoding,  int? width,  int? height,  double? fps,  int? bitrate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoEncoder() when $default != null:
return $default(_that.token,_that.name,_that.encoding,_that.width,_that.height,_that.fps,_that.bitrate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String name,  String? encoding,  int? width,  int? height,  double? fps,  int? bitrate)  $default,) {final _that = this;
switch (_that) {
case _VideoEncoder():
return $default(_that.token,_that.name,_that.encoding,_that.width,_that.height,_that.fps,_that.bitrate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String name,  String? encoding,  int? width,  int? height,  double? fps,  int? bitrate)?  $default,) {final _that = this;
switch (_that) {
case _VideoEncoder() when $default != null:
return $default(_that.token,_that.name,_that.encoding,_that.width,_that.height,_that.fps,_that.bitrate);case _:
  return null;

}
}

}

/// @nodoc


class _VideoEncoder implements VideoEncoder {
  const _VideoEncoder({required this.token, required this.name, this.encoding, this.width, this.height, this.fps, this.bitrate});
  

@override final  String token;
@override final  String name;
@override final  String? encoding;
@override final  int? width;
@override final  int? height;
@override final  double? fps;
@override final  int? bitrate;

/// Create a copy of VideoEncoder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoEncoderCopyWith<_VideoEncoder> get copyWith => __$VideoEncoderCopyWithImpl<_VideoEncoder>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoEncoder&&(identical(other.token, token) || other.token == token)&&(identical(other.name, name) || other.name == name)&&(identical(other.encoding, encoding) || other.encoding == encoding)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.fps, fps) || other.fps == fps)&&(identical(other.bitrate, bitrate) || other.bitrate == bitrate));
}


@override
int get hashCode {
    return Object.hash(runtimeType,token,name,encoding,width,height,fps,bitrate);
}

@override
String toString() {
    return 'VideoEncoder(token: $token, name: $name, encoding: $encoding, width: $width, height: $height, fps: $fps, bitrate: $bitrate)';
}


}

/// @nodoc
abstract mixin class _$VideoEncoderCopyWith<$Res> implements $VideoEncoderCopyWith<$Res> {
  factory _$VideoEncoderCopyWith(_VideoEncoder value, $Res Function(_VideoEncoder) _then) = __$VideoEncoderCopyWithImpl;
@override @useResult
$Res call({
 String token, String name, String? encoding, int? width, int? height, double? fps, int? bitrate
});




}
/// @nodoc
class __$VideoEncoderCopyWithImpl<$Res>
    implements _$VideoEncoderCopyWith<$Res> {
  __$VideoEncoderCopyWithImpl(this._self, this._then);

  final _VideoEncoder _self;
  final $Res Function(_VideoEncoder) _then;

/// Create a copy of VideoEncoder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? name = null,Object? encoding = freezed,Object? width = freezed,Object? height = freezed,Object? fps = freezed,Object? bitrate = freezed,}) {
  return _then(_VideoEncoder(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,encoding: freezed == encoding ? _self.encoding : encoding // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,fps: freezed == fps ? _self.fps : fps // ignore: cast_nullable_to_non_nullable
as double?,bitrate: freezed == bitrate ? _self.bitrate : bitrate // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$ImageSettings {

 double? get brightness; double? get contrast; double? get saturation; double? get sharpness; String? get irCut; List<String> get irCutModes;
/// Create a copy of ImageSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageSettingsCopyWith<ImageSettings> get copyWith => _$ImageSettingsCopyWithImpl<ImageSettings>(this as ImageSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ImageSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageSettings&&(identical(other.brightness, _this.brightness) || other.brightness == _this.brightness)&&(identical(other.contrast, _this.contrast) || other.contrast == _this.contrast)&&(identical(other.saturation, _this.saturation) || other.saturation == _this.saturation)&&(identical(other.sharpness, _this.sharpness) || other.sharpness == _this.sharpness)&&(identical(other.irCut, _this.irCut) || other.irCut == _this.irCut)&&const DeepCollectionEquality().equals(other.irCutModes, _this.irCutModes));
}


@override
int get hashCode {
  final _this = this as ImageSettings;
  return Object.hash(runtimeType,_this.brightness,_this.contrast,_this.saturation,_this.sharpness,_this.irCut,const DeepCollectionEquality().hash(_this.irCutModes));
}

@override
String toString() {
  final _this = this as ImageSettings;
  return 'ImageSettings(brightness: ${_this.brightness}, contrast: ${_this.contrast}, saturation: ${_this.saturation}, sharpness: ${_this.sharpness}, irCut: ${_this.irCut}, irCutModes: ${_this.irCutModes})';
}


}

/// @nodoc
abstract mixin class $ImageSettingsCopyWith<$Res>  {
  factory $ImageSettingsCopyWith(ImageSettings value, $Res Function(ImageSettings) _then) = _$ImageSettingsCopyWithImpl;
@useResult
$Res call({
 double? brightness, double? contrast, double? saturation, double? sharpness, String? irCut, List<String> irCutModes
});




}
/// @nodoc
class _$ImageSettingsCopyWithImpl<$Res>
    implements $ImageSettingsCopyWith<$Res> {
  _$ImageSettingsCopyWithImpl(this._self, this._then);

  final ImageSettings _self;
  final $Res Function(ImageSettings) _then;

/// Create a copy of ImageSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? brightness = freezed,Object? contrast = freezed,Object? saturation = freezed,Object? sharpness = freezed,Object? irCut = freezed,Object? irCutModes = null,}) {
  return _then(ImageSettings(
brightness: freezed == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as double?,contrast: freezed == contrast ? _self.contrast : contrast // ignore: cast_nullable_to_non_nullable
as double?,saturation: freezed == saturation ? _self.saturation : saturation // ignore: cast_nullable_to_non_nullable
as double?,sharpness: freezed == sharpness ? _self.sharpness : sharpness // ignore: cast_nullable_to_non_nullable
as double?,irCut: freezed == irCut ? _self.irCut : irCut // ignore: cast_nullable_to_non_nullable
as String?,irCutModes: null == irCutModes ? _self.irCutModes : irCutModes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageSettings].
extension ImageSettingsPatterns on ImageSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageSettings() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageSettings value)  $default,){
final _that = this;
switch (_that) {
case _ImageSettings():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ImageSettings() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? brightness,  double? contrast,  double? saturation,  double? sharpness,  String? irCut,  List<String> irCutModes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageSettings() when $default != null:
return $default(_that.brightness,_that.contrast,_that.saturation,_that.sharpness,_that.irCut,_that.irCutModes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? brightness,  double? contrast,  double? saturation,  double? sharpness,  String? irCut,  List<String> irCutModes)  $default,) {final _that = this;
switch (_that) {
case _ImageSettings():
return $default(_that.brightness,_that.contrast,_that.saturation,_that.sharpness,_that.irCut,_that.irCutModes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? brightness,  double? contrast,  double? saturation,  double? sharpness,  String? irCut,  List<String> irCutModes)?  $default,) {final _that = this;
switch (_that) {
case _ImageSettings() when $default != null:
return $default(_that.brightness,_that.contrast,_that.saturation,_that.sharpness,_that.irCut,_that.irCutModes);case _:
  return null;

}
}

}

/// @nodoc


class _ImageSettings implements ImageSettings {
  const _ImageSettings({this.brightness, this.contrast, this.saturation, this.sharpness, this.irCut,  List<String> irCutModes = const <String>[]}): _irCutModes = irCutModes;
  

@override final  double? brightness;
@override final  double? contrast;
@override final  double? saturation;
@override final  double? sharpness;
@override final  String? irCut;
 final  List<String> _irCutModes;
@override@JsonKey() List<String> get irCutModes {
  if (_irCutModes is EqualUnmodifiableListView) return _irCutModes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_irCutModes);
}


/// Create a copy of ImageSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageSettingsCopyWith<_ImageSettings> get copyWith => __$ImageSettingsCopyWithImpl<_ImageSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageSettings&&(identical(other.brightness, brightness) || other.brightness == brightness)&&(identical(other.contrast, contrast) || other.contrast == contrast)&&(identical(other.saturation, saturation) || other.saturation == saturation)&&(identical(other.sharpness, sharpness) || other.sharpness == sharpness)&&(identical(other.irCut, irCut) || other.irCut == irCut)&&const DeepCollectionEquality().equals(other.irCutModes, _irCutModes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,brightness,contrast,saturation,sharpness,irCut,const DeepCollectionEquality().hash(_irCutModes));
}

@override
String toString() {
    return 'ImageSettings(brightness: $brightness, contrast: $contrast, saturation: $saturation, sharpness: $sharpness, irCut: $irCut, irCutModes: $irCutModes)';
}


}

/// @nodoc
abstract mixin class _$ImageSettingsCopyWith<$Res> implements $ImageSettingsCopyWith<$Res> {
  factory _$ImageSettingsCopyWith(_ImageSettings value, $Res Function(_ImageSettings) _then) = __$ImageSettingsCopyWithImpl;
@override @useResult
$Res call({
 double? brightness, double? contrast, double? saturation, double? sharpness, String? irCut, List<String> irCutModes
});




}
/// @nodoc
class __$ImageSettingsCopyWithImpl<$Res>
    implements _$ImageSettingsCopyWith<$Res> {
  __$ImageSettingsCopyWithImpl(this._self, this._then);

  final _ImageSettings _self;
  final $Res Function(_ImageSettings) _then;

/// Create a copy of ImageSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? brightness = freezed,Object? contrast = freezed,Object? saturation = freezed,Object? sharpness = freezed,Object? irCut = freezed,Object? irCutModes = null,}) {
  return _then(_ImageSettings(
brightness: freezed == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as double?,contrast: freezed == contrast ? _self.contrast : contrast // ignore: cast_nullable_to_non_nullable
as double?,saturation: freezed == saturation ? _self.saturation : saturation // ignore: cast_nullable_to_non_nullable
as double?,sharpness: freezed == sharpness ? _self.sharpness : sharpness // ignore: cast_nullable_to_non_nullable
as double?,irCut: freezed == irCut ? _self.irCut : irCut // ignore: cast_nullable_to_non_nullable
as String?,irCutModes: null == irCutModes ? _self._irCutModes : irCutModes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$MotionSettings {

 bool? get enabled; int? get sensitivity; int get min; int get max;
/// Create a copy of MotionSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MotionSettingsCopyWith<MotionSettings> get copyWith => _$MotionSettingsCopyWithImpl<MotionSettings>(this as MotionSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MotionSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MotionSettings&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.sensitivity, _this.sensitivity) || other.sensitivity == _this.sensitivity)&&(identical(other.min, _this.min) || other.min == _this.min)&&(identical(other.max, _this.max) || other.max == _this.max));
}


@override
int get hashCode {
  final _this = this as MotionSettings;
  return Object.hash(runtimeType,_this.enabled,_this.sensitivity,_this.min,_this.max);
}

@override
String toString() {
  final _this = this as MotionSettings;
  return 'MotionSettings(enabled: ${_this.enabled}, sensitivity: ${_this.sensitivity}, min: ${_this.min}, max: ${_this.max})';
}


}

/// @nodoc
abstract mixin class $MotionSettingsCopyWith<$Res>  {
  factory $MotionSettingsCopyWith(MotionSettings value, $Res Function(MotionSettings) _then) = _$MotionSettingsCopyWithImpl;
@useResult
$Res call({
 bool? enabled, int? sensitivity, int min, int max
});




}
/// @nodoc
class _$MotionSettingsCopyWithImpl<$Res>
    implements $MotionSettingsCopyWith<$Res> {
  _$MotionSettingsCopyWithImpl(this._self, this._then);

  final MotionSettings _self;
  final $Res Function(MotionSettings) _then;

/// Create a copy of MotionSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = freezed,Object? sensitivity = freezed,Object? min = null,Object? max = null,}) {
  return _then(MotionSettings(
enabled: freezed == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool?,sensitivity: freezed == sensitivity ? _self.sensitivity : sensitivity // ignore: cast_nullable_to_non_nullable
as int?,min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MotionSettings].
extension MotionSettingsPatterns on MotionSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MotionSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MotionSettings() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MotionSettings value)  $default,){
final _that = this;
switch (_that) {
case _MotionSettings():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MotionSettings value)?  $default,){
final _that = this;
switch (_that) {
case _MotionSettings() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? enabled,  int? sensitivity,  int min,  int max)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MotionSettings() when $default != null:
return $default(_that.enabled,_that.sensitivity,_that.min,_that.max);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? enabled,  int? sensitivity,  int min,  int max)  $default,) {final _that = this;
switch (_that) {
case _MotionSettings():
return $default(_that.enabled,_that.sensitivity,_that.min,_that.max);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? enabled,  int? sensitivity,  int min,  int max)?  $default,) {final _that = this;
switch (_that) {
case _MotionSettings() when $default != null:
return $default(_that.enabled,_that.sensitivity,_that.min,_that.max);case _:
  return null;

}
}

}

/// @nodoc


class _MotionSettings implements MotionSettings {
  const _MotionSettings({this.enabled, this.sensitivity, this.min = 0, this.max = 100});
  

@override final  bool? enabled;
@override final  int? sensitivity;
@override@JsonKey() final  int min;
@override@JsonKey() final  int max;

/// Create a copy of MotionSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MotionSettingsCopyWith<_MotionSettings> get copyWith => __$MotionSettingsCopyWithImpl<_MotionSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MotionSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.sensitivity, sensitivity) || other.sensitivity == sensitivity)&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max));
}


@override
int get hashCode {
    return Object.hash(runtimeType,enabled,sensitivity,min,max);
}

@override
String toString() {
    return 'MotionSettings(enabled: $enabled, sensitivity: $sensitivity, min: $min, max: $max)';
}


}

/// @nodoc
abstract mixin class _$MotionSettingsCopyWith<$Res> implements $MotionSettingsCopyWith<$Res> {
  factory _$MotionSettingsCopyWith(_MotionSettings value, $Res Function(_MotionSettings) _then) = __$MotionSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool? enabled, int? sensitivity, int min, int max
});




}
/// @nodoc
class __$MotionSettingsCopyWithImpl<$Res>
    implements _$MotionSettingsCopyWith<$Res> {
  __$MotionSettingsCopyWithImpl(this._self, this._then);

  final _MotionSettings _self;
  final $Res Function(_MotionSettings) _then;

/// Create a copy of MotionSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = freezed,Object? sensitivity = freezed,Object? min = null,Object? max = null,}) {
  return _then(_MotionSettings(
enabled: freezed == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool?,sensitivity: freezed == sensitivity ? _self.sensitivity : sensitivity // ignore: cast_nullable_to_non_nullable
as int?,min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CameraSettings {

 CameraDevice get device; List<VideoEncoder> get encoders; ImageSettings? get image; MotionSettings? get motion;
/// Create a copy of CameraSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraSettingsCopyWith<CameraSettings> get copyWith => _$CameraSettingsCopyWithImpl<CameraSettings>(this as CameraSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CameraSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraSettings&&(identical(other.device, _this.device) || other.device == _this.device)&&const DeepCollectionEquality().equals(other.encoders, _this.encoders)&&(identical(other.image, _this.image) || other.image == _this.image)&&(identical(other.motion, _this.motion) || other.motion == _this.motion));
}


@override
int get hashCode {
  final _this = this as CameraSettings;
  return Object.hash(runtimeType,_this.device,const DeepCollectionEquality().hash(_this.encoders),_this.image,_this.motion);
}

@override
String toString() {
  final _this = this as CameraSettings;
  return 'CameraSettings(device: ${_this.device}, encoders: ${_this.encoders}, image: ${_this.image}, motion: ${_this.motion})';
}


}

/// @nodoc
abstract mixin class $CameraSettingsCopyWith<$Res>  {
  factory $CameraSettingsCopyWith(CameraSettings value, $Res Function(CameraSettings) _then) = _$CameraSettingsCopyWithImpl;
@useResult
$Res call({
 CameraDevice device, List<VideoEncoder> encoders, ImageSettings? image, MotionSettings? motion
});


$CameraDeviceCopyWith<$Res> get device;$ImageSettingsCopyWith<$Res>? get image;$MotionSettingsCopyWith<$Res>? get motion;

}
/// @nodoc
class _$CameraSettingsCopyWithImpl<$Res>
    implements $CameraSettingsCopyWith<$Res> {
  _$CameraSettingsCopyWithImpl(this._self, this._then);

  final CameraSettings _self;
  final $Res Function(CameraSettings) _then;

/// Create a copy of CameraSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? device = null,Object? encoders = null,Object? image = freezed,Object? motion = freezed,}) {
  return _then(CameraSettings(
device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as CameraDevice,encoders: null == encoders ? _self.encoders : encoders // ignore: cast_nullable_to_non_nullable
as List<VideoEncoder>,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as ImageSettings?,motion: freezed == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionSettings?,
  ));
}
/// Create a copy of CameraSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CameraDeviceCopyWith<$Res> get device {
  
  return $CameraDeviceCopyWith<$Res>(_self.device, (value) {
    return _then(_self.copyWith(device: value));
  });
}/// Create a copy of CameraSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageSettingsCopyWith<$Res>? get image {
    if (_self.image == null) {
    return null;
  }

  return $ImageSettingsCopyWith<$Res>(_self.image!, (value) {
    return _then(_self.copyWith(image: value));
  });
}/// Create a copy of CameraSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MotionSettingsCopyWith<$Res>? get motion {
    if (_self.motion == null) {
    return null;
  }

  return $MotionSettingsCopyWith<$Res>(_self.motion!, (value) {
    return _then(_self.copyWith(motion: value));
  });
}
}


/// Adds pattern-matching-related methods to [CameraSettings].
extension CameraSettingsPatterns on CameraSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CameraSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CameraSettings() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CameraSettings value)  $default,){
final _that = this;
switch (_that) {
case _CameraSettings():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CameraSettings value)?  $default,){
final _that = this;
switch (_that) {
case _CameraSettings() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CameraDevice device,  List<VideoEncoder> encoders,  ImageSettings? image,  MotionSettings? motion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CameraSettings() when $default != null:
return $default(_that.device,_that.encoders,_that.image,_that.motion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CameraDevice device,  List<VideoEncoder> encoders,  ImageSettings? image,  MotionSettings? motion)  $default,) {final _that = this;
switch (_that) {
case _CameraSettings():
return $default(_that.device,_that.encoders,_that.image,_that.motion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CameraDevice device,  List<VideoEncoder> encoders,  ImageSettings? image,  MotionSettings? motion)?  $default,) {final _that = this;
switch (_that) {
case _CameraSettings() when $default != null:
return $default(_that.device,_that.encoders,_that.image,_that.motion);case _:
  return null;

}
}

}

/// @nodoc


class _CameraSettings implements CameraSettings {
  const _CameraSettings({required this.device,  List<VideoEncoder> encoders = const <VideoEncoder>[], this.image, this.motion}): _encoders = encoders;
  

@override final  CameraDevice device;
 final  List<VideoEncoder> _encoders;
@override@JsonKey() List<VideoEncoder> get encoders {
  if (_encoders is EqualUnmodifiableListView) return _encoders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_encoders);
}

@override final  ImageSettings? image;
@override final  MotionSettings? motion;

/// Create a copy of CameraSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CameraSettingsCopyWith<_CameraSettings> get copyWith => __$CameraSettingsCopyWithImpl<_CameraSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CameraSettings&&(identical(other.device, device) || other.device == device)&&const DeepCollectionEquality().equals(other.encoders, _encoders)&&(identical(other.image, image) || other.image == image)&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,device,const DeepCollectionEquality().hash(_encoders),image,motion);
}

@override
String toString() {
    return 'CameraSettings(device: $device, encoders: $encoders, image: $image, motion: $motion)';
}


}

/// @nodoc
abstract mixin class _$CameraSettingsCopyWith<$Res> implements $CameraSettingsCopyWith<$Res> {
  factory _$CameraSettingsCopyWith(_CameraSettings value, $Res Function(_CameraSettings) _then) = __$CameraSettingsCopyWithImpl;
@override @useResult
$Res call({
 CameraDevice device, List<VideoEncoder> encoders, ImageSettings? image, MotionSettings? motion
});


@override $CameraDeviceCopyWith<$Res> get device;@override $ImageSettingsCopyWith<$Res>? get image;@override $MotionSettingsCopyWith<$Res>? get motion;

}
/// @nodoc
class __$CameraSettingsCopyWithImpl<$Res>
    implements _$CameraSettingsCopyWith<$Res> {
  __$CameraSettingsCopyWithImpl(this._self, this._then);

  final _CameraSettings _self;
  final $Res Function(_CameraSettings) _then;

/// Create a copy of CameraSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? device = null,Object? encoders = null,Object? image = freezed,Object? motion = freezed,}) {
  return _then(_CameraSettings(
device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as CameraDevice,encoders: null == encoders ? _self._encoders : encoders // ignore: cast_nullable_to_non_nullable
as List<VideoEncoder>,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as ImageSettings?,motion: freezed == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionSettings?,
  ));
}

/// Create a copy of CameraSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CameraDeviceCopyWith<$Res> get device {
  
  return $CameraDeviceCopyWith<$Res>(_self.device, (value) {
    return _then(_self.copyWith(device: value));
  });
}/// Create a copy of CameraSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageSettingsCopyWith<$Res>? get image {
    if (_self.image == null) {
    return null;
  }

  return $ImageSettingsCopyWith<$Res>(_self.image!, (value) {
    return _then(_self.copyWith(image: value));
  });
}/// Create a copy of CameraSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MotionSettingsCopyWith<$Res>? get motion {
    if (_self.motion == null) {
    return null;
  }

  return $MotionSettingsCopyWith<$Res>(_self.motion!, (value) {
    return _then(_self.copyWith(motion: value));
  });
}
}

// dart format on
