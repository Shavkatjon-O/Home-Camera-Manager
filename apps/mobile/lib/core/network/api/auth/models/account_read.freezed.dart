// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountRead {


/// Create a copy of AccountRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountReadCopyWith<AccountRead> get copyWith => _$AccountReadCopyWithImpl<AccountRead>(this as AccountRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AccountRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.emailVerified, _this.emailVerified) || other.emailVerified == _this.emailVerified)&&(identical(other.isPlatformAdmin, _this.isPlatformAdmin) || other.isPlatformAdmin == _this.isPlatformAdmin)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as AccountRead;
  return Object.hash(runtimeType,_this.uuid,_this.username,_this.email,_this.name,_this.emailVerified,_this.isPlatformAdmin,_this.createdAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as AccountRead;
  return 'AccountRead(uuid: ${_this.uuid}, username: ${_this.username}, email: ${_this.email}, name: ${_this.name}, emailVerified: ${_this.emailVerified}, isPlatformAdmin: ${_this.isPlatformAdmin}, createdAt: ${_this.createdAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $AccountReadCopyWith<$Res>  {
  factory $AccountReadCopyWith(AccountRead value, $Res Function(AccountRead) _then) = _$AccountReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String username,@JsonKey(required: true) String? email,@JsonKey(required: true) String? name,@JsonKey(name: "email_verified", required: true, disallowNullValue: true) bool emailVerified,@JsonKey(name: "is_platform_admin", disallowNullValue: true, readValue: AccountRead._presentValue, fromJson: AccountRead._read_isPlatformAdmin, toJson: AccountRead._write_isPlatformAdmin) bool isPlatformAdmin,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: AccountRead._read_createdAt, toJson: AccountRead._write_createdAt) DateTime createdAt,@JsonKey(readValue: AccountRead._extras, fromJson: AccountRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$AccountReadCopyWithImpl<$Res>
    implements $AccountReadCopyWith<$Res> {
  _$AccountReadCopyWithImpl(this._self, this._then);

  final AccountRead _self;
  final $Res Function(AccountRead) _then;

/// Create a copy of AccountRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? username = null,Object? email = freezed,Object? name = freezed,Object? emailVerified = null,Object? isPlatformAdmin = null,Object? createdAt = null,Object? additionalProperties = null,}) {
  return _then(AccountRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,isPlatformAdmin: null == isPlatformAdmin ? _self.isPlatformAdmin : isPlatformAdmin // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountRead].
extension AccountReadPatterns on AccountRead {
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
