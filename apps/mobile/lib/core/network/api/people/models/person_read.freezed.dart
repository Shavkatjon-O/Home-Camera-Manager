// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'person_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PersonRead {


/// Create a copy of PersonRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonReadCopyWith<PersonRead> get copyWith => _$PersonReadCopyWithImpl<PersonRead>(this as PersonRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PersonRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.sampleCount, _this.sampleCount) || other.sampleCount == _this.sampleCount)&&(identical(other.uploadCount, _this.uploadCount) || other.uploadCount == _this.uploadCount)&&const DeepCollectionEquality().equals(other.samples, _this.samples)&&(identical(other.lastSeenAt, _this.lastSeenAt) || other.lastSeenAt == _this.lastSeenAt)&&const DeepCollectionEquality().equals(other.sightings, _this.sightings)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as PersonRead;
  return Object.hash(runtimeType,_this.uuid,_this.name,_this.notes,_this.color,_this.sampleCount,_this.uploadCount,const DeepCollectionEquality().hash(_this.samples),_this.lastSeenAt,const DeepCollectionEquality().hash(_this.sightings),_this.createdAt,_this.updatedAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as PersonRead;
  return 'PersonRead(uuid: ${_this.uuid}, name: ${_this.name}, notes: ${_this.notes}, color: ${_this.color}, sampleCount: ${_this.sampleCount}, uploadCount: ${_this.uploadCount}, samples: ${_this.samples}, lastSeenAt: ${_this.lastSeenAt}, sightings: ${_this.sightings}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $PersonReadCopyWith<$Res>  {
  factory $PersonReadCopyWith(PersonRead value, $Res Function(PersonRead) _then) = _$PersonReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true) String? notes,@JsonKey(required: true, disallowNullValue: true) String color,@JsonKey(name: "sample_count", required: true, disallowNullValue: true, fromJson: PersonRead._read_sampleCount, toJson: PersonRead._write_sampleCount) int sampleCount,@JsonKey(name: "upload_count", required: true, disallowNullValue: true, fromJson: PersonRead._read_uploadCount, toJson: PersonRead._write_uploadCount) int uploadCount,@JsonKey(required: true, disallowNullValue: true) List<SampleRead> samples,@JsonKey(name: "last_seen_at", required: true, fromJson: PersonRead._read_lastSeenAt, toJson: PersonRead._write_lastSeenAt) DateTime? lastSeenAt,@JsonKey(required: true, disallowNullValue: true) List<SightingRead> sightings,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: PersonRead._read_createdAt, toJson: PersonRead._write_createdAt) DateTime createdAt,@JsonKey(name: "updated_at", required: true, disallowNullValue: true, fromJson: PersonRead._read_updatedAt, toJson: PersonRead._write_updatedAt) DateTime updatedAt,@JsonKey(readValue: PersonRead._extras, fromJson: PersonRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$PersonReadCopyWithImpl<$Res>
    implements $PersonReadCopyWith<$Res> {
  _$PersonReadCopyWithImpl(this._self, this._then);

  final PersonRead _self;
  final $Res Function(PersonRead) _then;

/// Create a copy of PersonRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? name = null,Object? notes = freezed,Object? color = null,Object? sampleCount = null,Object? uploadCount = null,Object? samples = null,Object? lastSeenAt = freezed,Object? sightings = null,Object? createdAt = null,Object? updatedAt = null,Object? additionalProperties = null,}) {
  return _then(PersonRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,sampleCount: null == sampleCount ? _self.sampleCount : sampleCount // ignore: cast_nullable_to_non_nullable
as int,uploadCount: null == uploadCount ? _self.uploadCount : uploadCount // ignore: cast_nullable_to_non_nullable
as int,samples: null == samples ? _self.samples : samples // ignore: cast_nullable_to_non_nullable
as List<SampleRead>,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sightings: null == sightings ? _self.sightings : sightings // ignore: cast_nullable_to_non_nullable
as List<SightingRead>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonRead].
extension PersonReadPatterns on PersonRead {
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
