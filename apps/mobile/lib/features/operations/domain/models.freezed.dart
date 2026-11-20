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
mixin _$AuditEntry {

 String get id; DateTime get at; String get actor; String get action; AuditCategory get category; String? get target; String? get siteName;
/// Create a copy of AuditEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditEntryCopyWith<AuditEntry> get copyWith => _$AuditEntryCopyWithImpl<AuditEntry>(this as AuditEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AuditEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.at, _this.at) || other.at == _this.at)&&(identical(other.actor, _this.actor) || other.actor == _this.actor)&&(identical(other.action, _this.action) || other.action == _this.action)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.target, _this.target) || other.target == _this.target)&&(identical(other.siteName, _this.siteName) || other.siteName == _this.siteName));
}


@override
int get hashCode {
  final _this = this as AuditEntry;
  return Object.hash(runtimeType,_this.id,_this.at,_this.actor,_this.action,_this.category,_this.target,_this.siteName);
}

@override
String toString() {
  final _this = this as AuditEntry;
  return 'AuditEntry(id: ${_this.id}, at: ${_this.at}, actor: ${_this.actor}, action: ${_this.action}, category: ${_this.category}, target: ${_this.target}, siteName: ${_this.siteName})';
}


}

/// @nodoc
abstract mixin class $AuditEntryCopyWith<$Res>  {
  factory $AuditEntryCopyWith(AuditEntry value, $Res Function(AuditEntry) _then) = _$AuditEntryCopyWithImpl;
@useResult
$Res call({
 String id, DateTime at, String actor, String action, AuditCategory category, String? target, String? siteName
});




}
/// @nodoc
class _$AuditEntryCopyWithImpl<$Res>
    implements $AuditEntryCopyWith<$Res> {
  _$AuditEntryCopyWithImpl(this._self, this._then);

  final AuditEntry _self;
  final $Res Function(AuditEntry) _then;

/// Create a copy of AuditEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? at = null,Object? actor = null,Object? action = null,Object? category = null,Object? target = freezed,Object? siteName = freezed,}) {
  return _then(AuditEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,actor: null == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AuditCategory,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String?,siteName: freezed == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditEntry].
extension AuditEntryPatterns on AuditEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditEntry value)  $default,){
final _that = this;
switch (_that) {
case _AuditEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AuditEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime at,  String actor,  String action,  AuditCategory category,  String? target,  String? siteName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditEntry() when $default != null:
return $default(_that.id,_that.at,_that.actor,_that.action,_that.category,_that.target,_that.siteName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime at,  String actor,  String action,  AuditCategory category,  String? target,  String? siteName)  $default,) {final _that = this;
switch (_that) {
case _AuditEntry():
return $default(_that.id,_that.at,_that.actor,_that.action,_that.category,_that.target,_that.siteName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime at,  String actor,  String action,  AuditCategory category,  String? target,  String? siteName)?  $default,) {final _that = this;
switch (_that) {
case _AuditEntry() when $default != null:
return $default(_that.id,_that.at,_that.actor,_that.action,_that.category,_that.target,_that.siteName);case _:
  return null;

}
}

}

/// @nodoc


class _AuditEntry implements AuditEntry {
  const _AuditEntry({required this.id, required this.at, required this.actor, required this.action, required this.category, this.target, this.siteName});
  

@override final  String id;
@override final  DateTime at;
@override final  String actor;
@override final  String action;
@override final  AuditCategory category;
@override final  String? target;
@override final  String? siteName;

/// Create a copy of AuditEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditEntryCopyWith<_AuditEntry> get copyWith => __$AuditEntryCopyWithImpl<_AuditEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.at, at) || other.at == at)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.action, action) || other.action == action)&&(identical(other.category, category) || other.category == category)&&(identical(other.target, target) || other.target == target)&&(identical(other.siteName, siteName) || other.siteName == siteName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,at,actor,action,category,target,siteName);
}

@override
String toString() {
    return 'AuditEntry(id: $id, at: $at, actor: $actor, action: $action, category: $category, target: $target, siteName: $siteName)';
}


}

