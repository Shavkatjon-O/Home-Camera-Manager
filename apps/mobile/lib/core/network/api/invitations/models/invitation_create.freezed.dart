// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitation_create.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InvitationCreate {


/// Create a copy of InvitationCreate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitationCreateCopyWith<InvitationCreate> get copyWith => _$InvitationCreateCopyWithImpl<InvitationCreate>(this as InvitationCreate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InvitationCreate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvitationCreate&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.allSites, _this.allSites) || other.allSites == _this.allSites)&&const DeepCollectionEquality().equals(other.sites, _this.sites)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as InvitationCreate;
  return Object.hash(runtimeType,_this.email,_this.role,_this.allSites,const DeepCollectionEquality().hash(_this.sites),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as InvitationCreate;
  return 'InvitationCreate(email: ${_this.email}, role: ${_this.role}, allSites: ${_this.allSites}, sites: ${_this.sites}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $InvitationCreateCopyWith<$Res>  {
  factory $InvitationCreateCopyWith(InvitationCreate value, $Res Function(InvitationCreate) _then) = _$InvitationCreateCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String email,@JsonKey(disallowNullValue: true, readValue: InvitationCreate._presentValue, fromJson: InvitationCreate._read_role, toJson: InvitationCreate._write_role) Role role,@JsonKey(name: "all_sites", disallowNullValue: true, readValue: InvitationCreate._presentValue, fromJson: InvitationCreate._read_allSites, toJson: InvitationCreate._write_allSites) bool allSites,@JsonKey(disallowNullValue: true, includeIfNull: false) List<String>? sites,@JsonKey(readValue: InvitationCreate._extras, fromJson: InvitationCreate._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$InvitationCreateCopyWithImpl<$Res>
    implements $InvitationCreateCopyWith<$Res> {
  _$InvitationCreateCopyWithImpl(this._self, this._then);

  final InvitationCreate _self;
  final $Res Function(InvitationCreate) _then;

/// Create a copy of InvitationCreate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? role = null,Object? allSites = null,Object? sites = freezed,Object? additionalProperties = null,}) {
  return _then(InvitationCreate(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,allSites: null == allSites ? _self.allSites : allSites // ignore: cast_nullable_to_non_nullable
as bool,sites: freezed == sites ? _self.sites : sites // ignore: cast_nullable_to_non_nullable
as List<String>?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [InvitationCreate].
extension InvitationCreatePatterns on InvitationCreate {
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
