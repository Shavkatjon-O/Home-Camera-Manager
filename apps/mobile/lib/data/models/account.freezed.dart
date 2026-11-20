// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$User {

 String get id; String get name; String get email; bool get verified;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as User;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.verified, _this.verified) || other.verified == _this.verified));
}


@override
int get hashCode {
  final _this = this as User;
  return Object.hash(runtimeType,_this.id,_this.name,_this.email,_this.verified);
}

@override
String toString() {
  final _this = this as User;
  return 'User(id: ${_this.id}, name: ${_this.name}, email: ${_this.email}, verified: ${_this.verified})';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, bool verified
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? verified = null,}) {
  return _then(User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  bool verified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.verified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  bool verified)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.name,_that.email,_that.verified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  bool verified)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.verified);case _:
  return null;

}
}

}

/// @nodoc


class _User implements User {
  const _User({required this.id, required this.name, required this.email, this.verified = true});
  

@override final  String id;
@override final  String name;
@override final  String email;
@override@JsonKey() final  bool verified;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.verified, verified) || other.verified == verified));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,email,verified);
}

@override
String toString() {
    return 'User(id: $id, name: $name, email: $email, verified: $verified)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, bool verified
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? verified = null,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$AuthTokens {

 String get access; String get refresh; String get sessionId; DateTime get accessExpiresAt;
/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthTokensCopyWith<AuthTokens> get copyWith => _$AuthTokensCopyWithImpl<AuthTokens>(this as AuthTokens, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AuthTokens;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthTokens&&(identical(other.access, _this.access) || other.access == _this.access)&&(identical(other.refresh, _this.refresh) || other.refresh == _this.refresh)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.accessExpiresAt, _this.accessExpiresAt) || other.accessExpiresAt == _this.accessExpiresAt));
}


@override
int get hashCode {
  final _this = this as AuthTokens;
  return Object.hash(runtimeType,_this.access,_this.refresh,_this.sessionId,_this.accessExpiresAt);
}

@override
String toString() {
  final _this = this as AuthTokens;
  return 'AuthTokens(access: ${_this.access}, refresh: ${_this.refresh}, sessionId: ${_this.sessionId}, accessExpiresAt: ${_this.accessExpiresAt})';
}


}

/// @nodoc
abstract mixin class $AuthTokensCopyWith<$Res>  {
  factory $AuthTokensCopyWith(AuthTokens value, $Res Function(AuthTokens) _then) = _$AuthTokensCopyWithImpl;
@useResult
$Res call({
 String access, String refresh, String sessionId, DateTime accessExpiresAt
});




}
/// @nodoc
class _$AuthTokensCopyWithImpl<$Res>
    implements $AuthTokensCopyWith<$Res> {
  _$AuthTokensCopyWithImpl(this._self, this._then);

  final AuthTokens _self;
  final $Res Function(AuthTokens) _then;

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? access = null,Object? refresh = null,Object? sessionId = null,Object? accessExpiresAt = null,}) {
  return _then(AuthTokens(
access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as String,refresh: null == refresh ? _self.refresh : refresh // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,accessExpiresAt: null == accessExpiresAt ? _self.accessExpiresAt : accessExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthTokens].
extension AuthTokensPatterns on AuthTokens {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthTokens value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthTokens value)  $default,){
final _that = this;
switch (_that) {
case _AuthTokens():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthTokens value)?  $default,){
final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String access,  String refresh,  String sessionId,  DateTime accessExpiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that.access,_that.refresh,_that.sessionId,_that.accessExpiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String access,  String refresh,  String sessionId,  DateTime accessExpiresAt)  $default,) {final _that = this;
switch (_that) {
case _AuthTokens():
return $default(_that.access,_that.refresh,_that.sessionId,_that.accessExpiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String access,  String refresh,  String sessionId,  DateTime accessExpiresAt)?  $default,) {final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that.access,_that.refresh,_that.sessionId,_that.accessExpiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _AuthTokens implements AuthTokens {
  const _AuthTokens({required this.access, required this.refresh, required this.sessionId, required this.accessExpiresAt});
  

@override final  String access;
@override final  String refresh;
@override final  String sessionId;
@override final  DateTime accessExpiresAt;

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthTokensCopyWith<_AuthTokens> get copyWith => __$AuthTokensCopyWithImpl<_AuthTokens>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthTokens&&(identical(other.access, access) || other.access == access)&&(identical(other.refresh, refresh) || other.refresh == refresh)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.accessExpiresAt, accessExpiresAt) || other.accessExpiresAt == accessExpiresAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,access,refresh,sessionId,accessExpiresAt);
}

@override
String toString() {
    return 'AuthTokens(access: $access, refresh: $refresh, sessionId: $sessionId, accessExpiresAt: $accessExpiresAt)';
}


}

