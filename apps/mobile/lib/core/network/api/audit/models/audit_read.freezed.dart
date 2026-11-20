// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuditRead {


/// Create a copy of AuditRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditReadCopyWith<AuditRead> get copyWith => _$AuditReadCopyWithImpl<AuditRead>(this as AuditRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AuditRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.at, _this.at) || other.at == _this.at)&&(identical(other.action, _this.action) || other.action == _this.action)&&(identical(other.actor, _this.actor) || other.actor == _this.actor)&&(identical(other.organisation, _this.organisation) || other.organisation == _this.organisation)&&(identical(other.site, _this.site) || other.site == _this.site)&&(identical(other.targetKind, _this.targetKind) || other.targetKind == _this.targetKind)&&(identical(other.targetUuid, _this.targetUuid) || other.targetUuid == _this.targetUuid)&&const DeepCollectionEquality().equals(other.details, _this.details)&&(identical(other.ip, _this.ip) || other.ip == _this.ip)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as AuditRead;
  return Object.hash(runtimeType,_this.uuid,_this.at,_this.action,_this.actor,_this.organisation,_this.site,_this.targetKind,_this.targetUuid,const DeepCollectionEquality().hash(_this.details),_this.ip,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as AuditRead;
  return 'AuditRead(uuid: ${_this.uuid}, at: ${_this.at}, action: ${_this.action}, actor: ${_this.actor}, organisation: ${_this.organisation}, site: ${_this.site}, targetKind: ${_this.targetKind}, targetUuid: ${_this.targetUuid}, details: ${_this.details}, ip: ${_this.ip}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $AuditReadCopyWith<$Res>  {
  factory $AuditReadCopyWith(AuditRead value, $Res Function(AuditRead) _then) = _$AuditReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true, fromJson: AuditRead._read_at, toJson: AuditRead._write_at) DateTime at,@JsonKey(required: true, disallowNullValue: true) String action,@JsonKey(required: true) String? actor,@JsonKey(required: true) String? organisation,@JsonKey(required: true) String? site,@JsonKey(name: "target_kind", required: true) String? targetKind,@JsonKey(name: "target_uuid", required: true) String? targetUuid,@JsonKey(required: true, disallowNullValue: true) Map<String, Object?> details,@JsonKey(required: true) String? ip,@JsonKey(readValue: AuditRead._extras, fromJson: AuditRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$AuditReadCopyWithImpl<$Res>
    implements $AuditReadCopyWith<$Res> {
  _$AuditReadCopyWithImpl(this._self, this._then);

  final AuditRead _self;
  final $Res Function(AuditRead) _then;

/// Create a copy of AuditRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? at = null,Object? action = null,Object? actor = freezed,Object? organisation = freezed,Object? site = freezed,Object? targetKind = freezed,Object? targetUuid = freezed,Object? details = null,Object? ip = freezed,Object? additionalProperties = null,}) {
  return _then(AuditRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as String?,organisation: freezed == organisation ? _self.organisation : organisation // ignore: cast_nullable_to_non_nullable
as String?,site: freezed == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as String?,targetKind: freezed == targetKind ? _self.targetKind : targetKind // ignore: cast_nullable_to_non_nullable
as String?,targetUuid: freezed == targetUuid ? _self.targetUuid : targetUuid // ignore: cast_nullable_to_non_nullable
as String?,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,ip: freezed == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditRead].
extension AuditReadPatterns on AuditRead {
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