/// @nodoc
abstract mixin class _$AuditEntryCopyWith<$Res> implements $AuditEntryCopyWith<$Res> {
  factory _$AuditEntryCopyWith(_AuditEntry value, $Res Function(_AuditEntry) _then) = __$AuditEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime at, String actor, String action, AuditCategory category, String? target, String? siteName
});




}
/// @nodoc
class __$AuditEntryCopyWithImpl<$Res>
    implements _$AuditEntryCopyWith<$Res> {
  __$AuditEntryCopyWithImpl(this._self, this._then);

  final _AuditEntry _self;
  final $Res Function(_AuditEntry) _then;

/// Create a copy of AuditEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? at = null,Object? actor = null,Object? action = null,Object? category = null,Object? target = freezed,Object? siteName = freezed,}) {
  return _then(_AuditEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,actor: null == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AuditCategory,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String?,siteName: freezed == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AuditPage {

 List<AuditEntry> get items; int get total; int get page;
/// Create a copy of AuditPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditPageCopyWith<AuditPage> get copyWith => _$AuditPageCopyWithImpl<AuditPage>(this as AuditPage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AuditPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditPage&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.page, _this.page) || other.page == _this.page));
}


@override
int get hashCode {
  final _this = this as AuditPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.total,_this.page);
}

@override
String toString() {
  final _this = this as AuditPage;
  return 'AuditPage(items: ${_this.items}, total: ${_this.total}, page: ${_this.page})';
}


}

/// @nodoc
abstract mixin class $AuditPageCopyWith<$Res>  {
  factory $AuditPageCopyWith(AuditPage value, $Res Function(AuditPage) _then) = _$AuditPageCopyWithImpl;
@useResult
$Res call({
 List<AuditEntry> items, int total, int page
});




}
/// @nodoc
class _$AuditPageCopyWithImpl<$Res>
    implements $AuditPageCopyWith<$Res> {
  _$AuditPageCopyWithImpl(this._self, this._then);

  final AuditPage _self;
  final $Res Function(AuditPage) _then;

/// Create a copy of AuditPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? page = null,}) {
  return _then(AuditPage(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AuditEntry>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditPage].
extension AuditPagePatterns on AuditPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditPage value)  $default,){
final _that = this;
switch (_that) {
case _AuditPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditPage value)?  $default,){
final _that = this;
switch (_that) {
case _AuditPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AuditEntry> items,  int total,  int page)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditPage() when $default != null:
return $default(_that.items,_that.total,_that.page);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AuditEntry> items,  int total,  int page)  $default,) {final _that = this;
switch (_that) {
case _AuditPage():
return $default(_that.items,_that.total,_that.page);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AuditEntry> items,  int total,  int page)?  $default,) {final _that = this;
switch (_that) {
case _AuditPage() when $default != null:
return $default(_that.items,_that.total,_that.page);case _:
  return null;

}
}

}

/// @nodoc


class _AuditPage implements AuditPage {
  const _AuditPage({required  List<AuditEntry> items, required this.total, required this.page}): _items = items;
  

 final  List<AuditEntry> _items;
@override List<AuditEntry> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;
@override final  int page;

/// Create a copy of AuditPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditPageCopyWith<_AuditPage> get copyWith => __$AuditPageCopyWithImpl<_AuditPage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditPage&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,page);
}

@override
String toString() {
    return 'AuditPage(items: $items, total: $total, page: $page)';
}


}

