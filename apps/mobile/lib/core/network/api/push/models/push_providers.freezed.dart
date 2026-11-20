// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'push_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PushProviders {


/// Create a copy of PushProviders
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PushProvidersCopyWith<PushProviders> get copyWith => _$PushProvidersCopyWithImpl<PushProviders>(this as PushProviders, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PushProviders;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PushProviders&&(identical(other.fcm, _this.fcm) || other.fcm == _this.fcm)&&(identical(other.ntfy, _this.ntfy) || other.ntfy == _this.ntfy)&&(identical(other.ntfyUrl, _this.ntfyUrl) || other.ntfyUrl == _this.ntfyUrl)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as PushProviders;
  return Object.hash(runtimeType,_this.fcm,_this.ntfy,_this.ntfyUrl,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as PushProviders;
  return 'PushProviders(fcm: ${_this.fcm}, ntfy: ${_this.ntfy}, ntfyUrl: ${_this.ntfyUrl}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $PushProvidersCopyWith<$Res>  {
  factory $PushProvidersCopyWith(PushProviders value, $Res Function(PushProviders) _then) = _$PushProvidersCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) bool fcm,@JsonKey(required: true, disallowNullValue: true) bool ntfy,@JsonKey(name: "ntfy_url", required: true) String? ntfyUrl,@JsonKey(readValue: PushProviders._extras, fromJson: PushProviders._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$PushProvidersCopyWithImpl<$Res>
    implements $PushProvidersCopyWith<$Res> {
  _$PushProvidersCopyWithImpl(this._self, this._then);

  final PushProviders _self;
  final $Res Function(PushProviders) _then;

/// Create a copy of PushProviders
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fcm = null,Object? ntfy = null,Object? ntfyUrl = freezed,Object? additionalProperties = null,}) {
  return _then(PushProviders(
fcm: null == fcm ? _self.fcm : fcm // ignore: cast_nullable_to_non_nullable
as bool,ntfy: null == ntfy ? _self.ntfy : ntfy // ignore: cast_nullable_to_non_nullable
as bool,ntfyUrl: freezed == ntfyUrl ? _self.ntfyUrl : ntfyUrl // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [PushProviders].
extension PushProvidersPatterns on PushProviders {
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
