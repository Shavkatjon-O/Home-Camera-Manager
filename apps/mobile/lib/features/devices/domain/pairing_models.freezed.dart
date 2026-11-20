// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pairing_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PairingCatalogEntry {

 String get id; int get rank; bool get available; bool get recommended; String? get reason;
/// Create a copy of PairingCatalogEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PairingCatalogEntryCopyWith<PairingCatalogEntry> get copyWith => _$PairingCatalogEntryCopyWithImpl<PairingCatalogEntry>(this as PairingCatalogEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PairingCatalogEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PairingCatalogEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.rank, _this.rank) || other.rank == _this.rank)&&(identical(other.available, _this.available) || other.available == _this.available)&&(identical(other.recommended, _this.recommended) || other.recommended == _this.recommended)&&(identical(other.reason, _this.reason) || other.reason == _this.reason));
}


@override
int get hashCode {
  final _this = this as PairingCatalogEntry;
  return Object.hash(runtimeType,_this.id,_this.rank,_this.available,_this.recommended,_this.reason);
}

@override
String toString() {
  final _this = this as PairingCatalogEntry;
  return 'PairingCatalogEntry(id: ${_this.id}, rank: ${_this.rank}, available: ${_this.available}, recommended: ${_this.recommended}, reason: ${_this.reason})';
}


}

