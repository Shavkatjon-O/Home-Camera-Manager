// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'similar_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SimilarRead {


/// Create a copy of SimilarRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SimilarReadCopyWith<SimilarRead> get copyWith => _$SimilarReadCopyWithImpl<SimilarRead>(this as SimilarRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SimilarRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SimilarRead&&(identical(other.sampleUuid, _this.sampleUuid) || other.sampleUuid == _this.sampleUuid)&&(identical(other.score, _this.score) || other.score == _this.score)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.seenAt, _this.seenAt) || other.seenAt == _this.seenAt)&&(identical(other.hasCrop, _this.hasCrop) || other.hasCrop == _this.hasCrop)&&(identical(other.personUuid, _this.personUuid) || other.personUuid == _this.personUuid)&&(identical(other.personName, _this.personName) || other.personName == _this.personName)&&(identical(other.personColor, _this.personColor) || other.personColor == _this.personColor)&&(identical(other.clusterUuid, _this.clusterUuid) || other.clusterUuid == _this.clusterUuid)&&(identical(other.clusterLabel, _this.clusterLabel) || other.clusterLabel == _this.clusterLabel)&&(identical(other.eventUuid, _this.eventUuid) || other.eventUuid == _this.eventUuid)&&(identical(other.cameraUuid, _this.cameraUuid) || other.cameraUuid == _this.cameraUuid)&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName)&&(identical(other.viewName, _this.viewName) || other.viewName == _this.viewName)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as SimilarRead;
  return Object.hash(runtimeType,_this.sampleUuid,_this.score,_this.source,_this.seenAt,_this.hasCrop,_this.personUuid,_this.personName,_this.personColor,_this.clusterUuid,_this.clusterLabel,_this.eventUuid,_this.cameraUuid,_this.cameraName,_this.viewName,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as SimilarRead;
  return 'SimilarRead(sampleUuid: ${_this.sampleUuid}, score: ${_this.score}, source: ${_this.source}, seenAt: ${_this.seenAt}, hasCrop: ${_this.hasCrop}, personUuid: ${_this.personUuid}, personName: ${_this.personName}, personColor: ${_this.personColor}, clusterUuid: ${_this.clusterUuid}, clusterLabel: ${_this.clusterLabel}, eventUuid: ${_this.eventUuid}, cameraUuid: ${_this.cameraUuid}, cameraName: ${_this.cameraName}, viewName: ${_this.viewName}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $SimilarReadCopyWith<$Res>  {
  factory $SimilarReadCopyWith(SimilarRead value, $Res Function(SimilarRead) _then) = _$SimilarReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "sample_uuid", required: true, disallowNullValue: true) String sampleUuid,@JsonKey(required: true, disallowNullValue: true) num score,@JsonKey(required: true, disallowNullValue: true, fromJson: SimilarRead._read_source, toJson: SimilarRead._write_source) SampleSource source,@JsonKey(name: "seen_at", required: true, disallowNullValue: true, fromJson: SimilarRead._read_seenAt, toJson: SimilarRead._write_seenAt) DateTime seenAt,@JsonKey(name: "has_crop", required: true, disallowNullValue: true) bool hasCrop,@JsonKey(name: "person_uuid", required: true) String? personUuid,@JsonKey(name: "person_name", required: true) String? personName,@JsonKey(name: "person_color", required: true) String? personColor,@JsonKey(name: "cluster_uuid", required: true) String? clusterUuid,@JsonKey(name: "cluster_label", required: true) String? clusterLabel,@JsonKey(name: "event_uuid", required: true) String? eventUuid,@JsonKey(name: "camera_uuid", required: true) String? cameraUuid,@JsonKey(name: "camera_name", required: true) String? cameraName,@JsonKey(name: "view_name", required: true) String? viewName,@JsonKey(readValue: SimilarRead._extras, fromJson: SimilarRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$SimilarReadCopyWithImpl<$Res>
    implements $SimilarReadCopyWith<$Res> {
  _$SimilarReadCopyWithImpl(this._self, this._then);

  final SimilarRead _self;
  final $Res Function(SimilarRead) _then;

/// Create a copy of SimilarRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sampleUuid = null,Object? score = null,Object? source = null,Object? seenAt = null,Object? hasCrop = null,Object? personUuid = freezed,Object? personName = freezed,Object? personColor = freezed,Object? clusterUuid = freezed,Object? clusterLabel = freezed,Object? eventUuid = freezed,Object? cameraUuid = freezed,Object? cameraName = freezed,Object? viewName = freezed,Object? additionalProperties = null,}) {
  return _then(SimilarRead(
sampleUuid: null == sampleUuid ? _self.sampleUuid : sampleUuid // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as num,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SampleSource,seenAt: null == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime,hasCrop: null == hasCrop ? _self.hasCrop : hasCrop // ignore: cast_nullable_to_non_nullable
as bool,personUuid: freezed == personUuid ? _self.personUuid : personUuid // ignore: cast_nullable_to_non_nullable
as String?,personName: freezed == personName ? _self.personName : personName // ignore: cast_nullable_to_non_nullable
as String?,personColor: freezed == personColor ? _self.personColor : personColor // ignore: cast_nullable_to_non_nullable
as String?,clusterUuid: freezed == clusterUuid ? _self.clusterUuid : clusterUuid // ignore: cast_nullable_to_non_nullable
as String?,clusterLabel: freezed == clusterLabel ? _self.clusterLabel : clusterLabel // ignore: cast_nullable_to_non_nullable
as String?,eventUuid: freezed == eventUuid ? _self.eventUuid : eventUuid // ignore: cast_nullable_to_non_nullable
as String?,cameraUuid: freezed == cameraUuid ? _self.cameraUuid : cameraUuid // ignore: cast_nullable_to_non_nullable
as String?,cameraName: freezed == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String?,viewName: freezed == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [SimilarRead].
extension SimilarReadPatterns on SimilarRead {
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
