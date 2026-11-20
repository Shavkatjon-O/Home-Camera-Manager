// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pairing_parameter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PairingParameter {


/// Create a copy of PairingParameter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PairingParameterCopyWith<PairingParameter> get copyWith => _$PairingParameterCopyWithImpl<PairingParameter>(this as PairingParameter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PairingParameter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PairingParameter&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.required2, _this.required2) || other.required2 == _this.required2)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.default2, _this.default2) || other.default2 == _this.default2)&&(identical(other.prefill, _this.prefill) || other.prefill == _this.prefill)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as PairingParameter;
  return Object.hash(runtimeType,_this.name,_this.type,_this.required2,_this.description,_this.default2,_this.prefill,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as PairingParameter;
  return 'PairingParameter(name: ${_this.name}, type: ${_this.type}, required2: ${_this.required2}, description: ${_this.description}, default2: ${_this.default2}, prefill: ${_this.prefill}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $PairingParameterCopyWith<$Res>  {
  factory $PairingParameterCopyWith(PairingParameter value, $Res Function(PairingParameter) _then) = _$PairingParameterCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true, disallowNullValue: true) String type,@JsonKey(name: "required", required: true, disallowNullValue: true) bool required2,@JsonKey(required: true, disallowNullValue: true) String description,@JsonKey(name: "default", explicitJsonNullWhenNonNullField: true, fromJson: PairingParameter._read_default2, toJson: PairingParameter._write_default2) PairingParameterDefault? default2,@JsonKey(explicitJsonNullWhenNonNullField: true, fromJson: PairingParameter._read_prefill, toJson: PairingParameter._write_prefill) PairingParameterPrefill? prefill,@JsonKey(readValue: PairingParameter._extras, fromJson: PairingParameter._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$PairingParameterCopyWithImpl<$Res>
    implements $PairingParameterCopyWith<$Res> {
  _$PairingParameterCopyWithImpl(this._self, this._then);

  final PairingParameter _self;
  final $Res Function(PairingParameter) _then;

/// Create a copy of PairingParameter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? required2 = null,Object? description = null,Object? default2 = freezed,Object? prefill = freezed,Object? additionalProperties = null,}) {
  return _then(PairingParameter(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,required2: null == required2 ? _self.required2 : required2 // ignore: cast_nullable_to_non_nullable
as bool,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,default2: freezed == default2 ? _self.default2 : default2 // ignore: cast_nullable_to_non_nullable
as PairingParameterDefault?,prefill: freezed == prefill ? _self.prefill : prefill // ignore: cast_nullable_to_non_nullable
as PairingParameterPrefill?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [PairingParameter].
extension PairingParameterPatterns on PairingParameter {
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
