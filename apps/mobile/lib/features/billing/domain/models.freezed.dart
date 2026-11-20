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
mixin _$PlanLimits {

 int? get sites; int? get cameras; int? get members; int? get eventRetentionDays; int? get clipRetentionDays;
/// Create a copy of PlanLimits
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanLimitsCopyWith<PlanLimits> get copyWith => _$PlanLimitsCopyWithImpl<PlanLimits>(this as PlanLimits, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlanLimits;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanLimits&&(identical(other.sites, _this.sites) || other.sites == _this.sites)&&(identical(other.cameras, _this.cameras) || other.cameras == _this.cameras)&&(identical(other.members, _this.members) || other.members == _this.members)&&(identical(other.eventRetentionDays, _this.eventRetentionDays) || other.eventRetentionDays == _this.eventRetentionDays)&&(identical(other.clipRetentionDays, _this.clipRetentionDays) || other.clipRetentionDays == _this.clipRetentionDays));
}


@override
int get hashCode {
  final _this = this as PlanLimits;
  return Object.hash(runtimeType,_this.sites,_this.cameras,_this.members,_this.eventRetentionDays,_this.clipRetentionDays);
}

@override
String toString() {
  final _this = this as PlanLimits;
  return 'PlanLimits(sites: ${_this.sites}, cameras: ${_this.cameras}, members: ${_this.members}, eventRetentionDays: ${_this.eventRetentionDays}, clipRetentionDays: ${_this.clipRetentionDays})';
}


}

