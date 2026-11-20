// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organisation_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrganisationUpdate {


/// Create a copy of OrganisationUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganisationUpdateCopyWith<OrganisationUpdate> get copyWith => _$OrganisationUpdateCopyWithImpl<OrganisationUpdate>(this as OrganisationUpdate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrganisationUpdate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganisationUpdate&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.facesEnabled, _this.facesEnabled) || other.facesEnabled == _this.facesEnabled)&&(identical(other.facesConsent, _this.facesConsent) || other.facesConsent == _this.facesConsent)&&(identical(other.consentVersion, _this.consentVersion) || other.consentVersion == _this.consentVersion)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as OrganisationUpdate;
  return Object.hash(runtimeType,_this.name,_this.facesEnabled,_this.facesConsent,_this.consentVersion,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as OrganisationUpdate;
  return 'OrganisationUpdate(name: ${_this.name}, facesEnabled: ${_this.facesEnabled}, facesConsent: ${_this.facesConsent}, consentVersion: ${_this.consentVersion}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $OrganisationUpdateCopyWith<$Res>  {
  factory $OrganisationUpdateCopyWith(OrganisationUpdate value, $Res Function(OrganisationUpdate) _then) = _$OrganisationUpdateCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? name,@JsonKey(name: "faces_enabled", includeIfNull: false) bool? facesEnabled,@JsonKey(name: "faces_consent", includeIfNull: false) bool? facesConsent,@JsonKey(name: "consent_version", includeIfNull: false) String? consentVersion,@JsonKey(readValue: OrganisationUpdate._extras, fromJson: OrganisationUpdate._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$OrganisationUpdateCopyWithImpl<$Res>
    implements $OrganisationUpdateCopyWith<$Res> {
  _$OrganisationUpdateCopyWithImpl(this._self, this._then);

  final OrganisationUpdate _self;
  final $Res Function(OrganisationUpdate) _then;

/// Create a copy of OrganisationUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? facesEnabled = freezed,Object? facesConsent = freezed,Object? consentVersion = freezed,Object? additionalProperties = null,}) {
  return _then(OrganisationUpdate(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,facesEnabled: freezed == facesEnabled ? _self.facesEnabled : facesEnabled // ignore: cast_nullable_to_non_nullable
as bool?,facesConsent: freezed == facesConsent ? _self.facesConsent : facesConsent // ignore: cast_nullable_to_non_nullable
as bool?,consentVersion: freezed == consentVersion ? _self.consentVersion : consentVersion // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganisationUpdate].
extension OrganisationUpdatePatterns on OrganisationUpdate {
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
