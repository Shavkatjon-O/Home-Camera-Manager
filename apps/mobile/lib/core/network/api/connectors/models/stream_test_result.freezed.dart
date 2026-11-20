// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stream_test_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StreamTestResult {


/// Create a copy of StreamTestResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreamTestResultCopyWith<StreamTestResult> get copyWith => _$StreamTestResultCopyWithImpl<StreamTestResult>(this as StreamTestResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StreamTestResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreamTestResult&&(identical(other.ok, _this.ok) || other.ok == _this.ok)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.rtspPort, _this.rtspPort) || other.rtspPort == _this.rtspPort)&&(identical(other.mainPath, _this.mainPath) || other.mainPath == _this.mainPath)&&(identical(other.subPath, _this.subPath) || other.subPath == _this.subPath)&&(identical(other.ptz, _this.ptz) || other.ptz == _this.ptz)&&(identical(other.manufacturer, _this.manufacturer) || other.manufacturer == _this.manufacturer)&&(identical(other.model, _this.model) || other.model == _this.model)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as StreamTestResult;
  return Object.hash(runtimeType,_this.ok,_this.error,_this.rtspPort,_this.mainPath,_this.subPath,_this.ptz,_this.manufacturer,_this.model,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as StreamTestResult;
  return 'StreamTestResult(ok: ${_this.ok}, error: ${_this.error}, rtspPort: ${_this.rtspPort}, mainPath: ${_this.mainPath}, subPath: ${_this.subPath}, ptz: ${_this.ptz}, manufacturer: ${_this.manufacturer}, model: ${_this.model}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $StreamTestResultCopyWith<$Res>  {
  factory $StreamTestResultCopyWith(StreamTestResult value, $Res Function(StreamTestResult) _then) = _$StreamTestResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) bool ok,@JsonKey(includeIfNull: false) String? error,@JsonKey(name: "rtsp_port", includeIfNull: false, fromJson: StreamTestResult._read_rtspPort, toJson: StreamTestResult._write_rtspPort) int? rtspPort,@JsonKey(name: "main_path", includeIfNull: false) String? mainPath,@JsonKey(name: "sub_path", includeIfNull: false) String? subPath,@JsonKey(includeIfNull: false) bool? ptz,@JsonKey(includeIfNull: false) String? manufacturer,@JsonKey(includeIfNull: false) String? model,@JsonKey(readValue: StreamTestResult._extras, fromJson: StreamTestResult._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$StreamTestResultCopyWithImpl<$Res>
    implements $StreamTestResultCopyWith<$Res> {
  _$StreamTestResultCopyWithImpl(this._self, this._then);

  final StreamTestResult _self;
  final $Res Function(StreamTestResult) _then;

/// Create a copy of StreamTestResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ok = null,Object? error = freezed,Object? rtspPort = freezed,Object? mainPath = freezed,Object? subPath = freezed,Object? ptz = freezed,Object? manufacturer = freezed,Object? model = freezed,Object? additionalProperties = null,}) {
  return _then(StreamTestResult(
ok: null == ok ? _self.ok : ok // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,rtspPort: freezed == rtspPort ? _self.rtspPort : rtspPort // ignore: cast_nullable_to_non_nullable
as int?,mainPath: freezed == mainPath ? _self.mainPath : mainPath // ignore: cast_nullable_to_non_nullable
as String?,subPath: freezed == subPath ? _self.subPath : subPath // ignore: cast_nullable_to_non_nullable
as String?,ptz: freezed == ptz ? _self.ptz : ptz // ignore: cast_nullable_to_non_nullable
as bool?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [StreamTestResult].
extension StreamTestResultPatterns on StreamTestResult {
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
