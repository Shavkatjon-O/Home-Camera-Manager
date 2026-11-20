// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'latency_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LatencyStats {


/// Create a copy of LatencyStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LatencyStatsCopyWith<LatencyStats> get copyWith => _$LatencyStatsCopyWithImpl<LatencyStats>(this as LatencyStats, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LatencyStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LatencyStats&&(identical(other.avgMs, _this.avgMs) || other.avgMs == _this.avgMs)&&(identical(other.p50Ms, _this.p50Ms) || other.p50Ms == _this.p50Ms)&&(identical(other.p95Ms, _this.p95Ms) || other.p95Ms == _this.p95Ms)&&(identical(other.maxMs, _this.maxMs) || other.maxMs == _this.maxMs)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as LatencyStats;
  return Object.hash(runtimeType,_this.avgMs,_this.p50Ms,_this.p95Ms,_this.maxMs,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as LatencyStats;
  return 'LatencyStats(avgMs: ${_this.avgMs}, p50Ms: ${_this.p50Ms}, p95Ms: ${_this.p95Ms}, maxMs: ${_this.maxMs}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $LatencyStatsCopyWith<$Res>  {
  factory $LatencyStatsCopyWith(LatencyStats value, $Res Function(LatencyStats) _then) = _$LatencyStatsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "avg_ms", required: true) num? avgMs,@JsonKey(name: "p50_ms", required: true) num? p50Ms,@JsonKey(name: "p95_ms", required: true) num? p95Ms,@JsonKey(name: "max_ms", required: true) num? maxMs,@JsonKey(readValue: LatencyStats._extras, fromJson: LatencyStats._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$LatencyStatsCopyWithImpl<$Res>
    implements $LatencyStatsCopyWith<$Res> {
  _$LatencyStatsCopyWithImpl(this._self, this._then);

  final LatencyStats _self;
  final $Res Function(LatencyStats) _then;

/// Create a copy of LatencyStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? avgMs = freezed,Object? p50Ms = freezed,Object? p95Ms = freezed,Object? maxMs = freezed,Object? additionalProperties = null,}) {
  return _then(LatencyStats(
avgMs: freezed == avgMs ? _self.avgMs : avgMs // ignore: cast_nullable_to_non_nullable
as num?,p50Ms: freezed == p50Ms ? _self.p50Ms : p50Ms // ignore: cast_nullable_to_non_nullable
as num?,p95Ms: freezed == p95Ms ? _self.p95Ms : p95Ms // ignore: cast_nullable_to_non_nullable
as num?,maxMs: freezed == maxMs ? _self.maxMs : maxMs // ignore: cast_nullable_to_non_nullable
as num?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [LatencyStats].
extension LatencyStatsPatterns on LatencyStats {
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
