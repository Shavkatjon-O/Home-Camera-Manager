// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'area_line_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AreaLineRead {


/// Create a copy of AreaLineRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AreaLineReadCopyWith<AreaLineRead> get copyWith => _$AreaLineReadCopyWithImpl<AreaLineRead>(this as AreaLineRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AreaLineRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AreaLineRead&&(identical(other.lineUuid, _this.lineUuid) || other.lineUuid == _this.lineUuid)&&(identical(other.lineName, _this.lineName) || other.lineName == _this.lineName)&&(identical(other.viewName, _this.viewName) || other.viewName == _this.viewName)&&(identical(other.entering, _this.entering) || other.entering == _this.entering)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as AreaLineRead;
  return Object.hash(runtimeType,_this.lineUuid,_this.lineName,_this.viewName,_this.entering,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as AreaLineRead;
  return 'AreaLineRead(lineUuid: ${_this.lineUuid}, lineName: ${_this.lineName}, viewName: ${_this.viewName}, entering: ${_this.entering}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $AreaLineReadCopyWith<$Res>  {
  factory $AreaLineReadCopyWith(AreaLineRead value, $Res Function(AreaLineRead) _then) = _$AreaLineReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "line_uuid", required: true, disallowNullValue: true) String lineUuid,@JsonKey(name: "line_name", required: true) String? lineName,@JsonKey(name: "view_name", required: true) String? viewName,@JsonKey(required: true, disallowNullValue: true) String entering,@JsonKey(readValue: AreaLineRead._extras, fromJson: AreaLineRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$AreaLineReadCopyWithImpl<$Res>
    implements $AreaLineReadCopyWith<$Res> {
  _$AreaLineReadCopyWithImpl(this._self, this._then);

  final AreaLineRead _self;
  final $Res Function(AreaLineRead) _then;

/// Create a copy of AreaLineRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineUuid = null,Object? lineName = freezed,Object? viewName = freezed,Object? entering = null,Object? additionalProperties = null,}) {
  return _then(AreaLineRead(
lineUuid: null == lineUuid ? _self.lineUuid : lineUuid // ignore: cast_nullable_to_non_nullable
as String,lineName: freezed == lineName ? _self.lineName : lineName // ignore: cast_nullable_to_non_nullable
as String?,viewName: freezed == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String?,entering: null == entering ? _self.entering : entering // ignore: cast_nullable_to_non_nullable
as String,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [AreaLineRead].
extension AreaLineReadPatterns on AreaLineRead {
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
