// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'count_bucket_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CountBucketRead {


/// Create a copy of CountBucketRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountBucketReadCopyWith<CountBucketRead> get copyWith => _$CountBucketReadCopyWithImpl<CountBucketRead>(this as CountBucketRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CountBucketRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountBucketRead&&(identical(other.lineUuid, _this.lineUuid) || other.lineUuid == _this.lineUuid)&&(identical(other.at, _this.at) || other.at == _this.at)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.in2, _this.in2) || other.in2 == _this.in2)&&(identical(other.out, _this.out) || other.out == _this.out)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as CountBucketRead;
  return Object.hash(runtimeType,_this.lineUuid,_this.at,_this.label,_this.in2,_this.out,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as CountBucketRead;
  return 'CountBucketRead(lineUuid: ${_this.lineUuid}, at: ${_this.at}, label: ${_this.label}, in2: ${_this.in2}, out: ${_this.out}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $CountBucketReadCopyWith<$Res>  {
  factory $CountBucketReadCopyWith(CountBucketRead value, $Res Function(CountBucketRead) _then) = _$CountBucketReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "line_uuid", required: true, disallowNullValue: true) String lineUuid,@JsonKey(required: true, disallowNullValue: true, fromJson: CountBucketRead._read_at, toJson: CountBucketRead._write_at) DateTime at,@JsonKey(required: true, disallowNullValue: true) String label,@JsonKey(name: "in", required: true, disallowNullValue: true, fromJson: CountBucketRead._read_in2, toJson: CountBucketRead._write_in2) int in2,@JsonKey(required: true, disallowNullValue: true, fromJson: CountBucketRead._read_out, toJson: CountBucketRead._write_out) int out,@JsonKey(readValue: CountBucketRead._extras, fromJson: CountBucketRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$CountBucketReadCopyWithImpl<$Res>
    implements $CountBucketReadCopyWith<$Res> {
  _$CountBucketReadCopyWithImpl(this._self, this._then);

  final CountBucketRead _self;
  final $Res Function(CountBucketRead) _then;

/// Create a copy of CountBucketRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineUuid = null,Object? at = null,Object? label = null,Object? in2 = null,Object? out = null,Object? additionalProperties = null,}) {
  return _then(CountBucketRead(
lineUuid: null == lineUuid ? _self.lineUuid : lineUuid // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,in2: null == in2 ? _self.in2 : in2 // ignore: cast_nullable_to_non_nullable
as int,out: null == out ? _self.out : out // ignore: cast_nullable_to_non_nullable
as int,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [CountBucketRead].
extension CountBucketReadPatterns on CountBucketRead {
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
