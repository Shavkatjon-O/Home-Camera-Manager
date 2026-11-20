// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'motion_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MotionRead {


/// Create a copy of MotionRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MotionReadCopyWith<MotionRead> get copyWith => _$MotionReadCopyWithImpl<MotionRead>(this as MotionRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MotionRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MotionRead&&(identical(other.cameraUuid, _this.cameraUuid) || other.cameraUuid == _this.cameraUuid)&&(identical(other.supported, _this.supported) || other.supported == _this.supported)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.sensitivity, _this.sensitivity) || other.sensitivity == _this.sensitivity)&&(identical(other.sensitivityRange, _this.sensitivityRange) || other.sensitivityRange == _this.sensitivityRange)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.activeCells, _this.activeCells) || other.activeCells == _this.activeCells)&&(identical(other.cells, _this.cells) || other.cells == _this.cells)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as MotionRead;
  return Object.hash(runtimeType,_this.cameraUuid,_this.supported,_this.reason,_this.sensitivity,_this.sensitivityRange,_this.enabled,_this.activeCells,_this.cells,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as MotionRead;
  return 'MotionRead(cameraUuid: ${_this.cameraUuid}, supported: ${_this.supported}, reason: ${_this.reason}, sensitivity: ${_this.sensitivity}, sensitivityRange: ${_this.sensitivityRange}, enabled: ${_this.enabled}, activeCells: ${_this.activeCells}, cells: ${_this.cells}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $MotionReadCopyWith<$Res>  {
  factory $MotionReadCopyWith(MotionRead value, $Res Function(MotionRead) _then) = _$MotionReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "camera_uuid", required: true, disallowNullValue: true) String cameraUuid,@JsonKey(required: true, disallowNullValue: true) bool supported,@JsonKey(includeIfNull: false) String? reason,@JsonKey(includeIfNull: false, fromJson: MotionRead._read_sensitivity, toJson: MotionRead._write_sensitivity) int? sensitivity,@JsonKey(name: "sensitivity_range", includeIfNull: false) RangeRead? sensitivityRange,@JsonKey(includeIfNull: false) bool? enabled,@JsonKey(name: "active_cells", includeIfNull: false, fromJson: MotionRead._read_activeCells, toJson: MotionRead._write_activeCells) int? activeCells,@JsonKey(includeIfNull: false, fromJson: MotionRead._read_cells, toJson: MotionRead._write_cells) int? cells,@JsonKey(readValue: MotionRead._extras, fromJson: MotionRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$RangeReadCopyWith<$Res>? get sensitivityRange;

}
/// @nodoc
class _$MotionReadCopyWithImpl<$Res>
    implements $MotionReadCopyWith<$Res> {
  _$MotionReadCopyWithImpl(this._self, this._then);

  final MotionRead _self;
  final $Res Function(MotionRead) _then;

/// Create a copy of MotionRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cameraUuid = null,Object? supported = null,Object? reason = freezed,Object? sensitivity = freezed,Object? sensitivityRange = freezed,Object? enabled = freezed,Object? activeCells = freezed,Object? cells = freezed,Object? additionalProperties = null,}) {
  return _then(MotionRead(
cameraUuid: null == cameraUuid ? _self.cameraUuid : cameraUuid // ignore: cast_nullable_to_non_nullable
as String,supported: null == supported ? _self.supported : supported // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,sensitivity: freezed == sensitivity ? _self.sensitivity : sensitivity // ignore: cast_nullable_to_non_nullable
as int?,sensitivityRange: freezed == sensitivityRange ? _self.sensitivityRange : sensitivityRange // ignore: cast_nullable_to_non_nullable
as RangeRead?,enabled: freezed == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool?,activeCells: freezed == activeCells ? _self.activeCells : activeCells // ignore: cast_nullable_to_non_nullable
as int?,cells: freezed == cells ? _self.cells : cells // ignore: cast_nullable_to_non_nullable
as int?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of MotionRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RangeReadCopyWith<$Res>? get sensitivityRange {
    if (_self.sensitivityRange == null) {
    return null;
  }

  return $RangeReadCopyWith<$Res>(_self.sensitivityRange!, (value) {
    return _then(_self.copyWith(sensitivityRange: value));
  });
}
}


/// Adds pattern-matching-related methods to [MotionRead].
extension MotionReadPatterns on MotionRead {
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
