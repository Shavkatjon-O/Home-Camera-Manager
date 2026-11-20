// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimeWindow {

 String get start; String get end; List<int> get days;
/// Create a copy of TimeWindow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeWindowCopyWith<TimeWindow> get copyWith => _$TimeWindowCopyWithImpl<TimeWindow>(this as TimeWindow, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TimeWindow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeWindow&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&const DeepCollectionEquality().equals(other.days, _this.days));
}


@override
int get hashCode {
  final _this = this as TimeWindow;
  return Object.hash(runtimeType,_this.start,_this.end,const DeepCollectionEquality().hash(_this.days));
}

@override
String toString() {
  final _this = this as TimeWindow;
  return 'TimeWindow(start: ${_this.start}, end: ${_this.end}, days: ${_this.days})';
}


}

/// @nodoc
abstract mixin class $TimeWindowCopyWith<$Res>  {
  factory $TimeWindowCopyWith(TimeWindow value, $Res Function(TimeWindow) _then) = _$TimeWindowCopyWithImpl;
@useResult
$Res call({
 String start, String end, List<int> days
});




}
/// @nodoc
class _$TimeWindowCopyWithImpl<$Res>
    implements $TimeWindowCopyWith<$Res> {
  _$TimeWindowCopyWithImpl(this._self, this._then);

  final TimeWindow _self;
  final $Res Function(TimeWindow) _then;

/// Create a copy of TimeWindow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = null,Object? days = null,}) {
  return _then(TimeWindow(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [TimeWindow].
extension TimeWindowPatterns on TimeWindow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeWindow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeWindow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeWindow value)  $default,){
final _that = this;
switch (_that) {
case _TimeWindow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeWindow value)?  $default,){
final _that = this;
switch (_that) {
case _TimeWindow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String start,  String end,  List<int> days)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeWindow() when $default != null:
return $default(_that.start,_that.end,_that.days);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String start,  String end,  List<int> days)  $default,) {final _that = this;
switch (_that) {
case _TimeWindow():
return $default(_that.start,_that.end,_that.days);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String start,  String end,  List<int> days)?  $default,) {final _that = this;
switch (_that) {
case _TimeWindow() when $default != null:
return $default(_that.start,_that.end,_that.days);case _:
  return null;

}
}

}

/// @nodoc


class _TimeWindow implements TimeWindow {
  const _TimeWindow({required this.start, required this.end,  List<int> days = const <int>[0, 1, 2, 3, 4, 5, 6]}): _days = days;
  

@override final  String start;
@override final  String end;
 final  List<int> _days;
@override@JsonKey() List<int> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}


/// Create a copy of TimeWindow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeWindowCopyWith<_TimeWindow> get copyWith => __$TimeWindowCopyWithImpl<_TimeWindow>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeWindow&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&const DeepCollectionEquality().equals(other.days, _days));
}


@override
int get hashCode {
    return Object.hash(runtimeType,start,end,const DeepCollectionEquality().hash(_days));
}

@override
String toString() {
    return 'TimeWindow(start: $start, end: $end, days: $days)';
}


}

/// @nodoc
abstract mixin class _$TimeWindowCopyWith<$Res> implements $TimeWindowCopyWith<$Res> {
  factory _$TimeWindowCopyWith(_TimeWindow value, $Res Function(_TimeWindow) _then) = __$TimeWindowCopyWithImpl;
@override @useResult
$Res call({
 String start, String end, List<int> days
});




}
/// @nodoc
class __$TimeWindowCopyWithImpl<$Res>
    implements _$TimeWindowCopyWith<$Res> {
  __$TimeWindowCopyWithImpl(this._self, this._then);

  final _TimeWindow _self;
  final $Res Function(_TimeWindow) _then;

/// Create a copy of TimeWindow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = null,Object? days = null,}) {
  return _then(_TimeWindow(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

/// @nodoc
mixin _$AlertPolicy {

 AlertMode get mode; List<TimeWindow> get schedule; List<String> get labels;
/// Create a copy of AlertPolicy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlertPolicyCopyWith<AlertPolicy> get copyWith => _$AlertPolicyCopyWithImpl<AlertPolicy>(this as AlertPolicy, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AlertPolicy;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlertPolicy&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&const DeepCollectionEquality().equals(other.schedule, _this.schedule)&&const DeepCollectionEquality().equals(other.labels, _this.labels));
}


@override
int get hashCode {
  final _this = this as AlertPolicy;
  return Object.hash(runtimeType,_this.mode,const DeepCollectionEquality().hash(_this.schedule),const DeepCollectionEquality().hash(_this.labels));
}

@override
String toString() {
  final _this = this as AlertPolicy;
  return 'AlertPolicy(mode: ${_this.mode}, schedule: ${_this.schedule}, labels: ${_this.labels})';
}


}

/// @nodoc
abstract mixin class $AlertPolicyCopyWith<$Res>  {
  factory $AlertPolicyCopyWith(AlertPolicy value, $Res Function(AlertPolicy) _then) = _$AlertPolicyCopyWithImpl;
@useResult
$Res call({
 AlertMode mode, List<TimeWindow> schedule, List<String> labels
});




}
/// @nodoc
class _$AlertPolicyCopyWithImpl<$Res>
    implements $AlertPolicyCopyWith<$Res> {
  _$AlertPolicyCopyWithImpl(this._self, this._then);

  final AlertPolicy _self;
  final $Res Function(AlertPolicy) _then;

/// Create a copy of AlertPolicy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? schedule = null,Object? labels = null,}) {
  return _then(AlertPolicy(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AlertMode,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as List<TimeWindow>,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AlertPolicy].
extension AlertPolicyPatterns on AlertPolicy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlertPolicy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlertPolicy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlertPolicy value)  $default,){
final _that = this;
switch (_that) {
case _AlertPolicy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlertPolicy value)?  $default,){
final _that = this;
switch (_that) {
case _AlertPolicy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AlertMode mode,  List<TimeWindow> schedule,  List<String> labels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlertPolicy() when $default != null:
return $default(_that.mode,_that.schedule,_that.labels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AlertMode mode,  List<TimeWindow> schedule,  List<String> labels)  $default,) {final _that = this;
switch (_that) {
case _AlertPolicy():
return $default(_that.mode,_that.schedule,_that.labels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AlertMode mode,  List<TimeWindow> schedule,  List<String> labels)?  $default,) {final _that = this;
switch (_that) {
case _AlertPolicy() when $default != null:
return $default(_that.mode,_that.schedule,_that.labels);case _:
  return null;

}
}

}

/// @nodoc


class _AlertPolicy implements AlertPolicy {
  const _AlertPolicy({this.mode = AlertMode.always,  List<TimeWindow> schedule = const <TimeWindow>[],  List<String> labels = const <String>['person']}): _schedule = schedule,_labels = labels;
  

@override@JsonKey() final  AlertMode mode;
 final  List<TimeWindow> _schedule;
@override@JsonKey() List<TimeWindow> get schedule {
  if (_schedule is EqualUnmodifiableListView) return _schedule;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_schedule);
}

 final  List<String> _labels;
@override@JsonKey() List<String> get labels {
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labels);
}


/// Create a copy of AlertPolicy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlertPolicyCopyWith<_AlertPolicy> get copyWith => __$AlertPolicyCopyWithImpl<_AlertPolicy>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlertPolicy&&(identical(other.mode, mode) || other.mode == mode)&&const DeepCollectionEquality().equals(other.schedule, _schedule)&&const DeepCollectionEquality().equals(other.labels, _labels));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mode,const DeepCollectionEquality().hash(_schedule),const DeepCollectionEquality().hash(_labels));
}

@override
String toString() {
    return 'AlertPolicy(mode: $mode, schedule: $schedule, labels: $labels)';
}


}

