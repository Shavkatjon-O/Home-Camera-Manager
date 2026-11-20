// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'count_total_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CountTotalRead {


/// Create a copy of CountTotalRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountTotalReadCopyWith<CountTotalRead> get copyWith => _$CountTotalReadCopyWithImpl<CountTotalRead>(this as CountTotalRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CountTotalRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountTotalRead&&(identical(other.lineUuid, _this.lineUuid) || other.lineUuid == _this.lineUuid)&&(identical(other.in2, _this.in2) || other.in2 == _this.in2)&&(identical(other.out, _this.out) || other.out == _this.out)&&const DeepCollectionEquality().equals(other.labels, _this.labels)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as CountTotalRead;
  return Object.hash(runtimeType,_this.lineUuid,_this.in2,_this.out,const DeepCollectionEquality().hash(_this.labels),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as CountTotalRead;
  return 'CountTotalRead(lineUuid: ${_this.lineUuid}, in2: ${_this.in2}, out: ${_this.out}, labels: ${_this.labels}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $CountTotalReadCopyWith<$Res>  {
  factory $CountTotalReadCopyWith(CountTotalRead value, $Res Function(CountTotalRead) _then) = _$CountTotalReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "line_uuid", required: true, disallowNullValue: true) String lineUuid,@JsonKey(name: "in", required: true, disallowNullValue: true, fromJson: CountTotalRead._read_in2, toJson: CountTotalRead._write_in2) int in2,@JsonKey(required: true, disallowNullValue: true, fromJson: CountTotalRead._read_out, toJson: CountTotalRead._write_out) int out,@JsonKey(required: true, disallowNullValue: true, fromJson: CountTotalRead._read_labels, toJson: CountTotalRead._write_labels) Map<String, Map<String, int>> labels,@JsonKey(readValue: CountTotalRead._extras, fromJson: CountTotalRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$CountTotalReadCopyWithImpl<$Res>
    implements $CountTotalReadCopyWith<$Res> {
  _$CountTotalReadCopyWithImpl(this._self, this._then);

  final CountTotalRead _self;
  final $Res Function(CountTotalRead) _then;

/// Create a copy of CountTotalRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineUuid = null,Object? in2 = null,Object? out = null,Object? labels = null,Object? additionalProperties = null,}) {
  return _then(CountTotalRead(
lineUuid: null == lineUuid ? _self.lineUuid : lineUuid // ignore: cast_nullable_to_non_nullable
as String,in2: null == in2 ? _self.in2 : in2 // ignore: cast_nullable_to_non_nullable
as int,out: null == out ? _self.out : out // ignore: cast_nullable_to_non_nullable
as int,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, int>>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [CountTotalRead].
extension CountTotalReadPatterns on CountTotalRead {
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