/// @nodoc
abstract mixin class $PlanLimitsCopyWith<$Res>  {
  factory $PlanLimitsCopyWith(PlanLimits value, $Res Function(PlanLimits) _then) = _$PlanLimitsCopyWithImpl;
@useResult
$Res call({
 int? sites, int? cameras, int? members, int? eventRetentionDays, int? clipRetentionDays
});




}
/// @nodoc
class _$PlanLimitsCopyWithImpl<$Res>
    implements $PlanLimitsCopyWith<$Res> {
  _$PlanLimitsCopyWithImpl(this._self, this._then);

  final PlanLimits _self;
  final $Res Function(PlanLimits) _then;

/// Create a copy of PlanLimits
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sites = freezed,Object? cameras = freezed,Object? members = freezed,Object? eventRetentionDays = freezed,Object? clipRetentionDays = freezed,}) {
  return _then(PlanLimits(
sites: freezed == sites ? _self.sites : sites // ignore: cast_nullable_to_non_nullable
as int?,cameras: freezed == cameras ? _self.cameras : cameras // ignore: cast_nullable_to_non_nullable
as int?,members: freezed == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as int?,eventRetentionDays: freezed == eventRetentionDays ? _self.eventRetentionDays : eventRetentionDays // ignore: cast_nullable_to_non_nullable
as int?,clipRetentionDays: freezed == clipRetentionDays ? _self.clipRetentionDays : clipRetentionDays // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanLimits].
extension PlanLimitsPatterns on PlanLimits {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanLimits value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanLimits() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanLimits value)  $default,){
final _that = this;
switch (_that) {
case _PlanLimits():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanLimits value)?  $default,){
final _that = this;
switch (_that) {
case _PlanLimits() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? sites,  int? cameras,  int? members,  int? eventRetentionDays,  int? clipRetentionDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanLimits() when $default != null:
return $default(_that.sites,_that.cameras,_that.members,_that.eventRetentionDays,_that.clipRetentionDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? sites,  int? cameras,  int? members,  int? eventRetentionDays,  int? clipRetentionDays)  $default,) {final _that = this;
switch (_that) {
case _PlanLimits():
return $default(_that.sites,_that.cameras,_that.members,_that.eventRetentionDays,_that.clipRetentionDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? sites,  int? cameras,  int? members,  int? eventRetentionDays,  int? clipRetentionDays)?  $default,) {final _that = this;
switch (_that) {
case _PlanLimits() when $default != null:
return $default(_that.sites,_that.cameras,_that.members,_that.eventRetentionDays,_that.clipRetentionDays);case _:
  return null;

}
}

}

/// @nodoc


class _PlanLimits implements PlanLimits {
  const _PlanLimits({this.sites, this.cameras, this.members, this.eventRetentionDays, this.clipRetentionDays});
  

@override final  int? sites;
@override final  int? cameras;
@override final  int? members;
@override final  int? eventRetentionDays;
@override final  int? clipRetentionDays;

/// Create a copy of PlanLimits
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanLimitsCopyWith<_PlanLimits> get copyWith => __$PlanLimitsCopyWithImpl<_PlanLimits>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanLimits&&(identical(other.sites, sites) || other.sites == sites)&&(identical(other.cameras, cameras) || other.cameras == cameras)&&(identical(other.members, members) || other.members == members)&&(identical(other.eventRetentionDays, eventRetentionDays) || other.eventRetentionDays == eventRetentionDays)&&(identical(other.clipRetentionDays, clipRetentionDays) || other.clipRetentionDays == clipRetentionDays));
}


@override
int get hashCode {
    return Object.hash(runtimeType,sites,cameras,members,eventRetentionDays,clipRetentionDays);
}

@override
String toString() {
    return 'PlanLimits(sites: $sites, cameras: $cameras, members: $members, eventRetentionDays: $eventRetentionDays, clipRetentionDays: $clipRetentionDays)';
}


}

/// @nodoc
abstract mixin class _$PlanLimitsCopyWith<$Res> implements $PlanLimitsCopyWith<$Res> {
  factory _$PlanLimitsCopyWith(_PlanLimits value, $Res Function(_PlanLimits) _then) = __$PlanLimitsCopyWithImpl;
@override @useResult
$Res call({
 int? sites, int? cameras, int? members, int? eventRetentionDays, int? clipRetentionDays
});




}
/// @nodoc
class __$PlanLimitsCopyWithImpl<$Res>
    implements _$PlanLimitsCopyWith<$Res> {
  __$PlanLimitsCopyWithImpl(this._self, this._then);

  final _PlanLimits _self;
  final $Res Function(_PlanLimits) _then;

/// Create a copy of PlanLimits
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sites = freezed,Object? cameras = freezed,Object? members = freezed,Object? eventRetentionDays = freezed,Object? clipRetentionDays = freezed,}) {
  return _then(_PlanLimits(
sites: freezed == sites ? _self.sites : sites // ignore: cast_nullable_to_non_nullable
as int?,cameras: freezed == cameras ? _self.cameras : cameras // ignore: cast_nullable_to_non_nullable
as int?,members: freezed == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as int?,eventRetentionDays: freezed == eventRetentionDays ? _self.eventRetentionDays : eventRetentionDays // ignore: cast_nullable_to_non_nullable
as int?,clipRetentionDays: freezed == clipRetentionDays ? _self.clipRetentionDays : clipRetentionDays // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$Plan {

 String get id; String get name; bool get internal; PlanLimits get limits; Set<PlanFeature> get features;
/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanCopyWith<Plan> get copyWith => _$PlanCopyWithImpl<Plan>(this as Plan, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Plan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Plan&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.internal, _this.internal) || other.internal == _this.internal)&&(identical(other.limits, _this.limits) || other.limits == _this.limits)&&const DeepCollectionEquality().equals(other.features, _this.features));
}


@override
int get hashCode {
  final _this = this as Plan;
  return Object.hash(runtimeType,_this.id,_this.name,_this.internal,_this.limits,const DeepCollectionEquality().hash(_this.features));
}

@override
String toString() {
  final _this = this as Plan;
  return 'Plan(id: ${_this.id}, name: ${_this.name}, internal: ${_this.internal}, limits: ${_this.limits}, features: ${_this.features})';
}


}

/// @nodoc
abstract mixin class $PlanCopyWith<$Res>  {
  factory $PlanCopyWith(Plan value, $Res Function(Plan) _then) = _$PlanCopyWithImpl;
@useResult
$Res call({
 String id, String name, bool internal, PlanLimits limits, Set<PlanFeature> features
});


$PlanLimitsCopyWith<$Res> get limits;

}
/// @nodoc
class _$PlanCopyWithImpl<$Res>
    implements $PlanCopyWith<$Res> {
  _$PlanCopyWithImpl(this._self, this._then);

  final Plan _self;
  final $Res Function(Plan) _then;

/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? internal = null,Object? limits = null,Object? features = null,}) {
  return _then(Plan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,internal: null == internal ? _self.internal : internal // ignore: cast_nullable_to_non_nullable
as bool,limits: null == limits ? _self.limits : limits // ignore: cast_nullable_to_non_nullable
as PlanLimits,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as Set<PlanFeature>,
  ));
}
/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanLimitsCopyWith<$Res> get limits {
  
  return $PlanLimitsCopyWith<$Res>(_self.limits, (value) {
    return _then(_self.copyWith(limits: value));
  });
}
}


