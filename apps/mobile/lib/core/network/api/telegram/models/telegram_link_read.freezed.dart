// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'telegram_link_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TelegramLinkRead {


/// Create a copy of TelegramLinkRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TelegramLinkReadCopyWith<TelegramLinkRead> get copyWith => _$TelegramLinkReadCopyWithImpl<TelegramLinkRead>(this as TelegramLinkRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TelegramLinkRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TelegramLinkRead&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.groupUrl, _this.groupUrl) || other.groupUrl == _this.groupUrl)&&(identical(other.bot, _this.bot) || other.bot == _this.bot)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as TelegramLinkRead;
  return Object.hash(runtimeType,_this.url,_this.groupUrl,_this.bot,_this.expiresAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as TelegramLinkRead;
  return 'TelegramLinkRead(url: ${_this.url}, groupUrl: ${_this.groupUrl}, bot: ${_this.bot}, expiresAt: ${_this.expiresAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $TelegramLinkReadCopyWith<$Res>  {
  factory $TelegramLinkReadCopyWith(TelegramLinkRead value, $Res Function(TelegramLinkRead) _then) = _$TelegramLinkReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String url,@JsonKey(name: "group_url", required: true, disallowNullValue: true) String groupUrl,@JsonKey(required: true, disallowNullValue: true) String bot,@JsonKey(name: "expires_at", required: true, disallowNullValue: true, fromJson: TelegramLinkRead._read_expiresAt, toJson: TelegramLinkRead._write_expiresAt) DateTime expiresAt,@JsonKey(readValue: TelegramLinkRead._extras, fromJson: TelegramLinkRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$TelegramLinkReadCopyWithImpl<$Res>
    implements $TelegramLinkReadCopyWith<$Res> {
  _$TelegramLinkReadCopyWithImpl(this._self, this._then);

  final TelegramLinkRead _self;
  final $Res Function(TelegramLinkRead) _then;

/// Create a copy of TelegramLinkRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? groupUrl = null,Object? bot = null,Object? expiresAt = null,Object? additionalProperties = null,}) {
  return _then(TelegramLinkRead(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,groupUrl: null == groupUrl ? _self.groupUrl : groupUrl // ignore: cast_nullable_to_non_nullable
as String,bot: null == bot ? _self.bot : bot // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [TelegramLinkRead].
extension TelegramLinkReadPatterns on TelegramLinkRead {
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