/// @nodoc
abstract mixin class _$AuditPageCopyWith<$Res> implements $AuditPageCopyWith<$Res> {
  factory _$AuditPageCopyWith(_AuditPage value, $Res Function(_AuditPage) _then) = __$AuditPageCopyWithImpl;
@override @useResult
$Res call({
 List<AuditEntry> items, int total, int page
});




}
/// @nodoc
class __$AuditPageCopyWithImpl<$Res>
    implements _$AuditPageCopyWith<$Res> {
  __$AuditPageCopyWithImpl(this._self, this._then);

  final _AuditPage _self;
  final $Res Function(_AuditPage) _then;

/// Create a copy of AuditPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? page = null,}) {
  return _then(_AuditPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AuditEntry>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$HealthBucket {

 DateTime get start; double? get availability; double? get latencyMs;
/// Create a copy of HealthBucket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthBucketCopyWith<HealthBucket> get copyWith => _$HealthBucketCopyWithImpl<HealthBucket>(this as HealthBucket, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HealthBucket;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthBucket&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.availability, _this.availability) || other.availability == _this.availability)&&(identical(other.latencyMs, _this.latencyMs) || other.latencyMs == _this.latencyMs));
}


@override
int get hashCode {
  final _this = this as HealthBucket;
  return Object.hash(runtimeType,_this.start,_this.availability,_this.latencyMs);
}

@override
String toString() {
  final _this = this as HealthBucket;
  return 'HealthBucket(start: ${_this.start}, availability: ${_this.availability}, latencyMs: ${_this.latencyMs})';
}


}

/// @nodoc
abstract mixin class $HealthBucketCopyWith<$Res>  {
  factory $HealthBucketCopyWith(HealthBucket value, $Res Function(HealthBucket) _then) = _$HealthBucketCopyWithImpl;
@useResult
$Res call({
 DateTime start, double? availability, double? latencyMs
});




}
/// @nodoc
class _$HealthBucketCopyWithImpl<$Res>
    implements $HealthBucketCopyWith<$Res> {
  _$HealthBucketCopyWithImpl(this._self, this._then);

  final HealthBucket _self;
  final $Res Function(HealthBucket) _then;

/// Create a copy of HealthBucket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? availability = freezed,Object? latencyMs = freezed,}) {
  return _then(HealthBucket(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,availability: freezed == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as double?,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthBucket].
extension HealthBucketPatterns on HealthBucket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthBucket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthBucket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthBucket value)  $default,){
final _that = this;
switch (_that) {
case _HealthBucket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthBucket value)?  $default,){
final _that = this;
switch (_that) {
case _HealthBucket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime start,  double? availability,  double? latencyMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthBucket() when $default != null:
return $default(_that.start,_that.availability,_that.latencyMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime start,  double? availability,  double? latencyMs)  $default,) {final _that = this;
switch (_that) {
case _HealthBucket():
return $default(_that.start,_that.availability,_that.latencyMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime start,  double? availability,  double? latencyMs)?  $default,) {final _that = this;
switch (_that) {
case _HealthBucket() when $default != null:
return $default(_that.start,_that.availability,_that.latencyMs);case _:
  return null;

}
}

}

/// @nodoc


class _HealthBucket implements HealthBucket {
  const _HealthBucket({required this.start, this.availability, this.latencyMs});
  

@override final  DateTime start;
@override final  double? availability;
@override final  double? latencyMs;

/// Create a copy of HealthBucket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthBucketCopyWith<_HealthBucket> get copyWith => __$HealthBucketCopyWithImpl<_HealthBucket>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthBucket&&(identical(other.start, start) || other.start == start)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,start,availability,latencyMs);
}

@override
String toString() {
    return 'HealthBucket(start: $start, availability: $availability, latencyMs: $latencyMs)';
}


}

/// @nodoc
abstract mixin class _$HealthBucketCopyWith<$Res> implements $HealthBucketCopyWith<$Res> {
  factory _$HealthBucketCopyWith(_HealthBucket value, $Res Function(_HealthBucket) _then) = __$HealthBucketCopyWithImpl;
@override @useResult
$Res call({
 DateTime start, double? availability, double? latencyMs
});




}
/// @nodoc
class __$HealthBucketCopyWithImpl<$Res>
    implements _$HealthBucketCopyWith<$Res> {
  __$HealthBucketCopyWithImpl(this._self, this._then);

  final _HealthBucket _self;
  final $Res Function(_HealthBucket) _then;

/// Create a copy of HealthBucket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? availability = freezed,Object? latencyMs = freezed,}) {
  return _then(_HealthBucket(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,availability: freezed == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as double?,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
mixin _$HealthTarget {

 String get id; String get name; String get kind; HealthStatus get status; double? get uptimePercent; double? get latencyMs; int get outageCount; String? get parentName; DateTime? get lastSampleAt; List<HealthBucket> get buckets;
/// Create a copy of HealthTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthTargetCopyWith<HealthTarget> get copyWith => _$HealthTargetCopyWithImpl<HealthTarget>(this as HealthTarget, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HealthTarget;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthTarget&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.uptimePercent, _this.uptimePercent) || other.uptimePercent == _this.uptimePercent)&&(identical(other.latencyMs, _this.latencyMs) || other.latencyMs == _this.latencyMs)&&(identical(other.outageCount, _this.outageCount) || other.outageCount == _this.outageCount)&&(identical(other.parentName, _this.parentName) || other.parentName == _this.parentName)&&(identical(other.lastSampleAt, _this.lastSampleAt) || other.lastSampleAt == _this.lastSampleAt)&&const DeepCollectionEquality().equals(other.buckets, _this.buckets));
}


@override
int get hashCode {
  final _this = this as HealthTarget;
  return Object.hash(runtimeType,_this.id,_this.name,_this.kind,_this.status,_this.uptimePercent,_this.latencyMs,_this.outageCount,_this.parentName,_this.lastSampleAt,const DeepCollectionEquality().hash(_this.buckets));
}

@override
String toString() {
  final _this = this as HealthTarget;
  return 'HealthTarget(id: ${_this.id}, name: ${_this.name}, kind: ${_this.kind}, status: ${_this.status}, uptimePercent: ${_this.uptimePercent}, latencyMs: ${_this.latencyMs}, outageCount: ${_this.outageCount}, parentName: ${_this.parentName}, lastSampleAt: ${_this.lastSampleAt}, buckets: ${_this.buckets})';
}


}

/// @nodoc
abstract mixin class $HealthTargetCopyWith<$Res>  {
  factory $HealthTargetCopyWith(HealthTarget value, $Res Function(HealthTarget) _then) = _$HealthTargetCopyWithImpl;
@useResult
$Res call({
 String id, String name, String kind, HealthStatus status, double? uptimePercent, double? latencyMs, int outageCount, String? parentName, DateTime? lastSampleAt, List<HealthBucket> buckets
});




}
/// @nodoc
class _$HealthTargetCopyWithImpl<$Res>
    implements $HealthTargetCopyWith<$Res> {
  _$HealthTargetCopyWithImpl(this._self, this._then);

  final HealthTarget _self;
  final $Res Function(HealthTarget) _then;

/// Create a copy of HealthTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? status = null,Object? uptimePercent = freezed,Object? latencyMs = freezed,Object? outageCount = null,Object? parentName = freezed,Object? lastSampleAt = freezed,Object? buckets = null,}) {
  return _then(HealthTarget(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HealthStatus,uptimePercent: freezed == uptimePercent ? _self.uptimePercent : uptimePercent // ignore: cast_nullable_to_non_nullable
as double?,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as double?,outageCount: null == outageCount ? _self.outageCount : outageCount // ignore: cast_nullable_to_non_nullable
as int,parentName: freezed == parentName ? _self.parentName : parentName // ignore: cast_nullable_to_non_nullable
as String?,lastSampleAt: freezed == lastSampleAt ? _self.lastSampleAt : lastSampleAt // ignore: cast_nullable_to_non_nullable
as DateTime?,buckets: null == buckets ? _self.buckets : buckets // ignore: cast_nullable_to_non_nullable
as List<HealthBucket>,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthTarget].
extension HealthTargetPatterns on HealthTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthTarget value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthTarget() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthTarget value)  $default,){
final _that = this;
switch (_that) {
case _HealthTarget():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthTarget value)?  $default,){
final _that = this;
switch (_that) {
case _HealthTarget() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String kind,  HealthStatus status,  double? uptimePercent,  double? latencyMs,  int outageCount,  String? parentName,  DateTime? lastSampleAt,  List<HealthBucket> buckets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthTarget() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.status,_that.uptimePercent,_that.latencyMs,_that.outageCount,_that.parentName,_that.lastSampleAt,_that.buckets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String kind,  HealthStatus status,  double? uptimePercent,  double? latencyMs,  int outageCount,  String? parentName,  DateTime? lastSampleAt,  List<HealthBucket> buckets)  $default,) {final _that = this;
switch (_that) {
case _HealthTarget():
return $default(_that.id,_that.name,_that.kind,_that.status,_that.uptimePercent,_that.latencyMs,_that.outageCount,_that.parentName,_that.lastSampleAt,_that.buckets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String kind,  HealthStatus status,  double? uptimePercent,  double? latencyMs,  int outageCount,  String? parentName,  DateTime? lastSampleAt,  List<HealthBucket> buckets)?  $default,) {final _that = this;
switch (_that) {
case _HealthTarget() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.status,_that.uptimePercent,_that.latencyMs,_that.outageCount,_that.parentName,_that.lastSampleAt,_that.buckets);case _:
  return null;

}
}

}

/// @nodoc


class _HealthTarget implements HealthTarget {
  const _HealthTarget({required this.id, required this.name, required this.kind, required this.status, this.uptimePercent, this.latencyMs, this.outageCount = 0, this.parentName, this.lastSampleAt,  List<HealthBucket> buckets = const <HealthBucket>[]}): _buckets = buckets;
  

@override final  String id;
@override final  String name;
@override final  String kind;
@override final  HealthStatus status;
@override final  double? uptimePercent;
@override final  double? latencyMs;
@override@JsonKey() final  int outageCount;
@override final  String? parentName;
@override final  DateTime? lastSampleAt;
 final  List<HealthBucket> _buckets;
@override@JsonKey() List<HealthBucket> get buckets {
  if (_buckets is EqualUnmodifiableListView) return _buckets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_buckets);
}


/// Create a copy of HealthTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthTargetCopyWith<_HealthTarget> get copyWith => __$HealthTargetCopyWithImpl<_HealthTarget>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthTarget&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.uptimePercent, uptimePercent) || other.uptimePercent == uptimePercent)&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs)&&(identical(other.outageCount, outageCount) || other.outageCount == outageCount)&&(identical(other.parentName, parentName) || other.parentName == parentName)&&(identical(other.lastSampleAt, lastSampleAt) || other.lastSampleAt == lastSampleAt)&&const DeepCollectionEquality().equals(other.buckets, _buckets));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,kind,status,uptimePercent,latencyMs,outageCount,parentName,lastSampleAt,const DeepCollectionEquality().hash(_buckets));
}

@override
String toString() {
    return 'HealthTarget(id: $id, name: $name, kind: $kind, status: $status, uptimePercent: $uptimePercent, latencyMs: $latencyMs, outageCount: $outageCount, parentName: $parentName, lastSampleAt: $lastSampleAt, buckets: $buckets)';
}


}

