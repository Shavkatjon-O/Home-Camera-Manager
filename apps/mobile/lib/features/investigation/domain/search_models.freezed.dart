// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchFacets {

 List<FacetItem> get views; List<FacetItem> get zones; List<FacetItem> get lines; List<FacetItem> get people; List<FacetItem> get clusters; List<String> get labels;
/// Create a copy of SearchFacets
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchFacetsCopyWith<SearchFacets> get copyWith => _$SearchFacetsCopyWithImpl<SearchFacets>(this as SearchFacets, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchFacets;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchFacets&&const DeepCollectionEquality().equals(other.views, _this.views)&&const DeepCollectionEquality().equals(other.zones, _this.zones)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&const DeepCollectionEquality().equals(other.people, _this.people)&&const DeepCollectionEquality().equals(other.clusters, _this.clusters)&&const DeepCollectionEquality().equals(other.labels, _this.labels));
}


@override
int get hashCode {
  final _this = this as SearchFacets;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.views),const DeepCollectionEquality().hash(_this.zones),const DeepCollectionEquality().hash(_this.lines),const DeepCollectionEquality().hash(_this.people),const DeepCollectionEquality().hash(_this.clusters),const DeepCollectionEquality().hash(_this.labels));
}

@override
String toString() {
  final _this = this as SearchFacets;
  return 'SearchFacets(views: ${_this.views}, zones: ${_this.zones}, lines: ${_this.lines}, people: ${_this.people}, clusters: ${_this.clusters}, labels: ${_this.labels})';
}


}

/// @nodoc
abstract mixin class $SearchFacetsCopyWith<$Res>  {
  factory $SearchFacetsCopyWith(SearchFacets value, $Res Function(SearchFacets) _then) = _$SearchFacetsCopyWithImpl;
@useResult
$Res call({
 List<FacetItem> views, List<FacetItem> zones, List<FacetItem> lines, List<FacetItem> people, List<FacetItem> clusters, List<String> labels
});




}
/// @nodoc
class _$SearchFacetsCopyWithImpl<$Res>
    implements $SearchFacetsCopyWith<$Res> {
  _$SearchFacetsCopyWithImpl(this._self, this._then);

  final SearchFacets _self;
  final $Res Function(SearchFacets) _then;

/// Create a copy of SearchFacets
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? views = null,Object? zones = null,Object? lines = null,Object? people = null,Object? clusters = null,Object? labels = null,}) {
  return _then(SearchFacets(
views: null == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as List<FacetItem>,zones: null == zones ? _self.zones : zones // ignore: cast_nullable_to_non_nullable
as List<FacetItem>,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<FacetItem>,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as List<FacetItem>,clusters: null == clusters ? _self.clusters : clusters // ignore: cast_nullable_to_non_nullable
as List<FacetItem>,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchFacets].
extension SearchFacetsPatterns on SearchFacets {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchFacets value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchFacets() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchFacets value)  $default,){
final _that = this;
switch (_that) {
case _SearchFacets():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchFacets value)?  $default,){
final _that = this;
switch (_that) {
case _SearchFacets() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FacetItem> views,  List<FacetItem> zones,  List<FacetItem> lines,  List<FacetItem> people,  List<FacetItem> clusters,  List<String> labels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchFacets() when $default != null:
return $default(_that.views,_that.zones,_that.lines,_that.people,_that.clusters,_that.labels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FacetItem> views,  List<FacetItem> zones,  List<FacetItem> lines,  List<FacetItem> people,  List<FacetItem> clusters,  List<String> labels)  $default,) {final _that = this;
switch (_that) {
case _SearchFacets():
return $default(_that.views,_that.zones,_that.lines,_that.people,_that.clusters,_that.labels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FacetItem> views,  List<FacetItem> zones,  List<FacetItem> lines,  List<FacetItem> people,  List<FacetItem> clusters,  List<String> labels)?  $default,) {final _that = this;
switch (_that) {
case _SearchFacets() when $default != null:
return $default(_that.views,_that.zones,_that.lines,_that.people,_that.clusters,_that.labels);case _:
  return null;

}
}

}

/// @nodoc


class _SearchFacets implements SearchFacets {
  const _SearchFacets({ List<FacetItem> views = const <FacetItem>[],  List<FacetItem> zones = const <FacetItem>[],  List<FacetItem> lines = const <FacetItem>[],  List<FacetItem> people = const <FacetItem>[],  List<FacetItem> clusters = const <FacetItem>[],  List<String> labels = const <String>[]}): _views = views,_zones = zones,_lines = lines,_people = people,_clusters = clusters,_labels = labels;
  

 final  List<FacetItem> _views;
@override@JsonKey() List<FacetItem> get views {
  if (_views is EqualUnmodifiableListView) return _views;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_views);
}

 final  List<FacetItem> _zones;
@override@JsonKey() List<FacetItem> get zones {
  if (_zones is EqualUnmodifiableListView) return _zones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_zones);
}

 final  List<FacetItem> _lines;
@override@JsonKey() List<FacetItem> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

 final  List<FacetItem> _people;
@override@JsonKey() List<FacetItem> get people {
  if (_people is EqualUnmodifiableListView) return _people;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_people);
}

 final  List<FacetItem> _clusters;
@override@JsonKey() List<FacetItem> get clusters {
  if (_clusters is EqualUnmodifiableListView) return _clusters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clusters);
}

 final  List<String> _labels;
@override@JsonKey() List<String> get labels {
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labels);
}


