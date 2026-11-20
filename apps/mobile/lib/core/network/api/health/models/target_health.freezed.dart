// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'target_health.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TargetHealth {


/// Create a copy of TargetHealth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TargetHealthCopyWith<TargetHealth> get copyWith => _$TargetHealthCopyWithImpl<TargetHealth>(this as TargetHealth, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TargetHealth;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TargetHealth&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.deviceKind, _this.deviceKind) || other.deviceKind == _this.deviceKind)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.port, _this.port) || other.port == _this.port)&&(identical(other.parentUuid, _this.parentUuid) || other.parentUuid == _this.parentUuid)&&(identical(other.parentName, _this.parentName) || other.parentName == _this.parentName)&&(identical(other.link, _this.link) || other.link == _this.link)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.lastSampleAt, _this.lastSampleAt) || other.lastSampleAt == _this.lastSampleAt)&&(identical(other.lastError, _this.lastError) || other.lastError == _this.lastError)&&(identical(other.samples, _this.samples) || other.samples == _this.samples)&&(identical(other.uptimePercent, _this.uptimePercent) || other.uptimePercent == _this.uptimePercent)&&(identical(other.latency, _this.latency) || other.latency == _this.latency)&&(identical(other.outageCount, _this.outageCount) || other.outageCount == _this.outageCount)&&(identical(other.lastOutage, _this.lastOutage) || other.lastOutage == _this.lastOutage)&&const DeepCollectionEquality().equals(other.buckets, _this.buckets)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as TargetHealth;
  return Object.hashAll([runtimeType,_this.uuid,_this.kind,_this.deviceKind,_this.name,_this.host,_this.port,_this.parentUuid,_this.parentName,_this.link,_this.notes,_this.enabled,_this.status,_this.lastSampleAt,_this.lastError,_this.samples,_this.uptimePercent,_this.latency,_this.outageCount,_this.lastOutage,const DeepCollectionEquality().hash(_this.buckets),const DeepCollectionEquality().hash(_this.additionalProperties)]);
}

@override
String toString() {
  final _this = this as TargetHealth;
  return 'TargetHealth(uuid: ${_this.uuid}, kind: ${_this.kind}, deviceKind: ${_this.deviceKind}, name: ${_this.name}, host: ${_this.host}, port: ${_this.port}, parentUuid: ${_this.parentUuid}, parentName: ${_this.parentName}, link: ${_this.link}, notes: ${_this.notes}, enabled: ${_this.enabled}, status: ${_this.status}, lastSampleAt: ${_this.lastSampleAt}, lastError: ${_this.lastError}, samples: ${_this.samples}, uptimePercent: ${_this.uptimePercent}, latency: ${_this.latency}, outageCount: ${_this.outageCount}, lastOutage: ${_this.lastOutage}, buckets: ${_this.buckets}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $TargetHealthCopyWith<$Res>  {
  factory $TargetHealthCopyWith(TargetHealth value, $Res Function(TargetHealth) _then) = _$TargetHealthCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true, fromJson: TargetHealth._read_kind, toJson: TargetHealth._write_kind) TargetKind kind,@JsonKey(name: "device_kind", required: true, fromJson: TargetHealth._read_deviceKind, toJson: TargetHealth._write_deviceKind) DeviceKind? deviceKind,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(required: true, disallowNullValue: true) String host,@JsonKey(required: true, disallowNullValue: true, fromJson: TargetHealth._read_port, toJson: TargetHealth._write_port) int port,@JsonKey(name: "parent_uuid", required: true) String? parentUuid,@JsonKey(name: "parent_name", required: true) String? parentName,@JsonKey(required: true, fromJson: TargetHealth._read_link, toJson: TargetHealth._write_link) LinkKind? link,@JsonKey(required: true) String? notes,@JsonKey(required: true, disallowNullValue: true) bool enabled,@JsonKey(required: true, disallowNullValue: true, fromJson: TargetHealth._read_status, toJson: TargetHealth._write_status) TargetStatus status,@JsonKey(name: "last_sample_at", required: true, fromJson: TargetHealth._read_lastSampleAt, toJson: TargetHealth._write_lastSampleAt) DateTime? lastSampleAt,@JsonKey(name: "last_error", required: true) String? lastError,@JsonKey(required: true, disallowNullValue: true, fromJson: TargetHealth._read_samples, toJson: TargetHealth._write_samples) int samples,@JsonKey(name: "uptime_percent", required: true) num? uptimePercent,@JsonKey(required: true, disallowNullValue: true) LatencyStats latency,@JsonKey(name: "outage_count", required: true, disallowNullValue: true, fromJson: TargetHealth._read_outageCount, toJson: TargetHealth._write_outageCount) int outageCount,@JsonKey(name: "last_outage", required: true) OutageBrief? lastOutage,@JsonKey(required: true, disallowNullValue: true) List<HealthBucket> buckets,@JsonKey(readValue: TargetHealth._extras, fromJson: TargetHealth._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});


