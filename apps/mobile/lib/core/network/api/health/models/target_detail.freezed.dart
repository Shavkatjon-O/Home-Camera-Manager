// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'target_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TargetDetail {


/// Create a copy of TargetDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TargetDetailCopyWith<TargetDetail> get copyWith => _$TargetDetailCopyWithImpl<TargetDetail>(this as TargetDetail, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TargetDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TargetDetail&&(identical(other.range, _this.range) || other.range == _this.range)&&(identical(other.since, _this.since) || other.since == _this.since)&&(identical(other.until, _this.until) || other.until == _this.until)&&(identical(other.bucketSeconds, _this.bucketSeconds) || other.bucketSeconds == _this.bucketSeconds)&&(identical(other.intervalSeconds, _this.intervalSeconds) || other.intervalSeconds == _this.intervalSeconds)&&(identical(other.target, _this.target) || other.target == _this.target)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as TargetDetail;
  return Object.hash(runtimeType,_this.range,_this.since,_this.until,_this.bucketSeconds,_this.intervalSeconds,_this.target,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as TargetDetail;
  return 'TargetDetail(range: ${_this.range}, since: ${_this.since}, until: ${_this.until}, bucketSeconds: ${_this.bucketSeconds}, intervalSeconds: ${_this.intervalSeconds}, target: ${_this.target}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $TargetDetailCopyWith<$Res>  {
  factory $TargetDetailCopyWith(TargetDetail value, $Res Function(TargetDetail) _then) = _$TargetDetailCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true, fromJson: TargetDetail._read_range, toJson: TargetDetail._write_range) HealthRange range,@JsonKey(required: true, disallowNullValue: true, fromJson: TargetDetail._read_since, toJson: TargetDetail._write_since) DateTime since,@JsonKey(required: true, disallowNullValue: true, fromJson: TargetDetail._read_until, toJson: TargetDetail._write_until) DateTime until,@JsonKey(name: "bucket_seconds", required: true, disallowNullValue: true, fromJson: TargetDetail._read_bucketSeconds, toJson: TargetDetail._write_bucketSeconds) int bucketSeconds,@JsonKey(name: "interval_seconds", required: true, disallowNullValue: true, fromJson: TargetDetail._read_intervalSeconds, toJson: TargetDetail._write_intervalSeconds) int intervalSeconds,@JsonKey(required: true, disallowNullValue: true) TargetHealth target,@JsonKey(readValue: TargetDetail._extras, fromJson: TargetDetail._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$TargetHealthCopyWith<$Res> get target;

}
/// @nodoc
class _$TargetDetailCopyWithImpl<$Res>
    implements $TargetDetailCopyWith<$Res> {
  _$TargetDetailCopyWithImpl(this._self, this._then);

  final TargetDetail _self;
  final $Res Function(TargetDetail) _then;

/// Create a copy of TargetDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? range = null,Object? since = null,Object? until = null,Object? bucketSeconds = null,Object? intervalSeconds = null,Object? target = null,Object? additionalProperties = null,}) {
  return _then(TargetDetail(
range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as HealthRange,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as DateTime,until: null == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as DateTime,bucketSeconds: null == bucketSeconds ? _self.bucketSeconds : bucketSeconds // ignore: cast_nullable_to_non_nullable
as int,intervalSeconds: null == intervalSeconds ? _self.intervalSeconds : intervalSeconds // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as TargetHealth,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of TargetDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetHealthCopyWith<$Res> get target {
  
  return $TargetHealthCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}


/// Adds pattern-matching-related methods to [TargetDetail].
extension TargetDetailPatterns on TargetDetail {
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
