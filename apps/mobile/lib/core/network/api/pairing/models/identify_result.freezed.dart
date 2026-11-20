// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identify_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IdentifyResult {


/// Create a copy of IdentifyResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdentifyResultCopyWith<IdentifyResult> get copyWith => _$IdentifyResultCopyWithImpl<IdentifyResult>(this as IdentifyResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as IdentifyResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdentifyResult&&(identical(other.adapter, _this.adapter) || other.adapter == _this.adapter)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.vendor, _this.vendor) || other.vendor == _this.vendor)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.rtspPort, _this.rtspPort) || other.rtspPort == _this.rtspPort)&&const DeepCollectionEquality().equals(other.channels, _this.channels)&&(identical(other.capabilities, _this.capabilities) || other.capabilities == _this.capabilities)&&(identical(other.attempt, _this.attempt) || other.attempt == _this.attempt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as IdentifyResult;
  return Object.hash(runtimeType,_this.adapter,_this.kind,_this.vendor,_this.model,_this.rtspPort,const DeepCollectionEquality().hash(_this.channels),_this.capabilities,_this.attempt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as IdentifyResult;
  return 'IdentifyResult(adapter: ${_this.adapter}, kind: ${_this.kind}, vendor: ${_this.vendor}, model: ${_this.model}, rtspPort: ${_this.rtspPort}, channels: ${_this.channels}, capabilities: ${_this.capabilities}, attempt: ${_this.attempt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $IdentifyResultCopyWith<$Res>  {
  factory $IdentifyResultCopyWith(IdentifyResult value, $Res Function(IdentifyResult) _then) = _$IdentifyResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String adapter,@JsonKey(required: true, disallowNullValue: true) String kind,@JsonKey(required: true) String? vendor,@JsonKey(required: true) String? model,@JsonKey(name: "rtsp_port", required: true, fromJson: IdentifyResult._read_rtspPort, toJson: IdentifyResult._write_rtspPort) int? rtspPort,@JsonKey(required: true, disallowNullValue: true) List<ChannelRead> channels,@JsonKey(required: true, disallowNullValue: true) CapabilitiesRead capabilities,@JsonKey(required: true, disallowNullValue: true) String attempt,@JsonKey(readValue: IdentifyResult._extras, fromJson: IdentifyResult._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$CapabilitiesReadCopyWith<$Res> get capabilities;

}
/// @nodoc
class _$IdentifyResultCopyWithImpl<$Res>
    implements $IdentifyResultCopyWith<$Res> {
  _$IdentifyResultCopyWithImpl(this._self, this._then);

  final IdentifyResult _self;
  final $Res Function(IdentifyResult) _then;

/// Create a copy of IdentifyResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? adapter = null,Object? kind = null,Object? vendor = freezed,Object? model = freezed,Object? rtspPort = freezed,Object? channels = null,Object? capabilities = null,Object? attempt = null,Object? additionalProperties = null,}) {
  return _then(IdentifyResult(
adapter: null == adapter ? _self.adapter : adapter // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,vendor: freezed == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,rtspPort: freezed == rtspPort ? _self.rtspPort : rtspPort // ignore: cast_nullable_to_non_nullable
as int?,channels: null == channels ? _self.channels : channels // ignore: cast_nullable_to_non_nullable
as List<ChannelRead>,capabilities: null == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as CapabilitiesRead,attempt: null == attempt ? _self.attempt : attempt // ignore: cast_nullable_to_non_nullable
as String,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of IdentifyResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CapabilitiesReadCopyWith<$Res> get capabilities {
  
  return $CapabilitiesReadCopyWith<$Res>(_self.capabilities, (value) {
    return _then(_self.copyWith(capabilities: value));
  });
}
}


/// Adds pattern-matching-related methods to [IdentifyResult].
extension IdentifyResultPatterns on IdentifyResult {
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