/// @nodoc
abstract mixin class _$AuthTokensCopyWith<$Res> implements $AuthTokensCopyWith<$Res> {
  factory _$AuthTokensCopyWith(_AuthTokens value, $Res Function(_AuthTokens) _then) = __$AuthTokensCopyWithImpl;
@override @useResult
$Res call({
 String access, String refresh, String sessionId, DateTime accessExpiresAt
});




}
/// @nodoc
class __$AuthTokensCopyWithImpl<$Res>
    implements _$AuthTokensCopyWith<$Res> {
  __$AuthTokensCopyWithImpl(this._self, this._then);

  final _AuthTokens _self;
  final $Res Function(_AuthTokens) _then;

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? access = null,Object? refresh = null,Object? sessionId = null,Object? accessExpiresAt = null,}) {
  return _then(_AuthTokens(
access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as String,refresh: null == refresh ? _self.refresh : refresh // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,accessExpiresAt: null == accessExpiresAt ? _self.accessExpiresAt : accessExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$Organisation {

 String get id; String get name; Role get role; bool get facesEnabled; List<String>? get siteScope;
/// Create a copy of Organisation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganisationCopyWith<Organisation> get copyWith => _$OrganisationCopyWithImpl<Organisation>(this as Organisation, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Organisation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Organisation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.facesEnabled, _this.facesEnabled) || other.facesEnabled == _this.facesEnabled)&&const DeepCollectionEquality().equals(other.siteScope, _this.siteScope));
}


@override
int get hashCode {
  final _this = this as Organisation;
  return Object.hash(runtimeType,_this.id,_this.name,_this.role,_this.facesEnabled,const DeepCollectionEquality().hash(_this.siteScope));
}

@override
String toString() {
  final _this = this as Organisation;
  return 'Organisation(id: ${_this.id}, name: ${_this.name}, role: ${_this.role}, facesEnabled: ${_this.facesEnabled}, siteScope: ${_this.siteScope})';
}


}

/// @nodoc
abstract mixin class $OrganisationCopyWith<$Res>  {
  factory $OrganisationCopyWith(Organisation value, $Res Function(Organisation) _then) = _$OrganisationCopyWithImpl;
@useResult
$Res call({
 String id, String name, Role role, bool facesEnabled, List<String>? siteScope
});




}
/// @nodoc
class _$OrganisationCopyWithImpl<$Res>
    implements $OrganisationCopyWith<$Res> {
  _$OrganisationCopyWithImpl(this._self, this._then);

  final Organisation _self;
  final $Res Function(Organisation) _then;

/// Create a copy of Organisation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? role = null,Object? facesEnabled = null,Object? siteScope = freezed,}) {
  return _then(Organisation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,facesEnabled: null == facesEnabled ? _self.facesEnabled : facesEnabled // ignore: cast_nullable_to_non_nullable
as bool,siteScope: freezed == siteScope ? _self.siteScope : siteScope // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Organisation].
extension OrganisationPatterns on Organisation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Organisation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Organisation() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Organisation value)  $default,){
final _that = this;
switch (_that) {
case _Organisation():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Organisation value)?  $default,){
final _that = this;
switch (_that) {
case _Organisation() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  Role role,  bool facesEnabled,  List<String>? siteScope)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Organisation() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.facesEnabled,_that.siteScope);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  Role role,  bool facesEnabled,  List<String>? siteScope)  $default,) {final _that = this;
switch (_that) {
case _Organisation():
return $default(_that.id,_that.name,_that.role,_that.facesEnabled,_that.siteScope);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  Role role,  bool facesEnabled,  List<String>? siteScope)?  $default,) {final _that = this;
switch (_that) {
case _Organisation() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.facesEnabled,_that.siteScope);case _:
  return null;

}
}

}

/// @nodoc


class _Organisation implements Organisation {
  const _Organisation({required this.id, required this.name, required this.role, this.facesEnabled = false,  List<String>? siteScope}): _siteScope = siteScope;
  

@override final  String id;
@override final  String name;
@override final  Role role;
@override@JsonKey() final  bool facesEnabled;
 final  List<String>? _siteScope;
@override List<String>? get siteScope {
  final value = _siteScope;
  if (value == null) return null;
  if (_siteScope is EqualUnmodifiableListView) return _siteScope;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Organisation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganisationCopyWith<_Organisation> get copyWith => __$OrganisationCopyWithImpl<_Organisation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Organisation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.facesEnabled, facesEnabled) || other.facesEnabled == facesEnabled)&&const DeepCollectionEquality().equals(other.siteScope, _siteScope));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,role,facesEnabled,const DeepCollectionEquality().hash(_siteScope));
}

@override
String toString() {
    return 'Organisation(id: $id, name: $name, role: $role, facesEnabled: $facesEnabled, siteScope: $siteScope)';
}


}

/// @nodoc
abstract mixin class _$OrganisationCopyWith<$Res> implements $OrganisationCopyWith<$Res> {
  factory _$OrganisationCopyWith(_Organisation value, $Res Function(_Organisation) _then) = __$OrganisationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Role role, bool facesEnabled, List<String>? siteScope
});




}
/// @nodoc
class __$OrganisationCopyWithImpl<$Res>
    implements _$OrganisationCopyWith<$Res> {
  __$OrganisationCopyWithImpl(this._self, this._then);

  final _Organisation _self;
  final $Res Function(_Organisation) _then;

/// Create a copy of Organisation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? role = null,Object? facesEnabled = null,Object? siteScope = freezed,}) {
  return _then(_Organisation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,facesEnabled: null == facesEnabled ? _self.facesEnabled : facesEnabled // ignore: cast_nullable_to_non_nullable
as bool,siteScope: freezed == siteScope ? _self._siteScope : siteScope // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

/// @nodoc
mixin _$Site {

 String get id; String get organisationId; String get name; SiteKind get kind; String get timezone; ArmMode get armMode; int get retentionDays;
/// Create a copy of Site
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteCopyWith<Site> get copyWith => _$SiteCopyWithImpl<Site>(this as Site, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Site;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Site&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organisationId, _this.organisationId) || other.organisationId == _this.organisationId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.armMode, _this.armMode) || other.armMode == _this.armMode)&&(identical(other.retentionDays, _this.retentionDays) || other.retentionDays == _this.retentionDays));
}


