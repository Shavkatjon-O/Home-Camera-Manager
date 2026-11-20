// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_source_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventSourceRead {


/// Create a copy of EventSourceRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventSourceReadCopyWith<EventSourceRead> get copyWith => _$EventSourceReadCopyWithImpl<EventSourceRead>(this as EventSourceRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventSourceRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventSourceRead&&(identical(other.cameraUuid, _this.cameraUuid) || other.cameraUuid == _this.cameraUuid)&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.endpoint, _this.endpoint) || other.endpoint == _this.endpoint)&&const DeepCollectionEquality().equals(other.topics, _this.topics)&&const DeepCollectionEquality().equals(other.kinds, _this.kinds)&&const DeepCollectionEquality().equals(other.conditions, _this.conditions)&&(identical(other.connectedAt, _this.connectedAt) || other.connectedAt == _this.connectedAt)&&(identical(other.lastMessageAt, _this.lastMessageAt) || other.lastMessageAt == _this.lastMessageAt)&&(identical(other.error, _this.error) || other.error == _this.error)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as EventSourceRead;
  return Object.hash(runtimeType,_this.cameraUuid,_this.cameraName,_this.state,_this.mode,_this.endpoint,const DeepCollectionEquality().hash(_this.topics),const DeepCollectionEquality().hash(_this.kinds),const DeepCollectionEquality().hash(_this.conditions),_this.connectedAt,_this.lastMessageAt,_this.error,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as EventSourceRead;
  return 'EventSourceRead(cameraUuid: ${_this.cameraUuid}, cameraName: ${_this.cameraName}, state: ${_this.state}, mode: ${_this.mode}, endpoint: ${_this.endpoint}, topics: ${_this.topics}, kinds: ${_this.kinds}, conditions: ${_this.conditions}, connectedAt: ${_this.connectedAt}, lastMessageAt: ${_this.lastMessageAt}, error: ${_this.error}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $EventSourceReadCopyWith<$Res>  {
  factory $EventSourceReadCopyWith(EventSourceRead value, $Res Function(EventSourceRead) _then) = _$EventSourceReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "camera_uuid", required: true, disallowNullValue: true) String cameraUuid,@JsonKey(name: "camera_name", required: true, disallowNullValue: true) String cameraName,@JsonKey(required: true, disallowNullValue: true, fromJson: EventSourceRead._read_state, toJson: EventSourceRead._write_state) SourceState state,@JsonKey(required: true, disallowNullValue: true, fromJson: EventSourceRead._read_mode, toJson: EventSourceRead._write_mode) SourceMode mode,@JsonKey(required: true) String? endpoint,@JsonKey(required: true, disallowNullValue: true) List<String> topics,@JsonKey(required: true, disallowNullValue: true, fromJson: EventSourceRead._read_kinds, toJson: EventSourceRead._write_kinds) List<EventKind> kinds,@JsonKey(required: true, disallowNullValue: true) Map<String, bool> conditions,@JsonKey(name: "connected_at", required: true, fromJson: EventSourceRead._read_connectedAt, toJson: EventSourceRead._write_connectedAt) DateTime? connectedAt,@JsonKey(name: "last_message_at", required: true, fromJson: EventSourceRead._read_lastMessageAt, toJson: EventSourceRead._write_lastMessageAt) DateTime? lastMessageAt,@JsonKey(required: true) String? error,@JsonKey(readValue: EventSourceRead._extras, fromJson: EventSourceRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$EventSourceReadCopyWithImpl<$Res>
    implements $EventSourceReadCopyWith<$Res> {
  _$EventSourceReadCopyWithImpl(this._self, this._then);

  final EventSourceRead _self;
  final $Res Function(EventSourceRead) _then;

/// Create a copy of EventSourceRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cameraUuid = null,Object? cameraName = null,Object? state = null,Object? mode = null,Object? endpoint = freezed,Object? topics = null,Object? kinds = null,Object? conditions = null,Object? connectedAt = freezed,Object? lastMessageAt = freezed,Object? error = freezed,Object? additionalProperties = null,}) {
  return _then(EventSourceRead(
cameraUuid: null == cameraUuid ? _self.cameraUuid : cameraUuid // ignore: cast_nullable_to_non_nullable
as String,cameraName: null == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as SourceState,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as SourceMode,endpoint: freezed == endpoint ? _self.endpoint : endpoint // ignore: cast_nullable_to_non_nullable
as String?,topics: null == topics ? _self.topics : topics // ignore: cast_nullable_to_non_nullable
as List<String>,kinds: null == kinds ? _self.kinds : kinds // ignore: cast_nullable_to_non_nullable
as List<EventKind>,conditions: null == conditions ? _self.conditions : conditions // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,connectedAt: freezed == connectedAt ? _self.connectedAt : connectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [EventSourceRead].
extension EventSourceReadPatterns on EventSourceRead {
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
