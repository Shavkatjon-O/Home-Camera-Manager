// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pairing_attempt_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PairingAttemptRead {


/// Create a copy of PairingAttemptRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PairingAttemptReadCopyWith<PairingAttemptRead> get copyWith => _$PairingAttemptReadCopyWithImpl<PairingAttemptRead>(this as PairingAttemptRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PairingAttemptRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PairingAttemptRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.adapter, _this.adapter) || other.adapter == _this.adapter)&&(identical(other.lastStep, _this.lastStep) || other.lastStep == _this.lastStep)&&(identical(other.outcome, _this.outcome) || other.outcome == _this.outcome)&&(identical(other.errorCode, _this.errorCode) || other.errorCode == _this.errorCode)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as PairingAttemptRead;
  return Object.hash(runtimeType,_this.uuid,_this.method,_this.adapter,_this.lastStep,_this.outcome,_this.errorCode,_this.durationMs,_this.createdAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as PairingAttemptRead;
  return 'PairingAttemptRead(uuid: ${_this.uuid}, method: ${_this.method}, adapter: ${_this.adapter}, lastStep: ${_this.lastStep}, outcome: ${_this.outcome}, errorCode: ${_this.errorCode}, durationMs: ${_this.durationMs}, createdAt: ${_this.createdAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $PairingAttemptReadCopyWith<$Res>  {
  factory $PairingAttemptReadCopyWith(PairingAttemptRead value, $Res Function(PairingAttemptRead) _then) = _$PairingAttemptReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true, fromJson: PairingAttemptRead._read_method, toJson: PairingAttemptRead._write_method) PairingMethodId method,@JsonKey(required: true) String? adapter,@JsonKey(name: "last_step", required: true, disallowNullValue: true) String lastStep,@JsonKey(required: true, disallowNullValue: true, fromJson: PairingAttemptRead._read_outcome, toJson: PairingAttemptRead._write_outcome) AttemptOutcome outcome,@JsonKey(name: "error_code", required: true) String? errorCode,@JsonKey(name: "duration_ms", required: true, disallowNullValue: true, fromJson: PairingAttemptRead._read_durationMs, toJson: PairingAttemptRead._write_durationMs) int durationMs,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: PairingAttemptRead._read_createdAt, toJson: PairingAttemptRead._write_createdAt) DateTime createdAt,@JsonKey(readValue: PairingAttemptRead._extras, fromJson: PairingAttemptRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$PairingAttemptReadCopyWithImpl<$Res>
    implements $PairingAttemptReadCopyWith<$Res> {
  _$PairingAttemptReadCopyWithImpl(this._self, this._then);

  final PairingAttemptRead _self;
  final $Res Function(PairingAttemptRead) _then;

/// Create a copy of PairingAttemptRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? method = null,Object? adapter = freezed,Object? lastStep = null,Object? outcome = null,Object? errorCode = freezed,Object? durationMs = null,Object? createdAt = null,Object? additionalProperties = null,}) {
  return _then(PairingAttemptRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PairingMethodId,adapter: freezed == adapter ? _self.adapter : adapter // ignore: cast_nullable_to_non_nullable
as String?,lastStep: null == lastStep ? _self.lastStep : lastStep // ignore: cast_nullable_to_non_nullable
as String,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as AttemptOutcome,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [PairingAttemptRead].
extension PairingAttemptReadPatterns on PairingAttemptRead {
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
