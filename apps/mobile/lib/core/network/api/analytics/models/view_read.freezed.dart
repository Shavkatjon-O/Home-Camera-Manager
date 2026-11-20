// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ViewRead {


/// Create a copy of ViewRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ViewReadCopyWith<ViewRead> get copyWith => _$ViewReadCopyWithImpl<ViewRead>(this as ViewRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ViewRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.cameraUuid, _this.cameraUuid) || other.cameraUuid == _this.cameraUuid)&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName)&&(identical(other.lens, _this.lens) || other.lens == _this.lens)&&(identical(other.lenses, _this.lenses) || other.lenses == _this.lenses)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.fps, _this.fps) || other.fps == _this.fps)&&(identical(other.tamper, _this.tamper) || other.tamper == _this.tamper)&&(identical(other.faces, _this.faces) || other.faces == _this.faces)&&(identical(other.moving, _this.moving) || other.moving == _this.moving)&&(identical(other.appearance, _this.appearance) || other.appearance == _this.appearance)&&(identical(other.falls, _this.falls) || other.falls == _this.falls)&&(identical(other.plates, _this.plates) || other.plates == _this.plates)&&(identical(other.follow, _this.follow) || other.follow == _this.follow)&&(identical(other.stream, _this.stream) || other.stream == _this.stream)&&const DeepCollectionEquality().equals(other.zones, _this.zones)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&const DeepCollectionEquality().equals(other.status, _this.status)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as ViewRead;
  return Object.hashAll([runtimeType,_this.uuid,_this.cameraUuid,_this.cameraName,_this.lens,_this.lenses,_this.name,_this.profile,_this.enabled,_this.fps,_this.tamper,_this.faces,_this.moving,_this.appearance,_this.falls,_this.plates,_this.follow,_this.stream,const DeepCollectionEquality().hash(_this.zones),const DeepCollectionEquality().hash(_this.lines),const DeepCollectionEquality().hash(_this.status),const DeepCollectionEquality().hash(_this.additionalProperties)]);
}

@override
String toString() {
  final _this = this as ViewRead;
  return 'ViewRead(uuid: ${_this.uuid}, cameraUuid: ${_this.cameraUuid}, cameraName: ${_this.cameraName}, lens: ${_this.lens}, lenses: ${_this.lenses}, name: ${_this.name}, profile: ${_this.profile}, enabled: ${_this.enabled}, fps: ${_this.fps}, tamper: ${_this.tamper}, faces: ${_this.faces}, moving: ${_this.moving}, appearance: ${_this.appearance}, falls: ${_this.falls}, plates: ${_this.plates}, follow: ${_this.follow}, stream: ${_this.stream}, zones: ${_this.zones}, lines: ${_this.lines}, status: ${_this.status}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ViewReadCopyWith<$Res>  {
  factory $ViewReadCopyWith(ViewRead value, $Res Function(ViewRead) _then) = _$ViewReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(name: "camera_uuid", required: true, disallowNullValue: true) String cameraUuid,@JsonKey(name: "camera_name", required: true, disallowNullValue: true) String cameraName,@JsonKey(required: true, disallowNullValue: true, fromJson: ViewRead._read_lens, toJson: ViewRead._write_lens) int lens,@JsonKey(required: true, disallowNullValue: true, fromJson: ViewRead._read_lenses, toJson: ViewRead._write_lenses) int lenses,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true, disallowNullValue: true, fromJson: ViewRead._read_profile, toJson: ViewRead._write_profile) Profile profile,@JsonKey(required: true, disallowNullValue: true) bool enabled,@JsonKey(required: true, disallowNullValue: true) num fps,@JsonKey(required: true) bool? tamper,@JsonKey(required: true) bool? faces,@JsonKey(required: true, disallowNullValue: true) bool moving,@JsonKey(required: true, disallowNullValue: true) bool appearance,@JsonKey(required: true, disallowNullValue: true) bool falls,@JsonKey(required: true, disallowNullValue: true) bool plates,@JsonKey(required: true, disallowNullValue: true) bool follow,@JsonKey(required: true, disallowNullValue: true, fromJson: ViewRead._read_stream, toJson: ViewRead._write_stream) ViewStream stream,@JsonKey(required: true, disallowNullValue: true) List<ZoneRead> zones,@JsonKey(required: true, disallowNullValue: true) List<LineRead> lines,@JsonKey(required: true) Map<String, Object?>? status,@JsonKey(readValue: ViewRead._extras, fromJson: ViewRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$ViewReadCopyWithImpl<$Res>
    implements $ViewReadCopyWith<$Res> {
  _$ViewReadCopyWithImpl(this._self, this._then);

  final ViewRead _self;
  final $Res Function(ViewRead) _then;

/// Create a copy of ViewRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? cameraUuid = null,Object? cameraName = null,Object? lens = null,Object? lenses = null,Object? name = null,Object? profile = null,Object? enabled = null,Object? fps = null,Object? tamper = freezed,Object? faces = freezed,Object? moving = null,Object? appearance = null,Object? falls = null,Object? plates = null,Object? follow = null,Object? stream = null,Object? zones = null,Object? lines = null,Object? status = freezed,Object? additionalProperties = null,}) {
  return _then(ViewRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,cameraUuid: null == cameraUuid ? _self.cameraUuid : cameraUuid // ignore: cast_nullable_to_non_nullable
as String,cameraName: null == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String,lens: null == lens ? _self.lens : lens // ignore: cast_nullable_to_non_nullable
as int,lenses: null == lenses ? _self.lenses : lenses // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,fps: null == fps ? _self.fps : fps // ignore: cast_nullable_to_non_nullable
as num,tamper: freezed == tamper ? _self.tamper : tamper // ignore: cast_nullable_to_non_nullable
as bool?,faces: freezed == faces ? _self.faces : faces // ignore: cast_nullable_to_non_nullable
as bool?,moving: null == moving ? _self.moving : moving // ignore: cast_nullable_to_non_nullable
as bool,appearance: null == appearance ? _self.appearance : appearance // ignore: cast_nullable_to_non_nullable
as bool,falls: null == falls ? _self.falls : falls // ignore: cast_nullable_to_non_nullable
as bool,plates: null == plates ? _self.plates : plates // ignore: cast_nullable_to_non_nullable
as bool,follow: null == follow ? _self.follow : follow // ignore: cast_nullable_to_non_nullable
as bool,stream: null == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as ViewStream,zones: null == zones ? _self.zones : zones // ignore: cast_nullable_to_non_nullable
as List<ZoneRead>,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<LineRead>,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [ViewRead].
extension ViewReadPatterns on ViewRead {
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
