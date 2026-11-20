// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clock_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClockRead {


/// Create a copy of ClockRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClockReadCopyWith<ClockRead> get copyWith => _$ClockReadCopyWithImpl<ClockRead>(this as ClockRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ClockRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClockRead&&(identical(other.cameraUtc, _this.cameraUtc) || other.cameraUtc == _this.cameraUtc)&&(identical(other.serverUtc, _this.serverUtc) || other.serverUtc == _this.serverUtc)&&(identical(other.offsetSeconds, _this.offsetSeconds) || other.offsetSeconds == _this.offsetSeconds)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.daylightSavings, _this.daylightSavings) || other.daylightSavings == _this.daylightSavings)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as ClockRead;
  return Object.hash(runtimeType,_this.cameraUtc,_this.serverUtc,_this.offsetSeconds,_this.mode,_this.timezone,_this.daylightSavings,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as ClockRead;
  return 'ClockRead(cameraUtc: ${_this.cameraUtc}, serverUtc: ${_this.serverUtc}, offsetSeconds: ${_this.offsetSeconds}, mode: ${_this.mode}, timezone: ${_this.timezone}, daylightSavings: ${_this.daylightSavings}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ClockReadCopyWith<$Res>  {
  factory $ClockReadCopyWith(ClockRead value, $Res Function(ClockRead) _then) = _$ClockReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "camera_utc", required: true, fromJson: ClockRead._read_cameraUtc, toJson: ClockRead._write_cameraUtc) DateTime? cameraUtc,@JsonKey(name: "server_utc", required: true, disallowNullValue: true, fromJson: ClockRead._read_serverUtc, toJson: ClockRead._write_serverUtc) DateTime serverUtc,@JsonKey(name: "offset_seconds", required: true) num? offsetSeconds,@JsonKey(required: true) String? mode,@JsonKey(required: true) String? timezone,@JsonKey(name: "daylight_savings", required: true) bool? daylightSavings,@JsonKey(readValue: ClockRead._extras, fromJson: ClockRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$ClockReadCopyWithImpl<$Res>
    implements $ClockReadCopyWith<$Res> {
  _$ClockReadCopyWithImpl(this._self, this._then);

  final ClockRead _self;
  final $Res Function(ClockRead) _then;

/// Create a copy of ClockRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cameraUtc = freezed,Object? serverUtc = null,Object? offsetSeconds = freezed,Object? mode = freezed,Object? timezone = freezed,Object? daylightSavings = freezed,Object? additionalProperties = null,}) {
  return _then(ClockRead(
cameraUtc: freezed == cameraUtc ? _self.cameraUtc : cameraUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,serverUtc: null == serverUtc ? _self.serverUtc : serverUtc // ignore: cast_nullable_to_non_nullable
as DateTime,offsetSeconds: freezed == offsetSeconds ? _self.offsetSeconds : offsetSeconds // ignore: cast_nullable_to_non_nullable
as num?,mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,daylightSavings: freezed == daylightSavings ? _self.daylightSavings : daylightSavings // ignore: cast_nullable_to_non_nullable
as bool?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [ClockRead].
extension ClockReadPatterns on ClockRead {
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
