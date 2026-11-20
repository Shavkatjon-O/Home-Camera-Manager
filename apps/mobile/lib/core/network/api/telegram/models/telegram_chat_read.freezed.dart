// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'telegram_chat_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TelegramChatRead {


/// Create a copy of TelegramChatRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TelegramChatReadCopyWith<TelegramChatRead> get copyWith => _$TelegramChatReadCopyWithImpl<TelegramChatRead>(this as TelegramChatRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TelegramChatRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TelegramChatRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.chatType, _this.chatType) || other.chatType == _this.chatType)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.blocked, _this.blocked) || other.blocked == _this.blocked)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as TelegramChatRead;
  return Object.hash(runtimeType,_this.uuid,_this.chatType,_this.title,_this.enabled,_this.blocked,_this.createdAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as TelegramChatRead;
  return 'TelegramChatRead(uuid: ${_this.uuid}, chatType: ${_this.chatType}, title: ${_this.title}, enabled: ${_this.enabled}, blocked: ${_this.blocked}, createdAt: ${_this.createdAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $TelegramChatReadCopyWith<$Res>  {
  factory $TelegramChatReadCopyWith(TelegramChatRead value, $Res Function(TelegramChatRead) _then) = _$TelegramChatReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(name: "chat_type", required: true, disallowNullValue: true) String chatType,@JsonKey(required: true) String? title,@JsonKey(required: true, disallowNullValue: true) bool enabled,@JsonKey(required: true, disallowNullValue: true) bool blocked,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: TelegramChatRead._read_createdAt, toJson: TelegramChatRead._write_createdAt) DateTime createdAt,@JsonKey(readValue: TelegramChatRead._extras, fromJson: TelegramChatRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$TelegramChatReadCopyWithImpl<$Res>
    implements $TelegramChatReadCopyWith<$Res> {
  _$TelegramChatReadCopyWithImpl(this._self, this._then);

  final TelegramChatRead _self;
  final $Res Function(TelegramChatRead) _then;

/// Create a copy of TelegramChatRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? chatType = null,Object? title = freezed,Object? enabled = null,Object? blocked = null,Object? createdAt = null,Object? additionalProperties = null,}) {
  return _then(TelegramChatRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,chatType: null == chatType ? _self.chatType : chatType // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,blocked: null == blocked ? _self.blocked : blocked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [TelegramChatRead].
extension TelegramChatReadPatterns on TelegramChatRead {
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