@override
int get hashCode {
  final _this = this as Site;
  return Object.hash(runtimeType,_this.id,_this.organisationId,_this.name,_this.kind,_this.timezone,_this.armMode,_this.retentionDays);
}

@override
String toString() {
  final _this = this as Site;
  return 'Site(id: ${_this.id}, organisationId: ${_this.organisationId}, name: ${_this.name}, kind: ${_this.kind}, timezone: ${_this.timezone}, armMode: ${_this.armMode}, retentionDays: ${_this.retentionDays})';
}


}

/// @nodoc
abstract mixin class $SiteCopyWith<$Res>  {
  factory $SiteCopyWith(Site value, $Res Function(Site) _then) = _$SiteCopyWithImpl;
@useResult
$Res call({
 String id, String organisationId, String name, SiteKind kind, String timezone, ArmMode armMode, int retentionDays
});




}
/// @nodoc
class _$SiteCopyWithImpl<$Res>
    implements $SiteCopyWith<$Res> {
  _$SiteCopyWithImpl(this._self, this._then);

  final Site _self;
  final $Res Function(Site) _then;

/// Create a copy of Site
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organisationId = null,Object? name = null,Object? kind = null,Object? timezone = null,Object? armMode = null,Object? retentionDays = null,}) {
  return _then(Site(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organisationId: null == organisationId ? _self.organisationId : organisationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SiteKind,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,armMode: null == armMode ? _self.armMode : armMode // ignore: cast_nullable_to_non_nullable
as ArmMode,retentionDays: null == retentionDays ? _self.retentionDays : retentionDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Site].
extension SitePatterns on Site {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Site value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Site() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Site value)  $default,){
final _that = this;
switch (_that) {
case _Site():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Site value)?  $default,){
final _that = this;
switch (_that) {
case _Site() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organisationId,  String name,  SiteKind kind,  String timezone,  ArmMode armMode,  int retentionDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Site() when $default != null:
return $default(_that.id,_that.organisationId,_that.name,_that.kind,_that.timezone,_that.armMode,_that.retentionDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organisationId,  String name,  SiteKind kind,  String timezone,  ArmMode armMode,  int retentionDays)  $default,) {final _that = this;
switch (_that) {
case _Site():
return $default(_that.id,_that.organisationId,_that.name,_that.kind,_that.timezone,_that.armMode,_that.retentionDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organisationId,  String name,  SiteKind kind,  String timezone,  ArmMode armMode,  int retentionDays)?  $default,) {final _that = this;
switch (_that) {
case _Site() when $default != null:
return $default(_that.id,_that.organisationId,_that.name,_that.kind,_that.timezone,_that.armMode,_that.retentionDays);case _:
  return null;

}
}

}

/// @nodoc


class _Site implements Site {
  const _Site({required this.id, required this.organisationId, required this.name, required this.kind, required this.timezone, this.armMode = ArmMode.schedule, this.retentionDays = 30});
  

@override final  String id;
@override final  String organisationId;
@override final  String name;
@override final  SiteKind kind;
@override final  String timezone;
@override@JsonKey() final  ArmMode armMode;
@override@JsonKey() final  int retentionDays;

/// Create a copy of Site
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteCopyWith<_Site> get copyWith => __$SiteCopyWithImpl<_Site>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Site&&(identical(other.id, id) || other.id == id)&&(identical(other.organisationId, organisationId) || other.organisationId == organisationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.armMode, armMode) || other.armMode == armMode)&&(identical(other.retentionDays, retentionDays) || other.retentionDays == retentionDays));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,organisationId,name,kind,timezone,armMode,retentionDays);
}

@override
String toString() {
    return 'Site(id: $id, organisationId: $organisationId, name: $name, kind: $kind, timezone: $timezone, armMode: $armMode, retentionDays: $retentionDays)';
}


}

/// @nodoc
abstract mixin class _$SiteCopyWith<$Res> implements $SiteCopyWith<$Res> {
  factory _$SiteCopyWith(_Site value, $Res Function(_Site) _then) = __$SiteCopyWithImpl;
@override @useResult
$Res call({
 String id, String organisationId, String name, SiteKind kind, String timezone, ArmMode armMode, int retentionDays
});




}
/// @nodoc
class __$SiteCopyWithImpl<$Res>
    implements _$SiteCopyWith<$Res> {
  __$SiteCopyWithImpl(this._self, this._then);

  final _Site _self;
  final $Res Function(_Site) _then;

/// Create a copy of Site
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organisationId = null,Object? name = null,Object? kind = null,Object? timezone = null,Object? armMode = null,Object? retentionDays = null,}) {
  return _then(_Site(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organisationId: null == organisationId ? _self.organisationId : organisationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SiteKind,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,armMode: null == armMode ? _self.armMode : armMode // ignore: cast_nullable_to_non_nullable
as ArmMode,retentionDays: null == retentionDays ? _self.retentionDays : retentionDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$Member {

 String get userId; String get name; String get email; Role get role; List<String>? get siteIds; DateTime? get lastActiveAt; bool get you;
/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberCopyWith<Member> get copyWith => _$MemberCopyWithImpl<Member>(this as Member, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Member;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Member&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.role, _this.role) || other.role == _this.role)&&const DeepCollectionEquality().equals(other.siteIds, _this.siteIds)&&(identical(other.lastActiveAt, _this.lastActiveAt) || other.lastActiveAt == _this.lastActiveAt)&&(identical(other.you, _this.you) || other.you == _this.you));
}


@override
int get hashCode {
  final _this = this as Member;
  return Object.hash(runtimeType,_this.userId,_this.name,_this.email,_this.role,const DeepCollectionEquality().hash(_this.siteIds),_this.lastActiveAt,_this.you);
}

@override
String toString() {
  final _this = this as Member;
  return 'Member(userId: ${_this.userId}, name: ${_this.name}, email: ${_this.email}, role: ${_this.role}, siteIds: ${_this.siteIds}, lastActiveAt: ${_this.lastActiveAt}, you: ${_this.you})';
}


}

