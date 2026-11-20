// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sighting_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SightingRead {


/// Create a copy of SightingRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SightingReadCopyWith<SightingRead> get copyWith => _$SightingReadCopyWithImpl<SightingRead>(this as SightingRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SightingRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SightingRead&&(identical(other.eventUuid, _this.eventUuid) || other.eventUuid == _this.eventUuid)&&(identical(other.sampleUuid, _this.sampleUuid) || other.sampleUuid == _this.sampleUuid)&&(identical(other.cameraUuid, _this.cameraUuid) || other.cameraUuid == _this.cameraUuid)&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName)&&(identical(other.viewName, _this.viewName) || other.viewName == _this.viewName)&&(identical(other.seenAt, _this.seenAt) || other.seenAt == _this.seenAt)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as SightingRead;
  return Object.hash(runtimeType,_this.eventUuid,_this.sampleUuid,_this.cameraUuid,_this.cameraName,_this.viewName,_this.seenAt,_this.confidence,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as SightingRead;
  return 'SightingRead(eventUuid: ${_this.eventUuid}, sampleUuid: ${_this.sampleUuid}, cameraUuid: ${_this.cameraUuid}, cameraName: ${_this.cameraName}, viewName: ${_this.viewName}, seenAt: ${_this.seenAt}, confidence: ${_this.confidence}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $SightingReadCopyWith<$Res>  {
  factory $SightingReadCopyWith(SightingRead value, $Res Function(SightingRead) _then) = _$SightingReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "event_uuid", required: true) String? eventUuid,@JsonKey(name: "sample_uuid", required: true, disallowNullValue: true) String sampleUuid,@JsonKey(name: "camera_uuid", required: true) String? cameraUuid,@JsonKey(name: "camera_name", required: true) String? cameraName,@JsonKey(name: "view_name", required: true) String? viewName,@JsonKey(name: "seen_at", required: true, disallowNullValue: true, fromJson: SightingRead._read_seenAt, toJson: SightingRead._write_seenAt) DateTime seenAt,@JsonKey(required: true) num? confidence,@JsonKey(readValue: SightingRead._extras, fromJson: SightingRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$SightingReadCopyWithImpl<$Res>
    implements $SightingReadCopyWith<$Res> {
  _$SightingReadCopyWithImpl(this._self, this._then);

  final SightingRead _self;
  final $Res Function(SightingRead) _then;

/// Create a copy of SightingRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventUuid = freezed,Object? sampleUuid = null,Object? cameraUuid = freezed,Object? cameraName = freezed,Object? viewName = freezed,Object? seenAt = null,Object? confidence = freezed,Object? additionalProperties = null,}) {
  return _then(SightingRead(
eventUuid: freezed == eventUuid ? _self.eventUuid : eventUuid // ignore: cast_nullable_to_non_nullable
as String?,sampleUuid: null == sampleUuid ? _self.sampleUuid : sampleUuid // ignore: cast_nullable_to_non_nullable
as String,cameraUuid: freezed == cameraUuid ? _self.cameraUuid : cameraUuid // ignore: cast_nullable_to_non_nullable
as String?,cameraName: freezed == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String?,viewName: freezed == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String?,seenAt: null == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as num?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [SightingRead].
extension SightingReadPatterns on SightingRead {
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
