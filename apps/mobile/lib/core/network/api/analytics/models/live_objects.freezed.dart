// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_objects.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LiveObjects {


/// Create a copy of LiveObjects
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveObjectsCopyWith<LiveObjects> get copyWith => _$LiveObjectsCopyWithImpl<LiveObjects>(this as LiveObjects, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LiveObjects;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveObjects&&(identical(other.view, _this.view) || other.view == _this.view)&&(identical(other.at, _this.at) || other.at == _this.at)&&const DeepCollectionEquality().equals(other.objects, _this.objects)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as LiveObjects;
  return Object.hash(runtimeType,_this.view,_this.at,const DeepCollectionEquality().hash(_this.objects),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as LiveObjects;
  return 'LiveObjects(view: ${_this.view}, at: ${_this.at}, objects: ${_this.objects}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $LiveObjectsCopyWith<$Res>  {
  factory $LiveObjectsCopyWith(LiveObjects value, $Res Function(LiveObjects) _then) = _$LiveObjectsCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String view,@JsonKey(required: true) num? at,@JsonKey(required: true, disallowNullValue: true) List<LiveObject> objects,@JsonKey(readValue: LiveObjects._extras, fromJson: LiveObjects._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$LiveObjectsCopyWithImpl<$Res>
    implements $LiveObjectsCopyWith<$Res> {
  _$LiveObjectsCopyWithImpl(this._self, this._then);

  final LiveObjects _self;
  final $Res Function(LiveObjects) _then;

/// Create a copy of LiveObjects
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? view = null,Object? at = freezed,Object? objects = null,Object? additionalProperties = null,}) {
  return _then(LiveObjects(
view: null == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as String,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as num?,objects: null == objects ? _self.objects : objects // ignore: cast_nullable_to_non_nullable
as List<LiveObject>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveObjects].
extension LiveObjectsPatterns on LiveObjects {
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