/// @nodoc
abstract mixin class _$HealthTargetCopyWith<$Res> implements $HealthTargetCopyWith<$Res> {
  factory _$HealthTargetCopyWith(_HealthTarget value, $Res Function(_HealthTarget) _then) = __$HealthTargetCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String kind, HealthStatus status, double? uptimePercent, double? latencyMs, int outageCount, String? parentName, DateTime? lastSampleAt, List<HealthBucket> buckets
});




}
/// @nodoc
class __$HealthTargetCopyWithImpl<$Res>
    implements _$HealthTargetCopyWith<$Res> {
  __$HealthTargetCopyWithImpl(this._self, this._then);

  final _HealthTarget _self;
  final $Res Function(_HealthTarget) _then;

/// Create a copy of HealthTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? status = null,Object? uptimePercent = freezed,Object? latencyMs = freezed,Object? outageCount = null,Object? parentName = freezed,Object? lastSampleAt = freezed,Object? buckets = null,}) {
  return _then(_HealthTarget(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HealthStatus,uptimePercent: freezed == uptimePercent ? _self.uptimePercent : uptimePercent // ignore: cast_nullable_to_non_nullable
as double?,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as double?,outageCount: null == outageCount ? _self.outageCount : outageCount // ignore: cast_nullable_to_non_nullable
as int,parentName: freezed == parentName ? _self.parentName : parentName // ignore: cast_nullable_to_non_nullable
as String?,lastSampleAt: freezed == lastSampleAt ? _self.lastSampleAt : lastSampleAt // ignore: cast_nullable_to_non_nullable
as DateTime?,buckets: null == buckets ? _self._buckets : buckets // ignore: cast_nullable_to_non_nullable
as List<HealthBucket>,
  ));
}


}

