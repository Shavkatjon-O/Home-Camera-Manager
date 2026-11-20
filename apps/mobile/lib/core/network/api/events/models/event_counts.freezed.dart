// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_counts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventCounts {


/// Create a copy of EventCounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCountsCopyWith<EventCounts> get copyWith => _$EventCountsCopyWithImpl<EventCounts>(this as EventCounts, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventCounts;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventCounts&&(identical(other.total, _this.total) || other.total == _this.total)&&const DeepCollectionEquality().equals(other.kinds, _this.kinds)&&const DeepCollectionEquality().equals(other.labels, _this.labels)&&(identical(other.alerts, _this.alerts) || other.alerts == _this.alerts)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as EventCounts;
  return Object.hash(runtimeType,_this.total,const DeepCollectionEquality().hash(_this.kinds),const DeepCollectionEquality().hash(_this.labels),_this.alerts,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as EventCounts;
  return 'EventCounts(total: ${_this.total}, kinds: ${_this.kinds}, labels: ${_this.labels}, alerts: ${_this.alerts}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $EventCountsCopyWith<$Res>  {
  factory $EventCountsCopyWith(EventCounts value, $Res Function(EventCounts) _then) = _$EventCountsCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true, fromJson: EventCounts._read_total, toJson: EventCounts._write_total) int total,@JsonKey(required: true, disallowNullValue: true, fromJson: EventCounts._read_kinds, toJson: EventCounts._write_kinds) Map<String, int> kinds,@JsonKey(required: true, disallowNullValue: true, fromJson: EventCounts._read_labels, toJson: EventCounts._write_labels) Map<String, int> labels,@JsonKey(required: true, disallowNullValue: true, fromJson: EventCounts._read_alerts, toJson: EventCounts._write_alerts) int alerts,@JsonKey(readValue: EventCounts._extras, fromJson: EventCounts._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$EventCountsCopyWithImpl<$Res>
    implements $EventCountsCopyWith<$Res> {
  _$EventCountsCopyWithImpl(this._self, this._then);

  final EventCounts _self;
  final $Res Function(EventCounts) _then;

/// Create a copy of EventCounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? kinds = null,Object? labels = null,Object? alerts = null,Object? additionalProperties = null,}) {
  return _then(EventCounts(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,kinds: null == kinds ? _self.kinds : kinds // ignore: cast_nullable_to_non_nullable
as Map<String, int>,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as Map<String, int>,alerts: null == alerts ? _self.alerts : alerts // ignore: cast_nullable_to_non_nullable
as int,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [EventCounts].
extension EventCountsPatterns on EventCounts {
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