/// @nodoc
abstract mixin class _$AlertPolicyCopyWith<$Res> implements $AlertPolicyCopyWith<$Res> {
  factory _$AlertPolicyCopyWith(_AlertPolicy value, $Res Function(_AlertPolicy) _then) = __$AlertPolicyCopyWithImpl;
@override @useResult
$Res call({
 AlertMode mode, List<TimeWindow> schedule, List<String> labels
});




}
/// @nodoc
class __$AlertPolicyCopyWithImpl<$Res>
    implements _$AlertPolicyCopyWith<$Res> {
  __$AlertPolicyCopyWithImpl(this._self, this._then);

  final _AlertPolicy _self;
  final $Res Function(_AlertPolicy) _then;

/// Create a copy of AlertPolicy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? schedule = null,Object? labels = null,}) {
  return _then(_AlertPolicy(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AlertMode,schedule: null == schedule ? _self._schedule : schedule // ignore: cast_nullable_to_non_nullable
as List<TimeWindow>,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$Zone {

 String? get id; String get name; List<Offset> get polygon; bool get wholeView; List<String> get labels; double get minDwell; double get loiterSeconds; int get crowdCount; AlertPolicy get alert; bool get enabled; bool get suspended; double get leftSeconds; double get takenSeconds; List<String> get objectLabels; AnimalMode get animals;
/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZoneCopyWith<Zone> get copyWith => _$ZoneCopyWithImpl<Zone>(this as Zone, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Zone;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Zone&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.polygon, _this.polygon)&&(identical(other.wholeView, _this.wholeView) || other.wholeView == _this.wholeView)&&const DeepCollectionEquality().equals(other.labels, _this.labels)&&(identical(other.minDwell, _this.minDwell) || other.minDwell == _this.minDwell)&&(identical(other.loiterSeconds, _this.loiterSeconds) || other.loiterSeconds == _this.loiterSeconds)&&(identical(other.crowdCount, _this.crowdCount) || other.crowdCount == _this.crowdCount)&&(identical(other.alert, _this.alert) || other.alert == _this.alert)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.suspended, _this.suspended) || other.suspended == _this.suspended)&&(identical(other.leftSeconds, _this.leftSeconds) || other.leftSeconds == _this.leftSeconds)&&(identical(other.takenSeconds, _this.takenSeconds) || other.takenSeconds == _this.takenSeconds)&&const DeepCollectionEquality().equals(other.objectLabels, _this.objectLabels)&&(identical(other.animals, _this.animals) || other.animals == _this.animals));
}


@override
int get hashCode {
  final _this = this as Zone;
  return Object.hash(runtimeType,_this.id,_this.name,const DeepCollectionEquality().hash(_this.polygon),_this.wholeView,const DeepCollectionEquality().hash(_this.labels),_this.minDwell,_this.loiterSeconds,_this.crowdCount,_this.alert,_this.enabled,_this.suspended,_this.leftSeconds,_this.takenSeconds,const DeepCollectionEquality().hash(_this.objectLabels),_this.animals);
}

@override
String toString() {
  final _this = this as Zone;
  return 'Zone(id: ${_this.id}, name: ${_this.name}, polygon: ${_this.polygon}, wholeView: ${_this.wholeView}, labels: ${_this.labels}, minDwell: ${_this.minDwell}, loiterSeconds: ${_this.loiterSeconds}, crowdCount: ${_this.crowdCount}, alert: ${_this.alert}, enabled: ${_this.enabled}, suspended: ${_this.suspended}, leftSeconds: ${_this.leftSeconds}, takenSeconds: ${_this.takenSeconds}, objectLabels: ${_this.objectLabels}, animals: ${_this.animals})';
}


}