/// @nodoc
mixin _$Outage {

 String get id; String get targetName; DateTime get startedAt; DateTime? get endedAt; bool get ongoing; String? get causeName;
/// Create a copy of Outage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutageCopyWith<Outage> get copyWith => _$OutageCopyWithImpl<Outage>(this as Outage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Outage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Outage&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.targetName, _this.targetName) || other.targetName == _this.targetName)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.ongoing, _this.ongoing) || other.ongoing == _this.ongoing)&&(identical(other.causeName, _this.causeName) || other.causeName == _this.causeName));
}


@override
int get hashCode {
  final _this = this as Outage;
  return Object.hash(runtimeType,_this.id,_this.targetName,_this.startedAt,_this.endedAt,_this.ongoing,_this.causeName);
}

@override
String toString() {
  final _this = this as Outage;
  return 'Outage(id: ${_this.id}, targetName: ${_this.targetName}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt}, ongoing: ${_this.ongoing}, causeName: ${_this.causeName})';
}


}

/// @nodoc
abstract mixin class $OutageCopyWith<$Res>  {
  factory $OutageCopyWith(Outage value, $Res Function(Outage) _then) = _$OutageCopyWithImpl;
@useResult
$Res call({
 String id, String targetName, DateTime startedAt, DateTime? endedAt, bool ongoing, String? causeName
});




}
/// @nodoc
class _$OutageCopyWithImpl<$Res>
    implements $OutageCopyWith<$Res> {
  _$OutageCopyWithImpl(this._self, this._then);

  final Outage _self;
  final $Res Function(Outage) _then;

/// Create a copy of Outage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? targetName = null,Object? startedAt = null,Object? endedAt = freezed,Object? ongoing = null,Object? causeName = freezed,}) {
  return _then(Outage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetName: null == targetName ? _self.targetName : targetName // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ongoing: null == ongoing ? _self.ongoing : ongoing // ignore: cast_nullable_to_non_nullable
as bool,causeName: freezed == causeName ? _self.causeName : causeName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Outage].
extension OutagePatterns on Outage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Outage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Outage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Outage value)  $default,){
final _that = this;
switch (_that) {
case _Outage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Outage value)?  $default,){
final _that = this;
switch (_that) {
case _Outage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String targetName,  DateTime startedAt,  DateTime? endedAt,  bool ongoing,  String? causeName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Outage() when $default != null:
return $default(_that.id,_that.targetName,_that.startedAt,_that.endedAt,_that.ongoing,_that.causeName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String targetName,  DateTime startedAt,  DateTime? endedAt,  bool ongoing,  String? causeName)  $default,) {final _that = this;
switch (_that) {
case _Outage():
return $default(_that.id,_that.targetName,_that.startedAt,_that.endedAt,_that.ongoing,_that.causeName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String targetName,  DateTime startedAt,  DateTime? endedAt,  bool ongoing,  String? causeName)?  $default,) {final _that = this;
switch (_that) {
case _Outage() when $default != null:
return $default(_that.id,_that.targetName,_that.startedAt,_that.endedAt,_that.ongoing,_that.causeName);case _:
  return null;

}
}

}

/// @nodoc


class _Outage implements Outage {
  const _Outage({required this.id, required this.targetName, required this.startedAt, this.endedAt, this.ongoing = false, this.causeName});
  

@override final  String id;
@override final  String targetName;
@override final  DateTime startedAt;
@override final  DateTime? endedAt;
@override@JsonKey() final  bool ongoing;
@override final  String? causeName;

/// Create a copy of Outage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutageCopyWith<_Outage> get copyWith => __$OutageCopyWithImpl<_Outage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Outage&&(identical(other.id, id) || other.id == id)&&(identical(other.targetName, targetName) || other.targetName == targetName)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.ongoing, ongoing) || other.ongoing == ongoing)&&(identical(other.causeName, causeName) || other.causeName == causeName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,targetName,startedAt,endedAt,ongoing,causeName);
}

@override
String toString() {
    return 'Outage(id: $id, targetName: $targetName, startedAt: $startedAt, endedAt: $endedAt, ongoing: $ongoing, causeName: $causeName)';
}


}

