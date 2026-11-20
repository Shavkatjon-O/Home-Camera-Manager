// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entitlements_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EntitlementsRead {


/// Create a copy of EntitlementsRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntitlementsReadCopyWith<EntitlementsRead> get copyWith => _$EntitlementsReadCopyWithImpl<EntitlementsRead>(this as EntitlementsRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EntitlementsRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntitlementsRead&&(identical(other.plan, _this.plan) || other.plan == _this.plan)&&const DeepCollectionEquality().equals(other.usage, _this.usage)&&(identical(other.suspended, _this.suspended) || other.suspended == _this.suspended)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as EntitlementsRead;
  return Object.hash(runtimeType,_this.plan,const DeepCollectionEquality().hash(_this.usage),_this.suspended,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as EntitlementsRead;
  return 'EntitlementsRead(plan: ${_this.plan}, usage: ${_this.usage}, suspended: ${_this.suspended}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $EntitlementsReadCopyWith<$Res>  {
  factory $EntitlementsReadCopyWith(EntitlementsRead value, $Res Function(EntitlementsRead) _then) = _$EntitlementsReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) PlanRead plan,@JsonKey(required: true, disallowNullValue: true, fromJson: EntitlementsRead._read_usage, toJson: EntitlementsRead._write_usage) Map<String, int> usage,@JsonKey(required: true, disallowNullValue: true) bool suspended,@JsonKey(readValue: EntitlementsRead._extras, fromJson: EntitlementsRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$PlanReadCopyWith<$Res> get plan;

}
/// @nodoc
class _$EntitlementsReadCopyWithImpl<$Res>
    implements $EntitlementsReadCopyWith<$Res> {
  _$EntitlementsReadCopyWithImpl(this._self, this._then);

  final EntitlementsRead _self;
  final $Res Function(EntitlementsRead) _then;

/// Create a copy of EntitlementsRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plan = null,Object? usage = null,Object? suspended = null,Object? additionalProperties = null,}) {
  return _then(EntitlementsRead(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as PlanRead,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as Map<String, int>,suspended: null == suspended ? _self.suspended : suspended // ignore: cast_nullable_to_non_nullable
as bool,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of EntitlementsRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanReadCopyWith<$Res> get plan {
  
  return $PlanReadCopyWith<$Res>(_self.plan, (value) {
    return _then(_self.copyWith(plan: value));
  });
}
}


/// Adds pattern-matching-related methods to [EntitlementsRead].
extension EntitlementsReadPatterns on EntitlementsRead {
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
