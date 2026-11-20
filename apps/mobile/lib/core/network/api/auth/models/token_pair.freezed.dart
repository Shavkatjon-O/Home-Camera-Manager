// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_pair.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TokenPair {


/// Create a copy of TokenPair
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenPairCopyWith<TokenPair> get copyWith => _$TokenPairCopyWithImpl<TokenPair>(this as TokenPair, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TokenPair;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenPair&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.tokenType, _this.tokenType) || other.tokenType == _this.tokenType)&&(identical(other.expiresIn, _this.expiresIn) || other.expiresIn == _this.expiresIn)&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken)&&(identical(other.refreshExpiresIn, _this.refreshExpiresIn) || other.refreshExpiresIn == _this.refreshExpiresIn)&&(identical(other.session, _this.session) || other.session == _this.session)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as TokenPair;
  return Object.hash(runtimeType,_this.accessToken,_this.tokenType,_this.expiresIn,_this.refreshToken,_this.refreshExpiresIn,_this.session,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as TokenPair;
  return 'TokenPair(accessToken: ${_this.accessToken}, tokenType: ${_this.tokenType}, expiresIn: ${_this.expiresIn}, refreshToken: ${_this.refreshToken}, refreshExpiresIn: ${_this.refreshExpiresIn}, session: ${_this.session}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $TokenPairCopyWith<$Res>  {
  factory $TokenPairCopyWith(TokenPair value, $Res Function(TokenPair) _then) = _$TokenPairCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "access_token", required: true, disallowNullValue: true) String accessToken,@JsonKey(name: "token_type", disallowNullValue: true, readValue: TokenPair._presentValue, fromJson: TokenPair._read_tokenType, toJson: TokenPair._write_tokenType) String tokenType,@JsonKey(name: "expires_in", required: true, disallowNullValue: true, fromJson: TokenPair._read_expiresIn, toJson: TokenPair._write_expiresIn) int expiresIn,@JsonKey(name: "refresh_token", required: true, disallowNullValue: true) String refreshToken,@JsonKey(name: "refresh_expires_in", required: true, disallowNullValue: true, fromJson: TokenPair._read_refreshExpiresIn, toJson: TokenPair._write_refreshExpiresIn) int refreshExpiresIn,@JsonKey(required: true, disallowNullValue: true) SessionRead session,@JsonKey(readValue: TokenPair._extras, fromJson: TokenPair._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$SessionReadCopyWith<$Res> get session;

}
/// @nodoc
class _$TokenPairCopyWithImpl<$Res>
    implements $TokenPairCopyWith<$Res> {
  _$TokenPairCopyWithImpl(this._self, this._then);

  final TokenPair _self;
  final $Res Function(TokenPair) _then;

/// Create a copy of TokenPair
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? tokenType = null,Object? expiresIn = null,Object? refreshToken = null,Object? refreshExpiresIn = null,Object? session = null,Object? additionalProperties = null,}) {
  return _then(TokenPair(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,refreshExpiresIn: null == refreshExpiresIn ? _self.refreshExpiresIn : refreshExpiresIn // ignore: cast_nullable_to_non_nullable
as int,session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as SessionRead,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of TokenPair
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionReadCopyWith<$Res> get session {
  
  return $SessionReadCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}


/// Adds pattern-matching-related methods to [TokenPair].
extension TokenPairPatterns on TokenPair {
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
