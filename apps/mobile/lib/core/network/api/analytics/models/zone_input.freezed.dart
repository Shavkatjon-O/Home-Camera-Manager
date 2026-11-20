// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zone_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ZoneInput {


/// Create a copy of ZoneInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZoneInputCopyWith<ZoneInput> get copyWith => _$ZoneInputCopyWithImpl<ZoneInput>(this as ZoneInput, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ZoneInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZoneInput&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.polygon, _this.polygon)&&(identical(other.wholeView, _this.wholeView) || other.wholeView == _this.wholeView)&&const DeepCollectionEquality().equals(other.labels, _this.labels)&&(identical(other.minDwell, _this.minDwell) || other.minDwell == _this.minDwell)&&(identical(other.loiterSeconds, _this.loiterSeconds) || other.loiterSeconds == _this.loiterSeconds)&&(identical(other.crowdCount, _this.crowdCount) || other.crowdCount == _this.crowdCount)&&const DeepCollectionEquality().equals(other.schedule, _this.schedule)&&(identical(other.alert, _this.alert) || other.alert == _this.alert)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.leftSeconds, _this.leftSeconds) || other.leftSeconds == _this.leftSeconds)&&(identical(other.takenSeconds, _this.takenSeconds) || other.takenSeconds == _this.takenSeconds)&&const DeepCollectionEquality().equals(other.objectLabels, _this.objectLabels)&&(identical(other.background, _this.background) || other.background == _this.background)&&(identical(other.animals, _this.animals) || other.animals == _this.animals)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as ZoneInput;
  return Object.hash(runtimeType,_this.uuid,_this.name,const DeepCollectionEquality().hash(_this.polygon),_this.wholeView,const DeepCollectionEquality().hash(_this.labels),_this.minDwell,_this.loiterSeconds,_this.crowdCount,const DeepCollectionEquality().hash(_this.schedule),_this.alert,_this.enabled,_this.reference,_this.leftSeconds,_this.takenSeconds,const DeepCollectionEquality().hash(_this.objectLabels),_this.background,_this.animals,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as ZoneInput;
  return 'ZoneInput(uuid: ${_this.uuid}, name: ${_this.name}, polygon: ${_this.polygon}, wholeView: ${_this.wholeView}, labels: ${_this.labels}, minDwell: ${_this.minDwell}, loiterSeconds: ${_this.loiterSeconds}, crowdCount: ${_this.crowdCount}, schedule: ${_this.schedule}, alert: ${_this.alert}, enabled: ${_this.enabled}, reference: ${_this.reference}, leftSeconds: ${_this.leftSeconds}, takenSeconds: ${_this.takenSeconds}, objectLabels: ${_this.objectLabels}, background: ${_this.background}, animals: ${_this.animals}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ZoneInputCopyWith<$Res>  {
  factory $ZoneInputCopyWith(ZoneInput value, $Res Function(ZoneInput) _then) = _$ZoneInputCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? uuid,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(disallowNullValue: true, includeIfNull: false, fromJson: ZoneInput._read_polygon, toJson: ZoneInput._write_polygon) List<ZoneInputPolygonItem>? polygon,@JsonKey(name: "whole_view", disallowNullValue: true, readValue: ZoneInput._presentValue, fromJson: ZoneInput._read_wholeView, toJson: ZoneInput._write_wholeView) bool wholeView,@JsonKey(disallowNullValue: true, includeIfNull: false) List<String>? labels,@JsonKey(name: "min_dwell", disallowNullValue: true, readValue: ZoneInput._presentValue, fromJson: ZoneInput._read_minDwell, toJson: ZoneInput._write_minDwell) num minDwell,@JsonKey(name: "loiter_seconds", disallowNullValue: true, readValue: ZoneInput._presentValue, fromJson: ZoneInput._read_loiterSeconds, toJson: ZoneInput._write_loiterSeconds) num loiterSeconds,@JsonKey(name: "crowd_count", disallowNullValue: true, readValue: ZoneInput._presentValue, fromJson: ZoneInput._read_crowdCount, toJson: ZoneInput._write_crowdCount) int crowdCount,@JsonKey(disallowNullValue: true, includeIfNull: false) List<Window>? schedule,@JsonKey(disallowNullValue: true, includeIfNull: false) AlertPolicy? alert,@JsonKey(disallowNullValue: true, readValue: ZoneInput._presentValue, fromJson: ZoneInput._read_enabled, toJson: ZoneInput._write_enabled) bool enabled,@JsonKey(includeIfNull: false) String? reference,@JsonKey(name: "left_seconds", disallowNullValue: true, readValue: ZoneInput._presentValue, fromJson: ZoneInput._read_leftSeconds, toJson: ZoneInput._write_leftSeconds) num leftSeconds,@JsonKey(name: "taken_seconds", disallowNullValue: true, readValue: ZoneInput._presentValue, fromJson: ZoneInput._read_takenSeconds, toJson: ZoneInput._write_takenSeconds) num takenSeconds,@JsonKey(name: "object_labels", disallowNullValue: true, includeIfNull: false) List<String>? objectLabels,@JsonKey(disallowNullValue: true, readValue: ZoneInput._presentValue, fromJson: ZoneInput._read_background, toJson: ZoneInput._write_background) bool background,@JsonKey(disallowNullValue: true, readValue: ZoneInput._presentValue, fromJson: ZoneInput._read_animals, toJson: ZoneInput._write_animals) AnimalMode animals,@JsonKey(readValue: ZoneInput._extras, fromJson: ZoneInput._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$AlertPolicyCopyWith<$Res>? get alert;

}
/// @nodoc
class _$ZoneInputCopyWithImpl<$Res>
    implements $ZoneInputCopyWith<$Res> {
  _$ZoneInputCopyWithImpl(this._self, this._then);

  final ZoneInput _self;
  final $Res Function(ZoneInput) _then;

/// Create a copy of ZoneInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = freezed,Object? name = null,Object? polygon = freezed,Object? wholeView = null,Object? labels = freezed,Object? minDwell = null,Object? loiterSeconds = null,Object? crowdCount = null,Object? schedule = freezed,Object? alert = freezed,Object? enabled = null,Object? reference = freezed,Object? leftSeconds = null,Object? takenSeconds = null,Object? objectLabels = freezed,Object? background = null,Object? animals = null,Object? additionalProperties = null,}) {
  return _then(ZoneInput(
uuid: freezed == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,polygon: freezed == polygon ? _self.polygon : polygon // ignore: cast_nullable_to_non_nullable
as List<ZoneInputPolygonItem>?,wholeView: null == wholeView ? _self.wholeView : wholeView // ignore: cast_nullable_to_non_nullable
as bool,labels: freezed == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>?,minDwell: null == minDwell ? _self.minDwell : minDwell // ignore: cast_nullable_to_non_nullable
as num,loiterSeconds: null == loiterSeconds ? _self.loiterSeconds : loiterSeconds // ignore: cast_nullable_to_non_nullable
as num,crowdCount: null == crowdCount ? _self.crowdCount : crowdCount // ignore: cast_nullable_to_non_nullable
as int,schedule: freezed == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as List<Window>?,alert: freezed == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as AlertPolicy?,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,leftSeconds: null == leftSeconds ? _self.leftSeconds : leftSeconds // ignore: cast_nullable_to_non_nullable
as num,takenSeconds: null == takenSeconds ? _self.takenSeconds : takenSeconds // ignore: cast_nullable_to_non_nullable
as num,objectLabels: freezed == objectLabels ? _self.objectLabels : objectLabels // ignore: cast_nullable_to_non_nullable
as List<String>?,background: null == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as bool,animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as AnimalMode,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of ZoneInput
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


/// Adds pattern-matching-related methods to [ZoneInput].
extension ZoneInputPatterns on ZoneInput {
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