/// Create a copy of SearchFacets
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchFacetsCopyWith<_SearchFacets> get copyWith => __$SearchFacetsCopyWithImpl<_SearchFacets>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchFacets&&const DeepCollectionEquality().equals(other.views, _views)&&const DeepCollectionEquality().equals(other.zones, _zones)&&const DeepCollectionEquality().equals(other.lines, _lines)&&const DeepCollectionEquality().equals(other.people, _people)&&const DeepCollectionEquality().equals(other.clusters, _clusters)&&const DeepCollectionEquality().equals(other.labels, _labels));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_views),const DeepCollectionEquality().hash(_zones),const DeepCollectionEquality().hash(_lines),const DeepCollectionEquality().hash(_people),const DeepCollectionEquality().hash(_clusters),const DeepCollectionEquality().hash(_labels));
}

@override
String toString() {
    return 'SearchFacets(views: $views, zones: $zones, lines: $lines, people: $people, clusters: $clusters, labels: $labels)';
}


}

/// @nodoc
abstract mixin class _$SearchFacetsCopyWith<$Res> implements $SearchFacetsCopyWith<$Res> {
  factory _$SearchFacetsCopyWith(_SearchFacets value, $Res Function(_SearchFacets) _then) = __$SearchFacetsCopyWithImpl;
@override @useResult
$Res call({
 List<FacetItem> views, List<FacetItem> zones, List<FacetItem> lines, List<FacetItem> people, List<FacetItem> clusters, List<String> labels
});




}
/// @nodoc
class __$SearchFacetsCopyWithImpl<$Res>
    implements _$SearchFacetsCopyWith<$Res> {
  __$SearchFacetsCopyWithImpl(this._self, this._then);

  final _SearchFacets _self;
  final $Res Function(_SearchFacets) _then;

/// Create a copy of SearchFacets
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? views = null,Object? zones = null,Object? lines = null,Object? people = null,Object? clusters = null,Object? labels = null,}) {
  return _then(_SearchFacets(
views: null == views ? _self._views : views // ignore: cast_nullable_to_non_nullable
as List<FacetItem>,zones: null == zones ? _self._zones : zones // ignore: cast_nullable_to_non_nullable
as List<FacetItem>,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<FacetItem>,people: null == people ? _self._people : people // ignore: cast_nullable_to_non_nullable
as List<FacetItem>,clusters: null == clusters ? _self._clusters : clusters // ignore: cast_nullable_to_non_nullable
as List<FacetItem>,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$FacetItem {

 String get id; String get name; String? get detail;
/// Create a copy of FacetItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacetItemCopyWith<FacetItem> get copyWith => _$FacetItemCopyWithImpl<FacetItem>(this as FacetItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FacetItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FacetItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.detail, _this.detail) || other.detail == _this.detail));
}


@override
int get hashCode {
  final _this = this as FacetItem;
  return Object.hash(runtimeType,_this.id,_this.name,_this.detail);
}

@override
String toString() {
  final _this = this as FacetItem;
  return 'FacetItem(id: ${_this.id}, name: ${_this.name}, detail: ${_this.detail})';
}


}

/// @nodoc
abstract mixin class $FacetItemCopyWith<$Res>  {
  factory $FacetItemCopyWith(FacetItem value, $Res Function(FacetItem) _then) = _$FacetItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? detail
});




}
/// @nodoc
class _$FacetItemCopyWithImpl<$Res>
    implements $FacetItemCopyWith<$Res> {
  _$FacetItemCopyWithImpl(this._self, this._then);

  final FacetItem _self;
  final $Res Function(FacetItem) _then;

/// Create a copy of FacetItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? detail = freezed,}) {
  return _then(FacetItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FacetItem].
extension FacetItemPatterns on FacetItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FacetItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FacetItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FacetItem value)  $default,){
final _that = this;
switch (_that) {
case _FacetItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FacetItem value)?  $default,){
final _that = this;
switch (_that) {
case _FacetItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FacetItem() when $default != null:
return $default(_that.id,_that.name,_that.detail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? detail)  $default,) {final _that = this;
switch (_that) {
case _FacetItem():
return $default(_that.id,_that.name,_that.detail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? detail)?  $default,) {final _that = this;
switch (_that) {
case _FacetItem() when $default != null:
return $default(_that.id,_that.name,_that.detail);case _:
  return null;

}
}

}

/// @nodoc


class _FacetItem implements FacetItem {
  const _FacetItem({required this.id, required this.name, this.detail});
  

@override final  String id;
@override final  String name;
@override final  String? detail;

/// Create a copy of FacetItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacetItemCopyWith<_FacetItem> get copyWith => __$FacetItemCopyWithImpl<_FacetItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FacetItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,detail);
}

@override
String toString() {
    return 'FacetItem(id: $id, name: $name, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$FacetItemCopyWith<$Res> implements $FacetItemCopyWith<$Res> {
  factory _$FacetItemCopyWith(_FacetItem value, $Res Function(_FacetItem) _then) = __$FacetItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? detail
});




}
/// @nodoc
class __$FacetItemCopyWithImpl<$Res>
    implements _$FacetItemCopyWith<$Res> {
  __$FacetItemCopyWithImpl(this._self, this._then);

  final _FacetItem _self;
  final $Res Function(_FacetItem) _then;

/// Create a copy of FacetItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? detail = freezed,}) {
  return _then(_FacetItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