/// @nodoc
abstract mixin class $PairingCatalogEntryCopyWith<$Res>  {
  factory $PairingCatalogEntryCopyWith(PairingCatalogEntry value, $Res Function(PairingCatalogEntry) _then) = _$PairingCatalogEntryCopyWithImpl;
@useResult
$Res call({
 String id, int rank, bool available, bool recommended, String? reason
});




}
/// @nodoc
class _$PairingCatalogEntryCopyWithImpl<$Res>
    implements $PairingCatalogEntryCopyWith<$Res> {
  _$PairingCatalogEntryCopyWithImpl(this._self, this._then);

  final PairingCatalogEntry _self;
  final $Res Function(PairingCatalogEntry) _then;

/// Create a copy of PairingCatalogEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rank = null,Object? available = null,Object? recommended = null,Object? reason = freezed,}) {
  return _then(PairingCatalogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,recommended: null == recommended ? _self.recommended : recommended // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PairingCatalogEntry].
extension PairingCatalogEntryPatterns on PairingCatalogEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PairingCatalogEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PairingCatalogEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PairingCatalogEntry value)  $default,){
final _that = this;
switch (_that) {
case _PairingCatalogEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PairingCatalogEntry value)?  $default,){
final _that = this;
switch (_that) {
case _PairingCatalogEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int rank,  bool available,  bool recommended,  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PairingCatalogEntry() when $default != null:
return $default(_that.id,_that.rank,_that.available,_that.recommended,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int rank,  bool available,  bool recommended,  String? reason)  $default,) {final _that = this;
switch (_that) {
case _PairingCatalogEntry():
return $default(_that.id,_that.rank,_that.available,_that.recommended,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int rank,  bool available,  bool recommended,  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _PairingCatalogEntry() when $default != null:
return $default(_that.id,_that.rank,_that.available,_that.recommended,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class _PairingCatalogEntry implements PairingCatalogEntry {
  const _PairingCatalogEntry({required this.id, required this.rank, this.available = true, this.recommended = false, this.reason});
  

@override final  String id;
@override final  int rank;
@override@JsonKey() final  bool available;
@override@JsonKey() final  bool recommended;
@override final  String? reason;

/// Create a copy of PairingCatalogEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PairingCatalogEntryCopyWith<_PairingCatalogEntry> get copyWith => __$PairingCatalogEntryCopyWithImpl<_PairingCatalogEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PairingCatalogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.available, available) || other.available == available)&&(identical(other.recommended, recommended) || other.recommended == recommended)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,rank,available,recommended,reason);
}

@override
String toString() {
    return 'PairingCatalogEntry(id: $id, rank: $rank, available: $available, recommended: $recommended, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$PairingCatalogEntryCopyWith<$Res> implements $PairingCatalogEntryCopyWith<$Res> {
  factory _$PairingCatalogEntryCopyWith(_PairingCatalogEntry value, $Res Function(_PairingCatalogEntry) _then) = __$PairingCatalogEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, int rank, bool available, bool recommended, String? reason
});




}
/// @nodoc
class __$PairingCatalogEntryCopyWithImpl<$Res>
    implements _$PairingCatalogEntryCopyWith<$Res> {
  __$PairingCatalogEntryCopyWithImpl(this._self, this._then);

  final _PairingCatalogEntry _self;
  final $Res Function(_PairingCatalogEntry) _then;

/// Create a copy of PairingCatalogEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rank = null,Object? available = null,Object? recommended = null,Object? reason = freezed,}) {
  return _then(_PairingCatalogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,recommended: null == recommended ? _self.recommended : recommended // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$LabelIdentity {

 String get method; CameraBrand? get brand; String? get manufacturer; String? get model; String? get serial; String? get discoveredId; String? get host; int? get port;
/// Create a copy of LabelIdentity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabelIdentityCopyWith<LabelIdentity> get copyWith => _$LabelIdentityCopyWithImpl<LabelIdentity>(this as LabelIdentity, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LabelIdentity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabelIdentity&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.manufacturer, _this.manufacturer) || other.manufacturer == _this.manufacturer)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.discoveredId, _this.discoveredId) || other.discoveredId == _this.discoveredId)&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.port, _this.port) || other.port == _this.port));
}


@override
int get hashCode {
  final _this = this as LabelIdentity;
  return Object.hash(runtimeType,_this.method,_this.brand,_this.manufacturer,_this.model,_this.serial,_this.discoveredId,_this.host,_this.port);
}

@override
String toString() {
  final _this = this as LabelIdentity;
  return 'LabelIdentity(method: ${_this.method}, brand: ${_this.brand}, manufacturer: ${_this.manufacturer}, model: ${_this.model}, serial: ${_this.serial}, discoveredId: ${_this.discoveredId}, host: ${_this.host}, port: ${_this.port})';
}


}

/// @nodoc
abstract mixin class $LabelIdentityCopyWith<$Res>  {
  factory $LabelIdentityCopyWith(LabelIdentity value, $Res Function(LabelIdentity) _then) = _$LabelIdentityCopyWithImpl;
@useResult
$Res call({
 String method, CameraBrand? brand, String? manufacturer, String? model, String? serial, String? discoveredId, String? host, int? port
});




}
/// @nodoc
class _$LabelIdentityCopyWithImpl<$Res>
    implements $LabelIdentityCopyWith<$Res> {
  _$LabelIdentityCopyWithImpl(this._self, this._then);

  final LabelIdentity _self;
  final $Res Function(LabelIdentity) _then;

/// Create a copy of LabelIdentity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? method = null,Object? brand = freezed,Object? manufacturer = freezed,Object? model = freezed,Object? serial = freezed,Object? discoveredId = freezed,Object? host = freezed,Object? port = freezed,}) {
  return _then(LabelIdentity(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as CameraBrand?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String?,discoveredId: freezed == discoveredId ? _self.discoveredId : discoveredId // ignore: cast_nullable_to_non_nullable
as String?,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String?,port: freezed == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [LabelIdentity].
extension LabelIdentityPatterns on LabelIdentity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabelIdentity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabelIdentity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabelIdentity value)  $default,){
final _that = this;
switch (_that) {
case _LabelIdentity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabelIdentity value)?  $default,){
final _that = this;
switch (_that) {
case _LabelIdentity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String method,  CameraBrand? brand,  String? manufacturer,  String? model,  String? serial,  String? discoveredId,  String? host,  int? port)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabelIdentity() when $default != null:
return $default(_that.method,_that.brand,_that.manufacturer,_that.model,_that.serial,_that.discoveredId,_that.host,_that.port);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String method,  CameraBrand? brand,  String? manufacturer,  String? model,  String? serial,  String? discoveredId,  String? host,  int? port)  $default,) {final _that = this;
switch (_that) {
case _LabelIdentity():
return $default(_that.method,_that.brand,_that.manufacturer,_that.model,_that.serial,_that.discoveredId,_that.host,_that.port);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String method,  CameraBrand? brand,  String? manufacturer,  String? model,  String? serial,  String? discoveredId,  String? host,  int? port)?  $default,) {final _that = this;
switch (_that) {
case _LabelIdentity() when $default != null:
return $default(_that.method,_that.brand,_that.manufacturer,_that.model,_that.serial,_that.discoveredId,_that.host,_that.port);case _:
  return null;

}
}

}

/// @nodoc


class _LabelIdentity implements LabelIdentity {
  const _LabelIdentity({required this.method, this.brand, this.manufacturer, this.model, this.serial, this.discoveredId, this.host, this.port});
  

@override final  String method;
@override final  CameraBrand? brand;
@override final  String? manufacturer;
@override final  String? model;
@override final  String? serial;
@override final  String? discoveredId;
@override final  String? host;
@override final  int? port;

/// Create a copy of LabelIdentity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabelIdentityCopyWith<_LabelIdentity> get copyWith => __$LabelIdentityCopyWithImpl<_LabelIdentity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabelIdentity&&(identical(other.method, method) || other.method == method)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.model, model) || other.model == model)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.discoveredId, discoveredId) || other.discoveredId == discoveredId)&&(identical(other.host, host) || other.host == host)&&(identical(other.port, port) || other.port == port));
}


@override
int get hashCode {
    return Object.hash(runtimeType,method,brand,manufacturer,model,serial,discoveredId,host,port);
}

@override
String toString() {
    return 'LabelIdentity(method: $method, brand: $brand, manufacturer: $manufacturer, model: $model, serial: $serial, discoveredId: $discoveredId, host: $host, port: $port)';
}


}

/// @nodoc
abstract mixin class _$LabelIdentityCopyWith<$Res> implements $LabelIdentityCopyWith<$Res> {
  factory _$LabelIdentityCopyWith(_LabelIdentity value, $Res Function(_LabelIdentity) _then) = __$LabelIdentityCopyWithImpl;
@override @useResult
$Res call({
 String method, CameraBrand? brand, String? manufacturer, String? model, String? serial, String? discoveredId, String? host, int? port
});




}
/// @nodoc
class __$LabelIdentityCopyWithImpl<$Res>
    implements _$LabelIdentityCopyWith<$Res> {
  __$LabelIdentityCopyWithImpl(this._self, this._then);

  final _LabelIdentity _self;
  final $Res Function(_LabelIdentity) _then;

/// Create a copy of LabelIdentity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? method = null,Object? brand = freezed,Object? manufacturer = freezed,Object? model = freezed,Object? serial = freezed,Object? discoveredId = freezed,Object? host = freezed,Object? port = freezed,}) {
  return _then(_LabelIdentity(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as CameraBrand?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String?,discoveredId: freezed == discoveredId ? _self.discoveredId : discoveredId // ignore: cast_nullable_to_non_nullable
as String?,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String?,port: freezed == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$NvrChannel {

 int get index; String get name; bool get online; String? get cameraId;
/// Create a copy of NvrChannel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NvrChannelCopyWith<NvrChannel> get copyWith => _$NvrChannelCopyWithImpl<NvrChannel>(this as NvrChannel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NvrChannel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NvrChannel&&(identical(other.index, _this.index) || other.index == _this.index)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.online, _this.online) || other.online == _this.online)&&(identical(other.cameraId, _this.cameraId) || other.cameraId == _this.cameraId));
}


@override
int get hashCode {
  final _this = this as NvrChannel;
  return Object.hash(runtimeType,_this.index,_this.name,_this.online,_this.cameraId);
}

@override
String toString() {
  final _this = this as NvrChannel;
  return 'NvrChannel(index: ${_this.index}, name: ${_this.name}, online: ${_this.online}, cameraId: ${_this.cameraId})';
}


}

/// @nodoc
abstract mixin class $NvrChannelCopyWith<$Res>  {
  factory $NvrChannelCopyWith(NvrChannel value, $Res Function(NvrChannel) _then) = _$NvrChannelCopyWithImpl;
@useResult
$Res call({
 int index, String name, bool online, String? cameraId
});




}
/// @nodoc
class _$NvrChannelCopyWithImpl<$Res>
    implements $NvrChannelCopyWith<$Res> {
  _$NvrChannelCopyWithImpl(this._self, this._then);

  final NvrChannel _self;
  final $Res Function(NvrChannel) _then;

/// Create a copy of NvrChannel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? name = null,Object? online = null,Object? cameraId = freezed,}) {
  return _then(NvrChannel(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,online: null == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as bool,cameraId: freezed == cameraId ? _self.cameraId : cameraId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NvrChannel].
extension NvrChannelPatterns on NvrChannel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NvrChannel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NvrChannel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NvrChannel value)  $default,){
final _that = this;
switch (_that) {
case _NvrChannel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NvrChannel value)?  $default,){
final _that = this;
switch (_that) {
case _NvrChannel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index,  String name,  bool online,  String? cameraId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NvrChannel() when $default != null:
return $default(_that.index,_that.name,_that.online,_that.cameraId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index,  String name,  bool online,  String? cameraId)  $default,) {final _that = this;
switch (_that) {
case _NvrChannel():
return $default(_that.index,_that.name,_that.online,_that.cameraId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index,  String name,  bool online,  String? cameraId)?  $default,) {final _that = this;
switch (_that) {
case _NvrChannel() when $default != null:
return $default(_that.index,_that.name,_that.online,_that.cameraId);case _:
  return null;

}
}

}

/// @nodoc


class _NvrChannel implements NvrChannel {
  const _NvrChannel({required this.index, required this.name, this.online = true, this.cameraId});
  

@override final  int index;
@override final  String name;
@override@JsonKey() final  bool online;
@override final  String? cameraId;

/// Create a copy of NvrChannel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NvrChannelCopyWith<_NvrChannel> get copyWith => __$NvrChannelCopyWithImpl<_NvrChannel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NvrChannel&&(identical(other.index, index) || other.index == index)&&(identical(other.name, name) || other.name == name)&&(identical(other.online, online) || other.online == online)&&(identical(other.cameraId, cameraId) || other.cameraId == cameraId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,index,name,online,cameraId);
}

@override
String toString() {
    return 'NvrChannel(index: $index, name: $name, online: $online, cameraId: $cameraId)';
}


}

/// @nodoc
abstract mixin class _$NvrChannelCopyWith<$Res> implements $NvrChannelCopyWith<$Res> {
  factory _$NvrChannelCopyWith(_NvrChannel value, $Res Function(_NvrChannel) _then) = __$NvrChannelCopyWithImpl;
@override @useResult
$Res call({
 int index, String name, bool online, String? cameraId
});




}
/// @nodoc
class __$NvrChannelCopyWithImpl<$Res>
    implements _$NvrChannelCopyWith<$Res> {
  __$NvrChannelCopyWithImpl(this._self, this._then);

  final _NvrChannel _self;
  final $Res Function(_NvrChannel) _then;

/// Create a copy of NvrChannel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? name = null,Object? online = null,Object? cameraId = freezed,}) {
  return _then(_NvrChannel(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,online: null == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as bool,cameraId: freezed == cameraId ? _self.cameraId : cameraId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$PairingReport {

 String get method; String get siteId; String get step; PairingOutcome get outcome; String? get errorCode; int get durationMs;
/// Create a copy of PairingReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PairingReportCopyWith<PairingReport> get copyWith => _$PairingReportCopyWithImpl<PairingReport>(this as PairingReport, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PairingReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PairingReport&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.siteId, _this.siteId) || other.siteId == _this.siteId)&&(identical(other.step, _this.step) || other.step == _this.step)&&(identical(other.outcome, _this.outcome) || other.outcome == _this.outcome)&&(identical(other.errorCode, _this.errorCode) || other.errorCode == _this.errorCode)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs));
}


@override
int get hashCode {
  final _this = this as PairingReport;
  return Object.hash(runtimeType,_this.method,_this.siteId,_this.step,_this.outcome,_this.errorCode,_this.durationMs);
}

@override
String toString() {
  final _this = this as PairingReport;
  return 'PairingReport(method: ${_this.method}, siteId: ${_this.siteId}, step: ${_this.step}, outcome: ${_this.outcome}, errorCode: ${_this.errorCode}, durationMs: ${_this.durationMs})';
}


}

/// @nodoc
abstract mixin class $PairingReportCopyWith<$Res>  {
  factory $PairingReportCopyWith(PairingReport value, $Res Function(PairingReport) _then) = _$PairingReportCopyWithImpl;
@useResult
$Res call({
 String method, String siteId, String step, PairingOutcome outcome, String? errorCode, int durationMs
});




}
/// @nodoc
class _$PairingReportCopyWithImpl<$Res>
    implements $PairingReportCopyWith<$Res> {
  _$PairingReportCopyWithImpl(this._self, this._then);

  final PairingReport _self;
  final $Res Function(PairingReport) _then;

/// Create a copy of PairingReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? method = null,Object? siteId = null,Object? step = null,Object? outcome = null,Object? errorCode = freezed,Object? durationMs = null,}) {
  return _then(PairingReport(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as String,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as PairingOutcome,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PairingReport].
extension PairingReportPatterns on PairingReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PairingReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PairingReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PairingReport value)  $default,){
final _that = this;
switch (_that) {
case _PairingReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PairingReport value)?  $default,){
final _that = this;
switch (_that) {
case _PairingReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String method,  String siteId,  String step,  PairingOutcome outcome,  String? errorCode,  int durationMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PairingReport() when $default != null:
return $default(_that.method,_that.siteId,_that.step,_that.outcome,_that.errorCode,_that.durationMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String method,  String siteId,  String step,  PairingOutcome outcome,  String? errorCode,  int durationMs)  $default,) {final _that = this;
switch (_that) {
case _PairingReport():
return $default(_that.method,_that.siteId,_that.step,_that.outcome,_that.errorCode,_that.durationMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String method,  String siteId,  String step,  PairingOutcome outcome,  String? errorCode,  int durationMs)?  $default,) {final _that = this;
switch (_that) {
case _PairingReport() when $default != null:
return $default(_that.method,_that.siteId,_that.step,_that.outcome,_that.errorCode,_that.durationMs);case _:
  return null;

}
}

}

/// @nodoc


class _PairingReport implements PairingReport {
  const _PairingReport({required this.method, required this.siteId, required this.step, required this.outcome, this.errorCode, required this.durationMs});
  

@override final  String method;
@override final  String siteId;
@override final  String step;
@override final  PairingOutcome outcome;
@override final  String? errorCode;
@override final  int durationMs;

/// Create a copy of PairingReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PairingReportCopyWith<_PairingReport> get copyWith => __$PairingReportCopyWithImpl<_PairingReport>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PairingReport&&(identical(other.method, method) || other.method == method)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.step, step) || other.step == step)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,method,siteId,step,outcome,errorCode,durationMs);
}

@override
String toString() {
    return 'PairingReport(method: $method, siteId: $siteId, step: $step, outcome: $outcome, errorCode: $errorCode, durationMs: $durationMs)';
}


}

/// @nodoc
abstract mixin class _$PairingReportCopyWith<$Res> implements $PairingReportCopyWith<$Res> {
  factory _$PairingReportCopyWith(_PairingReport value, $Res Function(_PairingReport) _then) = __$PairingReportCopyWithImpl;
@override @useResult
$Res call({
 String method, String siteId, String step, PairingOutcome outcome, String? errorCode, int durationMs
});




}
/// @nodoc
class __$PairingReportCopyWithImpl<$Res>
    implements _$PairingReportCopyWith<$Res> {
  __$PairingReportCopyWithImpl(this._self, this._then);

  final _PairingReport _self;
  final $Res Function(_PairingReport) _then;

/// Create a copy of PairingReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? method = null,Object? siteId = null,Object? step = null,Object? outcome = null,Object? errorCode = freezed,Object? durationMs = null,}) {
  return _then(_PairingReport(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as String,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as PairingOutcome,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$FoundConnector {

 String get name; String get host; int get port; String? get code; String? get version;
/// Create a copy of FoundConnector
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoundConnectorCopyWith<FoundConnector> get copyWith => _$FoundConnectorCopyWithImpl<FoundConnector>(this as FoundConnector, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FoundConnector;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoundConnector&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.port, _this.port) || other.port == _this.port)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.version, _this.version) || other.version == _this.version));
}


@override
int get hashCode {
  final _this = this as FoundConnector;
  return Object.hash(runtimeType,_this.name,_this.host,_this.port,_this.code,_this.version);
}

@override
String toString() {
  final _this = this as FoundConnector;
  return 'FoundConnector(name: ${_this.name}, host: ${_this.host}, port: ${_this.port}, code: ${_this.code}, version: ${_this.version})';
}


}

/// @nodoc
abstract mixin class $FoundConnectorCopyWith<$Res>  {
  factory $FoundConnectorCopyWith(FoundConnector value, $Res Function(FoundConnector) _then) = _$FoundConnectorCopyWithImpl;
@useResult
$Res call({
 String name, String host, int port, String? code, String? version
});




}
/// @nodoc
class _$FoundConnectorCopyWithImpl<$Res>
    implements $FoundConnectorCopyWith<$Res> {
  _$FoundConnectorCopyWithImpl(this._self, this._then);

  final FoundConnector _self;
  final $Res Function(FoundConnector) _then;

/// Create a copy of FoundConnector
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? host = null,Object? port = null,Object? code = freezed,Object? version = freezed,}) {
  return _then(FoundConnector(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FoundConnector].
extension FoundConnectorPatterns on FoundConnector {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoundConnector value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoundConnector() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoundConnector value)  $default,){
final _that = this;
switch (_that) {
case _FoundConnector():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoundConnector value)?  $default,){
final _that = this;
switch (_that) {
case _FoundConnector() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String host,  int port,  String? code,  String? version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoundConnector() when $default != null:
return $default(_that.name,_that.host,_that.port,_that.code,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String host,  int port,  String? code,  String? version)  $default,) {final _that = this;
switch (_that) {
case _FoundConnector():
return $default(_that.name,_that.host,_that.port,_that.code,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String host,  int port,  String? code,  String? version)?  $default,) {final _that = this;
switch (_that) {
case _FoundConnector() when $default != null:
return $default(_that.name,_that.host,_that.port,_that.code,_that.version);case _:
  return null;

}
}

}

/// @nodoc


class _FoundConnector implements FoundConnector {
  const _FoundConnector({required this.name, required this.host, required this.port, this.code, this.version});
  

@override final  String name;
@override final  String host;
@override final  int port;
@override final  String? code;
@override final  String? version;

/// Create a copy of FoundConnector
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoundConnectorCopyWith<_FoundConnector> get copyWith => __$FoundConnectorCopyWithImpl<_FoundConnector>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoundConnector&&(identical(other.name, name) || other.name == name)&&(identical(other.host, host) || other.host == host)&&(identical(other.port, port) || other.port == port)&&(identical(other.code, code) || other.code == code)&&(identical(other.version, version) || other.version == version));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,host,port,code,version);
}

@override
String toString() {
    return 'FoundConnector(name: $name, host: $host, port: $port, code: $code, version: $version)';
}


}

/// @nodoc
abstract mixin class _$FoundConnectorCopyWith<$Res> implements $FoundConnectorCopyWith<$Res> {
  factory _$FoundConnectorCopyWith(_FoundConnector value, $Res Function(_FoundConnector) _then) = __$FoundConnectorCopyWithImpl;
@override @useResult
$Res call({
 String name, String host, int port, String? code, String? version
});




}
/// @nodoc
class __$FoundConnectorCopyWithImpl<$Res>
    implements _$FoundConnectorCopyWith<$Res> {
  __$FoundConnectorCopyWithImpl(this._self, this._then);

  final _FoundConnector _self;
  final $Res Function(_FoundConnector) _then;

/// Create a copy of FoundConnector
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? host = null,Object? port = null,Object? code = freezed,Object? version = freezed,}) {
  return _then(_FoundConnector(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
