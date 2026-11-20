// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitation_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InvitationPreview {


/// Create a copy of InvitationPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitationPreviewCopyWith<InvitationPreview> get copyWith => _$InvitationPreviewCopyWithImpl<InvitationPreview>(this as InvitationPreview, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InvitationPreview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvitationPreview&&(identical(other.organisation, _this.organisation) || other.organisation == _this.organisation)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.invitedBy, _this.invitedBy) || other.invitedBy == _this.invitedBy)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as InvitationPreview;
  return Object.hash(runtimeType,_this.organisation,_this.role,_this.invitedBy,_this.email,_this.status,_this.expiresAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as InvitationPreview;
  return 'InvitationPreview(organisation: ${_this.organisation}, role: ${_this.role}, invitedBy: ${_this.invitedBy}, email: ${_this.email}, status: ${_this.status}, expiresAt: ${_this.expiresAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $InvitationPreviewCopyWith<$Res>  {
  factory $InvitationPreviewCopyWith(InvitationPreview value, $Res Function(InvitationPreview) _then) = _$InvitationPreviewCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String organisation,@JsonKey(required: true, disallowNullValue: true, fromJson: InvitationPreview._read_role, toJson: InvitationPreview._write_role) Role role,@JsonKey(name: "invited_by", required: true) String? invitedBy,@JsonKey(required: true, disallowNullValue: true) String email,@JsonKey(required: true, disallowNullValue: true, fromJson: InvitationPreview._read_status, toJson: InvitationPreview._write_status) InvitationStatus status,@JsonKey(name: "expires_at", required: true, disallowNullValue: true, fromJson: InvitationPreview._read_expiresAt, toJson: InvitationPreview._write_expiresAt) DateTime expiresAt,@JsonKey(readValue: InvitationPreview._extras, fromJson: InvitationPreview._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
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
@pragma('vm:prefer-inline') @override $Res call({Object? organisation = null,Object? role = null,Object? invitedBy = freezed,Object? email = null,Object? status = null,Object? expiresAt = null,Object? additionalProperties = null,}) {
  return _then(InvitationPreview(
organisation: null == organisation ? _self.organisation : organisation // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,invitedBy: freezed == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvitationStatus,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
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
