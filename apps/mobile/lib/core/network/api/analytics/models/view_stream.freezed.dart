// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_stream.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ViewStreamKnown {


/// Create a copy of ViewStreamKnown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ViewStreamKnownCopyWith<ViewStreamKnown> get copyWith => _$ViewStreamKnownCopyWithImpl<ViewStreamKnown>(this as ViewStreamKnown, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ViewStreamKnown;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewStreamKnown&&(identical(other.value, _this.value) || other.value == _this.value));
}


@override
int get hashCode {
  final _this = this as ViewStreamKnown;
  return Object.hash(runtimeType,_this.value);
}

@override
String toString() {
  final _this = this as ViewStreamKnown;
  return 'ViewStreamKnown(value: ${_this.value})';
}


}

/// @nodoc
abstract mixin class $ViewStreamKnownCopyWith<$Res>  {
  factory $ViewStreamKnownCopyWith(ViewStreamKnown value, $Res Function(ViewStreamKnown) _then) = _$ViewStreamKnownCopyWithImpl;
@useResult
$Res call({
 ViewStreamValue value
});




}
/// @nodoc
class _$ViewStreamKnownCopyWithImpl<$Res>
    implements $ViewStreamKnownCopyWith<$Res> {
  _$ViewStreamKnownCopyWithImpl(this._self, this._then);

  final ViewStreamKnown _self;
  final $Res Function(ViewStreamKnown) _then;

/// Create a copy of ViewStreamKnown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(ViewStreamKnown(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as ViewStreamValue,
  ));
}

}


/// Adds pattern-matching-related methods to [ViewStreamKnown].
extension ViewStreamKnownPatterns on ViewStreamKnown {
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
mixin _$ViewStreamUnknown {


/// Create a copy of ViewStreamUnknown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ViewStreamUnknownCopyWith<ViewStreamUnknown> get copyWith => _$ViewStreamUnknownCopyWithImpl<ViewStreamUnknown>(this as ViewStreamUnknown, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ViewStreamUnknown;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewStreamUnknown&&(identical(other.rawValue, _this.rawValue) || other.rawValue == _this.rawValue));
}


@override
int get hashCode {
  final _this = this as ViewStreamUnknown;
  return Object.hash(runtimeType,_this.rawValue);
}

@override
String toString() {
  final _this = this as ViewStreamUnknown;
  return 'ViewStreamUnknown(rawValue: ${_this.rawValue})';
}


}

/// @nodoc
abstract mixin class $ViewStreamUnknownCopyWith<$Res>  {
  factory $ViewStreamUnknownCopyWith(ViewStreamUnknown value, $Res Function(ViewStreamUnknown) _then) = _$ViewStreamUnknownCopyWithImpl;
@useResult
$Res call({
 String rawValue
});




}
/// @nodoc
class _$ViewStreamUnknownCopyWithImpl<$Res>
    implements $ViewStreamUnknownCopyWith<$Res> {
  _$ViewStreamUnknownCopyWithImpl(this._self, this._then);

  final ViewStreamUnknown _self;
  final $Res Function(ViewStreamUnknown) _then;

/// Create a copy of ViewStreamUnknown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rawValue = null,}) {
  return _then(ViewStreamUnknown(
null == rawValue ? _self.rawValue : rawValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ViewStreamUnknown].
extension ViewStreamUnknownPatterns on ViewStreamUnknown {
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