/// Adds pattern-matching-related methods to [Plan].
extension PlanPatterns on Plan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Plan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Plan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Plan value)  $default,){
final _that = this;
switch (_that) {
case _Plan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Plan value)?  $default,){
final _that = this;
switch (_that) {
case _Plan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  bool internal,  PlanLimits limits,  Set<PlanFeature> features)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Plan() when $default != null:
return $default(_that.id,_that.name,_that.internal,_that.limits,_that.features);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  bool internal,  PlanLimits limits,  Set<PlanFeature> features)  $default,) {final _that = this;
switch (_that) {
case _Plan():
return $default(_that.id,_that.name,_that.internal,_that.limits,_that.features);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  bool internal,  PlanLimits limits,  Set<PlanFeature> features)?  $default,) {final _that = this;
switch (_that) {
case _Plan() when $default != null:
return $default(_that.id,_that.name,_that.internal,_that.limits,_that.features);case _:
  return null;

}
}

}

/// @nodoc


class _Plan extends Plan {
  const _Plan({required this.id, required this.name, this.internal = false, this.limits = const PlanLimits(),  Set<PlanFeature> features = const <PlanFeature>{}}): _features = features,super._();
  

@override final  String id;
@override final  String name;
@override@JsonKey() final  bool internal;
@override@JsonKey() final  PlanLimits limits;
 final  Set<PlanFeature> _features;
@override@JsonKey() Set<PlanFeature> get features {
  if (_features is EqualUnmodifiableSetView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_features);
}


/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanCopyWith<_Plan> get copyWith => __$PlanCopyWithImpl<_Plan>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Plan&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.internal, internal) || other.internal == internal)&&(identical(other.limits, limits) || other.limits == limits)&&const DeepCollectionEquality().equals(other.features, _features));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,internal,limits,const DeepCollectionEquality().hash(_features));
}

@override
String toString() {
    return 'Plan(id: $id, name: $name, internal: $internal, limits: $limits, features: $features)';
}


}

/// @nodoc
abstract mixin class _$PlanCopyWith<$Res> implements $PlanCopyWith<$Res> {
  factory _$PlanCopyWith(_Plan value, $Res Function(_Plan) _then) = __$PlanCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool internal, PlanLimits limits, Set<PlanFeature> features
});


@override $PlanLimitsCopyWith<$Res> get limits;

}
/// @nodoc
class __$PlanCopyWithImpl<$Res>
    implements _$PlanCopyWith<$Res> {
  __$PlanCopyWithImpl(this._self, this._then);

  final _Plan _self;
  final $Res Function(_Plan) _then;

/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? internal = null,Object? limits = null,Object? features = null,}) {
  return _then(_Plan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,internal: null == internal ? _self.internal : internal // ignore: cast_nullable_to_non_nullable
as bool,limits: null == limits ? _self.limits : limits // ignore: cast_nullable_to_non_nullable
as PlanLimits,features: null == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as Set<PlanFeature>,
  ));
}

/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanLimitsCopyWith<$Res> get limits {
  
  return $PlanLimitsCopyWith<$Res>(_self.limits, (value) {
    return _then(_self.copyWith(limits: value));
  });
}
}

/// @nodoc
mixin _$Usage {

 DateTime get periodStart; int get sites; int get cameras; int get members; double get cameraHours; double get analyticsHours; int get events; int get clipBytes; int get notifications; bool get metered;
/// Create a copy of Usage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsageCopyWith<Usage> get copyWith => _$UsageCopyWithImpl<Usage>(this as Usage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Usage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Usage&&(identical(other.periodStart, _this.periodStart) || other.periodStart == _this.periodStart)&&(identical(other.sites, _this.sites) || other.sites == _this.sites)&&(identical(other.cameras, _this.cameras) || other.cameras == _this.cameras)&&(identical(other.members, _this.members) || other.members == _this.members)&&(identical(other.cameraHours, _this.cameraHours) || other.cameraHours == _this.cameraHours)&&(identical(other.analyticsHours, _this.analyticsHours) || other.analyticsHours == _this.analyticsHours)&&(identical(other.events, _this.events) || other.events == _this.events)&&(identical(other.clipBytes, _this.clipBytes) || other.clipBytes == _this.clipBytes)&&(identical(other.notifications, _this.notifications) || other.notifications == _this.notifications)&&(identical(other.metered, _this.metered) || other.metered == _this.metered));
}


