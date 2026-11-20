// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_bucket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HealthBucket {


/// Create a copy of HealthBucket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthBucketCopyWith<HealthBucket> get copyWith => _$HealthBucketCopyWithImpl<HealthBucket>(this as HealthBucket, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HealthBucket;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthBucket&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.samples, _this.samples) || other.samples == _this.samples)&&(identical(other.availability, _this.availability) || other.availability == _this.availability)&&(identical(other.latencyMs, _this.latencyMs) || other.latencyMs == _this.latencyMs)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as HealthBucket;
  return Object.hash(runtimeType,_this.start,_this.samples,_this.availability,_this.latencyMs,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as HealthBucket;
  return 'HealthBucket(start: ${_this.start}, samples: ${_this.samples}, availability: ${_this.availability}, latencyMs: ${_this.latencyMs}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $HealthBucketCopyWith<$Res>  {
  factory $HealthBucketCopyWith(HealthBucket value, $Res Function(HealthBucket) _then) = _$HealthBucketCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true, fromJson: HealthBucket._read_start, toJson: HealthBucket._write_start) DateTime start,@JsonKey(required: true, disallowNullValue: true, fromJson: HealthBucket._read_samples, toJson: HealthBucket._write_samples) int samples,@JsonKey(required: true) num? availability,@JsonKey(name: "latency_ms", required: true) num? latencyMs,@JsonKey(readValue: HealthBucket._extras, fromJson: HealthBucket._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
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
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? samples = null,Object? availability = freezed,Object? latencyMs = freezed,Object? additionalProperties = null,}) {
  return _then(HealthBucket(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,samples: null == samples ? _self.samples : samples // ignore: cast_nullable_to_non_nullable
as int,availability: freezed == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as num?,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as num?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
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
