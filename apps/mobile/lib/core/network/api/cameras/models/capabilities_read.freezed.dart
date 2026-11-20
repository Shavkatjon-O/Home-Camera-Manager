// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capabilities_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CapabilitiesRead {


/// Create a copy of CapabilitiesRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CapabilitiesReadCopyWith<CapabilitiesRead> get copyWith => _$CapabilitiesReadCopyWithImpl<CapabilitiesRead>(this as CapabilitiesRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CapabilitiesRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CapabilitiesRead&&(identical(other.adapter, _this.adapter) || other.adapter == _this.adapter)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.channels, _this.channels) || other.channels == _this.channels)&&(identical(other.identify, _this.identify) || other.identify == _this.identify)&&(identical(other.media, _this.media) || other.media == _this.media)&&(identical(other.control, _this.control) || other.control == _this.control)&&(identical(other.imaging, _this.imaging) || other.imaging == _this.imaging)&&(identical(other.events, _this.events) || other.events == _this.events)&&(identical(other.playback, _this.playback) || other.playback == _this.playback)&&(identical(other.maintenance, _this.maintenance) || other.maintenance == _this.maintenance)&&(identical(other.provisioning, _this.provisioning) || other.provisioning == _this.provisioning)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as CapabilitiesRead;
  return Object.hash(runtimeType,_this.adapter,_this.version,_this.kind,_this.channels,_this.identify,_this.media,_this.control,_this.imaging,_this.events,_this.playback,_this.maintenance,_this.provisioning,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as CapabilitiesRead;
  return 'CapabilitiesRead(adapter: ${_this.adapter}, version: ${_this.version}, kind: ${_this.kind}, channels: ${_this.channels}, identify: ${_this.identify}, media: ${_this.media}, control: ${_this.control}, imaging: ${_this.imaging}, events: ${_this.events}, playback: ${_this.playback}, maintenance: ${_this.maintenance}, provisioning: ${_this.provisioning}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $CapabilitiesReadCopyWith<$Res>  {
  factory $CapabilitiesReadCopyWith(CapabilitiesRead value, $Res Function(CapabilitiesRead) _then) = _$CapabilitiesReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String adapter,@JsonKey(required: true, disallowNullValue: true, fromJson: CapabilitiesRead._read_version, toJson: CapabilitiesRead._write_version) int version,@JsonKey(required: true, disallowNullValue: true) String kind,@JsonKey(required: true, disallowNullValue: true, fromJson: CapabilitiesRead._read_channels, toJson: CapabilitiesRead._write_channels) int channels,@JsonKey(required: true, disallowNullValue: true) bool identify,@JsonKey(required: true, disallowNullValue: true) MediaCapabilities media,@JsonKey(required: true, disallowNullValue: true) ControlCapabilities control,@JsonKey(required: true, disallowNullValue: true) ImagingCapabilities imaging,@JsonKey(required: true, disallowNullValue: true) EventCapabilities events,@JsonKey(required: true, disallowNullValue: true) PlaybackCapabilities playback,@JsonKey(required: true, disallowNullValue: true) MaintenanceCapabilities maintenance,@JsonKey(required: true, disallowNullValue: true) ProvisioningCapabilities provisioning,@JsonKey(readValue: CapabilitiesRead._extras, fromJson: CapabilitiesRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$MediaCapabilitiesCopyWith<$Res> get media;$ControlCapabilitiesCopyWith<$Res> get control;$ImagingCapabilitiesCopyWith<$Res> get imaging;$EventCapabilitiesCopyWith<$Res> get events;$PlaybackCapabilitiesCopyWith<$Res> get playback;$MaintenanceCapabilitiesCopyWith<$Res> get maintenance;$ProvisioningCapabilitiesCopyWith<$Res> get provisioning;

}
/// @nodoc
class _$CapabilitiesReadCopyWithImpl<$Res>
    implements $CapabilitiesReadCopyWith<$Res> {
  _$CapabilitiesReadCopyWithImpl(this._self, this._then);

  final CapabilitiesRead _self;
  final $Res Function(CapabilitiesRead) _then;

/// Create a copy of CapabilitiesRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? adapter = null,Object? version = null,Object? kind = null,Object? channels = null,Object? identify = null,Object? media = null,Object? control = null,Object? imaging = null,Object? events = null,Object? playback = null,Object? maintenance = null,Object? provisioning = null,Object? additionalProperties = null,}) {
  return _then(CapabilitiesRead(
adapter: null == adapter ? _self.adapter : adapter // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,channels: null == channels ? _self.channels : channels // ignore: cast_nullable_to_non_nullable
as int,identify: null == identify ? _self.identify : identify // ignore: cast_nullable_to_non_nullable
as bool,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as MediaCapabilities,control: null == control ? _self.control : control // ignore: cast_nullable_to_non_nullable
as ControlCapabilities,imaging: null == imaging ? _self.imaging : imaging // ignore: cast_nullable_to_non_nullable
as ImagingCapabilities,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as EventCapabilities,playback: null == playback ? _self.playback : playback // ignore: cast_nullable_to_non_nullable
as PlaybackCapabilities,maintenance: null == maintenance ? _self.maintenance : maintenance // ignore: cast_nullable_to_non_nullable
as MaintenanceCapabilities,provisioning: null == provisioning ? _self.provisioning : provisioning // ignore: cast_nullable_to_non_nullable
as ProvisioningCapabilities,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of CapabilitiesRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaCapabilitiesCopyWith<$Res> get media {
  
  return $MediaCapabilitiesCopyWith<$Res>(_self.media, (value) {
    return _then(_self.copyWith(media: value));
  });
}/// Create a copy of CapabilitiesRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ControlCapabilitiesCopyWith<$Res> get control {
  
  return $ControlCapabilitiesCopyWith<$Res>(_self.control, (value) {
    return _then(_self.copyWith(control: value));
  });
}/// Create a copy of CapabilitiesRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImagingCapabilitiesCopyWith<$Res> get imaging {
  
  return $ImagingCapabilitiesCopyWith<$Res>(_self.imaging, (value) {
    return _then(_self.copyWith(imaging: value));
  });
}/// Create a copy of CapabilitiesRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventCapabilitiesCopyWith<$Res> get events {
  
  return $EventCapabilitiesCopyWith<$Res>(_self.events, (value) {
    return _then(_self.copyWith(events: value));
  });
}/// Create a copy of CapabilitiesRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaybackCapabilitiesCopyWith<$Res> get playback {
  
  return $PlaybackCapabilitiesCopyWith<$Res>(_self.playback, (value) {
    return _then(_self.copyWith(playback: value));
  });
}/// Create a copy of CapabilitiesRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MaintenanceCapabilitiesCopyWith<$Res> get maintenance {
  
  return $MaintenanceCapabilitiesCopyWith<$Res>(_self.maintenance, (value) {
    return _then(_self.copyWith(maintenance: value));
  });
}/// Create a copy of CapabilitiesRead
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProvisioningCapabilitiesCopyWith<$Res> get provisioning {
  
  return $ProvisioningCapabilitiesCopyWith<$Res>(_self.provisioning, (value) {
    return _then(_self.copyWith(provisioning: value));
  });
}
}


/// Adds pattern-matching-related methods to [CapabilitiesRead].
extension CapabilitiesReadPatterns on CapabilitiesRead {
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
