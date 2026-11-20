// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
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

 String get id; String get organisationId; String get name; SiteKind get kind; String get timezone; ArmMode get armMode; int get retentionDays; int? get ownRetentionDays;
/// Create a copy of Site
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteCopyWith<Site> get copyWith => _$SiteCopyWithImpl<Site>(this as Site, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Site;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Site&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organisationId, _this.organisationId) || other.organisationId == _this.organisationId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.armMode, _this.armMode) || other.armMode == _this.armMode)&&(identical(other.retentionDays, _this.retentionDays) || other.retentionDays == _this.retentionDays)&&(identical(other.ownRetentionDays, _this.ownRetentionDays) || other.ownRetentionDays == _this.ownRetentionDays));
}


@override
int get hashCode {
  final _this = this as Site;
  return Object.hash(runtimeType,_this.id,_this.organisationId,_this.name,_this.kind,_this.timezone,_this.armMode,_this.retentionDays,_this.ownRetentionDays);
}

@override
String toString() {
  final _this = this as Site;
  return 'Site(id: ${_this.id}, organisationId: ${_this.organisationId}, name: ${_this.name}, kind: ${_this.kind}, timezone: ${_this.timezone}, armMode: ${_this.armMode}, retentionDays: ${_this.retentionDays}, ownRetentionDays: ${_this.ownRetentionDays})';
}


}

/// @nodoc
abstract mixin class $SiteCopyWith<$Res>  {
  factory $SiteCopyWith(Site value, $Res Function(Site) _then) = _$SiteCopyWithImpl;
@useResult
$Res call({
 String id, String organisationId, String name, SiteKind kind, String timezone, ArmMode armMode, int retentionDays, int? ownRetentionDays
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organisationId = null,Object? name = null,Object? kind = null,Object? timezone = null,Object? armMode = null,Object? retentionDays = null,Object? ownRetentionDays = freezed,}) {
  return _then(Site(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organisationId: null == organisationId ? _self.organisationId : organisationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SiteKind,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,armMode: null == armMode ? _self.armMode : armMode // ignore: cast_nullable_to_non_nullable
as ArmMode,retentionDays: null == retentionDays ? _self.retentionDays : retentionDays // ignore: cast_nullable_to_non_nullable
as int,ownRetentionDays: freezed == ownRetentionDays ? _self.ownRetentionDays : ownRetentionDays // ignore: cast_nullable_to_non_nullable
as int?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organisationId,  String name,  SiteKind kind,  String timezone,  ArmMode armMode,  int retentionDays,  int? ownRetentionDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Site() when $default != null:
return $default(_that.id,_that.organisationId,_that.name,_that.kind,_that.timezone,_that.armMode,_that.retentionDays,_that.ownRetentionDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organisationId,  String name,  SiteKind kind,  String timezone,  ArmMode armMode,  int retentionDays,  int? ownRetentionDays)  $default,) {final _that = this;
switch (_that) {
case _Site():
return $default(_that.id,_that.organisationId,_that.name,_that.kind,_that.timezone,_that.armMode,_that.retentionDays,_that.ownRetentionDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organisationId,  String name,  SiteKind kind,  String timezone,  ArmMode armMode,  int retentionDays,  int? ownRetentionDays)?  $default,) {final _that = this;
switch (_that) {
case _Site() when $default != null:
return $default(_that.id,_that.organisationId,_that.name,_that.kind,_that.timezone,_that.armMode,_that.retentionDays,_that.ownRetentionDays);case _:
  return null;

}
}

}

/// @nodoc


class _Site implements Site {
  const _Site({required this.id, required this.organisationId, required this.name, required this.kind, required this.timezone, this.armMode = ArmMode.schedule, this.retentionDays = 30, this.ownRetentionDays});
  

@override final  String id;
@override final  String organisationId;
@override final  String name;
@override final  SiteKind kind;
@override final  String timezone;
@override@JsonKey() final  ArmMode armMode;
@override@JsonKey() final  int retentionDays;
@override final  int? ownRetentionDays;

/// Create a copy of Site
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteCopyWith<_Site> get copyWith => __$SiteCopyWithImpl<_Site>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Site&&(identical(other.id, id) || other.id == id)&&(identical(other.organisationId, organisationId) || other.organisationId == organisationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.armMode, armMode) || other.armMode == armMode)&&(identical(other.retentionDays, retentionDays) || other.retentionDays == retentionDays)&&(identical(other.ownRetentionDays, ownRetentionDays) || other.ownRetentionDays == ownRetentionDays));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,organisationId,name,kind,timezone,armMode,retentionDays,ownRetentionDays);
}

@override
String toString() {
    return 'Site(id: $id, organisationId: $organisationId, name: $name, kind: $kind, timezone: $timezone, armMode: $armMode, retentionDays: $retentionDays, ownRetentionDays: $ownRetentionDays)';
}


}

/// @nodoc
abstract mixin class _$SiteCopyWith<$Res> implements $SiteCopyWith<$Res> {
  factory _$SiteCopyWith(_Site value, $Res Function(_Site) _then) = __$SiteCopyWithImpl;
@override @useResult
$Res call({
 String id, String organisationId, String name, SiteKind kind, String timezone, ArmMode armMode, int retentionDays, int? ownRetentionDays
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organisationId = null,Object? name = null,Object? kind = null,Object? timezone = null,Object? armMode = null,Object? retentionDays = null,Object? ownRetentionDays = freezed,}) {
  return _then(_Site(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organisationId: null == organisationId ? _self.organisationId : organisationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SiteKind,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,armMode: null == armMode ? _self.armMode : armMode // ignore: cast_nullable_to_non_nullable
as ArmMode,retentionDays: null == retentionDays ? _self.retentionDays : retentionDays // ignore: cast_nullable_to_non_nullable
as int,ownRetentionDays: freezed == ownRetentionDays ? _self.ownRetentionDays : ownRetentionDays // ignore: cast_nullable_to_non_nullable
as int?,
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

// dart format on