/// @nodoc
abstract mixin class $ZoneCopyWith<$Res>  {
  factory $ZoneCopyWith(Zone value, $Res Function(Zone) _then) = _$ZoneCopyWithImpl;
@useResult
$Res call({
 String? id, String name, List<Offset> polygon, bool wholeView, List<String> labels, double minDwell, double loiterSeconds, int crowdCount, AlertPolicy alert, bool enabled, bool suspended, double leftSeconds, double takenSeconds, List<String> objectLabels, AnimalMode animals
});


$AlertPolicyCopyWith<$Res> get alert;

}
/// @nodoc
class _$ZoneCopyWithImpl<$Res>
    implements $ZoneCopyWith<$Res> {
  _$ZoneCopyWithImpl(this._self, this._then);

  final Zone _self;
  final $Res Function(Zone) _then;

/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? polygon = null,Object? wholeView = null,Object? labels = null,Object? minDwell = null,Object? loiterSeconds = null,Object? crowdCount = null,Object? alert = null,Object? enabled = null,Object? suspended = null,Object? leftSeconds = null,Object? takenSeconds = null,Object? objectLabels = null,Object? animals = null,}) {
  return _then(Zone(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,polygon: null == polygon ? _self.polygon : polygon // ignore: cast_nullable_to_non_nullable
as List<Offset>,wholeView: null == wholeView ? _self.wholeView : wholeView // ignore: cast_nullable_to_non_nullable
as bool,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,minDwell: null == minDwell ? _self.minDwell : minDwell // ignore: cast_nullable_to_non_nullable
as double,loiterSeconds: null == loiterSeconds ? _self.loiterSeconds : loiterSeconds // ignore: cast_nullable_to_non_nullable
as double,crowdCount: null == crowdCount ? _self.crowdCount : crowdCount // ignore: cast_nullable_to_non_nullable
as int,alert: null == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as AlertPolicy,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,suspended: null == suspended ? _self.suspended : suspended // ignore: cast_nullable_to_non_nullable
as bool,leftSeconds: null == leftSeconds ? _self.leftSeconds : leftSeconds // ignore: cast_nullable_to_non_nullable
as double,takenSeconds: null == takenSeconds ? _self.takenSeconds : takenSeconds // ignore: cast_nullable_to_non_nullable
as double,objectLabels: null == objectLabels ? _self.objectLabels : objectLabels // ignore: cast_nullable_to_non_nullable
as List<String>,animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as AnimalMode,
  ));
}
/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlertPolicyCopyWith<$Res> get alert {
  
  return $AlertPolicyCopyWith<$Res>(_self.alert, (value) {
    return _then(_self.copyWith(alert: value));
  });
}
}


/// Adds pattern-matching-related methods to [Zone].
extension ZonePatterns on Zone {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Zone value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Zone() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Zone value)  $default,){
final _that = this;
switch (_that) {
case _Zone():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Zone value)?  $default,){
final _that = this;
switch (_that) {
case _Zone() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String name,  List<Offset> polygon,  bool wholeView,  List<String> labels,  double minDwell,  double loiterSeconds,  int crowdCount,  AlertPolicy alert,  bool enabled,  bool suspended,  double leftSeconds,  double takenSeconds,  List<String> objectLabels,  AnimalMode animals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Zone() when $default != null:
return $default(_that.id,_that.name,_that.polygon,_that.wholeView,_that.labels,_that.minDwell,_that.loiterSeconds,_that.crowdCount,_that.alert,_that.enabled,_that.suspended,_that.leftSeconds,_that.takenSeconds,_that.objectLabels,_that.animals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String name,  List<Offset> polygon,  bool wholeView,  List<String> labels,  double minDwell,  double loiterSeconds,  int crowdCount,  AlertPolicy alert,  bool enabled,  bool suspended,  double leftSeconds,  double takenSeconds,  List<String> objectLabels,  AnimalMode animals)  $default,) {final _that = this;
switch (_that) {
case _Zone():
return $default(_that.id,_that.name,_that.polygon,_that.wholeView,_that.labels,_that.minDwell,_that.loiterSeconds,_that.crowdCount,_that.alert,_that.enabled,_that.suspended,_that.leftSeconds,_that.takenSeconds,_that.objectLabels,_that.animals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String name,  List<Offset> polygon,  bool wholeView,  List<String> labels,  double minDwell,  double loiterSeconds,  int crowdCount,  AlertPolicy alert,  bool enabled,  bool suspended,  double leftSeconds,  double takenSeconds,  List<String> objectLabels,  AnimalMode animals)?  $default,) {final _that = this;
switch (_that) {
case _Zone() when $default != null:
return $default(_that.id,_that.name,_that.polygon,_that.wholeView,_that.labels,_that.minDwell,_that.loiterSeconds,_that.crowdCount,_that.alert,_that.enabled,_that.suspended,_that.leftSeconds,_that.takenSeconds,_that.objectLabels,_that.animals);case _:
  return null;

}
}

}

/// @nodoc


class _Zone implements Zone {
  const _Zone({this.id, required this.name, required  List<Offset> polygon, this.wholeView = false,  List<String> labels = const <String>['person'], this.minDwell = 1.0, this.loiterSeconds = 0.0, this.crowdCount = 0, this.alert = const AlertPolicy(), this.enabled = true, this.suspended = false, this.leftSeconds = 0.0, this.takenSeconds = 0.0,  List<String> objectLabels = const <String>[], this.animals = AnimalMode.record}): _polygon = polygon,_labels = labels,_objectLabels = objectLabels;
  

@override final  String? id;
@override final  String name;
 final  List<Offset> _polygon;
@override List<Offset> get polygon {
  if (_polygon is EqualUnmodifiableListView) return _polygon;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_polygon);
}

@override@JsonKey() final  bool wholeView;
 final  List<String> _labels;
@override@JsonKey() List<String> get labels {
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labels);
}

@override@JsonKey() final  double minDwell;
@override@JsonKey() final  double loiterSeconds;
@override@JsonKey() final  int crowdCount;
@override@JsonKey() final  AlertPolicy alert;
@override@JsonKey() final  bool enabled;
@override@JsonKey() final  bool suspended;
@override@JsonKey() final  double leftSeconds;
@override@JsonKey() final  double takenSeconds;
 final  List<String> _objectLabels;
@override@JsonKey() List<String> get objectLabels {
  if (_objectLabels is EqualUnmodifiableListView) return _objectLabels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_objectLabels);
}

@override@JsonKey() final  AnimalMode animals;