/// @nodoc
abstract mixin class _$OutageCopyWith<$Res> implements $OutageCopyWith<$Res> {
  factory _$OutageCopyWith(_Outage value, $Res Function(_Outage) _then) = __$OutageCopyWithImpl;
@override @useResult
$Res call({
 String id, String targetName, DateTime startedAt, DateTime? endedAt, bool ongoing, String? causeName
});




}
/// @nodoc
class __$OutageCopyWithImpl<$Res>
    implements _$OutageCopyWith<$Res> {
  __$OutageCopyWithImpl(this._self, this._then);

  final _Outage _self;
  final $Res Function(_Outage) _then;

/// Create a copy of Outage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? targetName = null,Object? startedAt = null,Object? endedAt = freezed,Object? ongoing = null,Object? causeName = freezed,}) {
  return _then(_Outage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetName: null == targetName ? _self.targetName : targetName // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ongoing: null == ongoing ? _self.ongoing : ongoing // ignore: cast_nullable_to_non_nullable
as bool,causeName: freezed == causeName ? _self.causeName : causeName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$HealthReport {

 List<HealthTarget> get targets; List<Outage> get outages;
/// Create a copy of HealthReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthReportCopyWith<HealthReport> get copyWith => _$HealthReportCopyWithImpl<HealthReport>(this as HealthReport, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HealthReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthReport&&const DeepCollectionEquality().equals(other.targets, _this.targets)&&const DeepCollectionEquality().equals(other.outages, _this.outages));
}


@override
int get hashCode {
  final _this = this as HealthReport;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.targets),const DeepCollectionEquality().hash(_this.outages));
}

