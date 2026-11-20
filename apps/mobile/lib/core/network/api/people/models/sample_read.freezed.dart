// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sample_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SampleRead {


/// Create a copy of SampleRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SampleReadCopyWith<SampleRead> get copyWith => _$SampleReadCopyWithImpl<SampleRead>(this as SampleRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SampleRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SampleRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.quality, _this.quality) || other.quality == _this.quality)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.seenAt, _this.seenAt) || other.seenAt == _this.seenAt)&&(identical(other.hasCrop, _this.hasCrop) || other.hasCrop == _this.hasCrop)&&(identical(other.eventUuid, _this.eventUuid) || other.eventUuid == _this.eventUuid)&&(identical(other.cameraUuid, _this.cameraUuid) || other.cameraUuid == _this.cameraUuid)&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName)&&(identical(other.viewName, _this.viewName) || other.viewName == _this.viewName)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as SampleRead;
  return Object.hash(runtimeType,_this.uuid,_this.source,_this.quality,_this.confidence,_this.seenAt,_this.hasCrop,_this.eventUuid,_this.cameraUuid,_this.cameraName,_this.viewName,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as SampleRead;
  return 'SampleRead(uuid: ${_this.uuid}, source: ${_this.source}, quality: ${_this.quality}, confidence: ${_this.confidence}, seenAt: ${_this.seenAt}, hasCrop: ${_this.hasCrop}, eventUuid: ${_this.eventUuid}, cameraUuid: ${_this.cameraUuid}, cameraName: ${_this.cameraName}, viewName: ${_this.viewName}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $SampleReadCopyWith<$Res>  {
  factory $SampleReadCopyWith(SampleRead value, $Res Function(SampleRead) _then) = _$SampleReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true, fromJson: SampleRead._read_source, toJson: SampleRead._write_source) SampleSource source,@JsonKey(required: true, disallowNullValue: true) num quality,@JsonKey(required: true) num? confidence,@JsonKey(name: "seen_at", required: true, disallowNullValue: true, fromJson: SampleRead._read_seenAt, toJson: SampleRead._write_seenAt) DateTime seenAt,@JsonKey(name: "has_crop", required: true, disallowNullValue: true) bool hasCrop,@JsonKey(name: "event_uuid", required: true) String? eventUuid,@JsonKey(name: "camera_uuid", required: true) String? cameraUuid,@JsonKey(name: "camera_name", required: true) String? cameraName,@JsonKey(name: "view_name", required: true) String? viewName,@JsonKey(readValue: SampleRead._extras, fromJson: SampleRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$SampleReadCopyWithImpl<$Res>
    implements $SampleReadCopyWith<$Res> {
  _$SampleReadCopyWithImpl(this._self, this._then);

  final SampleRead _self;
  final $Res Function(SampleRead) _then;

/// Create a copy of SampleRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? source = null,Object? quality = null,Object? confidence = freezed,Object? seenAt = null,Object? hasCrop = null,Object? eventUuid = freezed,Object? cameraUuid = freezed,Object? cameraName = freezed,Object? viewName = freezed,Object? additionalProperties = null,}) {
  return _then(SampleRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SampleSource,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as num,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as num?,seenAt: null == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime,hasCrop: null == hasCrop ? _self.hasCrop : hasCrop // ignore: cast_nullable_to_non_nullable
as bool,eventUuid: freezed == eventUuid ? _self.eventUuid : eventUuid // ignore: cast_nullable_to_non_nullable
as String?,cameraUuid: freezed == cameraUuid ? _self.cameraUuid : cameraUuid // ignore: cast_nullable_to_non_nullable
as String?,cameraName: freezed == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String?,viewName: freezed == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [SampleRead].
extension SampleReadPatterns on SampleRead {
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
