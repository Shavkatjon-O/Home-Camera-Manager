// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ptz_move.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PtzMove {


/// Create a copy of PtzMove
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PtzMoveCopyWith<PtzMove> get copyWith => _$PtzMoveCopyWithImpl<PtzMove>(this as PtzMove, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PtzMove;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PtzMove&&(identical(other.pan, _this.pan) || other.pan == _this.pan)&&(identical(other.tilt, _this.tilt) || other.tilt == _this.tilt)&&(identical(other.zoom, _this.zoom) || other.zoom == _this.zoom)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as PtzMove;
  return Object.hash(runtimeType,_this.pan,_this.tilt,_this.zoom,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as PtzMove;
  return 'PtzMove(pan: ${_this.pan}, tilt: ${_this.tilt}, zoom: ${_this.zoom}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $PtzMoveCopyWith<$Res>  {
  factory $PtzMoveCopyWith(PtzMove value, $Res Function(PtzMove) _then) = _$PtzMoveCopyWithImpl;
@useResult
$Res call({
@JsonKey(disallowNullValue: true, readValue: PtzMove._presentValue, fromJson: PtzMove._read_pan, toJson: PtzMove._write_pan) num pan,@JsonKey(disallowNullValue: true, readValue: PtzMove._presentValue, fromJson: PtzMove._read_tilt, toJson: PtzMove._write_tilt) num tilt,@JsonKey(disallowNullValue: true, readValue: PtzMove._presentValue, fromJson: PtzMove._read_zoom, toJson: PtzMove._write_zoom) num zoom,@JsonKey(readValue: PtzMove._extras, fromJson: PtzMove._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$PtzMoveCopyWithImpl<$Res>
    implements $PtzMoveCopyWith<$Res> {
  _$PtzMoveCopyWithImpl(this._self, this._then);

  final PtzMove _self;
  final $Res Function(PtzMove) _then;

/// Create a copy of PtzMove
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pan = null,Object? tilt = null,Object? zoom = null,Object? additionalProperties = null,}) {
  return _then(PtzMove(
pan: null == pan ? _self.pan : pan // ignore: cast_nullable_to_non_nullable
as num,tilt: null == tilt ? _self.tilt : tilt // ignore: cast_nullable_to_non_nullable
as num,zoom: null == zoom ? _self.zoom : zoom // ignore: cast_nullable_to_non_nullable
as num,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [PtzMove].
extension PtzMovePatterns on PtzMove {
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