/// @nodoc
abstract mixin class $MemberCopyWith<$Res>  {
  factory $MemberCopyWith(Member value, $Res Function(Member) _then) = _$MemberCopyWithImpl;
@useResult
$Res call({
 String userId, String name, String email, Role role, List<String>? siteIds, DateTime? lastActiveAt, bool you
});




}
/// @nodoc
class _$MemberCopyWithImpl<$Res>
    implements $MemberCopyWith<$Res> {
  _$MemberCopyWithImpl(this._self, this._then);

  final Member _self;
  final $Res Function(Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? name = null,Object? email = null,Object? role = null,Object? siteIds = freezed,Object? lastActiveAt = freezed,Object? you = null,}) {
  return _then(Member(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,siteIds: freezed == siteIds ? _self.siteIds : siteIds // ignore: cast_nullable_to_non_nullable
as List<String>?,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,you: null == you ? _self.you : you // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Member].
extension MemberPatterns on Member {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Member value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Member value)  $default,){
final _that = this;
switch (_that) {
case _Member():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Member value)?  $default,){
final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String name,  String email,  Role role,  List<String>? siteIds,  DateTime? lastActiveAt,  bool you)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.userId,_that.name,_that.email,_that.role,_that.siteIds,_that.lastActiveAt,_that.you);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String name,  String email,  Role role,  List<String>? siteIds,  DateTime? lastActiveAt,  bool you)  $default,) {final _that = this;
switch (_that) {
case _Member():
return $default(_that.userId,_that.name,_that.email,_that.role,_that.siteIds,_that.lastActiveAt,_that.you);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String name,  String email,  Role role,  List<String>? siteIds,  DateTime? lastActiveAt,  bool you)?  $default,) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.userId,_that.name,_that.email,_that.role,_that.siteIds,_that.lastActiveAt,_that.you);case _:
  return null;

}
}

}

/// @nodoc


class _Member implements Member {
  const _Member({required this.userId, required this.name, required this.email, required this.role,  List<String>? siteIds, this.lastActiveAt, this.you = false}): _siteIds = siteIds;
  

@override final  String userId;
@override final  String name;
@override final  String email;
@override final  Role role;
 final  List<String>? _siteIds;
@override List<String>? get siteIds {
  final value = _siteIds;
  if (value == null) return null;
  if (_siteIds is EqualUnmodifiableListView) return _siteIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  DateTime? lastActiveAt;
@override@JsonKey() final  bool you;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberCopyWith<_Member> get copyWith => __$MemberCopyWithImpl<_Member>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Member&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other.siteIds, _siteIds)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&(identical(other.you, you) || other.you == you));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId,name,email,role,const DeepCollectionEquality().hash(_siteIds),lastActiveAt,you);
}

@override
String toString() {
    return 'Member(userId: $userId, name: $name, email: $email, role: $role, siteIds: $siteIds, lastActiveAt: $lastActiveAt, you: $you)';
}


}

/// @nodoc
abstract mixin class _$MemberCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$MemberCopyWith(_Member value, $Res Function(_Member) _then) = __$MemberCopyWithImpl;
@override @useResult
$Res call({
 String userId, String name, String email, Role role, List<String>? siteIds, DateTime? lastActiveAt, bool you
});




}
/// @nodoc
class __$MemberCopyWithImpl<$Res>
    implements _$MemberCopyWith<$Res> {
  __$MemberCopyWithImpl(this._self, this._then);

  final _Member _self;
  final $Res Function(_Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? name = null,Object? email = null,Object? role = null,Object? siteIds = freezed,Object? lastActiveAt = freezed,Object? you = null,}) {
  return _then(_Member(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,siteIds: freezed == siteIds ? _self._siteIds : siteIds // ignore: cast_nullable_to_non_nullable
as List<String>?,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,you: null == you ? _self.you : you // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$Invitation {

 String get id; String get email; Role get role; List<String>? get siteIds; DateTime get expiresAt; String get invitedBy; InvitationState get state;
/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitationCopyWith<Invitation> get copyWith => _$InvitationCopyWithImpl<Invitation>(this as Invitation, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Invitation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invitation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.role, _this.role) || other.role == _this.role)&&const DeepCollectionEquality().equals(other.siteIds, _this.siteIds)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.invitedBy, _this.invitedBy) || other.invitedBy == _this.invitedBy)&&(identical(other.state, _this.state) || other.state == _this.state));
}


@override
int get hashCode {
  final _this = this as Invitation;
  return Object.hash(runtimeType,_this.id,_this.email,_this.role,const DeepCollectionEquality().hash(_this.siteIds),_this.expiresAt,_this.invitedBy,_this.state);
}

@override
String toString() {
  final _this = this as Invitation;
  return 'Invitation(id: ${_this.id}, email: ${_this.email}, role: ${_this.role}, siteIds: ${_this.siteIds}, expiresAt: ${_this.expiresAt}, invitedBy: ${_this.invitedBy}, state: ${_this.state})';
}


}