/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ZoneCopyWith<_Zone> get copyWith => __$ZoneCopyWithImpl<_Zone>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Zone&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.polygon, _polygon)&&(identical(other.wholeView, wholeView) || other.wholeView == wholeView)&&const DeepCollectionEquality().equals(other.labels, _labels)&&(identical(other.minDwell, minDwell) || other.minDwell == minDwell)&&(identical(other.loiterSeconds, loiterSeconds) || other.loiterSeconds == loiterSeconds)&&(identical(other.crowdCount, crowdCount) || other.crowdCount == crowdCount)&&(identical(other.alert, alert) || other.alert == alert)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.suspended, suspended) || other.suspended == suspended)&&(identical(other.leftSeconds, leftSeconds) || other.leftSeconds == leftSeconds)&&(identical(other.takenSeconds, takenSeconds) || other.takenSeconds == takenSeconds)&&const DeepCollectionEquality().equals(other.objectLabels, _objectLabels)&&(identical(other.animals, animals) || other.animals == animals));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_polygon),wholeView,const DeepCollectionEquality().hash(_labels),minDwell,loiterSeconds,crowdCount,alert,enabled,suspended,leftSeconds,takenSeconds,const DeepCollectionEquality().hash(_objectLabels),animals);
}

@override
String toString() {
    return 'Zone(id: $id, name: $name, polygon: $polygon, wholeView: $wholeView, labels: $labels, minDwell: $minDwell, loiterSeconds: $loiterSeconds, crowdCount: $crowdCount, alert: $alert, enabled: $enabled, suspended: $suspended, leftSeconds: $leftSeconds, takenSeconds: $takenSeconds, objectLabels: $objectLabels, animals: $animals)';
}


}

/// @nodoc
abstract mixin class _$ZoneCopyWith<$Res> implements $ZoneCopyWith<$Res> {
  factory _$ZoneCopyWith(_Zone value, $Res Function(_Zone) _then) = __$ZoneCopyWithImpl;
@override @useResult
$Res call({
 String? id, String name, List<Offset> polygon, bool wholeView, List<String> labels, double minDwell, double loiterSeconds, int crowdCount, AlertPolicy alert, bool enabled, bool suspended, double leftSeconds, double takenSeconds, List<String> objectLabels, AnimalMode animals
});


@override $AlertPolicyCopyWith<$Res> get alert;

}
/// @nodoc
class __$ZoneCopyWithImpl<$Res>
    implements _$ZoneCopyWith<$Res> {
  __$ZoneCopyWithImpl(this._self, this._then);

  final _Zone _self;
  final $Res Function(_Zone) _then;

/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? polygon = null,Object? wholeView = null,Object? labels = null,Object? minDwell = null,Object? loiterSeconds = null,Object? crowdCount = null,Object? alert = null,Object? enabled = null,Object? suspended = null,Object? leftSeconds = null,Object? takenSeconds = null,Object? objectLabels = null,Object? animals = null,}) {
  return _then(_Zone(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,polygon: null == polygon ? _self._polygon : polygon // ignore: cast_nullable_to_non_nullable
as List<Offset>,wholeView: null == wholeView ? _self.wholeView : wholeView // ignore: cast_nullable_to_non_nullable
as bool,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,minDwell: null == minDwell ? _self.minDwell : minDwell // ignore: cast_nullable_to_non_nullable
as double,loiterSeconds: null == loiterSeconds ? _self.loiterSeconds : loiterSeconds // ignore: cast_nullable_to_non_nullable
as double,crowdCount: null == crowdCount ? _self.crowdCount : crowdCount // ignore: cast_nullable_to_non_nullable
as int,alert: null == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as AlertPolicy,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,suspended: null == suspended ? _self.suspended : suspended // ignore: cast_nullable_to_non_nullable
as bool,leftSeconds: null == leftSeconds ? _self.leftSeconds : leftSeconds // ignore: cast_nullable_to_non_nullable
as double,takenSeconds: null == takenSeconds ? _self.takenSeconds : takenSeconds // ignore: cast_nullable_to_non_nullable
as double,objectLabels: null == objectLabels ? _self._objectLabels : objectLabels // ignore: cast_nullable_to_non_nullable
as List<String>,animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as AnimalMode,
  ));
}

/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlertPolicyCopyWith<$Res> get alert {
  
  return $AlertPolicyCopyWith<$Res>(_self.alert, (value) {
    return _then(_self.copyWith(alert: value));
  });
}
}

/// @nodoc
mixin _$Line {

 String? get id; String get name; Offset get a; Offset get b; List<String> get labels; LineDirection get direction; AlertPolicy get alert; bool get enabled; bool get suspended; AnimalMode get animals;
/// Create a copy of Line
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineCopyWith<Line> get copyWith => _$LineCopyWithImpl<Line>(this as Line, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Line;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Line&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.a, _this.a) || other.a == _this.a)&&(identical(other.b, _this.b) || other.b == _this.b)&&const DeepCollectionEquality().equals(other.labels, _this.labels)&&(identical(other.direction, _this.direction) || other.direction == _this.direction)&&(identical(other.alert, _this.alert) || other.alert == _this.alert)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.suspended, _this.suspended) || other.suspended == _this.suspended)&&(identical(other.animals, _this.animals) || other.animals == _this.animals));
}


@override
int get hashCode {
  final _this = this as Line;
  return Object.hash(runtimeType,_this.id,_this.name,_this.a,_this.b,const DeepCollectionEquality().hash(_this.labels),_this.direction,_this.alert,_this.enabled,_this.suspended,_this.animals);
}

@override
String toString() {
  final _this = this as Line;
  return 'Line(id: ${_this.id}, name: ${_this.name}, a: ${_this.a}, b: ${_this.b}, labels: ${_this.labels}, direction: ${_this.direction}, alert: ${_this.alert}, enabled: ${_this.enabled}, suspended: ${_this.suspended}, animals: ${_this.animals})';
}


}

