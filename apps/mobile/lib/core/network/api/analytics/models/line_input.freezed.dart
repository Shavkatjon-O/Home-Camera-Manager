// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'line_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LineInput {


/// Create a copy of LineInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineInputCopyWith<LineInput> get copyWith => _$LineInputCopyWithImpl<LineInput>(this as LineInput, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LineInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineInput&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.points, _this.points) || other.points == _this.points)&&const DeepCollectionEquality().equals(other.labels, _this.labels)&&(identical(other.direction, _this.direction) || other.direction == _this.direction)&&const DeepCollectionEquality().equals(other.schedule, _this.schedule)&&(identical(other.alert, _this.alert) || other.alert == _this.alert)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.animals, _this.animals) || other.animals == _this.animals)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as LineInput;
  return Object.hash(runtimeType,_this.uuid,_this.name,_this.points,const DeepCollectionEquality().hash(_this.labels),_this.direction,const DeepCollectionEquality().hash(_this.schedule),_this.alert,_this.enabled,_this.reference,_this.animals,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as LineInput;
  return 'LineInput(uuid: ${_this.uuid}, name: ${_this.name}, points: ${_this.points}, labels: ${_this.labels}, direction: ${_this.direction}, schedule: ${_this.schedule}, alert: ${_this.alert}, enabled: ${_this.enabled}, reference: ${_this.reference}, animals: ${_this.animals}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $LineInputCopyWith<$Res>  {
  factory $LineInputCopyWith(LineInput value, $Res Function(LineInput) _then) = _$LineInputCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? uuid,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true, fromJson: LineInput._read_points, toJson: LineInput._write_points) LineInputPoints points,@JsonKey(disallowNullValue: true, includeIfNull: false) List<String>? labels,@JsonKey(disallowNullValue: true, readValue: LineInput._presentValue, fromJson: LineInput._read_direction, toJson: LineInput._write_direction) LineDirection direction,@JsonKey(disallowNullValue: true, includeIfNull: false) List<Window>? schedule,@JsonKey(disallowNullValue: true, includeIfNull: false) AlertPolicy? alert,@JsonKey(disallowNullValue: true, readValue: LineInput._presentValue, fromJson: LineInput._read_enabled, toJson: LineInput._write_enabled) bool enabled,@JsonKey(includeIfNull: false) String? reference,@JsonKey(disallowNullValue: true, readValue: LineInput._presentValue, fromJson: LineInput._read_animals, toJson: LineInput._write_animals) AnimalMode animals,@JsonKey(readValue: LineInput._extras, fromJson: LineInput._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$AlertPolicyCopyWith<$Res>? get alert;

}
/// @nodoc
class _$LineInputCopyWithImpl<$Res>
    implements $LineInputCopyWith<$Res> {
  _$LineInputCopyWithImpl(this._self, this._then);

  final LineInput _self;
  final $Res Function(LineInput) _then;

/// Create a copy of LineInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = freezed,Object? name = null,Object? points = null,Object? labels = freezed,Object? direction = null,Object? schedule = freezed,Object? alert = freezed,Object? enabled = null,Object? reference = freezed,Object? animals = null,Object? additionalProperties = null,}) {
  return _then(LineInput(
uuid: freezed == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as LineInputPoints,labels: freezed == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as LineDirection,schedule: freezed == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as List<Window>?,alert: freezed == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as AlertPolicy?,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as AnimalMode,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of LineInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlertPolicyCopyWith<$Res>? get alert {
    if (_self.alert == null) {
    return null;
  }

  return $AlertPolicyCopyWith<$Res>(_self.alert!, (value) {
    return _then(_self.copyWith(alert: value));
  });
}
}


/// Adds pattern-matching-related methods to [LineInput].
extension LineInputPatterns on LineInput {
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
