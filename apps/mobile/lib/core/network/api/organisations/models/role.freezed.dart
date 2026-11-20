// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'role.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoleKnown {


/// Create a copy of RoleKnown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleKnownCopyWith<RoleKnown> get copyWith => _$RoleKnownCopyWithImpl<RoleKnown>(this as RoleKnown, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RoleKnown;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleKnown&&(identical(other.value, _this.value) || other.value == _this.value));
}


@override
int get hashCode {
  final _this = this as RoleKnown;
  return Object.hash(runtimeType,_this.value);
}

@override
String toString() {
  final _this = this as RoleKnown;
  return 'RoleKnown(value: ${_this.value})';
}


}

/// @nodoc
abstract mixin class $RoleKnownCopyWith<$Res>  {
  factory $RoleKnownCopyWith(RoleKnown value, $Res Function(RoleKnown) _then) = _$RoleKnownCopyWithImpl;
@useResult
$Res call({
 RoleValue value
});




}
/// @nodoc
class _$RoleKnownCopyWithImpl<$Res>
    implements $RoleKnownCopyWith<$Res> {
  _$RoleKnownCopyWithImpl(this._self, this._then);

  final RoleKnown _self;
  final $Res Function(RoleKnown) _then;

/// Create a copy of RoleKnown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(RoleKnown(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as RoleValue,
  ));
}

}


/// Adds pattern-matching-related methods to [RoleKnown].
extension RoleKnownPatterns on RoleKnown {
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

/// @nodoc
mixin _$RoleUnknown {


/// Create a copy of RoleUnknown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleUnknownCopyWith<RoleUnknown> get copyWith => _$RoleUnknownCopyWithImpl<RoleUnknown>(this as RoleUnknown, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RoleUnknown;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleUnknown&&(identical(other.rawValue, _this.rawValue) || other.rawValue == _this.rawValue));
}


@override
int get hashCode {
  final _this = this as RoleUnknown;
  return Object.hash(runtimeType,_this.rawValue);
}

@override
String toString() {
  final _this = this as RoleUnknown;
  return 'RoleUnknown(rawValue: ${_this.rawValue})';
}


}

/// @nodoc
abstract mixin class $RoleUnknownCopyWith<$Res>  {
  factory $RoleUnknownCopyWith(RoleUnknown value, $Res Function(RoleUnknown) _then) = _$RoleUnknownCopyWithImpl;
@useResult
$Res call({
 String rawValue
});




}
/// @nodoc
class _$RoleUnknownCopyWithImpl<$Res>
    implements $RoleUnknownCopyWith<$Res> {
  _$RoleUnknownCopyWithImpl(this._self, this._then);

  final RoleUnknown _self;
  final $Res Function(RoleUnknown) _then;

/// Create a copy of RoleUnknown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rawValue = null,}) {
  return _then(RoleUnknown(
null == rawValue ? _self.rawValue : rawValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RoleUnknown].
extension RoleUnknownPatterns on RoleUnknown {
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