/// @nodoc
abstract mixin class $LineCopyWith<$Res>  {
  factory $LineCopyWith(Line value, $Res Function(Line) _then) = _$LineCopyWithImpl;
@useResult
$Res call({
 String? id, String name, Offset a, Offset b, List<String> labels, LineDirection direction, AlertPolicy alert, bool enabled, bool suspended, AnimalMode animals
});


$AlertPolicyCopyWith<$Res> get alert;

}
/// @nodoc
class _$LineCopyWithImpl<$Res>
    implements $LineCopyWith<$Res> {
  _$LineCopyWithImpl(this._self, this._then);

  final Line _self;
  final $Res Function(Line) _then;

/// Create a copy of Line
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? a = null,Object? b = null,Object? labels = null,Object? direction = null,Object? alert = null,Object? enabled = null,Object? suspended = null,Object? animals = null,}) {
  return _then(Line(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,a: null == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as Offset,b: null == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as Offset,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as LineDirection,alert: null == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as AlertPolicy,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,suspended: null == suspended ? _self.suspended : suspended // ignore: cast_nullable_to_non_nullable
as bool,animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as AnimalMode,
  ));
}
/// Create a copy of Line
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlertPolicyCopyWith<$Res> get alert {
  
  return $AlertPolicyCopyWith<$Res>(_self.alert, (value) {
    return _then(_self.copyWith(alert: value));
  });
}
}


/// Adds pattern-matching-related methods to [Line].
extension LinePatterns on Line {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Line value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Line() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Line value)  $default,){
final _that = this;
switch (_that) {
case _Line():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Line value)?  $default,){
final _that = this;
switch (_that) {
case _Line() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String name,  Offset a,  Offset b,  List<String> labels,  LineDirection direction,  AlertPolicy alert,  bool enabled,  bool suspended,  AnimalMode animals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Line() when $default != null:
return $default(_that.id,_that.name,_that.a,_that.b,_that.labels,_that.direction,_that.alert,_that.enabled,_that.suspended,_that.animals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String name,  Offset a,  Offset b,  List<String> labels,  LineDirection direction,  AlertPolicy alert,  bool enabled,  bool suspended,  AnimalMode animals)  $default,) {final _that = this;
switch (_that) {
case _Line():
return $default(_that.id,_that.name,_that.a,_that.b,_that.labels,_that.direction,_that.alert,_that.enabled,_that.suspended,_that.animals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String name,  Offset a,  Offset b,  List<String> labels,  LineDirection direction,  AlertPolicy alert,  bool enabled,  bool suspended,  AnimalMode animals)?  $default,) {final _that = this;
switch (_that) {
case _Line() when $default != null:
return $default(_that.id,_that.name,_that.a,_that.b,_that.labels,_that.direction,_that.alert,_that.enabled,_that.suspended,_that.animals);case _:
  return null;

}
}

}

/// @nodoc


class _Line implements Line {
  const _Line({this.id, required this.name, required this.a, required this.b,  List<String> labels = const <String>['person'], this.direction = LineDirection.both, this.alert = const AlertPolicy(mode: AlertMode.off), this.enabled = true, this.suspended = false, this.animals = AnimalMode.record}): _labels = labels;
  

@override final  String? id;
@override final  String name;
@override final  Offset a;
@override final  Offset b;
 final  List<String> _labels;
@override@JsonKey() List<String> get labels {
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labels);
}

@override@JsonKey() final  LineDirection direction;
@override@JsonKey() final  AlertPolicy alert;
@override@JsonKey() final  bool enabled;
@override@JsonKey() final  bool suspended;
@override@JsonKey() final  AnimalMode animals;

/// Create a copy of Line
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineCopyWith<_Line> get copyWith => __$LineCopyWithImpl<_Line>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Line&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.a, a) || other.a == a)&&(identical(other.b, b) || other.b == b)&&const DeepCollectionEquality().equals(other.labels, _labels)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.alert, alert) || other.alert == alert)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.suspended, suspended) || other.suspended == suspended)&&(identical(other.animals, animals) || other.animals == animals));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,a,b,const DeepCollectionEquality().hash(_labels),direction,alert,enabled,suspended,animals);
}

@override
String toString() {
    return 'Line(id: $id, name: $name, a: $a, b: $b, labels: $labels, direction: $direction, alert: $alert, enabled: $enabled, suspended: $suspended, animals: $animals)';
}


}

/// @nodoc
abstract mixin class _$LineCopyWith<$Res> implements $LineCopyWith<$Res> {
  factory _$LineCopyWith(_Line value, $Res Function(_Line) _then) = __$LineCopyWithImpl;
@override @useResult
$Res call({
 String? id, String name, Offset a, Offset b, List<String> labels, LineDirection direction, AlertPolicy alert, bool enabled, bool suspended, AnimalMode animals
});


@override $AlertPolicyCopyWith<$Res> get alert;

}
/// @nodoc
class __$LineCopyWithImpl<$Res>
    implements _$LineCopyWith<$Res> {
  __$LineCopyWithImpl(this._self, this._then);

  final _Line _self;
  final $Res Function(_Line) _then;

/// Create a copy of Line
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? a = null,Object? b = null,Object? labels = null,Object? direction = null,Object? alert = null,Object? enabled = null,Object? suspended = null,Object? animals = null,}) {
  return _then(_Line(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,a: null == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as Offset,b: null == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as Offset,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as LineDirection,alert: null == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as AlertPolicy,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,suspended: null == suspended ? _self.suspended : suspended // ignore: cast_nullable_to_non_nullable
as bool,animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as AnimalMode,
  ));
}

/// Create a copy of Line
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlertPolicyCopyWith<$Res> get alert {
  
  return $AlertPolicyCopyWith<$Res>(_self.alert, (value) {
    return _then(_self.copyWith(alert: value));
  });
}
}

