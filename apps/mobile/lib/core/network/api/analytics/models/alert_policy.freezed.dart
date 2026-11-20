// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_policy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AlertPolicy {


/// Create a copy of AlertPolicy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlertPolicyCopyWith<AlertPolicy> get copyWith => _$AlertPolicyCopyWithImpl<AlertPolicy>(this as AlertPolicy, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AlertPolicy;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlertPolicy&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&const DeepCollectionEquality().equals(other.schedule, _this.schedule)&&const DeepCollectionEquality().equals(other.labels, _this.labels)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as AlertPolicy;
  return Object.hash(runtimeType,_this.mode,const DeepCollectionEquality().hash(_this.schedule),const DeepCollectionEquality().hash(_this.labels),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as AlertPolicy;
  return 'AlertPolicy(mode: ${_this.mode}, schedule: ${_this.schedule}, labels: ${_this.labels}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $AlertPolicyCopyWith<$Res>  {
  factory $AlertPolicyCopyWith(AlertPolicy value, $Res Function(AlertPolicy) _then) = _$AlertPolicyCopyWithImpl;
@useResult
$Res call({
@JsonKey(disallowNullValue: true, readValue: AlertPolicy._presentValue, fromJson: AlertPolicy._read_mode, toJson: AlertPolicy._write_mode) AlertMode mode,@JsonKey(disallowNullValue: true, includeIfNull: false) List<Window>? schedule,@JsonKey(disallowNullValue: true, includeIfNull: false) List<String>? labels,@JsonKey(readValue: AlertPolicy._extras, fromJson: AlertPolicy._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$AlertPolicyCopyWithImpl<$Res>
    implements $AlertPolicyCopyWith<$Res> {
  _$AlertPolicyCopyWithImpl(this._self, this._then);

  final AlertPolicy _self;
  final $Res Function(AlertPolicy) _then;

/// Create a copy of AlertPolicy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? schedule = freezed,Object? labels = freezed,Object? additionalProperties = null,}) {
  return _then(AlertPolicy(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AlertMode,schedule: freezed == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as List<Window>?,labels: freezed == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [AlertPolicy].
extension AlertPolicyPatterns on AlertPolicy {
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
