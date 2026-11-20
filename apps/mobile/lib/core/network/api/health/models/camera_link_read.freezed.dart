// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_link_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CameraLinkRead {


/// Create a copy of CameraLinkRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraLinkReadCopyWith<CameraLinkRead> get copyWith => _$CameraLinkReadCopyWithImpl<CameraLinkRead>(this as CameraLinkRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CameraLinkRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraLinkRead&&(identical(other.cameraUuid, _this.cameraUuid) || other.cameraUuid == _this.cameraUuid)&&(identical(other.parentUuid, _this.parentUuid) || other.parentUuid == _this.parentUuid)&&(identical(other.parentName, _this.parentName) || other.parentName == _this.parentName)&&(identical(other.link, _this.link) || other.link == _this.link)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as CameraLinkRead;
  return Object.hash(runtimeType,_this.cameraUuid,_this.parentUuid,_this.parentName,_this.link,_this.updatedAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as CameraLinkRead;
  return 'CameraLinkRead(cameraUuid: ${_this.cameraUuid}, parentUuid: ${_this.parentUuid}, parentName: ${_this.parentName}, link: ${_this.link}, updatedAt: ${_this.updatedAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $CameraLinkReadCopyWith<$Res>  {
  factory $CameraLinkReadCopyWith(CameraLinkRead value, $Res Function(CameraLinkRead) _then) = _$CameraLinkReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "camera_uuid", required: true, disallowNullValue: true) String cameraUuid,@JsonKey(name: "parent_uuid", required: true) String? parentUuid,@JsonKey(name: "parent_name", required: true) String? parentName,@JsonKey(required: true, fromJson: CameraLinkRead._read_link, toJson: CameraLinkRead._write_link) LinkKind? link,@JsonKey(name: "updated_at", required: true, fromJson: CameraLinkRead._read_updatedAt, toJson: CameraLinkRead._write_updatedAt) DateTime? updatedAt,@JsonKey(readValue: CameraLinkRead._extras, fromJson: CameraLinkRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$CameraLinkReadCopyWithImpl<$Res>
    implements $CameraLinkReadCopyWith<$Res> {
  _$CameraLinkReadCopyWithImpl(this._self, this._then);

  final CameraLinkRead _self;
  final $Res Function(CameraLinkRead) _then;

/// Create a copy of CameraLinkRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cameraUuid = null,Object? parentUuid = freezed,Object? parentName = freezed,Object? link = freezed,Object? updatedAt = freezed,Object? additionalProperties = null,}) {
  return _then(CameraLinkRead(
cameraUuid: null == cameraUuid ? _self.cameraUuid : cameraUuid // ignore: cast_nullable_to_non_nullable
as String,parentUuid: freezed == parentUuid ? _self.parentUuid : parentUuid // ignore: cast_nullable_to_non_nullable
as String?,parentName: freezed == parentName ? _self.parentName : parentName // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as LinkKind?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [CameraLinkRead].
extension CameraLinkReadPatterns on CameraLinkRead {
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
