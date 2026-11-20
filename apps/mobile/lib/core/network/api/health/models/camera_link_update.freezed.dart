// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_link_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CameraLinkUpdate {


/// Create a copy of CameraLinkUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraLinkUpdateCopyWith<CameraLinkUpdate> get copyWith => _$CameraLinkUpdateCopyWithImpl<CameraLinkUpdate>(this as CameraLinkUpdate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CameraLinkUpdate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraLinkUpdate&&(identical(other.parentUuid, _this.parentUuid) || other.parentUuid == _this.parentUuid)&&(identical(other.link, _this.link) || other.link == _this.link)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as CameraLinkUpdate;
  return Object.hash(runtimeType,_this.parentUuid,_this.link,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as CameraLinkUpdate;
  return 'CameraLinkUpdate(parentUuid: ${_this.parentUuid}, link: ${_this.link}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $CameraLinkUpdateCopyWith<$Res>  {
  factory $CameraLinkUpdateCopyWith(CameraLinkUpdate value, $Res Function(CameraLinkUpdate) _then) = _$CameraLinkUpdateCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "parent_uuid", required: true) String? parentUuid,@JsonKey(includeIfNull: false, fromJson: CameraLinkUpdate._read_link, toJson: CameraLinkUpdate._write_link) LinkKind? link,@JsonKey(readValue: CameraLinkUpdate._extras, fromJson: CameraLinkUpdate._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$CameraLinkUpdateCopyWithImpl<$Res>
    implements $CameraLinkUpdateCopyWith<$Res> {
  _$CameraLinkUpdateCopyWithImpl(this._self, this._then);

  final CameraLinkUpdate _self;
  final $Res Function(CameraLinkUpdate) _then;

/// Create a copy of CameraLinkUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? parentUuid = freezed,Object? link = freezed,Object? additionalProperties = null,}) {
  return _then(CameraLinkUpdate(
parentUuid: freezed == parentUuid ? _self.parentUuid : parentUuid // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as LinkKind?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [CameraLinkUpdate].
extension CameraLinkUpdatePatterns on CameraLinkUpdate {
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