/// @nodoc
abstract mixin class $InvitationCopyWith<$Res>  {
  factory $InvitationCopyWith(Invitation value, $Res Function(Invitation) _then) = _$InvitationCopyWithImpl;
@useResult
$Res call({
 String id, String email, Role role, List<String>? siteIds, DateTime expiresAt, String invitedBy, InvitationState state
});




}
/// @nodoc
class _$InvitationCopyWithImpl<$Res>
    implements $InvitationCopyWith<$Res> {
  _$InvitationCopyWithImpl(this._self, this._then);

  final Invitation _self;
  final $Res Function(Invitation) _then;

/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? role = null,Object? siteIds = freezed,Object? expiresAt = null,Object? invitedBy = null,Object? state = null,}) {
  return _then(Invitation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,siteIds: freezed == siteIds ? _self.siteIds : siteIds // ignore: cast_nullable_to_non_nullable
as List<String>?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,invitedBy: null == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as InvitationState,
  ));
}

}


/// Adds pattern-matching-related methods to [Invitation].
extension InvitationPatterns on Invitation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invitation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invitation() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invitation value)  $default,){
final _that = this;
switch (_that) {
case _Invitation():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invitation value)?  $default,){
final _that = this;
switch (_that) {
case _Invitation() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  Role role,  List<String>? siteIds,  DateTime expiresAt,  String invitedBy,  InvitationState state)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invitation() when $default != null:
return $default(_that.id,_that.email,_that.role,_that.siteIds,_that.expiresAt,_that.invitedBy,_that.state);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  Role role,  List<String>? siteIds,  DateTime expiresAt,  String invitedBy,  InvitationState state)  $default,) {final _that = this;
switch (_that) {
case _Invitation():
return $default(_that.id,_that.email,_that.role,_that.siteIds,_that.expiresAt,_that.invitedBy,_that.state);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  Role role,  List<String>? siteIds,  DateTime expiresAt,  String invitedBy,  InvitationState state)?  $default,) {final _that = this;
switch (_that) {
case _Invitation() when $default != null:
return $default(_that.id,_that.email,_that.role,_that.siteIds,_that.expiresAt,_that.invitedBy,_that.state);case _:
  return null;

}
}

}

/// @nodoc


class _Invitation implements Invitation {
  const _Invitation({required this.id, required this.email, required this.role,  List<String>? siteIds, required this.expiresAt, required this.invitedBy, this.state = InvitationState.pending}): _siteIds = siteIds;
  

@override final  String id;
@override final  String email;
@override final  Role role;
 final  List<String>? _siteIds;
@override List<String>? get siteIds {
  final value = _siteIds;
  if (value == null) return null;
  if (_siteIds is EqualUnmodifiableListView) return _siteIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  DateTime expiresAt;
@override final  String invitedBy;
@override@JsonKey() final  InvitationState state;

/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitationCopyWith<_Invitation> get copyWith => __$InvitationCopyWithImpl<_Invitation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invitation&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other.siteIds, _siteIds)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.state, state) || other.state == state));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,email,role,const DeepCollectionEquality().hash(_siteIds),expiresAt,invitedBy,state);
}

@override
String toString() {
    return 'Invitation(id: $id, email: $email, role: $role, siteIds: $siteIds, expiresAt: $expiresAt, invitedBy: $invitedBy, state: $state)';
}


}

/// @nodoc
abstract mixin class _$InvitationCopyWith<$Res> implements $InvitationCopyWith<$Res> {
  factory _$InvitationCopyWith(_Invitation value, $Res Function(_Invitation) _then) = __$InvitationCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, Role role, List<String>? siteIds, DateTime expiresAt, String invitedBy, InvitationState state
});




}
/// @nodoc
class __$InvitationCopyWithImpl<$Res>
    implements _$InvitationCopyWith<$Res> {
  __$InvitationCopyWithImpl(this._self, this._then);

  final _Invitation _self;
  final $Res Function(_Invitation) _then;

/// Create a copy of Invitation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? role = null,Object? siteIds = freezed,Object? expiresAt = null,Object? invitedBy = null,Object? state = null,}) {
  return _then(_Invitation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,siteIds: freezed == siteIds ? _self._siteIds : siteIds // ignore: cast_nullable_to_non_nullable
as List<String>?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,invitedBy: null == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as InvitationState,
  ));
}


}