/// @nodoc
mixin _$AnalyticsView {

 String get id; String get cameraId; String get cameraName; int get lens; int get lenses; String get name; Profile get profile; bool get enabled; StreamQuality get stream; double get fps; bool get tamper; bool get faces; bool get moving; bool get appearance; bool get falls; bool get plates; bool get follow; bool get ptz; List<Zone> get zones; List<Line> get lines; bool get suspended; double? get fpsMeasured;
/// Create a copy of AnalyticsView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsViewCopyWith<AnalyticsView> get copyWith => _$AnalyticsViewCopyWithImpl<AnalyticsView>(this as AnalyticsView, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AnalyticsView;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsView&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.cameraId, _this.cameraId) || other.cameraId == _this.cameraId)&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName)&&(identical(other.lens, _this.lens) || other.lens == _this.lens)&&(identical(other.lenses, _this.lenses) || other.lenses == _this.lenses)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.stream, _this.stream) || other.stream == _this.stream)&&(identical(other.fps, _this.fps) || other.fps == _this.fps)&&(identical(other.tamper, _this.tamper) || other.tamper == _this.tamper)&&(identical(other.faces, _this.faces) || other.faces == _this.faces)&&(identical(other.moving, _this.moving) || other.moving == _this.moving)&&(identical(other.appearance, _this.appearance) || other.appearance == _this.appearance)&&(identical(other.falls, _this.falls) || other.falls == _this.falls)&&(identical(other.plates, _this.plates) || other.plates == _this.plates)&&(identical(other.follow, _this.follow) || other.follow == _this.follow)&&(identical(other.ptz, _this.ptz) || other.ptz == _this.ptz)&&const DeepCollectionEquality().equals(other.zones, _this.zones)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.suspended, _this.suspended) || other.suspended == _this.suspended)&&(identical(other.fpsMeasured, _this.fpsMeasured) || other.fpsMeasured == _this.fpsMeasured));
}


@override
int get hashCode {
  final _this = this as AnalyticsView;
  return Object.hashAll([runtimeType,_this.id,_this.cameraId,_this.cameraName,_this.lens,_this.lenses,_this.name,_this.profile,_this.enabled,_this.stream,_this.fps,_this.tamper,_this.faces,_this.moving,_this.appearance,_this.falls,_this.plates,_this.follow,_this.ptz,const DeepCollectionEquality().hash(_this.zones),const DeepCollectionEquality().hash(_this.lines),_this.suspended,_this.fpsMeasured]);
}

@override
String toString() {
  final _this = this as AnalyticsView;
  return 'AnalyticsView(id: ${_this.id}, cameraId: ${_this.cameraId}, cameraName: ${_this.cameraName}, lens: ${_this.lens}, lenses: ${_this.lenses}, name: ${_this.name}, profile: ${_this.profile}, enabled: ${_this.enabled}, stream: ${_this.stream}, fps: ${_this.fps}, tamper: ${_this.tamper}, faces: ${_this.faces}, moving: ${_this.moving}, appearance: ${_this.appearance}, falls: ${_this.falls}, plates: ${_this.plates}, follow: ${_this.follow}, ptz: ${_this.ptz}, zones: ${_this.zones}, lines: ${_this.lines}, suspended: ${_this.suspended}, fpsMeasured: ${_this.fpsMeasured})';
}


}

/// @nodoc
abstract mixin class $AnalyticsViewCopyWith<$Res>  {
  factory $AnalyticsViewCopyWith(AnalyticsView value, $Res Function(AnalyticsView) _then) = _$AnalyticsViewCopyWithImpl;
@useResult
$Res call({
 String id, String cameraId, String cameraName, int lens, int lenses, String name, Profile profile, bool enabled, StreamQuality stream, double fps, bool tamper, bool faces, bool moving, bool appearance, bool falls, bool plates, bool follow, bool ptz, List<Zone> zones, List<Line> lines, bool suspended, double? fpsMeasured
});




}
/// @nodoc
class _$AnalyticsViewCopyWithImpl<$Res>
    implements $AnalyticsViewCopyWith<$Res> {
  _$AnalyticsViewCopyWithImpl(this._self, this._then);

  final AnalyticsView _self;
  final $Res Function(AnalyticsView) _then;

/// Create a copy of AnalyticsView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cameraId = null,Object? cameraName = null,Object? lens = null,Object? lenses = null,Object? name = null,Object? profile = null,Object? enabled = null,Object? stream = null,Object? fps = null,Object? tamper = null,Object? faces = null,Object? moving = null,Object? appearance = null,Object? falls = null,Object? plates = null,Object? follow = null,Object? ptz = null,Object? zones = null,Object? lines = null,Object? suspended = null,Object? fpsMeasured = freezed,}) {
  return _then(AnalyticsView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cameraId: null == cameraId ? _self.cameraId : cameraId // ignore: cast_nullable_to_non_nullable
as String,cameraName: null == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String,lens: null == lens ? _self.lens : lens // ignore: cast_nullable_to_non_nullable
as int,lenses: null == lenses ? _self.lenses : lenses // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,stream: null == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as StreamQuality,fps: null == fps ? _self.fps : fps // ignore: cast_nullable_to_non_nullable
as double,tamper: null == tamper ? _self.tamper : tamper // ignore: cast_nullable_to_non_nullable
as bool,faces: null == faces ? _self.faces : faces // ignore: cast_nullable_to_non_nullable
as bool,moving: null == moving ? _self.moving : moving // ignore: cast_nullable_to_non_nullable
as bool,appearance: null == appearance ? _self.appearance : appearance // ignore: cast_nullable_to_non_nullable
as bool,falls: null == falls ? _self.falls : falls // ignore: cast_nullable_to_non_nullable
as bool,plates: null == plates ? _self.plates : plates // ignore: cast_nullable_to_non_nullable
as bool,follow: null == follow ? _self.follow : follow // ignore: cast_nullable_to_non_nullable
as bool,ptz: null == ptz ? _self.ptz : ptz // ignore: cast_nullable_to_non_nullable
as bool,zones: null == zones ? _self.zones : zones // ignore: cast_nullable_to_non_nullable
as List<Zone>,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<Line>,suspended: null == suspended ? _self.suspended : suspended // ignore: cast_nullable_to_non_nullable
as bool,fpsMeasured: freezed == fpsMeasured ? _self.fpsMeasured : fpsMeasured // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsView].
extension AnalyticsViewPatterns on AnalyticsView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsView value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsView value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String cameraId,  String cameraName,  int lens,  int lenses,  String name,  Profile profile,  bool enabled,  StreamQuality stream,  double fps,  bool tamper,  bool faces,  bool moving,  bool appearance,  bool falls,  bool plates,  bool follow,  bool ptz,  List<Zone> zones,  List<Line> lines,  bool suspended,  double? fpsMeasured)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsView() when $default != null:
return $default(_that.id,_that.cameraId,_that.cameraName,_that.lens,_that.lenses,_that.name,_that.profile,_that.enabled,_that.stream,_that.fps,_that.tamper,_that.faces,_that.moving,_that.appearance,_that.falls,_that.plates,_that.follow,_that.ptz,_that.zones,_that.lines,_that.suspended,_that.fpsMeasured);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String cameraId,  String cameraName,  int lens,  int lenses,  String name,  Profile profile,  bool enabled,  StreamQuality stream,  double fps,  bool tamper,  bool faces,  bool moving,  bool appearance,  bool falls,  bool plates,  bool follow,  bool ptz,  List<Zone> zones,  List<Line> lines,  bool suspended,  double? fpsMeasured)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsView():
return $default(_that.id,_that.cameraId,_that.cameraName,_that.lens,_that.lenses,_that.name,_that.profile,_that.enabled,_that.stream,_that.fps,_that.tamper,_that.faces,_that.moving,_that.appearance,_that.falls,_that.plates,_that.follow,_that.ptz,_that.zones,_that.lines,_that.suspended,_that.fpsMeasured);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String cameraId,  String cameraName,  int lens,  int lenses,  String name,  Profile profile,  bool enabled,  StreamQuality stream,  double fps,  bool tamper,  bool faces,  bool moving,  bool appearance,  bool falls,  bool plates,  bool follow,  bool ptz,  List<Zone> zones,  List<Line> lines,  bool suspended,  double? fpsMeasured)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsView() when $default != null:
return $default(_that.id,_that.cameraId,_that.cameraName,_that.lens,_that.lenses,_that.name,_that.profile,_that.enabled,_that.stream,_that.fps,_that.tamper,_that.faces,_that.moving,_that.appearance,_that.falls,_that.plates,_that.follow,_that.ptz,_that.zones,_that.lines,_that.suspended,_that.fpsMeasured);case _:
  return null;

}
}

}

