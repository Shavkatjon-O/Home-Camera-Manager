// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'count_line_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CountLineRead {


/// Create a copy of CountLineRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountLineReadCopyWith<CountLineRead> get copyWith => _$CountLineReadCopyWithImpl<CountLineRead>(this as CountLineRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CountLineRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountLineRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.viewUuid, _this.viewUuid) || other.viewUuid == _this.viewUuid)&&(identical(other.viewName, _this.viewName) || other.viewName == _this.viewName)&&(identical(other.cameraUuid, _this.cameraUuid) || other.cameraUuid == _this.cameraUuid)&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName)&&(identical(other.direction, _this.direction) || other.direction == _this.direction)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as CountLineRead;
  return Object.hash(runtimeType,_this.uuid,_this.name,_this.viewUuid,_this.viewName,_this.cameraUuid,_this.cameraName,_this.direction,_this.enabled,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as CountLineRead;
  return 'CountLineRead(uuid: ${_this.uuid}, name: ${_this.name}, viewUuid: ${_this.viewUuid}, viewName: ${_this.viewName}, cameraUuid: ${_this.cameraUuid}, cameraName: ${_this.cameraName}, direction: ${_this.direction}, enabled: ${_this.enabled}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $CountLineReadCopyWith<$Res>  {
  factory $CountLineReadCopyWith(CountLineRead value, $Res Function(CountLineRead) _then) = _$CountLineReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(name: "view_uuid", required: true, disallowNullValue: true) String viewUuid,@JsonKey(name: "view_name", required: true, disallowNullValue: true) String viewName,@JsonKey(name: "camera_uuid", required: true, disallowNullValue: true) String cameraUuid,@JsonKey(name: "camera_name", required: true) String? cameraName,@JsonKey(required: true, disallowNullValue: true) String direction,@JsonKey(required: true, disallowNullValue: true) bool enabled,@JsonKey(readValue: CountLineRead._extras, fromJson: CountLineRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$CountLineReadCopyWithImpl<$Res>
    implements $CountLineReadCopyWith<$Res> {
  _$CountLineReadCopyWithImpl(this._self, this._then);

  final CountLineRead _self;
  final $Res Function(CountLineRead) _then;

/// Create a copy of CountLineRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? name = null,Object? viewUuid = null,Object? viewName = null,Object? cameraUuid = null,Object? cameraName = freezed,Object? direction = null,Object? enabled = null,Object? additionalProperties = null,}) {
  return _then(CountLineRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,viewUuid: null == viewUuid ? _self.viewUuid : viewUuid // ignore: cast_nullable_to_non_nullable
as String,viewName: null == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String,cameraUuid: null == cameraUuid ? _self.cameraUuid : cameraUuid // ignore: cast_nullable_to_non_nullable
as String,cameraName: freezed == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [CountLineRead].
extension CountLineReadPatterns on CountLineRead {
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
