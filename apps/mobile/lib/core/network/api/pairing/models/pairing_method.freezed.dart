// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pairing_method.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PairingMethod {


/// Create a copy of PairingMethod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PairingMethodCopyWith<PairingMethod> get copyWith => _$PairingMethodCopyWithImpl<PairingMethod>(this as PairingMethod, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PairingMethod;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PairingMethod&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&const DeepCollectionEquality().equals(other.requires, _this.requires)&&const DeepCollectionEquality().equals(other.parameters, _this.parameters)&&(identical(other.endpoint, _this.endpoint) || other.endpoint == _this.endpoint)&&(identical(other.adapter, _this.adapter) || other.adapter == _this.adapter)&&(identical(other.recommended, _this.recommended) || other.recommended == _this.recommended)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as PairingMethod;
  return Object.hash(runtimeType,_this.id,_this.title,_this.description,const DeepCollectionEquality().hash(_this.requires),const DeepCollectionEquality().hash(_this.parameters),_this.endpoint,_this.adapter,_this.recommended,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as PairingMethod;
  return 'PairingMethod(id: ${_this.id}, title: ${_this.title}, description: ${_this.description}, requires: ${_this.requires}, parameters: ${_this.parameters}, endpoint: ${_this.endpoint}, adapter: ${_this.adapter}, recommended: ${_this.recommended}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $PairingMethodCopyWith<$Res>  {
  factory $PairingMethodCopyWith(PairingMethod value, $Res Function(PairingMethod) _then) = _$PairingMethodCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true, fromJson: PairingMethod._read_id, toJson: PairingMethod._write_id) PairingMethodId id,@JsonKey(required: true, disallowNullValue: true) String title,@JsonKey(required: true, disallowNullValue: true) String description,@JsonKey(required: true, disallowNullValue: true) List<String> requires,@JsonKey(required: true, disallowNullValue: true) List<PairingParameter> parameters,@JsonKey(required: true, disallowNullValue: true) String endpoint,@JsonKey(includeIfNull: false) String? adapter,@JsonKey(disallowNullValue: true, readValue: PairingMethod._presentValue, fromJson: PairingMethod._read_recommended, toJson: PairingMethod._write_recommended) bool recommended,@JsonKey(readValue: PairingMethod._extras, fromJson: PairingMethod._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$PairingMethodCopyWithImpl<$Res>
    implements $PairingMethodCopyWith<$Res> {
  _$PairingMethodCopyWithImpl(this._self, this._then);

  final PairingMethod _self;
  final $Res Function(PairingMethod) _then;

/// Create a copy of PairingMethod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? requires = null,Object? parameters = null,Object? endpoint = null,Object? adapter = freezed,Object? recommended = null,Object? additionalProperties = null,}) {
  return _then(PairingMethod(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as PairingMethodId,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,requires: null == requires ? _self.requires : requires // ignore: cast_nullable_to_non_nullable
as List<String>,parameters: null == parameters ? _self.parameters : parameters // ignore: cast_nullable_to_non_nullable
as List<PairingParameter>,endpoint: null == endpoint ? _self.endpoint : endpoint // ignore: cast_nullable_to_non_nullable
as String,adapter: freezed == adapter ? _self.adapter : adapter // ignore: cast_nullable_to_non_nullable
as String?,recommended: null == recommended ? _self.recommended : recommended // ignore: cast_nullable_to_non_nullable
as bool,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [PairingMethod].
extension PairingMethodPatterns on PairingMethod {
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