@override
int get hashCode {
  final _this = this as Usage;
  return Object.hash(runtimeType,_this.periodStart,_this.sites,_this.cameras,_this.members,_this.cameraHours,_this.analyticsHours,_this.events,_this.clipBytes,_this.notifications,_this.metered);
}

@override
String toString() {
  final _this = this as Usage;
  return 'Usage(periodStart: ${_this.periodStart}, sites: ${_this.sites}, cameras: ${_this.cameras}, members: ${_this.members}, cameraHours: ${_this.cameraHours}, analyticsHours: ${_this.analyticsHours}, events: ${_this.events}, clipBytes: ${_this.clipBytes}, notifications: ${_this.notifications}, metered: ${_this.metered})';
}


}

/// @nodoc
abstract mixin class $UsageCopyWith<$Res>  {
  factory $UsageCopyWith(Usage value, $Res Function(Usage) _then) = _$UsageCopyWithImpl;
@useResult
$Res call({
 DateTime periodStart, int sites, int cameras, int members, double cameraHours, double analyticsHours, int events, int clipBytes, int notifications, bool metered
});




}
/// @nodoc
class _$UsageCopyWithImpl<$Res>
    implements $UsageCopyWith<$Res> {
  _$UsageCopyWithImpl(this._self, this._then);

  final Usage _self;
  final $Res Function(Usage) _then;

/// Create a copy of Usage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? periodStart = null,Object? sites = null,Object? cameras = null,Object? members = null,Object? cameraHours = null,Object? analyticsHours = null,Object? events = null,Object? clipBytes = null,Object? notifications = null,Object? metered = null,}) {
  return _then(Usage(
periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,sites: null == sites ? _self.sites : sites // ignore: cast_nullable_to_non_nullable
as int,cameras: null == cameras ? _self.cameras : cameras // ignore: cast_nullable_to_non_nullable
as int,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as int,cameraHours: null == cameraHours ? _self.cameraHours : cameraHours // ignore: cast_nullable_to_non_nullable
as double,analyticsHours: null == analyticsHours ? _self.analyticsHours : analyticsHours // ignore: cast_nullable_to_non_nullable
as double,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as int,clipBytes: null == clipBytes ? _self.clipBytes : clipBytes // ignore: cast_nullable_to_non_nullable
as int,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as int,metered: null == metered ? _self.metered : metered // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Usage].
extension UsagePatterns on Usage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Usage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Usage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Usage value)  $default,){
final _that = this;
switch (_that) {
case _Usage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Usage value)?  $default,){
final _that = this;
switch (_that) {
case _Usage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime periodStart,  int sites,  int cameras,  int members,  double cameraHours,  double analyticsHours,  int events,  int clipBytes,  int notifications,  bool metered)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Usage() when $default != null:
return $default(_that.periodStart,_that.sites,_that.cameras,_that.members,_that.cameraHours,_that.analyticsHours,_that.events,_that.clipBytes,_that.notifications,_that.metered);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime periodStart,  int sites,  int cameras,  int members,  double cameraHours,  double analyticsHours,  int events,  int clipBytes,  int notifications,  bool metered)  $default,) {final _that = this;
switch (_that) {
case _Usage():
return $default(_that.periodStart,_that.sites,_that.cameras,_that.members,_that.cameraHours,_that.analyticsHours,_that.events,_that.clipBytes,_that.notifications,_that.metered);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime periodStart,  int sites,  int cameras,  int members,  double cameraHours,  double analyticsHours,  int events,  int clipBytes,  int notifications,  bool metered)?  $default,) {final _that = this;
switch (_that) {
case _Usage() when $default != null:
return $default(_that.periodStart,_that.sites,_that.cameras,_that.members,_that.cameraHours,_that.analyticsHours,_that.events,_that.clipBytes,_that.notifications,_that.metered);case _:
  return null;

}
}

}

/// @nodoc


