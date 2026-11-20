// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'line_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LineRead {


/// Create a copy of LineRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineReadCopyWith<LineRead> get copyWith => _$LineReadCopyWithImpl<LineRead>(this as LineRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LineRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.points, _this.points)&&const DeepCollectionEquality().equals(other.labels, _this.labels)&&(identical(other.direction, _this.direction) || other.direction == _this.direction)&&const DeepCollectionEquality().equals(other.schedule, _this.schedule)&&const DeepCollectionEquality().equals(other.alert, _this.alert)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.suspended, _this.suspended) || other.suspended == _this.suspended)&&(identical(other.animals, _this.animals) || other.animals == _this.animals)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as LineRead;
  return Object.hash(runtimeType,_this.uuid,_this.name,const DeepCollectionEquality().hash(_this.points),const DeepCollectionEquality().hash(_this.labels),_this.direction,const DeepCollectionEquality().hash(_this.schedule),const DeepCollectionEquality().hash(_this.alert),_this.enabled,_this.reference,_this.suspended,_this.animals,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as LineRead;
  return 'LineRead(uuid: ${_this.uuid}, name: ${_this.name}, points: ${_this.points}, labels: ${_this.labels}, direction: ${_this.direction}, schedule: ${_this.schedule}, alert: ${_this.alert}, enabled: ${_this.enabled}, reference: ${_this.reference}, suspended: ${_this.suspended}, animals: ${_this.animals}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $LineReadCopyWith<$Res>  {
  factory $LineReadCopyWith(LineRead value, $Res Function(LineRead) _then) = _$LineReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true, disallowNullValue: true) List<List<num>> points,@JsonKey(required: true, disallowNullValue: true) List<String> labels,@JsonKey(required: true, disallowNullValue: true, fromJson: LineRead._read_direction, toJson: LineRead._write_direction) LineDirection direction,@JsonKey(required: true, disallowNullValue: true) List<Map<String, Object?>> schedule,@JsonKey(required: true, disallowNullValue: true) Map<String, Object?> alert,@JsonKey(required: true, disallowNullValue: true) bool enabled,@JsonKey(required: true) String? reference,@JsonKey(required: true, disallowNullValue: true) bool suspended,@JsonKey(disallowNullValue: true, readValue: LineRead._presentValue, fromJson: LineRead._read_animals, toJson: LineRead._write_animals) AnimalMode animals,@JsonKey(readValue: LineRead._extras, fromJson: LineRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$LineReadCopyWithImpl<$Res>
    implements $LineReadCopyWith<$Res> {
  _$LineReadCopyWithImpl(this._self, this._then);

  final LineRead _self;
  final $Res Function(LineRead) _then;

/// Create a copy of LineRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? name = null,Object? points = null,Object? labels = null,Object? direction = null,Object? schedule = null,Object? alert = null,Object? enabled = null,Object? reference = freezed,Object? suspended = null,Object? animals = null,Object? additionalProperties = null,}) {
  return _then(LineRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<List<num>>,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as LineDirection,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as List<Map<String, Object?>>,alert: null == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,suspended: null == suspended ? _self.suspended : suspended // ignore: cast_nullable_to_non_nullable
as bool,animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as AnimalMode,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [LineRead].
extension LineReadPatterns on LineRead {
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
