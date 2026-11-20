// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_upload_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhotoUploadResult {


/// Create a copy of PhotoUploadResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoUploadResultCopyWith<PhotoUploadResult> get copyWith => _$PhotoUploadResultCopyWithImpl<PhotoUploadResult>(this as PhotoUploadResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PhotoUploadResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoUploadResult&&(identical(other.person, _this.person) || other.person == _this.person)&&const DeepCollectionEquality().equals(other.added, _this.added)&&const DeepCollectionEquality().equals(other.rejected, _this.rejected)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as PhotoUploadResult;
  return Object.hash(runtimeType,_this.person,const DeepCollectionEquality().hash(_this.added),const DeepCollectionEquality().hash(_this.rejected),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as PhotoUploadResult;
  return 'PhotoUploadResult(person: ${_this.person}, added: ${_this.added}, rejected: ${_this.rejected}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $PhotoUploadResultCopyWith<$Res>  {
  factory $PhotoUploadResultCopyWith(PhotoUploadResult value, $Res Function(PhotoUploadResult) _then) = _$PhotoUploadResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) PersonRead person,@JsonKey(required: true, disallowNullValue: true) List<SampleRead> added,@JsonKey(required: true, disallowNullValue: true) List<PhotoRejection> rejected,@JsonKey(readValue: PhotoUploadResult._extras, fromJson: PhotoUploadResult._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$PersonReadCopyWith<$Res> get person;

}
/// @nodoc
class _$PhotoUploadResultCopyWithImpl<$Res>
    implements $PhotoUploadResultCopyWith<$Res> {
  _$PhotoUploadResultCopyWithImpl(this._self, this._then);

  final PhotoUploadResult _self;
  final $Res Function(PhotoUploadResult) _then;

/// Create a copy of PhotoUploadResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? person = null,Object? added = null,Object? rejected = null,Object? additionalProperties = null,}) {
  return _then(PhotoUploadResult(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as PersonRead,added: null == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as List<SampleRead>,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as List<PhotoRejection>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of PhotoUploadResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonReadCopyWith<$Res> get person {
  
  return $PersonReadCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}
}


/// Adds pattern-matching-related methods to [PhotoUploadResult].
extension PhotoUploadResultPatterns on PhotoUploadResult {
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
