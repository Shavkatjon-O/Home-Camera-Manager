// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'face_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FaceRead {


/// Create a copy of FaceRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FaceReadCopyWith<FaceRead> get copyWith => _$FaceReadCopyWithImpl<FaceRead>(this as FaceRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FaceRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FaceRead&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.personUuid, _this.personUuid) || other.personUuid == _this.personUuid)&&(identical(other.personName, _this.personName) || other.personName == _this.personName)&&(identical(other.personColor, _this.personColor) || other.personColor == _this.personColor)&&(identical(other.clusterUuid, _this.clusterUuid) || other.clusterUuid == _this.clusterUuid)&&(identical(other.clusterLabel, _this.clusterLabel) || other.clusterLabel == _this.clusterLabel)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.sampleUuid, _this.sampleUuid) || other.sampleUuid == _this.sampleUuid)&&(identical(other.hasCrop, _this.hasCrop) || other.hasCrop == _this.hasCrop)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as FaceRead;
  return Object.hash(runtimeType,_this.status,_this.personUuid,_this.personName,_this.personColor,_this.clusterUuid,_this.clusterLabel,_this.confidence,_this.sampleUuid,_this.hasCrop,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as FaceRead;
  return 'FaceRead(status: ${_this.status}, personUuid: ${_this.personUuid}, personName: ${_this.personName}, personColor: ${_this.personColor}, clusterUuid: ${_this.clusterUuid}, clusterLabel: ${_this.clusterLabel}, confidence: ${_this.confidence}, sampleUuid: ${_this.sampleUuid}, hasCrop: ${_this.hasCrop}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $FaceReadCopyWith<$Res>  {
  factory $FaceReadCopyWith(FaceRead value, $Res Function(FaceRead) _then) = _$FaceReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true, fromJson: FaceRead._read_status, toJson: FaceRead._write_status) FaceStatus status,@JsonKey(name: "person_uuid", required: true) String? personUuid,@JsonKey(name: "person_name", required: true) String? personName,@JsonKey(name: "person_color", required: true) String? personColor,@JsonKey(name: "cluster_uuid", required: true) String? clusterUuid,@JsonKey(name: "cluster_label", required: true) String? clusterLabel,@JsonKey(required: true) num? confidence,@JsonKey(name: "sample_uuid", required: true) String? sampleUuid,@JsonKey(name: "has_crop", required: true, disallowNullValue: true) bool hasCrop,@JsonKey(readValue: FaceRead._extras, fromJson: FaceRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$FaceReadCopyWithImpl<$Res>
    implements $FaceReadCopyWith<$Res> {
  _$FaceReadCopyWithImpl(this._self, this._then);

  final FaceRead _self;
  final $Res Function(FaceRead) _then;

/// Create a copy of FaceRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? personUuid = freezed,Object? personName = freezed,Object? personColor = freezed,Object? clusterUuid = freezed,Object? clusterLabel = freezed,Object? confidence = freezed,Object? sampleUuid = freezed,Object? hasCrop = null,Object? additionalProperties = null,}) {
  return _then(FaceRead(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FaceStatus,personUuid: freezed == personUuid ? _self.personUuid : personUuid // ignore: cast_nullable_to_non_nullable
as String?,personName: freezed == personName ? _self.personName : personName // ignore: cast_nullable_to_non_nullable
as String?,personColor: freezed == personColor ? _self.personColor : personColor // ignore: cast_nullable_to_non_nullable
as String?,clusterUuid: freezed == clusterUuid ? _self.clusterUuid : clusterUuid // ignore: cast_nullable_to_non_nullable
as String?,clusterLabel: freezed == clusterLabel ? _self.clusterLabel : clusterLabel // ignore: cast_nullable_to_non_nullable
as String?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as num?,sampleUuid: freezed == sampleUuid ? _self.sampleUuid : sampleUuid // ignore: cast_nullable_to_non_nullable
as String?,hasCrop: null == hasCrop ? _self.hasCrop : hasCrop // ignore: cast_nullable_to_non_nullable
as bool,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [FaceRead].
extension FaceReadPatterns on FaceRead {
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
