// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnalyticsStatus {


/// Create a copy of AnalyticsStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsStatusCopyWith<AnalyticsStatus> get copyWith => _$AnalyticsStatusCopyWithImpl<AnalyticsStatus>(this as AnalyticsStatus, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AnalyticsStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsStatus&&const DeepCollectionEquality().equals(other.pipeline, _this.pipeline)&&const DeepCollectionEquality().equals(other.gpu, _this.gpu)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.views, _this.views)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as AnalyticsStatus;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.pipeline),const DeepCollectionEquality().hash(_this.gpu),_this.updatedAt,const DeepCollectionEquality().hash(_this.views),const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as AnalyticsStatus;
  return 'AnalyticsStatus(pipeline: ${_this.pipeline}, gpu: ${_this.gpu}, updatedAt: ${_this.updatedAt}, views: ${_this.views}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $AnalyticsStatusCopyWith<$Res>  {
  factory $AnalyticsStatusCopyWith(AnalyticsStatus value, $Res Function(AnalyticsStatus) _then) = _$AnalyticsStatusCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true) Map<String, Object?>? pipeline,@JsonKey(required: true, disallowNullValue: true) Map<String, Object?> gpu,@JsonKey(name: "updated_at", required: true, fromJson: AnalyticsStatus._read_updatedAt, toJson: AnalyticsStatus._write_updatedAt) DateTime? updatedAt,@JsonKey(required: true, disallowNullValue: true) Map<String, Map<String, Object?>> views,@JsonKey(readValue: AnalyticsStatus._extras, fromJson: AnalyticsStatus._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$AnalyticsStatusCopyWithImpl<$Res>
    implements $AnalyticsStatusCopyWith<$Res> {
  _$AnalyticsStatusCopyWithImpl(this._self, this._then);

  final AnalyticsStatus _self;
  final $Res Function(AnalyticsStatus) _then;

/// Create a copy of AnalyticsStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pipeline = freezed,Object? gpu = null,Object? updatedAt = freezed,Object? views = null,Object? additionalProperties = null,}) {
  return _then(AnalyticsStatus(
pipeline: freezed == pipeline ? _self.pipeline : pipeline // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,gpu: null == gpu ? _self.gpu : gpu // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,views: null == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, Object?>>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsStatus].
extension AnalyticsStatusPatterns on AnalyticsStatus {
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
