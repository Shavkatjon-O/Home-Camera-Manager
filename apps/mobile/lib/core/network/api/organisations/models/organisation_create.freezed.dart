// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organisation_create.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrganisationCreate {


/// Create a copy of OrganisationCreate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganisationCreateCopyWith<OrganisationCreate> get copyWith => _$OrganisationCreateCopyWithImpl<OrganisationCreate>(this as OrganisationCreate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrganisationCreate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganisationCreate&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.site, _this.site) || other.site == _this.site)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as OrganisationCreate;
  return Object.hash(runtimeType,_this.name,_this.site,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as OrganisationCreate;
  return 'OrganisationCreate(name: ${_this.name}, site: ${_this.site}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $OrganisationCreateCopyWith<$Res>  {
  factory $OrganisationCreateCopyWith(OrganisationCreate value, $Res Function(OrganisationCreate) _then) = _$OrganisationCreateCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(includeIfNull: false) SiteCreate? site,@JsonKey(readValue: OrganisationCreate._extras, fromJson: OrganisationCreate._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$SiteCreateCopyWith<$Res>? get site;

}
/// @nodoc
class _$OrganisationCreateCopyWithImpl<$Res>
    implements $OrganisationCreateCopyWith<$Res> {
  _$OrganisationCreateCopyWithImpl(this._self, this._then);

  final OrganisationCreate _self;
  final $Res Function(OrganisationCreate) _then;

/// Create a copy of OrganisationCreate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? site = freezed,Object? additionalProperties = null,}) {
  return _then(OrganisationCreate(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,site: freezed == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as SiteCreate?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of OrganisationCreate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SiteCreateCopyWith<$Res>? get site {
    if (_self.site == null) {
    return null;
  }

  return $SiteCreateCopyWith<$Res>(_self.site!, (value) {
    return _then(_self.copyWith(site: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrganisationCreate].
extension OrganisationCreatePatterns on OrganisationCreate {
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
