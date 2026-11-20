// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organisation_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrganisationRead {


/// Create a copy of OrganisationRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganisationReadCopyWith<OrganisationRead> get copyWith => _$OrganisationReadCopyWithImpl<OrganisationRead>(this as OrganisationRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrganisationRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganisationRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.facesEnabled, _this.facesEnabled) || other.facesEnabled == _this.facesEnabled)&&(identical(other.facesConsentAt, _this.facesConsentAt) || other.facesConsentAt == _this.facesConsentAt)&&(identical(other.siteCount, _this.siteCount) || other.siteCount == _this.siteCount)&&(identical(other.memberCount, _this.memberCount) || other.memberCount == _this.memberCount)&&const DeepCollectionEquality().equals(other.sites, _this.sites)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as OrganisationRead;
  return Object.hash(runtimeType,_this.uuid,_this.name,_this.role,_this.facesEnabled,_this.facesConsentAt,_this.siteCount,_this.memberCount,const DeepCollectionEquality().hash(_this.sites),_this.createdAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as OrganisationRead;
  return 'OrganisationRead(uuid: ${_this.uuid}, name: ${_this.name}, role: ${_this.role}, facesEnabled: ${_this.facesEnabled}, facesConsentAt: ${_this.facesConsentAt}, siteCount: ${_this.siteCount}, memberCount: ${_this.memberCount}, sites: ${_this.sites}, createdAt: ${_this.createdAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $OrganisationReadCopyWith<$Res>  {
  factory $OrganisationReadCopyWith(OrganisationRead value, $Res Function(OrganisationRead) _then) = _$OrganisationReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true, disallowNullValue: true, fromJson: OrganisationRead._read_role, toJson: OrganisationRead._write_role) Role role,@JsonKey(name: "faces_enabled", required: true, disallowNullValue: true) bool facesEnabled,@JsonKey(name: "faces_consent_at", required: true, fromJson: OrganisationRead._read_facesConsentAt, toJson: OrganisationRead._write_facesConsentAt) DateTime? facesConsentAt,@JsonKey(name: "site_count", required: true, disallowNullValue: true, fromJson: OrganisationRead._read_siteCount, toJson: OrganisationRead._write_siteCount) int siteCount,@JsonKey(name: "member_count", required: true, disallowNullValue: true, fromJson: OrganisationRead._read_memberCount, toJson: OrganisationRead._write_memberCount) int memberCount,@JsonKey(required: true, disallowNullValue: true) List<SiteRead> sites,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: OrganisationRead._read_createdAt, toJson: OrganisationRead._write_createdAt) DateTime createdAt,@JsonKey(readValue: OrganisationRead._extras, fromJson: OrganisationRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$OrganisationReadCopyWithImpl<$Res>
    implements $OrganisationReadCopyWith<$Res> {
  _$OrganisationReadCopyWithImpl(this._self, this._then);

  final OrganisationRead _self;
  final $Res Function(OrganisationRead) _then;

/// Create a copy of OrganisationRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? name = null,Object? role = null,Object? facesEnabled = null,Object? facesConsentAt = freezed,Object? siteCount = null,Object? memberCount = null,Object? sites = null,Object? createdAt = null,Object? additionalProperties = null,}) {
  return _then(OrganisationRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,facesEnabled: null == facesEnabled ? _self.facesEnabled : facesEnabled // ignore: cast_nullable_to_non_nullable
as bool,facesConsentAt: freezed == facesConsentAt ? _self.facesConsentAt : facesConsentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,siteCount: null == siteCount ? _self.siteCount : siteCount // ignore: cast_nullable_to_non_nullable
as int,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,sites: null == sites ? _self.sites : sites // ignore: cast_nullable_to_non_nullable
as List<SiteRead>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganisationRead].
extension OrganisationReadPatterns on OrganisationRead {
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