/// @nodoc


class _AnalyticsView extends AnalyticsView {
  const _AnalyticsView({required this.id, required this.cameraId, required this.cameraName, required this.lens, required this.lenses, required this.name, this.profile = Profile.perimeter, this.enabled = true, this.stream = StreamQuality.sub, this.fps = 8.0, this.tamper = true, this.faces = false, this.moving = false, this.appearance = true, this.falls = false, this.plates = false, this.follow = false, this.ptz = false,  List<Zone> zones = const <Zone>[],  List<Line> lines = const <Line>[], this.suspended = false, this.fpsMeasured}): _zones = zones,_lines = lines,super._();
  

@override final  String id;
@override final  String cameraId;
@override final  String cameraName;
@override final  int lens;
@override final  int lenses;
@override final  String name;
@override@JsonKey() final  Profile profile;
@override@JsonKey() final  bool enabled;
@override@JsonKey() final  StreamQuality stream;
@override@JsonKey() final  double fps;
@override@JsonKey() final  bool tamper;
@override@JsonKey() final  bool faces;
@override@JsonKey() final  bool moving;
@override@JsonKey() final  bool appearance;
@override@JsonKey() final  bool falls;
@override@JsonKey() final  bool plates;
@override@JsonKey() final  bool follow;
@override@JsonKey() final  bool ptz;
 final  List<Zone> _zones;
@override@JsonKey() List<Zone> get zones {
  if (_zones is EqualUnmodifiableListView) return _zones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_zones);
}

 final  List<Line> _lines;
@override@JsonKey() List<Line> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override@JsonKey() final  bool suspended;
@override final  double? fpsMeasured;

/// Create a copy of AnalyticsView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsViewCopyWith<_AnalyticsView> get copyWith => __$AnalyticsViewCopyWithImpl<_AnalyticsView>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsView&&(identical(other.id, id) || other.id == id)&&(identical(other.cameraId, cameraId) || other.cameraId == cameraId)&&(identical(other.cameraName, cameraName) || other.cameraName == cameraName)&&(identical(other.lens, lens) || other.lens == lens)&&(identical(other.lenses, lenses) || other.lenses == lenses)&&(identical(other.name, name) || other.name == name)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.stream, stream) || other.stream == stream)&&(identical(other.fps, fps) || other.fps == fps)&&(identical(other.tamper, tamper) || other.tamper == tamper)&&(identical(other.faces, faces) || other.faces == faces)&&(identical(other.moving, moving) || other.moving == moving)&&(identical(other.appearance, appearance) || other.appearance == appearance)&&(identical(other.falls, falls) || other.falls == falls)&&(identical(other.plates, plates) || other.plates == plates)&&(identical(other.follow, follow) || other.follow == follow)&&(identical(other.ptz, ptz) || other.ptz == ptz)&&const DeepCollectionEquality().equals(other.zones, _zones)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.suspended, suspended) || other.suspended == suspended)&&(identical(other.fpsMeasured, fpsMeasured) || other.fpsMeasured == fpsMeasured));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,cameraId,cameraName,lens,lenses,name,profile,enabled,stream,fps,tamper,faces,moving,appearance,falls,plates,follow,ptz,const DeepCollectionEquality().hash(_zones),const DeepCollectionEquality().hash(_lines),suspended,fpsMeasured]);
}

