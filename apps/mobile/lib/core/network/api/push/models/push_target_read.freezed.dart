// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'push_target_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PushTargetRead {


/// Create a copy of PushTargetRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PushTargetReadCopyWith<PushTargetRead> get copyWith => _$PushTargetReadCopyWithImpl<PushTargetRead>(this as PushTargetRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PushTargetRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PushTargetRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.lastSuccessAt, _this.lastSuccessAt) || other.lastSuccessAt == _this.lastSuccessAt)&&(identical(other.lastError, _this.lastError) || other.lastError == _this.lastError)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as PushTargetRead;
  return Object.hash(runtimeType,_this.uuid,_this.provider,_this.token,_this.enabled,_this.lastSuccessAt,_this.lastError,_this.createdAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as PushTargetRead;
  return 'PushTargetRead(uuid: ${_this.uuid}, provider: ${_this.provider}, token: ${_this.token}, enabled: ${_this.enabled}, lastSuccessAt: ${_this.lastSuccessAt}, lastError: ${_this.lastError}, createdAt: ${_this.createdAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $PushTargetReadCopyWith<$Res>  {
  factory $PushTargetReadCopyWith(PushTargetRead value, $Res Function(PushTargetRead) _then) = _$PushTargetReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true, fromJson: PushTargetRead._read_provider, toJson: PushTargetRead._write_provider) PushProvider provider,@JsonKey(required: true, disallowNullValue: true) String token,@JsonKey(required: true, disallowNullValue: true) bool enabled,@JsonKey(name: "last_success_at", required: true, fromJson: PushTargetRead._read_lastSuccessAt, toJson: PushTargetRead._write_lastSuccessAt) DateTime? lastSuccessAt,@JsonKey(name: "last_error", required: true) String? lastError,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: PushTargetRead._read_createdAt, toJson: PushTargetRead._write_createdAt) DateTime createdAt,@JsonKey(readValue: PushTargetRead._extras, fromJson: PushTargetRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$PushTargetReadCopyWithImpl<$Res>
    implements $PushTargetReadCopyWith<$Res> {
  _$PushTargetReadCopyWithImpl(this._self, this._then);

  final PushTargetRead _self;
  final $Res Function(PushTargetRead) _then;

/// Create a copy of PushTargetRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? provider = null,Object? token = null,Object? enabled = null,Object? lastSuccessAt = freezed,Object? lastError = freezed,Object? createdAt = null,Object? additionalProperties = null,}) {
  return _then(PushTargetRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as PushProvider,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,lastSuccessAt: freezed == lastSuccessAt ? _self.lastSuccessAt : lastSuccessAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [PushTargetRead].
extension PushTargetReadPatterns on PushTargetRead {
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