class _Usage implements Usage {
  const _Usage({required this.periodStart, this.sites = 0, this.cameras = 0, this.members = 0, this.cameraHours = 0, this.analyticsHours = 0, this.events = 0, this.clipBytes = 0, this.notifications = 0, this.metered = true});
  

@override final  DateTime periodStart;
@override@JsonKey() final  int sites;
@override@JsonKey() final  int cameras;
@override@JsonKey() final  int members;
@override@JsonKey() final  double cameraHours;
@override@JsonKey() final  double analyticsHours;
@override@JsonKey() final  int events;
@override@JsonKey() final  int clipBytes;
@override@JsonKey() final  int notifications;
@override@JsonKey() final  bool metered;

/// Create a copy of Usage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsageCopyWith<_Usage> get copyWith => __$UsageCopyWithImpl<_Usage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Usage&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.sites, sites) || other.sites == sites)&&(identical(other.cameras, cameras) || other.cameras == cameras)&&(identical(other.members, members) || other.members == members)&&(identical(other.cameraHours, cameraHours) || other.cameraHours == cameraHours)&&(identical(other.analyticsHours, analyticsHours) || other.analyticsHours == analyticsHours)&&(identical(other.events, events) || other.events == events)&&(identical(other.clipBytes, clipBytes) || other.clipBytes == clipBytes)&&(identical(other.notifications, notifications) || other.notifications == notifications)&&(identical(other.metered, metered) || other.metered == metered));
}


@override
int get hashCode {
    return Object.hash(runtimeType,periodStart,sites,cameras,members,cameraHours,analyticsHours,events,clipBytes,notifications,metered);
}

@override
String toString() {
    return 'Usage(periodStart: $periodStart, sites: $sites, cameras: $cameras, members: $members, cameraHours: $cameraHours, analyticsHours: $analyticsHours, events: $events, clipBytes: $clipBytes, notifications: $notifications, metered: $metered)';
}


}

