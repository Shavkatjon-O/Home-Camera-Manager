// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journey_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JourneyRead {


/// Create a copy of JourneyRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JourneyReadCopyWith<JourneyRead> get copyWith => _$JourneyReadCopyWithImpl<JourneyRead>(this as JourneyRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as JourneyRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JourneyRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&const DeepCollectionEquality().equals(other.steps, _this.steps)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as JourneyRead;
  return Object.hash(runtimeType,_this.uuid,_this.description,_this.startedAt,_this.endedAt,const DeepCollectionEquality().hash(_this.steps),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as JourneyRead;
  return 'JourneyRead(uuid: ${_this.uuid}, description: ${_this.description}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt}, steps: ${_this.steps}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $JourneyReadCopyWith<$Res>  {
  factory $JourneyReadCopyWith(JourneyRead value, $Res Function(JourneyRead) _then) = _$JourneyReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String description,@JsonKey(name: "started_at", required: true, disallowNullValue: true, fromJson: JourneyRead._read_startedAt, toJson: JourneyRead._write_startedAt) DateTime startedAt,@JsonKey(name: "ended_at", required: true, disallowNullValue: true, fromJson: JourneyRead._read_endedAt, toJson: JourneyRead._write_endedAt) DateTime endedAt,@JsonKey(required: true, disallowNullValue: true) List<JourneyStepRead> steps,@JsonKey(readValue: JourneyRead._extras, fromJson: JourneyRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$JourneyReadCopyWithImpl<$Res>
    implements $JourneyReadCopyWith<$Res> {
  _$JourneyReadCopyWithImpl(this._self, this._then);

  final JourneyRead _self;
  final $Res Function(JourneyRead) _then;

/// Create a copy of JourneyRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? description = null,Object? startedAt = null,Object? endedAt = null,Object? steps = null,Object? additionalProperties = null,}) {
  return _then(JourneyRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<JourneyStepRead>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [JourneyRead].
extension JourneyReadPatterns on JourneyRead {
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