@override
String toString() {
    return 'AnalyticsView(id: $id, cameraId: $cameraId, cameraName: $cameraName, lens: $lens, lenses: $lenses, name: $name, profile: $profile, enabled: $enabled, stream: $stream, fps: $fps, tamper: $tamper, faces: $faces, moving: $moving, appearance: $appearance, falls: $falls, plates: $plates, follow: $follow, ptz: $ptz, zones: $zones, lines: $lines, suspended: $suspended, fpsMeasured: $fpsMeasured)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsViewCopyWith<$Res> implements $AnalyticsViewCopyWith<$Res> {
  factory _$AnalyticsViewCopyWith(_AnalyticsView value, $Res Function(_AnalyticsView) _then) = __$AnalyticsViewCopyWithImpl;
@override @useResult
$Res call({
 String id, String cameraId, String cameraName, int lens, int lenses, String name, Profile profile, bool enabled, StreamQuality stream, double fps, bool tamper, bool faces, bool moving, bool appearance, bool falls, bool plates, bool follow, bool ptz, List<Zone> zones, List<Line> lines, bool suspended, double? fpsMeasured
});




}
/// @nodoc
class __$AnalyticsViewCopyWithImpl<$Res>
    implements _$AnalyticsViewCopyWith<$Res> {
  __$AnalyticsViewCopyWithImpl(this._self, this._then);

  final _AnalyticsView _self;
  final $Res Function(_AnalyticsView) _then;

/// Create a copy of AnalyticsView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cameraId = null,Object? cameraName = null,Object? lens = null,Object? lenses = null,Object? name = null,Object? profile = null,Object? enabled = null,Object? stream = null,Object? fps = null,Object? tamper = null,Object? faces = null,Object? moving = null,Object? appearance = null,Object? falls = null,Object? plates = null,Object? follow = null,Object? ptz = null,Object? zones = null,Object? lines = null,Object? suspended = null,Object? fpsMeasured = freezed,}) {
  return _then(_AnalyticsView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cameraId: null == cameraId ? _self.cameraId : cameraId // ignore: cast_nullable_to_non_nullable
as String,cameraName: null == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String,lens: null == lens ? _self.lens : lens // ignore: cast_nullable_to_non_nullable
as int,lenses: null == lenses ? _self.lenses : lenses // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,stream: null == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as StreamQuality,fps: null == fps ? _self.fps : fps // ignore: cast_nullable_to_non_nullable
as double,tamper: null == tamper ? _self.tamper : tamper // ignore: cast_nullable_to_non_nullable
as bool,faces: null == faces ? _self.faces : faces // ignore: cast_nullable_to_non_nullable
as bool,moving: null == moving ? _self.moving : moving // ignore: cast_nullable_to_non_nullable
as bool,appearance: null == appearance ? _self.appearance : appearance // ignore: cast_nullable_to_non_nullable
as bool,falls: null == falls ? _self.falls : falls // ignore: cast_nullable_to_non_nullable
as bool,plates: null == plates ? _self.plates : plates // ignore: cast_nullable_to_non_nullable
as bool,follow: null == follow ? _self.follow : follow // ignore: cast_nullable_to_non_nullable
as bool,ptz: null == ptz ? _self.ptz : ptz // ignore: cast_nullable_to_non_nullable
as bool,zones: null == zones ? _self._zones : zones // ignore: cast_nullable_to_non_nullable
as List<Zone>,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<Line>,suspended: null == suspended ? _self.suspended : suspended // ignore: cast_nullable_to_non_nullable
as bool,fpsMeasured: freezed == fpsMeasured ? _self.fpsMeasured : fpsMeasured // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
mixin _$LiveObject {

 int get track; String get label; Rect get box; String? get name;
/// Create a copy of LiveObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveObjectCopyWith<LiveObject> get copyWith => _$LiveObjectCopyWithImpl<LiveObject>(this as LiveObject, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LiveObject;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveObject&&(identical(other.track, _this.track) || other.track == _this.track)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.box, _this.box) || other.box == _this.box)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as LiveObject;
  return Object.hash(runtimeType,_this.track,_this.label,_this.box,_this.name);
}

@override
String toString() {
  final _this = this as LiveObject;
  return 'LiveObject(track: ${_this.track}, label: ${_this.label}, box: ${_this.box}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $LiveObjectCopyWith<$Res>  {
  factory $LiveObjectCopyWith(LiveObject value, $Res Function(LiveObject) _then) = _$LiveObjectCopyWithImpl;
@useResult
$Res call({
 int track, String label, Rect box, String? name
});




}
/// @nodoc
class _$LiveObjectCopyWithImpl<$Res>
    implements $LiveObjectCopyWith<$Res> {
  _$LiveObjectCopyWithImpl(this._self, this._then);

  final LiveObject _self;
  final $Res Function(LiveObject) _then;

/// Create a copy of LiveObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? track = null,Object? label = null,Object? box = null,Object? name = freezed,}) {
  return _then(LiveObject(
track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,box: null == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as Rect,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveObject].
extension LiveObjectPatterns on LiveObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveObject value)  $default,){
final _that = this;
switch (_that) {
case _LiveObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveObject value)?  $default,){
final _that = this;
switch (_that) {
case _LiveObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int track,  String label,  Rect box,  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveObject() when $default != null:
return $default(_that.track,_that.label,_that.box,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int track,  String label,  Rect box,  String? name)  $default,) {final _that = this;
switch (_that) {
case _LiveObject():
return $default(_that.track,_that.label,_that.box,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int track,  String label,  Rect box,  String? name)?  $default,) {final _that = this;
switch (_that) {
case _LiveObject() when $default != null:
return $default(_that.track,_that.label,_that.box,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _LiveObject implements LiveObject {
  const _LiveObject({required this.track, required this.label, required this.box, this.name});
  

@override final  int track;
@override final  String label;
@override final  Rect box;
@override final  String? name;

/// Create a copy of LiveObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveObjectCopyWith<_LiveObject> get copyWith => __$LiveObjectCopyWithImpl<_LiveObject>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveObject&&(identical(other.track, track) || other.track == track)&&(identical(other.label, label) || other.label == label)&&(identical(other.box, box) || other.box == box)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,track,label,box,name);
}

@override
String toString() {
    return 'LiveObject(track: $track, label: $label, box: $box, name: $name)';
}


}

/// @nodoc
abstract mixin class _$LiveObjectCopyWith<$Res> implements $LiveObjectCopyWith<$Res> {
  factory _$LiveObjectCopyWith(_LiveObject value, $Res Function(_LiveObject) _then) = __$LiveObjectCopyWithImpl;
@override @useResult
$Res call({
 int track, String label, Rect box, String? name
});




}
/// @nodoc
class __$LiveObjectCopyWithImpl<$Res>
    implements _$LiveObjectCopyWith<$Res> {
  __$LiveObjectCopyWithImpl(this._self, this._then);

  final _LiveObject _self;
  final $Res Function(_LiveObject) _then;

/// Create a copy of LiveObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? track = null,Object? label = null,Object? box = null,Object? name = freezed,}) {
  return _then(_LiveObject(
track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,box: null == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as Rect,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
