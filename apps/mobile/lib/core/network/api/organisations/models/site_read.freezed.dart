// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'site_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SiteRead {


/// Create a copy of SiteRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteReadCopyWith<SiteRead> get copyWith => _$SiteReadCopyWithImpl<SiteRead>(this as SiteRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SiteRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.organisation, _this.organisation) || other.organisation == _this.organisation)&&(identical(other.organisationName, _this.organisationName) || other.organisationName == _this.organisationName)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.cameraCount, _this.cameraCount) || other.cameraCount == _this.cameraCount)&&(identical(other.connectorCount, _this.connectorCount) || other.connectorCount == _this.connectorCount)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as SiteRead;
  return Object.hash(runtimeType,_this.uuid,_this.organisation,_this.organisationName,_this.name,_this.kind,_this.timezone,_this.position,_this.role,_this.cameraCount,_this.connectorCount,_this.createdAt,_this.updatedAt,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as SiteRead;
  return 'SiteRead(uuid: ${_this.uuid}, organisation: ${_this.organisation}, organisationName: ${_this.organisationName}, name: ${_this.name}, kind: ${_this.kind}, timezone: ${_this.timezone}, position: ${_this.position}, role: ${_this.role}, cameraCount: ${_this.cameraCount}, connectorCount: ${_this.connectorCount}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $SiteReadCopyWith<$Res>  {
  factory $SiteReadCopyWith(SiteRead value, $Res Function(SiteRead) _then) = _$SiteReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String organisation,@JsonKey(name: "organisation_name", required: true, disallowNullValue: true) String organisationName,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true, disallowNullValue: true, fromJson: SiteRead._read_kind, toJson: SiteRead._write_kind) SiteKind kind,@JsonKey(required: true, disallowNullValue: true) String timezone,@JsonKey(required: true, disallowNullValue: true, fromJson: SiteRead._read_position, toJson: SiteRead._write_position) int position,@JsonKey(required: true, disallowNullValue: true, fromJson: SiteRead._read_role, toJson: SiteRead._write_role) Role role,@JsonKey(name: "camera_count", required: true, disallowNullValue: true, fromJson: SiteRead._read_cameraCount, toJson: SiteRead._write_cameraCount) int cameraCount,@JsonKey(name: "connector_count", required: true, disallowNullValue: true, fromJson: SiteRead._read_connectorCount, toJson: SiteRead._write_connectorCount) int connectorCount,@JsonKey(name: "created_at", required: true, disallowNullValue: true, fromJson: SiteRead._read_createdAt, toJson: SiteRead._write_createdAt) DateTime createdAt,@JsonKey(name: "updated_at", required: true, disallowNullValue: true, fromJson: SiteRead._read_updatedAt, toJson: SiteRead._write_updatedAt) DateTime updatedAt,@JsonKey(readValue: SiteRead._extras, fromJson: SiteRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$SiteReadCopyWithImpl<$Res>
    implements $SiteReadCopyWith<$Res> {
  _$SiteReadCopyWithImpl(this._self, this._then);

  final SiteRead _self;
  final $Res Function(SiteRead) _then;

/// Create a copy of SiteRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? organisation = null,Object? organisationName = null,Object? name = null,Object? kind = null,Object? timezone = null,Object? position = null,Object? role = null,Object? cameraCount = null,Object? connectorCount = null,Object? createdAt = null,Object? updatedAt = null,Object? additionalProperties = null,}) {
  return _then(SiteRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,organisation: null == organisation ? _self.organisation : organisation // ignore: cast_nullable_to_non_nullable
as String,organisationName: null == organisationName ? _self.organisationName : organisationName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SiteKind,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,cameraCount: null == cameraCount ? _self.cameraCount : cameraCount // ignore: cast_nullable_to_non_nullable
as int,connectorCount: null == connectorCount ? _self.connectorCount : connectorCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [SiteRead].
extension SiteReadPatterns on SiteRead {
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
