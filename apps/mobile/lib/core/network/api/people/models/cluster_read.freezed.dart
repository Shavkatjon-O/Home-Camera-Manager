// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cluster_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClusterRead {


/// Create a copy of ClusterRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClusterReadCopyWith<ClusterRead> get copyWith => _$ClusterReadCopyWithImpl<ClusterRead>(this as ClusterRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ClusterRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClusterRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.seenCount, _this.seenCount) || other.seenCount == _this.seenCount)&&(identical(other.firstSeenAt, _this.firstSeenAt) || other.firstSeenAt == _this.firstSeenAt)&&(identical(other.lastSeenAt, _this.lastSeenAt) || other.lastSeenAt == _this.lastSeenAt)&&const DeepCollectionEquality().equals(other.samples, _this.samples)&&const DeepCollectionEquality().equals(other.sightings, _this.sightings)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as ClusterRead;
  return Object.hash(runtimeType,_this.uuid,_this.number,_this.label,_this.seenCount,_this.firstSeenAt,_this.lastSeenAt,const DeepCollectionEquality().hash(_this.samples),const DeepCollectionEquality().hash(_this.sightings),_this.createdAt,_this.updatedAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as ClusterRead;
  return 'ClusterRead(uuid: ${_this.uuid}, number: ${_this.number}, label: ${_this.label}, seenCount: ${_this.seenCount}, firstSeenAt: ${_this.firstSeenAt}, lastSeenAt: ${_this.lastSeenAt}, samples: ${_this.samples}, sightings: ${_this.sightings}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ClusterReadCopyWith<$Res>  {
  factory $ClusterReadCopyWith(ClusterRead value, $Res Function(ClusterRead) _then) = _$ClusterReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true, fromJson: ClusterRead._read_number, toJson: ClusterRead._write_number) int number,@JsonKey(required: true, disallowNullValue: true) String label,@JsonKey(name: "seen_count", required: true, disallowNullValue: true, fromJson: ClusterRead._read_seenCount, toJson: ClusterRead._write_seenCount) int seenCount,@JsonKey(name: "first_seen_at", required: true, disallowNullValue: true, fromJson: ClusterRead._read_firstSeenAt, toJson: ClusterRead._write_firstSeenAt) DateTime firstSeenAt,@JsonKey(name: "last_seen_at", required: true, disallowNullValue: true, fromJson: ClusterRead._read_lastSeenAt, toJson: ClusterRead._write_lastSeenAt) DateTime lastSeenAt,@JsonKey(required: true, disallowNullValue: true) List<SampleRead> samples,@JsonKey(required: true, disallowNullValue: true) List<SightingRead> sightings,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: ClusterRead._read_createdAt, toJson: ClusterRead._write_createdAt) DateTime createdAt,@JsonKey(name: "updated_at", required: true, disallowNullValue: true, fromJson: ClusterRead._read_updatedAt, toJson: ClusterRead._write_updatedAt) DateTime updatedAt,@JsonKey(readValue: ClusterRead._extras, fromJson: ClusterRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$ClusterReadCopyWithImpl<$Res>
    implements $ClusterReadCopyWith<$Res> {
  _$ClusterReadCopyWithImpl(this._self, this._then);

  final ClusterRead _self;
  final $Res Function(ClusterRead) _then;

/// Create a copy of ClusterRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? number = null,Object? label = null,Object? seenCount = null,Object? firstSeenAt = null,Object? lastSeenAt = null,Object? samples = null,Object? sightings = null,Object? createdAt = null,Object? updatedAt = null,Object? additionalProperties = null,}) {
  return _then(ClusterRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,seenCount: null == seenCount ? _self.seenCount : seenCount // ignore: cast_nullable_to_non_nullable
as int,firstSeenAt: null == firstSeenAt ? _self.firstSeenAt : firstSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastSeenAt: null == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,samples: null == samples ? _self.samples : samples // ignore: cast_nullable_to_non_nullable
as List<SampleRead>,sightings: null == sightings ? _self.sightings : sightings // ignore: cast_nullable_to_non_nullable
as List<SightingRead>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [ClusterRead].
extension ClusterReadPatterns on ClusterRead {
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
