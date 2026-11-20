// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'site_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SiteUpdate {


/// Create a copy of SiteUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteUpdateCopyWith<SiteUpdate> get copyWith => _$SiteUpdateCopyWithImpl<SiteUpdate>(this as SiteUpdate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SiteUpdate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteUpdate&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.eventRetentionDays, _this.eventRetentionDays) || other.eventRetentionDays == _this.eventRetentionDays)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as SiteUpdate;
  return Object.hash(runtimeType,_this.name,_this.kind,_this.timezone,_this.position,_this.eventRetentionDays,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as SiteUpdate;
  return 'SiteUpdate(name: ${_this.name}, kind: ${_this.kind}, timezone: ${_this.timezone}, position: ${_this.position}, eventRetentionDays: ${_this.eventRetentionDays}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $SiteUpdateCopyWith<$Res>  {
  factory $SiteUpdateCopyWith(SiteUpdate value, $Res Function(SiteUpdate) _then) = _$SiteUpdateCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false, fromJson: SiteUpdate._read_kind, toJson: SiteUpdate._write_kind) SiteKind? kind,@JsonKey(includeIfNull: false) String? timezone,@JsonKey(includeIfNull: false, fromJson: SiteUpdate._read_position, toJson: SiteUpdate._write_position) int? position,@JsonKey(name: "event_retention_days", includeIfNull: false, fromJson: SiteUpdate._read_eventRetentionDays, toJson: SiteUpdate._write_eventRetentionDays) int? eventRetentionDays,@JsonKey(readValue: SiteUpdate._extras, fromJson: SiteUpdate._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$SiteUpdateCopyWithImpl<$Res>
    implements $SiteUpdateCopyWith<$Res> {
  _$SiteUpdateCopyWithImpl(this._self, this._then);

  final SiteUpdate _self;
  final $Res Function(SiteUpdate) _then;

/// Create a copy of SiteUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? kind = freezed,Object? timezone = freezed,Object? position = freezed,Object? eventRetentionDays = freezed,Object? additionalProperties = null,}) {
  return _then(SiteUpdate(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SiteKind?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int?,eventRetentionDays: freezed == eventRetentionDays ? _self.eventRetentionDays : eventRetentionDays // ignore: cast_nullable_to_non_nullable
as int?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [SiteUpdate].
extension SiteUpdatePatterns on SiteUpdate {
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
