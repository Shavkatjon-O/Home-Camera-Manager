// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'jwk.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Jwk {


/// Create a copy of Jwk
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JwkCopyWith<Jwk> get copyWith => _$JwkCopyWithImpl<Jwk>(this as Jwk, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Jwk;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Jwk&&(identical(other.kty, _this.kty) || other.kty == _this.kty)&&(identical(other.crv, _this.crv) || other.crv == _this.crv)&&(identical(other.x, _this.x) || other.x == _this.x)&&(identical(other.y, _this.y) || other.y == _this.y)&&(identical(other.kid, _this.kid) || other.kid == _this.kid)&&(identical(other.use, _this.use) || other.use == _this.use)&&(identical(other.alg, _this.alg) || other.alg == _this.alg)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as Jwk;
  return Object.hash(runtimeType,_this.kty,_this.crv,_this.x,_this.y,_this.kid,_this.use,_this.alg,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as Jwk;
  return 'Jwk(kty: ${_this.kty}, crv: ${_this.crv}, x: ${_this.x}, y: ${_this.y}, kid: ${_this.kid}, use: ${_this.use}, alg: ${_this.alg}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $JwkCopyWith<$Res>  {
  factory $JwkCopyWith(Jwk value, $Res Function(Jwk) _then) = _$JwkCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String kty,@JsonKey(required: true, disallowNullValue: true) String crv,@JsonKey(required: true, disallowNullValue: true) String x,@JsonKey(required: true, disallowNullValue: true) String y,@JsonKey(required: true, disallowNullValue: true) String kid,@JsonKey(required: true, disallowNullValue: true) String use,@JsonKey(required: true, disallowNullValue: true) String alg,@JsonKey(readValue: Jwk._extras, fromJson: Jwk._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$JwkCopyWithImpl<$Res>
    implements $JwkCopyWith<$Res> {
  _$JwkCopyWithImpl(this._self, this._then);

  final Jwk _self;
  final $Res Function(Jwk) _then;

/// Create a copy of Jwk
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kty = null,Object? crv = null,Object? x = null,Object? y = null,Object? kid = null,Object? use = null,Object? alg = null,Object? additionalProperties = null,}) {
  return _then(Jwk(
kty: null == kty ? _self.kty : kty // ignore: cast_nullable_to_non_nullable
as String,crv: null == crv ? _self.crv : crv // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as String,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as String,kid: null == kid ? _self.kid : kid // ignore: cast_nullable_to_non_nullable
as String,use: null == use ? _self.use : use // ignore: cast_nullable_to_non_nullable
as String,alg: null == alg ? _self.alg : alg // ignore: cast_nullable_to_non_nullable
as String,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [Jwk].
extension JwkPatterns on Jwk {
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