@override
String toString() {
  final _this = this as HealthReport;
  return 'HealthReport(targets: ${_this.targets}, outages: ${_this.outages})';
}


}

/// @nodoc
abstract mixin class $HealthReportCopyWith<$Res>  {
  factory $HealthReportCopyWith(HealthReport value, $Res Function(HealthReport) _then) = _$HealthReportCopyWithImpl;
@useResult
$Res call({
 List<HealthTarget> targets, List<Outage> outages
});




}
/// @nodoc
class _$HealthReportCopyWithImpl<$Res>
    implements $HealthReportCopyWith<$Res> {
  _$HealthReportCopyWithImpl(this._self, this._then);

  final HealthReport _self;
  final $Res Function(HealthReport) _then;

/// Create a copy of HealthReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targets = null,Object? outages = null,}) {
  return _then(HealthReport(
targets: null == targets ? _self.targets : targets // ignore: cast_nullable_to_non_nullable
as List<HealthTarget>,outages: null == outages ? _self.outages : outages // ignore: cast_nullable_to_non_nullable
as List<Outage>,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthReport].
extension HealthReportPatterns on HealthReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthReport value)  $default,){
final _that = this;
switch (_that) {
case _HealthReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthReport value)?  $default,){
final _that = this;
switch (_that) {
case _HealthReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HealthTarget> targets,  List<Outage> outages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthReport() when $default != null:
return $default(_that.targets,_that.outages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HealthTarget> targets,  List<Outage> outages)  $default,) {final _that = this;
switch (_that) {
case _HealthReport():
return $default(_that.targets,_that.outages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HealthTarget> targets,  List<Outage> outages)?  $default,) {final _that = this;
switch (_that) {
case _HealthReport() when $default != null:
return $default(_that.targets,_that.outages);case _:
  return null;

}
}

}

/// @nodoc


class _HealthReport implements HealthReport {
  const _HealthReport({required  List<HealthTarget> targets, required  List<Outage> outages}): _targets = targets,_outages = outages;
  

 final  List<HealthTarget> _targets;
@override List<HealthTarget> get targets {
  if (_targets is EqualUnmodifiableListView) return _targets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targets);
}

 final  List<Outage> _outages;
@override List<Outage> get outages {
  if (_outages is EqualUnmodifiableListView) return _outages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_outages);
}


/// Create a copy of HealthReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthReportCopyWith<_HealthReport> get copyWith => __$HealthReportCopyWithImpl<_HealthReport>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthReport&&const DeepCollectionEquality().equals(other.targets, _targets)&&const DeepCollectionEquality().equals(other.outages, _outages));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_targets),const DeepCollectionEquality().hash(_outages));
}

@override
String toString() {
    return 'HealthReport(targets: $targets, outages: $outages)';
}


}

/// @nodoc
abstract mixin class _$HealthReportCopyWith<$Res> implements $HealthReportCopyWith<$Res> {
  factory _$HealthReportCopyWith(_HealthReport value, $Res Function(_HealthReport) _then) = __$HealthReportCopyWithImpl;
@override @useResult
$Res call({
 List<HealthTarget> targets, List<Outage> outages
});




}
/// @nodoc
class __$HealthReportCopyWithImpl<$Res>
    implements _$HealthReportCopyWith<$Res> {
  __$HealthReportCopyWithImpl(this._self, this._then);

  final _HealthReport _self;
  final $Res Function(_HealthReport) _then;

/// Create a copy of HealthReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targets = null,Object? outages = null,}) {
  return _then(_HealthReport(
targets: null == targets ? _self._targets : targets // ignore: cast_nullable_to_non_nullable
as List<HealthTarget>,outages: null == outages ? _self._outages : outages // ignore: cast_nullable_to_non_nullable
as List<Outage>,
  ));
}


}

// dart format on
