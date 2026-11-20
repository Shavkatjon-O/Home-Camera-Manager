// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'counts_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CountsRead {


/// Create a copy of CountsRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountsReadCopyWith<CountsRead> get copyWith => _$CountsReadCopyWithImpl<CountsRead>(this as CountsRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CountsRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountsRead&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.bucket, _this.bucket) || other.bucket == _this.bucket)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&const DeepCollectionEquality().equals(other.buckets, _this.buckets)&&const DeepCollectionEquality().equals(other.totals, _this.totals)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as CountsRead;
  return Object.hash(runtimeType,_this.start,_this.end,_this.bucket,_this.timezone,const DeepCollectionEquality().hash(_this.lines),const DeepCollectionEquality().hash(_this.buckets),const DeepCollectionEquality().hash(_this.totals),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as CountsRead;
  return 'CountsRead(start: ${_this.start}, end: ${_this.end}, bucket: ${_this.bucket}, timezone: ${_this.timezone}, lines: ${_this.lines}, buckets: ${_this.buckets}, totals: ${_this.totals}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $CountsReadCopyWith<$Res>  {
  factory $CountsReadCopyWith(CountsRead value, $Res Function(CountsRead) _then) = _$CountsReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true, fromJson: CountsRead._read_start, toJson: CountsRead._write_start) DateTime start,@JsonKey(required: true, disallowNullValue: true, fromJson: CountsRead._read_end, toJson: CountsRead._write_end) DateTime end,@JsonKey(required: true, disallowNullValue: true, fromJson: CountsRead._read_bucket, toJson: CountsRead._write_bucket) CountsReadBucket bucket,@JsonKey(required: true, disallowNullValue: true) String timezone,@JsonKey(required: true, disallowNullValue: true) List<CountLineRead> lines,@JsonKey(required: true, disallowNullValue: true) List<CountBucketRead> buckets,@JsonKey(required: true, disallowNullValue: true) List<CountTotalRead> totals,@JsonKey(readValue: CountsRead._extras, fromJson: CountsRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$CountsReadCopyWithImpl<$Res>
    implements $CountsReadCopyWith<$Res> {
  _$CountsReadCopyWithImpl(this._self, this._then);

  final CountsRead _self;
  final $Res Function(CountsRead) _then;

/// Create a copy of CountsRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = null,Object? bucket = null,Object? timezone = null,Object? lines = null,Object? buckets = null,Object? totals = null,Object? additionalProperties = null,}) {
  return _then(CountsRead(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as CountsReadBucket,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CountLineRead>,buckets: null == buckets ? _self.buckets : buckets // ignore: cast_nullable_to_non_nullable
as List<CountBucketRead>,totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as List<CountTotalRead>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [CountsRead].
extension CountsReadPatterns on CountsRead {
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
