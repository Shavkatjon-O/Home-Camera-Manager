// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitation_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InvitationRead {


/// Create a copy of InvitationRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitationReadCopyWith<InvitationRead> get copyWith => _$InvitationReadCopyWithImpl<InvitationRead>(this as InvitationRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InvitationRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvitationRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.allSites, _this.allSites) || other.allSites == _this.allSites)&&const DeepCollectionEquality().equals(other.sites, _this.sites)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.invitedBy, _this.invitedBy) || other.invitedBy == _this.invitedBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.acceptedAt, _this.acceptedAt) || other.acceptedAt == _this.acceptedAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as InvitationRead;
  return Object.hash(runtimeType,_this.uuid,_this.email,_this.role,_this.allSites,const DeepCollectionEquality().hash(_this.sites),_this.status,_this.expiresAt,_this.invitedBy,_this.createdAt,_this.acceptedAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as InvitationRead;
  return 'InvitationRead(uuid: ${_this.uuid}, email: ${_this.email}, role: ${_this.role}, allSites: ${_this.allSites}, sites: ${_this.sites}, status: ${_this.status}, expiresAt: ${_this.expiresAt}, invitedBy: ${_this.invitedBy}, createdAt: ${_this.createdAt}, acceptedAt: ${_this.acceptedAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $InvitationReadCopyWith<$Res>  {
  factory $InvitationReadCopyWith(InvitationRead value, $Res Function(InvitationRead) _then) = _$InvitationReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String email,@JsonKey(required: true, disallowNullValue: true, fromJson: InvitationRead._read_role, toJson: InvitationRead._write_role) Role role,@JsonKey(name: "all_sites", required: true, disallowNullValue: true) bool allSites,@JsonKey(required: true, disallowNullValue: true) List<String> sites,@JsonKey(required: true, disallowNullValue: true, fromJson: InvitationRead._read_status, toJson: InvitationRead._write_status) InvitationStatus status,@JsonKey(name: "expires_at", required: true, disallowNullValue: true, fromJson: InvitationRead._read_expiresAt, toJson: InvitationRead._write_expiresAt) DateTime expiresAt,@JsonKey(name: "invited_by", required: true) String? invitedBy,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: InvitationRead._read_createdAt, toJson: InvitationRead._write_createdAt) DateTime createdAt,@JsonKey(name: "accepted_at", required: true, fromJson: InvitationRead._read_acceptedAt, toJson: InvitationRead._write_acceptedAt) DateTime? acceptedAt,@JsonKey(readValue: InvitationRead._extras, fromJson: InvitationRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$InvitationReadCopyWithImpl<$Res>
    implements $InvitationReadCopyWith<$Res> {
  _$InvitationReadCopyWithImpl(this._self, this._then);

  final InvitationRead _self;
  final $Res Function(InvitationRead) _then;

/// Create a copy of InvitationRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? email = null,Object? role = null,Object? allSites = null,Object? sites = null,Object? status = null,Object? expiresAt = null,Object? invitedBy = freezed,Object? createdAt = null,Object? acceptedAt = freezed,Object? additionalProperties = null,}) {
  return _then(InvitationRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,allSites: null == allSites ? _self.allSites : allSites // ignore: cast_nullable_to_non_nullable
as bool,sites: null == sites ? _self.sites : sites // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvitationStatus,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,invitedBy: freezed == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [InvitationRead].
extension InvitationReadPatterns on InvitationRead {
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
