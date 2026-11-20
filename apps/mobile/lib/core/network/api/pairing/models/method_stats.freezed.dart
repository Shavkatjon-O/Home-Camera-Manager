// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'method_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MethodStats {


/// Create a copy of MethodStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MethodStatsCopyWith<MethodStats> get copyWith => _$MethodStatsCopyWithImpl<MethodStats>(this as MethodStats, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MethodStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MethodStats&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.succeeded, _this.succeeded) || other.succeeded == _this.succeeded)&&(identical(other.failed, _this.failed) || other.failed == _this.failed)&&(identical(other.abandoned, _this.abandoned) || other.abandoned == _this.abandoned)&&(identical(other.successRate, _this.successRate) || other.successRate == _this.successRate)&&(identical(other.medianDurationMs, _this.medianDurationMs) || other.medianDurationMs == _this.medianDurationMs)&&const DeepCollectionEquality().equals(other.errors, _this.errors)&&const DeepCollectionEquality().equals(other.stoppedAt, _this.stoppedAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as MethodStats;
  return Object.hash(runtimeType,_this.method,_this.attempts,_this.succeeded,_this.failed,_this.abandoned,_this.successRate,_this.medianDurationMs,const DeepCollectionEquality().hash(_this.errors),const DeepCollectionEquality().hash(_this.stoppedAt),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as MethodStats;
  return 'MethodStats(method: ${_this.method}, attempts: ${_this.attempts}, succeeded: ${_this.succeeded}, failed: ${_this.failed}, abandoned: ${_this.abandoned}, successRate: ${_this.successRate}, medianDurationMs: ${_this.medianDurationMs}, errors: ${_this.errors}, stoppedAt: ${_this.stoppedAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $MethodStatsCopyWith<$Res>  {
  factory $MethodStatsCopyWith(MethodStats value, $Res Function(MethodStats) _then) = _$MethodStatsCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true, fromJson: MethodStats._read_method, toJson: MethodStats._write_method) PairingMethodId method,@JsonKey(required: true, disallowNullValue: true, fromJson: MethodStats._read_attempts, toJson: MethodStats._write_attempts) int attempts,@JsonKey(required: true, disallowNullValue: true, fromJson: MethodStats._read_succeeded, toJson: MethodStats._write_succeeded) int succeeded,@JsonKey(required: true, disallowNullValue: true, fromJson: MethodStats._read_failed, toJson: MethodStats._write_failed) int failed,@JsonKey(required: true, disallowNullValue: true, fromJson: MethodStats._read_abandoned, toJson: MethodStats._write_abandoned) int abandoned,@JsonKey(name: "success_rate", required: true, disallowNullValue: true) num successRate,@JsonKey(name: "median_duration_ms", required: true, fromJson: MethodStats._read_medianDurationMs, toJson: MethodStats._write_medianDurationMs) int? medianDurationMs,@JsonKey(required: true, disallowNullValue: true) List<StatCount> errors,@JsonKey(name: "stopped_at", required: true, disallowNullValue: true) List<StatCount> stoppedAt,@JsonKey(readValue: MethodStats._extras, fromJson: MethodStats._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$MethodStatsCopyWithImpl<$Res>
    implements $MethodStatsCopyWith<$Res> {
  _$MethodStatsCopyWithImpl(this._self, this._then);

  final MethodStats _self;
  final $Res Function(MethodStats) _then;

/// Create a copy of MethodStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? method = null,Object? attempts = null,Object? succeeded = null,Object? failed = null,Object? abandoned = null,Object? successRate = null,Object? medianDurationMs = freezed,Object? errors = null,Object? stoppedAt = null,Object? additionalProperties = null,}) {
  return _then(MethodStats(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PairingMethodId,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,succeeded: null == succeeded ? _self.succeeded : succeeded // ignore: cast_nullable_to_non_nullable
as int,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as int,abandoned: null == abandoned ? _self.abandoned : abandoned // ignore: cast_nullable_to_non_nullable
as int,successRate: null == successRate ? _self.successRate : successRate // ignore: cast_nullable_to_non_nullable
as num,medianDurationMs: freezed == medianDurationMs ? _self.medianDurationMs : medianDurationMs // ignore: cast_nullable_to_non_nullable
as int?,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<StatCount>,stoppedAt: null == stoppedAt ? _self.stoppedAt : stoppedAt // ignore: cast_nullable_to_non_nullable
as List<StatCount>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [MethodStats].
extension MethodStatsPatterns on MethodStats {
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
