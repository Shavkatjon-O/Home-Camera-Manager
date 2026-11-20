// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facets.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Facets {


/// Create a copy of Facets
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacetsCopyWith<Facets> get copyWith => _$FacetsCopyWithImpl<Facets>(this as Facets, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Facets;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Facets&&const DeepCollectionEquality().equals(other.kinds, _this.kinds)&&const DeepCollectionEquality().equals(other.labels, _this.labels)&&const DeepCollectionEquality().equals(other.views, _this.views)&&const DeepCollectionEquality().equals(other.zones, _this.zones)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&const DeepCollectionEquality().equals(other.people, _this.people)&&const DeepCollectionEquality().equals(other.clusters, _this.clusters)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as Facets;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.kinds),const DeepCollectionEquality().hash(_this.labels),const DeepCollectionEquality().hash(_this.views),const DeepCollectionEquality().hash(_this.zones),const DeepCollectionEquality().hash(_this.lines),const DeepCollectionEquality().hash(_this.people),const DeepCollectionEquality().hash(_this.clusters),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as Facets;
  return 'Facets(kinds: ${_this.kinds}, labels: ${_this.labels}, views: ${_this.views}, zones: ${_this.zones}, lines: ${_this.lines}, people: ${_this.people}, clusters: ${_this.clusters}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $FacetsCopyWith<$Res>  {
  factory $FacetsCopyWith(Facets value, $Res Function(Facets) _then) = _$FacetsCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) List<String> kinds,@JsonKey(required: true, disallowNullValue: true) List<String> labels,@JsonKey(required: true, disallowNullValue: true) List<ViewFacet> views,@JsonKey(required: true, disallowNullValue: true) List<ZoneFacet> zones,@JsonKey(required: true, disallowNullValue: true) List<LineFacet> lines,@JsonKey(required: true, disallowNullValue: true) List<PersonFacet> people,@JsonKey(required: true, disallowNullValue: true) List<ClusterFacet> clusters,@JsonKey(readValue: Facets._extras, fromJson: Facets._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$FacetsCopyWithImpl<$Res>
    implements $FacetsCopyWith<$Res> {
  _$FacetsCopyWithImpl(this._self, this._then);

  final Facets _self;
  final $Res Function(Facets) _then;

/// Create a copy of Facets
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kinds = null,Object? labels = null,Object? views = null,Object? zones = null,Object? lines = null,Object? people = null,Object? clusters = null,Object? additionalProperties = null,}) {
  return _then(Facets(
kinds: null == kinds ? _self.kinds : kinds // ignore: cast_nullable_to_non_nullable
as List<String>,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,views: null == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as List<ViewFacet>,zones: null == zones ? _self.zones : zones // ignore: cast_nullable_to_non_nullable
as List<ZoneFacet>,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<LineFacet>,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as List<PersonFacet>,clusters: null == clusters ? _self.clusters : clusters // ignore: cast_nullable_to_non_nullable
as List<ClusterFacet>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [Facets].
extension FacetsPatterns on Facets {
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
