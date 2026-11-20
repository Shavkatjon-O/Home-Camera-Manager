// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'similar_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SimilarQuery {


/// Create a copy of SimilarQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SimilarQueryCopyWith<SimilarQuery> get copyWith => _$SimilarQueryCopyWithImpl<SimilarQuery>(this as SimilarQuery, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SimilarQuery;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SimilarQuery&&(identical(other.sample, _this.sample) || other.sample == _this.sample)&&(identical(other.event, _this.event) || other.event == _this.event)&&(identical(other.photo, _this.photo) || other.photo == _this.photo)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.pageSize, _this.pageSize) || other.pageSize == _this.pageSize));
}


@override
int get hashCode {
  final _this = this as SimilarQuery;
  return Object.hash(runtimeType,_this.sample,_this.event,_this.photo,_this.page,_this.pageSize);
}

@override
String toString() {
  final _this = this as SimilarQuery;
  return 'SimilarQuery(sample: ${_this.sample}, event: ${_this.event}, photo: ${_this.photo}, page: ${_this.page}, pageSize: ${_this.pageSize})';
}


}

/// @nodoc
abstract mixin class $SimilarQueryCopyWith<$Res>  {
  factory $SimilarQueryCopyWith(SimilarQuery value, $Res Function(SimilarQuery) _then) = _$SimilarQueryCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? sample,@JsonKey(includeIfNull: false) String? event,@JsonKey(includeIfNull: false) String? photo,@JsonKey(disallowNullValue: true, readValue: SimilarQuery._presentValue, fromJson: SimilarQuery._read_page, toJson: SimilarQuery._write_page) int page,@JsonKey(name: "page_size", disallowNullValue: true, readValue: SimilarQuery._presentValue, fromJson: SimilarQuery._read_pageSize, toJson: SimilarQuery._write_pageSize) int pageSize
});




}
/// @nodoc
class _$SimilarQueryCopyWithImpl<$Res>
    implements $SimilarQueryCopyWith<$Res> {
  _$SimilarQueryCopyWithImpl(this._self, this._then);

  final SimilarQuery _self;
  final $Res Function(SimilarQuery) _then;

/// Create a copy of SimilarQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sample = freezed,Object? event = freezed,Object? photo = freezed,Object? page = null,Object? pageSize = null,}) {
  return _then(SimilarQuery(
sample: freezed == sample ? _self.sample : sample // ignore: cast_nullable_to_non_nullable
as String?,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as String?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SimilarQuery].
extension SimilarQueryPatterns on SimilarQuery {
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
