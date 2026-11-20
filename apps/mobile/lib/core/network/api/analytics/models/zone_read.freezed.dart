// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zone_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ZoneRead {


/// Create a copy of ZoneRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZoneReadCopyWith<ZoneRead> get copyWith => _$ZoneReadCopyWithImpl<ZoneRead>(this as ZoneRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ZoneRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZoneRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.polygon, _this.polygon)&&(identical(other.wholeView, _this.wholeView) || other.wholeView == _this.wholeView)&&const DeepCollectionEquality().equals(other.labels, _this.labels)&&(identical(other.minDwell, _this.minDwell) || other.minDwell == _this.minDwell)&&(identical(other.loiterSeconds, _this.loiterSeconds) || other.loiterSeconds == _this.loiterSeconds)&&(identical(other.crowdCount, _this.crowdCount) || other.crowdCount == _this.crowdCount)&&const DeepCollectionEquality().equals(other.schedule, _this.schedule)&&const DeepCollectionEquality().equals(other.alert, _this.alert)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.suspended, _this.suspended) || other.suspended == _this.suspended)&&(identical(other.leftSeconds, _this.leftSeconds) || other.leftSeconds == _this.leftSeconds)&&(identical(other.takenSeconds, _this.takenSeconds) || other.takenSeconds == _this.takenSeconds)&&const DeepCollectionEquality().equals(other.objectLabels, _this.objectLabels)&&(identical(other.background, _this.background) || other.background == _this.background)&&(identical(other.animals, _this.animals) || other.animals == _this.animals)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as ZoneRead;
  return Object.hashAll([runtimeType,_this.uuid,_this.name,const DeepCollectionEquality().hash(_this.polygon),_this.wholeView,const DeepCollectionEquality().hash(_this.labels),_this.minDwell,_this.loiterSeconds,_this.crowdCount,const DeepCollectionEquality().hash(_this.schedule),const DeepCollectionEquality().hash(_this.alert),_this.enabled,_this.reference,_this.suspended,_this.leftSeconds,_this.takenSeconds,const DeepCollectionEquality().hash(_this.objectLabels),_this.background,_this.animals,const DeepCollectionEquality().hash(_this.additionalProperties)]);
}

@override
String toString() {
  final _this = this as ZoneRead;
  return 'ZoneRead(uuid: ${_this.uuid}, name: ${_this.name}, polygon: ${_this.polygon}, wholeView: ${_this.wholeView}, labels: ${_this.labels}, minDwell: ${_this.minDwell}, loiterSeconds: ${_this.loiterSeconds}, crowdCount: ${_this.crowdCount}, schedule: ${_this.schedule}, alert: ${_this.alert}, enabled: ${_this.enabled}, reference: ${_this.reference}, suspended: ${_this.suspended}, leftSeconds: ${_this.leftSeconds}, takenSeconds: ${_this.takenSeconds}, objectLabels: ${_this.objectLabels}, background: ${_this.background}, animals: ${_this.animals}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ZoneReadCopyWith<$Res>  {
  factory $ZoneReadCopyWith(ZoneRead value, $Res Function(ZoneRead) _then) = _$ZoneReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true, disallowNullValue: true) List<List<num>> polygon,@JsonKey(name: "whole_view", required: true, disallowNullValue: true) bool wholeView,@JsonKey(required: true, disallowNullValue: true) List<String> labels,@JsonKey(name: "min_dwell", required: true, disallowNullValue: true) num minDwell,@JsonKey(name: "loiter_seconds", required: true, disallowNullValue: true) num loiterSeconds,@JsonKey(name: "crowd_count", required: true, disallowNullValue: true, fromJson: ZoneRead._read_crowdCount, toJson: ZoneRead._write_crowdCount) int crowdCount,@JsonKey(required: true, disallowNullValue: true) List<Map<String, Object?>> schedule,@JsonKey(required: true, disallowNullValue: true) Map<String, Object?> alert,@JsonKey(required: true, disallowNullValue: true) bool enabled,@JsonKey(required: true) String? reference,@JsonKey(required: true, disallowNullValue: true) bool suspended,@JsonKey(name: "left_seconds", disallowNullValue: true, readValue: ZoneRead._presentValue, fromJson: ZoneRead._read_leftSeconds, toJson: ZoneRead._write_leftSeconds) num leftSeconds,@JsonKey(name: "taken_seconds", disallowNullValue: true, readValue: ZoneRead._presentValue, fromJson: ZoneRead._read_takenSeconds, toJson: ZoneRead._write_takenSeconds) num takenSeconds,@JsonKey(name: "object_labels", disallowNullValue: true, readValue: ZoneRead._presentValue, fromJson: ZoneRead._read_objectLabels, toJson: ZoneRead._write_objectLabels) List<String> objectLabels,@JsonKey(disallowNullValue: true, readValue: ZoneRead._presentValue, fromJson: ZoneRead._read_background, toJson: ZoneRead._write_background) bool background,@JsonKey(disallowNullValue: true, readValue: ZoneRead._presentValue, fromJson: ZoneRead._read_animals, toJson: ZoneRead._write_animals) AnimalMode animals,@JsonKey(readValue: ZoneRead._extras, fromJson: ZoneRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$ZoneReadCopyWithImpl<$Res>
    implements $ZoneReadCopyWith<$Res> {
  _$ZoneReadCopyWithImpl(this._self, this._then);

  final ZoneRead _self;
  final $Res Function(ZoneRead) _then;

/// Create a copy of ZoneRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? name = null,Object? polygon = null,Object? wholeView = null,Object? labels = null,Object? minDwell = null,Object? loiterSeconds = null,Object? crowdCount = null,Object? schedule = null,Object? alert = null,Object? enabled = null,Object? reference = freezed,Object? suspended = null,Object? leftSeconds = null,Object? takenSeconds = null,Object? objectLabels = null,Object? background = null,Object? animals = null,Object? additionalProperties = null,}) {
  return _then(ZoneRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,polygon: null == polygon ? _self.polygon : polygon // ignore: cast_nullable_to_non_nullable
as List<List<num>>,wholeView: null == wholeView ? _self.wholeView : wholeView // ignore: cast_nullable_to_non_nullable
as bool,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,minDwell: null == minDwell ? _self.minDwell : minDwell // ignore: cast_nullable_to_non_nullable
as num,loiterSeconds: null == loiterSeconds ? _self.loiterSeconds : loiterSeconds // ignore: cast_nullable_to_non_nullable
as num,crowdCount: null == crowdCount ? _self.crowdCount : crowdCount // ignore: cast_nullable_to_non_nullable
as int,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as List<Map<String, Object?>>,alert: null == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,suspended: null == suspended ? _self.suspended : suspended // ignore: cast_nullable_to_non_nullable
as bool,leftSeconds: null == leftSeconds ? _self.leftSeconds : leftSeconds // ignore: cast_nullable_to_non_nullable
as num,takenSeconds: null == takenSeconds ? _self.takenSeconds : takenSeconds // ignore: cast_nullable_to_non_nullable
as num,objectLabels: null == objectLabels ? _self.objectLabels : objectLabels // ignore: cast_nullable_to_non_nullable
as List<String>,background: null == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as bool,animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as AnimalMode,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [ZoneRead].
extension ZoneReadPatterns on ZoneRead {
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