$LatencyStatsCopyWith<$Res> get latency;$OutageBriefCopyWith<$Res>? get lastOutage;

}
/// @nodoc
class _$TargetHealthCopyWithImpl<$Res>
    implements $TargetHealthCopyWith<$Res> {
  _$TargetHealthCopyWithImpl(this._self, this._then);

  final TargetHealth _self;
  final $Res Function(TargetHealth) _then;

/// Create a copy of TargetHealth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? kind = null,Object? deviceKind = freezed,Object? name = null,Object? host = null,Object? port = null,Object? parentUuid = freezed,Object? parentName = freezed,Object? link = freezed,Object? notes = freezed,Object? enabled = null,Object? status = null,Object? lastSampleAt = freezed,Object? lastError = freezed,Object? samples = null,Object? uptimePercent = freezed,Object? latency = null,Object? outageCount = null,Object? lastOutage = freezed,Object? buckets = null,Object? additionalProperties = null,}) {
  return _then(TargetHealth(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TargetKind,deviceKind: freezed == deviceKind ? _self.deviceKind : deviceKind // ignore: cast_nullable_to_non_nullable
as DeviceKind?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,parentUuid: freezed == parentUuid ? _self.parentUuid : parentUuid // ignore: cast_nullable_to_non_nullable
as String?,parentName: freezed == parentName ? _self.parentName : parentName // ignore: cast_nullable_to_non_nullable
as String?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as LinkKind?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TargetStatus,lastSampleAt: freezed == lastSampleAt ? _self.lastSampleAt : lastSampleAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,samples: null == samples ? _self.samples : samples // ignore: cast_nullable_to_non_nullable
as int,uptimePercent: freezed == uptimePercent ? _self.uptimePercent : uptimePercent // ignore: cast_nullable_to_non_nullable
as num?,latency: null == latency ? _self.latency : latency // ignore: cast_nullable_to_non_nullable
as LatencyStats,outageCount: null == outageCount ? _self.outageCount : outageCount // ignore: cast_nullable_to_non_nullable
as int,lastOutage: freezed == lastOutage ? _self.lastOutage : lastOutage // ignore: cast_nullable_to_non_nullable
as OutageBrief?,buckets: null == buckets ? _self.buckets : buckets // ignore: cast_nullable_to_non_nullable
as List<HealthBucket>,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of TargetHealth
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LatencyStatsCopyWith<$Res> get latency {
  
  return $LatencyStatsCopyWith<$Res>(_self.latency, (value) {
    return _then(_self.copyWith(latency: value));
  });
}/// Create a copy of TargetHealth
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutageBriefCopyWith<$Res>? get lastOutage {
    if (_self.lastOutage == null) {
    return null;
  }

  return $OutageBriefCopyWith<$Res>(_self.lastOutage!, (value) {
    return _then(_self.copyWith(lastOutage: value));
  });
}
}


/// Adds pattern-matching-related methods to [TargetHealth].
extension TargetHealthPatterns on TargetHealth {
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