/// @nodoc
mixin _$InvitationPreview {

 String get token; String get organisationName; String get invitedBy; Role get role; List<String> get siteNames; DateTime get expiresAt;
/// Create a copy of InvitationPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitationPreviewCopyWith<InvitationPreview> get copyWith => _$InvitationPreviewCopyWithImpl<InvitationPreview>(this as InvitationPreview, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InvitationPreview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvitationPreview&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.organisationName, _this.organisationName) || other.organisationName == _this.organisationName)&&(identical(other.invitedBy, _this.invitedBy) || other.invitedBy == _this.invitedBy)&&(identical(other.role, _this.role) || other.role == _this.role)&&const DeepCollectionEquality().equals(other.siteNames, _this.siteNames)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}


@override
int get hashCode {
  final _this = this as InvitationPreview;
  return Object.hash(runtimeType,_this.token,_this.organisationName,_this.invitedBy,_this.role,const DeepCollectionEquality().hash(_this.siteNames),_this.expiresAt);
}

@override
String toString() {
  final _this = this as InvitationPreview;
  return 'InvitationPreview(token: ${_this.token}, organisationName: ${_this.organisationName}, invitedBy: ${_this.invitedBy}, role: ${_this.role}, siteNames: ${_this.siteNames}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $InvitationPreviewCopyWith<$Res>  {
  factory $InvitationPreviewCopyWith(InvitationPreview value, $Res Function(InvitationPreview) _then) = _$InvitationPreviewCopyWithImpl;
@useResult
$Res call({
 String token, String organisationName, String invitedBy, Role role, List<String> siteNames, DateTime expiresAt
});




}
/// @nodoc
class _$InvitationPreviewCopyWithImpl<$Res>
    implements $InvitationPreviewCopyWith<$Res> {
  _$InvitationPreviewCopyWithImpl(this._self, this._then);

  final InvitationPreview _self;
  final $Res Function(InvitationPreview) _then;

/// Create a copy of InvitationPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? organisationName = null,Object? invitedBy = null,Object? role = null,Object? siteNames = null,Object? expiresAt = null,}) {
  return _then(InvitationPreview(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,organisationName: null == organisationName ? _self.organisationName : organisationName // ignore: cast_nullable_to_non_nullable
as String,invitedBy: null == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,siteNames: null == siteNames ? _self.siteNames : siteNames // ignore: cast_nullable_to_non_nullable
as List<String>,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InvitationPreview].
extension InvitationPreviewPatterns on InvitationPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvitationPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvitationPreview() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvitationPreview value)  $default,){
final _that = this;
switch (_that) {
case _InvitationPreview():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvitationPreview value)?  $default,){
final _that = this;
switch (_that) {
case _InvitationPreview() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String organisationName,  String invitedBy,  Role role,  List<String> siteNames,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvitationPreview() when $default != null:
return $default(_that.token,_that.organisationName,_that.invitedBy,_that.role,_that.siteNames,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String organisationName,  String invitedBy,  Role role,  List<String> siteNames,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _InvitationPreview():
return $default(_that.token,_that.organisationName,_that.invitedBy,_that.role,_that.siteNames,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String organisationName,  String invitedBy,  Role role,  List<String> siteNames,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _InvitationPreview() when $default != null:
return $default(_that.token,_that.organisationName,_that.invitedBy,_that.role,_that.siteNames,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _InvitationPreview implements InvitationPreview {
  const _InvitationPreview({required this.token, required this.organisationName, required this.invitedBy, required this.role, required  List<String> siteNames, required this.expiresAt}): _siteNames = siteNames;
  

@override final  String token;
@override final  String organisationName;
@override final  String invitedBy;
@override final  Role role;
 final  List<String> _siteNames;
@override List<String> get siteNames {
  if (_siteNames is EqualUnmodifiableListView) return _siteNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_siteNames);
}

@override final  DateTime expiresAt;

/// Create a copy of InvitationPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitationPreviewCopyWith<_InvitationPreview> get copyWith => __$InvitationPreviewCopyWithImpl<_InvitationPreview>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvitationPreview&&(identical(other.token, token) || other.token == token)&&(identical(other.organisationName, organisationName) || other.organisationName == organisationName)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other.siteNames, _siteNames)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,token,organisationName,invitedBy,role,const DeepCollectionEquality().hash(_siteNames),expiresAt);
}

@override
String toString() {
    return 'InvitationPreview(token: $token, organisationName: $organisationName, invitedBy: $invitedBy, role: $role, siteNames: $siteNames, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$InvitationPreviewCopyWith<$Res> implements $InvitationPreviewCopyWith<$Res> {
  factory _$InvitationPreviewCopyWith(_InvitationPreview value, $Res Function(_InvitationPreview) _then) = __$InvitationPreviewCopyWithImpl;
@override @useResult
$Res call({
 String token, String organisationName, String invitedBy, Role role, List<String> siteNames, DateTime expiresAt
});




}
/// @nodoc
class __$InvitationPreviewCopyWithImpl<$Res>
    implements _$InvitationPreviewCopyWith<$Res> {
  __$InvitationPreviewCopyWithImpl(this._self, this._then);

  final _InvitationPreview _self;
  final $Res Function(_InvitationPreview) _then;

/// Create a copy of InvitationPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? organisationName = null,Object? invitedBy = null,Object? role = null,Object? siteNames = null,Object? expiresAt = null,}) {
  return _then(_InvitationPreview(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,organisationName: null == organisationName ? _self.organisationName : organisationName // ignore: cast_nullable_to_non_nullable
as String,invitedBy: null == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,siteNames: null == siteNames ? _self._siteNames : siteNames // ignore: cast_nullable_to_non_nullable
as List<String>,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$DeviceSession {

 String get id; String get deviceName; String get platform; DateTime get createdAt; DateTime get lastUsedAt; bool get current;
/// Create a copy of DeviceSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceSessionCopyWith<DeviceSession> get copyWith => _$DeviceSessionCopyWithImpl<DeviceSession>(this as DeviceSession, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeviceSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName)&&(identical(other.platform, _this.platform) || other.platform == _this.platform)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.lastUsedAt, _this.lastUsedAt) || other.lastUsedAt == _this.lastUsedAt)&&(identical(other.current, _this.current) || other.current == _this.current));
}


@override
int get hashCode {
  final _this = this as DeviceSession;
  return Object.hash(runtimeType,_this.id,_this.deviceName,_this.platform,_this.createdAt,_this.lastUsedAt,_this.current);
}

@override
String toString() {
  final _this = this as DeviceSession;
  return 'DeviceSession(id: ${_this.id}, deviceName: ${_this.deviceName}, platform: ${_this.platform}, createdAt: ${_this.createdAt}, lastUsedAt: ${_this.lastUsedAt}, current: ${_this.current})';
}


}

/// @nodoc
abstract mixin class $DeviceSessionCopyWith<$Res>  {
  factory $DeviceSessionCopyWith(DeviceSession value, $Res Function(DeviceSession) _then) = _$DeviceSessionCopyWithImpl;
@useResult
$Res call({
 String id, String deviceName, String platform, DateTime createdAt, DateTime lastUsedAt, bool current
});




}
/// @nodoc
class _$DeviceSessionCopyWithImpl<$Res>
    implements $DeviceSessionCopyWith<$Res> {
  _$DeviceSessionCopyWithImpl(this._self, this._then);

  final DeviceSession _self;
  final $Res Function(DeviceSession) _then;

/// Create a copy of DeviceSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deviceName = null,Object? platform = null,Object? createdAt = null,Object? lastUsedAt = null,Object? current = null,}) {
  return _then(DeviceSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: null == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceSession].
extension DeviceSessionPatterns on DeviceSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceSession() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceSession value)  $default,){
final _that = this;
switch (_that) {
case _DeviceSession():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceSession value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceSession() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String deviceName,  String platform,  DateTime createdAt,  DateTime lastUsedAt,  bool current)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceSession() when $default != null:
return $default(_that.id,_that.deviceName,_that.platform,_that.createdAt,_that.lastUsedAt,_that.current);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String deviceName,  String platform,  DateTime createdAt,  DateTime lastUsedAt,  bool current)  $default,) {final _that = this;
switch (_that) {
case _DeviceSession():
return $default(_that.id,_that.deviceName,_that.platform,_that.createdAt,_that.lastUsedAt,_that.current);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String deviceName,  String platform,  DateTime createdAt,  DateTime lastUsedAt,  bool current)?  $default,) {final _that = this;
switch (_that) {
case _DeviceSession() when $default != null:
return $default(_that.id,_that.deviceName,_that.platform,_that.createdAt,_that.lastUsedAt,_that.current);case _:
  return null;

}
}

}

/// @nodoc


class _DeviceSession implements DeviceSession {
  const _DeviceSession({required this.id, required this.deviceName, required this.platform, required this.createdAt, required this.lastUsedAt, this.current = false});
  

@override final  String id;
@override final  String deviceName;
@override final  String platform;
@override final  DateTime createdAt;
@override final  DateTime lastUsedAt;
@override@JsonKey() final  bool current;

/// Create a copy of DeviceSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceSessionCopyWith<_DeviceSession> get copyWith => __$DeviceSessionCopyWithImpl<_DeviceSession>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceSession&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt)&&(identical(other.current, current) || other.current == current));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,deviceName,platform,createdAt,lastUsedAt,current);
}

@override
String toString() {
    return 'DeviceSession(id: $id, deviceName: $deviceName, platform: $platform, createdAt: $createdAt, lastUsedAt: $lastUsedAt, current: $current)';
}


}

/// @nodoc
abstract mixin class _$DeviceSessionCopyWith<$Res> implements $DeviceSessionCopyWith<$Res> {
  factory _$DeviceSessionCopyWith(_DeviceSession value, $Res Function(_DeviceSession) _then) = __$DeviceSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String deviceName, String platform, DateTime createdAt, DateTime lastUsedAt, bool current
});




}
/// @nodoc
class __$DeviceSessionCopyWithImpl<$Res>
    implements _$DeviceSessionCopyWith<$Res> {
  __$DeviceSessionCopyWithImpl(this._self, this._then);

  final _DeviceSession _self;
  final $Res Function(_DeviceSession) _then;

/// Create a copy of DeviceSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deviceName = null,Object? platform = null,Object? createdAt = null,Object? lastUsedAt = null,Object? current = null,}) {
  return _then(_DeviceSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: null == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$NotificationPrefs {

 String get siteId; bool get enabled; bool get alertsOnly; Set<String> get mutedKinds; String? get quietFrom; String? get quietUntil;
/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPrefsCopyWith<NotificationPrefs> get copyWith => _$NotificationPrefsCopyWithImpl<NotificationPrefs>(this as NotificationPrefs, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NotificationPrefs;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPrefs&&(identical(other.siteId, _this.siteId) || other.siteId == _this.siteId)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.alertsOnly, _this.alertsOnly) || other.alertsOnly == _this.alertsOnly)&&const DeepCollectionEquality().equals(other.mutedKinds, _this.mutedKinds)&&(identical(other.quietFrom, _this.quietFrom) || other.quietFrom == _this.quietFrom)&&(identical(other.quietUntil, _this.quietUntil) || other.quietUntil == _this.quietUntil));
}


@override
int get hashCode {
  final _this = this as NotificationPrefs;
  return Object.hash(runtimeType,_this.siteId,_this.enabled,_this.alertsOnly,const DeepCollectionEquality().hash(_this.mutedKinds),_this.quietFrom,_this.quietUntil);
}

@override
String toString() {
  final _this = this as NotificationPrefs;
  return 'NotificationPrefs(siteId: ${_this.siteId}, enabled: ${_this.enabled}, alertsOnly: ${_this.alertsOnly}, mutedKinds: ${_this.mutedKinds}, quietFrom: ${_this.quietFrom}, quietUntil: ${_this.quietUntil})';
}


}

