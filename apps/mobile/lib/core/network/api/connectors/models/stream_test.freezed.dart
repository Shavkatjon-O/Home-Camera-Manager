// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stream_test.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StreamTest {


/// Create a copy of StreamTest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreamTestCopyWith<StreamTest> get copyWith => _$StreamTestCopyWithImpl<StreamTest>(this as StreamTest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StreamTest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreamTest&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.rtspPort, _this.rtspPort) || other.rtspPort == _this.rtspPort)&&(identical(other.onvifPort, _this.onvifPort) || other.onvifPort == _this.onvifPort)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.mainPath, _this.mainPath) || other.mainPath == _this.mainPath)&&(identical(other.subPath, _this.subPath) || other.subPath == _this.subPath)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as StreamTest;
  return Object.hash(runtimeType,_this.host,_this.brand,_this.rtspPort,_this.onvifPort,_this.username,_this.password,_this.mainPath,_this.subPath,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as StreamTest;
  return 'StreamTest(host: ${_this.host}, brand: ${_this.brand}, rtspPort: ${_this.rtspPort}, onvifPort: ${_this.onvifPort}, username: ${_this.username}, password: ${_this.password}, mainPath: ${_this.mainPath}, subPath: ${_this.subPath}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $StreamTestCopyWith<$Res>  {
  factory $StreamTestCopyWith(StreamTest value, $Res Function(StreamTest) _then) = _$StreamTestCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String host,@JsonKey(disallowNullValue: true, readValue: StreamTest._presentValue, fromJson: StreamTest._read_brand, toJson: StreamTest._write_brand) CameraBrand brand,@JsonKey(name: "rtsp_port", includeIfNull: false, fromJson: StreamTest._read_rtspPort, toJson: StreamTest._write_rtspPort) int? rtspPort,@JsonKey(name: "onvif_port", includeIfNull: false, fromJson: StreamTest._read_onvifPort, toJson: StreamTest._write_onvifPort) int? onvifPort,@JsonKey(includeIfNull: false) String? username,@JsonKey(includeIfNull: false) String? password,@JsonKey(name: "main_path", includeIfNull: false) String? mainPath,@JsonKey(name: "sub_path", includeIfNull: false) String? subPath,@JsonKey(readValue: StreamTest._extras, fromJson: StreamTest._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
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
@pragma('vm:prefer-inline') @override $Res call({Object? host = null,Object? brand = null,Object? rtspPort = freezed,Object? onvifPort = freezed,Object? username = freezed,Object? password = freezed,Object? mainPath = freezed,Object? subPath = freezed,Object? additionalProperties = null,}) {
  return _then(StreamTest(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as CameraBrand,rtspPort: freezed == rtspPort ? _self.rtspPort : rtspPort // ignore: cast_nullable_to_non_nullable
as int?,onvifPort: freezed == onvifPort ? _self.onvifPort : onvifPort // ignore: cast_nullable_to_non_nullable
as int?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,mainPath: freezed == mainPath ? _self.mainPath : mainPath // ignore: cast_nullable_to_non_nullable
as String?,subPath: freezed == subPath ? _self.subPath : subPath // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
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
