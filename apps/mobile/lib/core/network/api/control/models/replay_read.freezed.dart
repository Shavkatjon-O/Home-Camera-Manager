// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'replay_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReplayRead {


/// Create a copy of ReplayRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplayReadCopyWith<ReplayRead> get copyWith => _$ReplayReadCopyWithImpl<ReplayRead>(this as ReplayRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReplayRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplayRead&&(identical(other.active, _this.active) || other.active == _this.active)&&(identical(other.session, _this.session) || other.session == _this.session)&&(identical(other.stream, _this.stream) || other.stream == _this.stream)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as ReplayRead;
  return Object.hash(runtimeType,_this.active,_this.session,_this.stream,_this.start,_this.failure,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as ReplayRead;
  return 'ReplayRead(active: ${_this.active}, session: ${_this.session}, stream: ${_this.stream}, start: ${_this.start}, failure: ${_this.failure}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ReplayReadCopyWith<$Res>  {
  factory $ReplayReadCopyWith(ReplayRead value, $Res Function(ReplayRead) _then) = _$ReplayReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) bool active,@JsonKey(includeIfNull: false) String? session,@JsonKey(includeIfNull: false) String? stream,@JsonKey(includeIfNull: false, fromJson: ReplayRead._read_start, toJson: ReplayRead._write_start) DateTime? start,@JsonKey(includeIfNull: false) String? failure,@JsonKey(readValue: ReplayRead._extras, fromJson: ReplayRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$ReplayReadCopyWithImpl<$Res>
    implements $ReplayReadCopyWith<$Res> {
  _$ReplayReadCopyWithImpl(this._self, this._then);

  final ReplayRead _self;
  final $Res Function(ReplayRead) _then;

/// Create a copy of ReplayRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? active = null,Object? session = freezed,Object? stream = freezed,Object? start = freezed,Object? failure = freezed,Object? additionalProperties = null,}) {
  return _then(ReplayRead(
active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as String?,stream: freezed == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as String?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReplayRead].
extension ReplayReadPatterns on ReplayRead {
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