/// @nodoc
abstract mixin class $NotificationPrefsCopyWith<$Res>  {
  factory $NotificationPrefsCopyWith(NotificationPrefs value, $Res Function(NotificationPrefs) _then) = _$NotificationPrefsCopyWithImpl;
@useResult
$Res call({
 String siteId, bool enabled, bool alertsOnly, Set<String> mutedKinds, String? quietFrom, String? quietUntil
});




}
/// @nodoc
class _$NotificationPrefsCopyWithImpl<$Res>
    implements $NotificationPrefsCopyWith<$Res> {
  _$NotificationPrefsCopyWithImpl(this._self, this._then);

  final NotificationPrefs _self;
  final $Res Function(NotificationPrefs) _then;

/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? siteId = null,Object? enabled = null,Object? alertsOnly = null,Object? mutedKinds = null,Object? quietFrom = freezed,Object? quietUntil = freezed,}) {
  return _then(NotificationPrefs(
siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,alertsOnly: null == alertsOnly ? _self.alertsOnly : alertsOnly // ignore: cast_nullable_to_non_nullable
as bool,mutedKinds: null == mutedKinds ? _self.mutedKinds : mutedKinds // ignore: cast_nullable_to_non_nullable
as Set<String>,quietFrom: freezed == quietFrom ? _self.quietFrom : quietFrom // ignore: cast_nullable_to_non_nullable
as String?,quietUntil: freezed == quietUntil ? _self.quietUntil : quietUntil // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPrefs].
extension NotificationPrefsPatterns on NotificationPrefs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPrefs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPrefs value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPrefs():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPrefs value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String siteId,  bool enabled,  bool alertsOnly,  Set<String> mutedKinds,  String? quietFrom,  String? quietUntil)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
return $default(_that.siteId,_that.enabled,_that.alertsOnly,_that.mutedKinds,_that.quietFrom,_that.quietUntil);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String siteId,  bool enabled,  bool alertsOnly,  Set<String> mutedKinds,  String? quietFrom,  String? quietUntil)  $default,) {final _that = this;
switch (_that) {
case _NotificationPrefs():
return $default(_that.siteId,_that.enabled,_that.alertsOnly,_that.mutedKinds,_that.quietFrom,_that.quietUntil);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String siteId,  bool enabled,  bool alertsOnly,  Set<String> mutedKinds,  String? quietFrom,  String? quietUntil)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
return $default(_that.siteId,_that.enabled,_that.alertsOnly,_that.mutedKinds,_that.quietFrom,_that.quietUntil);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationPrefs implements NotificationPrefs {
  const _NotificationPrefs({required this.siteId, this.enabled = true, this.alertsOnly = true,  Set<String> mutedKinds = const <String>{}, this.quietFrom, this.quietUntil}): _mutedKinds = mutedKinds;
  

@override final  String siteId;
@override@JsonKey() final  bool enabled;
@override@JsonKey() final  bool alertsOnly;
 final  Set<String> _mutedKinds;
@override@JsonKey() Set<String> get mutedKinds {
  if (_mutedKinds is EqualUnmodifiableSetView) return _mutedKinds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_mutedKinds);
}

@override final  String? quietFrom;
@override final  String? quietUntil;

/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPrefsCopyWith<_NotificationPrefs> get copyWith => __$NotificationPrefsCopyWithImpl<_NotificationPrefs>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPrefs&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.alertsOnly, alertsOnly) || other.alertsOnly == alertsOnly)&&const DeepCollectionEquality().equals(other.mutedKinds, _mutedKinds)&&(identical(other.quietFrom, quietFrom) || other.quietFrom == quietFrom)&&(identical(other.quietUntil, quietUntil) || other.quietUntil == quietUntil));
}