/// @nodoc
abstract mixin class _$UsageCopyWith<$Res> implements $UsageCopyWith<$Res> {
  factory _$UsageCopyWith(_Usage value, $Res Function(_Usage) _then) = __$UsageCopyWithImpl;
@override @useResult
$Res call({
 DateTime periodStart, int sites, int cameras, int members, double cameraHours, double analyticsHours, int events, int clipBytes, int notifications, bool metered
});




}
/// @nodoc
class __$UsageCopyWithImpl<$Res>
    implements _$UsageCopyWith<$Res> {
  __$UsageCopyWithImpl(this._self, this._then);

  final _Usage _self;
  final $Res Function(_Usage) _then;

/// Create a copy of Usage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? periodStart = null,Object? sites = null,Object? cameras = null,Object? members = null,Object? cameraHours = null,Object? analyticsHours = null,Object? events = null,Object? clipBytes = null,Object? notifications = null,Object? metered = null,}) {
  return _then(_Usage(
periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,sites: null == sites ? _self.sites : sites // ignore: cast_nullable_to_non_nullable
as int,cameras: null == cameras ? _self.cameras : cameras // ignore: cast_nullable_to_non_nullable
as int,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as int,cameraHours: null == cameraHours ? _self.cameraHours : cameraHours // ignore: cast_nullable_to_non_nullable
as double,analyticsHours: null == analyticsHours ? _self.analyticsHours : analyticsHours // ignore: cast_nullable_to_non_nullable
as double,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as int,clipBytes: null == clipBytes ? _self.clipBytes : clipBytes // ignore: cast_nullable_to_non_nullable
as int,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as int,metered: null == metered ? _self.metered : metered // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$PlanReport {

 Plan get plan; Usage get usage; bool get suspended;
/// Create a copy of PlanReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanReportCopyWith<PlanReport> get copyWith => _$PlanReportCopyWithImpl<PlanReport>(this as PlanReport, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlanReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanReport&&(identical(other.plan, _this.plan) || other.plan == _this.plan)&&(identical(other.usage, _this.usage) || other.usage == _this.usage)&&(identical(other.suspended, _this.suspended) || other.suspended == _this.suspended));
}


@override
int get hashCode {
  final _this = this as PlanReport;
  return Object.hash(runtimeType,_this.plan,_this.usage,_this.suspended);
}

@override
String toString() {
  final _this = this as PlanReport;
  return 'PlanReport(plan: ${_this.plan}, usage: ${_this.usage}, suspended: ${_this.suspended})';
}


}

/// @nodoc
abstract mixin class $PlanReportCopyWith<$Res>  {
  factory $PlanReportCopyWith(PlanReport value, $Res Function(PlanReport) _then) = _$PlanReportCopyWithImpl;
@useResult
$Res call({
 Plan plan, Usage usage, bool suspended
});


$PlanCopyWith<$Res> get plan;$UsageCopyWith<$Res> get usage;

}
/// @nodoc
class _$PlanReportCopyWithImpl<$Res>
    implements $PlanReportCopyWith<$Res> {
  _$PlanReportCopyWithImpl(this._self, this._then);

  final PlanReport _self;
  final $Res Function(PlanReport) _then;

/// Create a copy of PlanReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plan = null,Object? usage = null,Object? suspended = null,}) {
  return _then(PlanReport(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as Plan,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as Usage,suspended: null == suspended ? _self.suspended : suspended // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PlanReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanCopyWith<$Res> get plan {
  
  return $PlanCopyWith<$Res>(_self.plan, (value) {
    return _then(_self.copyWith(plan: value));
  });
}/// Create a copy of PlanReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsageCopyWith<$Res> get usage {
  
  return $UsageCopyWith<$Res>(_self.usage, (value) {
    return _then(_self.copyWith(usage: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlanReport].
extension PlanReportPatterns on PlanReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanReport value)  $default,){
final _that = this;
switch (_that) {
case _PlanReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanReport value)?  $default,){
final _that = this;
switch (_that) {
case _PlanReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Plan plan,  Usage usage,  bool suspended)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanReport() when $default != null:
return $default(_that.plan,_that.usage,_that.suspended);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Plan plan,  Usage usage,  bool suspended)  $default,) {final _that = this;
switch (_that) {
case _PlanReport():
return $default(_that.plan,_that.usage,_that.suspended);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Plan plan,  Usage usage,  bool suspended)?  $default,) {final _that = this;
switch (_that) {
case _PlanReport() when $default != null:
return $default(_that.plan,_that.usage,_that.suspended);case _:
  return null;

}
}

}

/// @nodoc


class _PlanReport implements PlanReport {
  const _PlanReport({required this.plan, required this.usage, this.suspended = false});
  

@override final  Plan plan;
@override final  Usage usage;
@override@JsonKey() final  bool suspended;

/// Create a copy of PlanReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanReportCopyWith<_PlanReport> get copyWith => __$PlanReportCopyWithImpl<_PlanReport>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanReport&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.usage, usage) || other.usage == usage)&&(identical(other.suspended, suspended) || other.suspended == suspended));
}


@override
int get hashCode {
    return Object.hash(runtimeType,plan,usage,suspended);
}

@override
String toString() {
    return 'PlanReport(plan: $plan, usage: $usage, suspended: $suspended)';
}


}

/// @nodoc
abstract mixin class _$PlanReportCopyWith<$Res> implements $PlanReportCopyWith<$Res> {
  factory _$PlanReportCopyWith(_PlanReport value, $Res Function(_PlanReport) _then) = __$PlanReportCopyWithImpl;
@override @useResult
$Res call({
 Plan plan, Usage usage, bool suspended
});


@override $PlanCopyWith<$Res> get plan;@override $UsageCopyWith<$Res> get usage;

}
/// @nodoc
class __$PlanReportCopyWithImpl<$Res>
    implements _$PlanReportCopyWith<$Res> {
  __$PlanReportCopyWithImpl(this._self, this._then);

  final _PlanReport _self;
  final $Res Function(_PlanReport) _then;

/// Create a copy of PlanReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plan = null,Object? usage = null,Object? suspended = null,}) {
  return _then(_PlanReport(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as Plan,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as Usage,suspended: null == suspended ? _self.suspended : suspended // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PlanReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanCopyWith<$Res> get plan {
  
  return $PlanCopyWith<$Res>(_self.plan, (value) {
    return _then(_self.copyWith(plan: value));
  });
}/// Create a copy of PlanReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsageCopyWith<$Res> get usage {
  
  return $UsageCopyWith<$Res>(_self.usage, (value) {
    return _then(_self.copyWith(usage: value));
  });
}
}

// dart format on
