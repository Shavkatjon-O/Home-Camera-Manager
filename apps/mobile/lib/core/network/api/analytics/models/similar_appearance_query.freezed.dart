// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'similar_appearance_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SimilarAppearanceQuery {


/// Create a copy of SimilarAppearanceQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SimilarAppearanceQueryCopyWith<SimilarAppearanceQuery> get copyWith => _$SimilarAppearanceQueryCopyWithImpl<SimilarAppearanceQuery>(this as SimilarAppearanceQuery, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SimilarAppearanceQuery;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SimilarAppearanceQuery&&(identical(other.eventUuid, _this.eventUuid) || other.eventUuid == _this.eventUuid)&&(identical(other.appearanceUuid, _this.appearanceUuid) || other.appearanceUuid == _this.appearanceUuid)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.limit, _this.limit) || other.limit == _this.limit)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as SimilarAppearanceQuery;
  return Object.hash(runtimeType,_this.eventUuid,_this.appearanceUuid,_this.start,_this.end,_this.limit,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as SimilarAppearanceQuery;
  return 'SimilarAppearanceQuery(eventUuid: ${_this.eventUuid}, appearanceUuid: ${_this.appearanceUuid}, start: ${_this.start}, end: ${_this.end}, limit: ${_this.limit}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $SimilarAppearanceQueryCopyWith<$Res>  {
  factory $SimilarAppearanceQueryCopyWith(SimilarAppearanceQuery value, $Res Function(SimilarAppearanceQuery) _then) = _$SimilarAppearanceQueryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "event_uuid", includeIfNull: false) String? eventUuid,@JsonKey(name: "appearance_uuid", includeIfNull: false) String? appearanceUuid,@JsonKey(includeIfNull: false, fromJson: SimilarAppearanceQuery._read_start, toJson: SimilarAppearanceQuery._write_start) DateTime? start,@JsonKey(includeIfNull: false, fromJson: SimilarAppearanceQuery._read_end, toJson: SimilarAppearanceQuery._write_end) DateTime? end,@JsonKey(disallowNullValue: true, readValue: SimilarAppearanceQuery._presentValue, fromJson: SimilarAppearanceQuery._read_limit, toJson: SimilarAppearanceQuery._write_limit) int limit,@JsonKey(readValue: SimilarAppearanceQuery._extras, fromJson: SimilarAppearanceQuery._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$SimilarAppearanceQueryCopyWithImpl<$Res>
    implements $SimilarAppearanceQueryCopyWith<$Res> {
  _$SimilarAppearanceQueryCopyWithImpl(this._self, this._then);

  final SimilarAppearanceQuery _self;
  final $Res Function(SimilarAppearanceQuery) _then;

/// Create a copy of SimilarAppearanceQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventUuid = freezed,Object? appearanceUuid = freezed,Object? start = freezed,Object? end = freezed,Object? limit = null,Object? additionalProperties = null,}) {
  return _then(SimilarAppearanceQuery(
eventUuid: freezed == eventUuid ? _self.eventUuid : eventUuid // ignore: cast_nullable_to_non_nullable
as String?,appearanceUuid: freezed == appearanceUuid ? _self.appearanceUuid : appearanceUuid // ignore: cast_nullable_to_non_nullable
as String?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime?,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [SimilarAppearanceQuery].
extension SimilarAppearanceQueryPatterns on SimilarAppearanceQuery {
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
