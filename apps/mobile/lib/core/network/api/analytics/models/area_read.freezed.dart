// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'area_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AreaRead {


/// Create a copy of AreaRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AreaReadCopyWith<AreaRead> get copyWith => _$AreaReadCopyWithImpl<AreaRead>(this as AreaRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AreaRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AreaRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.occupancy, _this.occupancy) || other.occupancy == _this.occupancy)&&(identical(other.entered, _this.entered) || other.entered == _this.entered)&&(identical(other.exited, _this.exited) || other.exited == _this.exited)&&(identical(other.since, _this.since) || other.since == _this.since)&&(identical(other.resetAt, _this.resetAt) || other.resetAt == _this.resetAt)&&const DeepCollectionEquality().equals(other.labels, _this.labels)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as AreaRead;
  return Object.hash(runtimeType,_this.uuid,_this.name,_this.occupancy,_this.entered,_this.exited,_this.since,_this.resetAt,const DeepCollectionEquality().hash(_this.labels),const DeepCollectionEquality().hash(_this.lines),_this.updatedAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as AreaRead;
  return 'AreaRead(uuid: ${_this.uuid}, name: ${_this.name}, occupancy: ${_this.occupancy}, entered: ${_this.entered}, exited: ${_this.exited}, since: ${_this.since}, resetAt: ${_this.resetAt}, labels: ${_this.labels}, lines: ${_this.lines}, updatedAt: ${_this.updatedAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $AreaReadCopyWith<$Res>  {
  factory $AreaReadCopyWith(AreaRead value, $Res Function(AreaRead) _then) = _$AreaReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true, disallowNullValue: true, fromJson: AreaRead._read_occupancy, toJson: AreaRead._write_occupancy) int occupancy,@JsonKey(required: true, disallowNullValue: true, fromJson: AreaRead._read_entered, toJson: AreaRead._write_entered) int entered,@JsonKey(required: true, disallowNullValue: true, fromJson: AreaRead._read_exited, toJson: AreaRead._write_exited) int exited,@JsonKey(required: true, disallowNullValue: true, fromJson: AreaRead._read_since, toJson: AreaRead._write_since) DateTime since,@JsonKey(name: "reset_at", required: true) String? resetAt,@JsonKey(required: true, disallowNullValue: true) List<String> labels,@JsonKey(required: true, disallowNullValue: true) List<AreaLineRead> lines,@JsonKey(name: "updated_at", required: true, disallowNullValue: true, fromJson: AreaRead._read_updatedAt, toJson: AreaRead._write_updatedAt) DateTime updatedAt,@JsonKey(readValue: AreaRead._extras, fromJson: AreaRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$AreaReadCopyWithImpl<$Res>
    implements $AreaReadCopyWith<$Res> {
  _$AreaReadCopyWithImpl(this._self, this._then);

  final AreaRead _self;
  final $Res Function(AreaRead) _then;

/// Create a copy of AreaRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? name = null,Object? occupancy = null,Object? entered = null,Object? exited = null,Object? since = null,Object? resetAt = freezed,Object? labels = null,Object? lines = null,Object? updatedAt = null,Object? additionalProperties = null,}) {
  return _then(AreaRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,occupancy: null == occupancy ? _self.occupancy : occupancy // ignore: cast_nullable_to_non_nullable
as int,entered: null == entered ? _self.entered : entered // ignore: cast_nullable_to_non_nullable
as int,exited: null == exited ? _self.exited : exited // ignore: cast_nullable_to_non_nullable
as int,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as DateTime,resetAt: freezed == resetAt ? _self.resetAt : resetAt // ignore: cast_nullable_to_non_nullable
as String?,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<AreaLineRead>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [AreaRead].
extension AreaReadPatterns on AreaRead {
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