@override
int get hashCode {
    return Object.hash(runtimeType,siteId,enabled,alertsOnly,const DeepCollectionEquality().hash(_mutedKinds),quietFrom,quietUntil);
}

@override
String toString() {
    return 'NotificationPrefs(siteId: $siteId, enabled: $enabled, alertsOnly: $alertsOnly, mutedKinds: $mutedKinds, quietFrom: $quietFrom, quietUntil: $quietUntil)';
}


}

/// @nodoc
abstract mixin class _$NotificationPrefsCopyWith<$Res> implements $NotificationPrefsCopyWith<$Res> {
  factory _$NotificationPrefsCopyWith(_NotificationPrefs value, $Res Function(_NotificationPrefs) _then) = __$NotificationPrefsCopyWithImpl;
@override @useResult
$Res call({
 String siteId, bool enabled, bool alertsOnly, Set<String> mutedKinds, String? quietFrom, String? quietUntil
});




}
/// @nodoc
class __$NotificationPrefsCopyWithImpl<$Res>
    implements _$NotificationPrefsCopyWith<$Res> {
  __$NotificationPrefsCopyWithImpl(this._self, this._then);

  final _NotificationPrefs _self;
  final $Res Function(_NotificationPrefs) _then;

/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? siteId = null,Object? enabled = null,Object? alertsOnly = null,Object? mutedKinds = null,Object? quietFrom = freezed,Object? quietUntil = freezed,}) {
  return _then(_NotificationPrefs(
siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,alertsOnly: null == alertsOnly ? _self.alertsOnly : alertsOnly // ignore: cast_nullable_to_non_nullable
as bool,mutedKinds: null == mutedKinds ? _self._mutedKinds : mutedKinds // ignore: cast_nullable_to_non_nullable
as Set<String>,quietFrom: freezed == quietFrom ? _self.quietFrom : quietFrom // ignore: cast_nullable_to_non_nullable
as String?,quietUntil: freezed == quietUntil ? _self.quietUntil : quietUntil // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
