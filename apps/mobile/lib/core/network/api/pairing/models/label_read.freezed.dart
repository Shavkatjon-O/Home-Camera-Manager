// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'label_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LabelRead {


/// Create a copy of LabelRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabelReadCopyWith<LabelRead> get copyWith => _$LabelReadCopyWithImpl<LabelRead>(this as LabelRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LabelRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabelRead&&(identical(other.adapter, _this.adapter) || other.adapter == _this.adapter)&&(identical(other.format, _this.format) || other.format == _this.format)&&(identical(other.confirmed, _this.confirmed) || other.confirmed == _this.confirmed)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.vendor, _this.vendor) || other.vendor == _this.vendor)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.port, _this.port) || other.port == _this.port)&&(identical(other.url, _this.url) || other.url == _this.url)&&const DeepCollectionEquality().equals(other.methods, _this.methods)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as LabelRead;
  return Object.hash(runtimeType,_this.adapter,_this.format,_this.confirmed,_this.kind,_this.vendor,_this.model,_this.serial,_this.code,_this.deviceId,_this.host,_this.port,_this.url,const DeepCollectionEquality().hash(_this.methods),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as LabelRead;
  return 'LabelRead(adapter: ${_this.adapter}, format: ${_this.format}, confirmed: ${_this.confirmed}, kind: ${_this.kind}, vendor: ${_this.vendor}, model: ${_this.model}, serial: ${_this.serial}, code: ${_this.code}, deviceId: ${_this.deviceId}, host: ${_this.host}, port: ${_this.port}, url: ${_this.url}, methods: ${_this.methods}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $LabelReadCopyWith<$Res>  {
  factory $LabelReadCopyWith(LabelRead value, $Res Function(LabelRead) _then) = _$LabelReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String adapter,@JsonKey(required: true, disallowNullValue: true) String format,@JsonKey(required: true, disallowNullValue: true) bool confirmed,@JsonKey(required: true, disallowNullValue: true) String kind,@JsonKey(required: true) String? vendor,@JsonKey(required: true) String? model,@JsonKey(required: true) String? serial,@JsonKey(required: true) String? code,@JsonKey(name: "device_id", required: true) String? deviceId,@JsonKey(required: true) String? host,@JsonKey(required: true, fromJson: LabelRead._read_port, toJson: LabelRead._write_port) int? port,@JsonKey(required: true) String? url,@JsonKey(required: true, disallowNullValue: true, fromJson: LabelRead._read_methods, toJson: LabelRead._write_methods) List<PairingMethodId> methods,@JsonKey(readValue: LabelRead._extras, fromJson: LabelRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$LabelReadCopyWithImpl<$Res>
    implements $LabelReadCopyWith<$Res> {
  _$LabelReadCopyWithImpl(this._self, this._then);

  final LabelRead _self;
  final $Res Function(LabelRead) _then;

/// Create a copy of LabelRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? adapter = null,Object? format = null,Object? confirmed = null,Object? kind = null,Object? vendor = freezed,Object? model = freezed,Object? serial = freezed,Object? code = freezed,Object? deviceId = freezed,Object? host = freezed,Object? port = freezed,Object? url = freezed,Object? methods = null,Object? additionalProperties = null,}) {
  return _then(LabelRead(
adapter: null == adapter ? _self.adapter : adapter // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as bool,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,vendor: freezed == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String?,port: freezed == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,methods: null == methods ? _self.methods : methods // ignore: cast_nullable_to_non_nullable
as List<PairingMethodId>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [LabelRead].
extension LabelReadPatterns on LabelRead {
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
