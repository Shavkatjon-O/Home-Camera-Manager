// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'area_line_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AreaLineInput {


/// Create a copy of AreaLineInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AreaLineInputCopyWith<AreaLineInput> get copyWith => _$AreaLineInputCopyWithImpl<AreaLineInput>(this as AreaLineInput, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AreaLineInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AreaLineInput&&(identical(other.lineUuid, _this.lineUuid) || other.lineUuid == _this.lineUuid)&&(identical(other.entering, _this.entering) || other.entering == _this.entering)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as AreaLineInput;
  return Object.hash(runtimeType,_this.lineUuid,_this.entering,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as AreaLineInput;
  return 'AreaLineInput(lineUuid: ${_this.lineUuid}, entering: ${_this.entering}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $AreaLineInputCopyWith<$Res>  {
  factory $AreaLineInputCopyWith(AreaLineInput value, $Res Function(AreaLineInput) _then) = _$AreaLineInputCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "line_uuid", required: true, disallowNullValue: true) String lineUuid,@JsonKey(required: true, disallowNullValue: true, fromJson: AreaLineInput._read_entering, toJson: AreaLineInput._write_entering) AreaLineInputEntering entering,@JsonKey(readValue: AreaLineInput._extras, fromJson: AreaLineInput._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$AreaLineInputCopyWithImpl<$Res>
    implements $AreaLineInputCopyWith<$Res> {
  _$AreaLineInputCopyWithImpl(this._self, this._then);

  final AreaLineInput _self;
  final $Res Function(AreaLineInput) _then;

/// Create a copy of AreaLineInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineUuid = null,Object? entering = null,Object? additionalProperties = null,}) {
  return _then(AreaLineInput(
lineUuid: null == lineUuid ? _self.lineUuid : lineUuid // ignore: cast_nullable_to_non_nullable
as String,entering: null == entering ? _self.entering : entering // ignore: cast_nullable_to_non_nullable
as AreaLineInputEntering,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [AreaLineInput].
extension AreaLineInputPatterns on AreaLineInput {
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
