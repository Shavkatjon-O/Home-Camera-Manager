// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maintenance_capabilities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MaintenanceCapabilities {


/// Create a copy of MaintenanceCapabilities
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaintenanceCapabilitiesCopyWith<MaintenanceCapabilities> get copyWith => _$MaintenanceCapabilitiesCopyWithImpl<MaintenanceCapabilities>(this as MaintenanceCapabilities, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MaintenanceCapabilities;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaintenanceCapabilities&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.reboot, _this.reboot) || other.reboot == _this.reboot)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as MaintenanceCapabilities;
  return Object.hash(runtimeType,_this.time,_this.reboot,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as MaintenanceCapabilities;
  return 'MaintenanceCapabilities(time: ${_this.time}, reboot: ${_this.reboot}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $MaintenanceCapabilitiesCopyWith<$Res>  {
  factory $MaintenanceCapabilitiesCopyWith(MaintenanceCapabilities value, $Res Function(MaintenanceCapabilities) _then) = _$MaintenanceCapabilitiesCopyWithImpl;
@useResult
$Res call({
@JsonKey(disallowNullValue: true, readValue: MaintenanceCapabilities._presentValue, fromJson: MaintenanceCapabilities._read_time, toJson: MaintenanceCapabilities._write_time) bool time,@JsonKey(disallowNullValue: true, readValue: MaintenanceCapabilities._presentValue, fromJson: MaintenanceCapabilities._read_reboot, toJson: MaintenanceCapabilities._write_reboot) bool reboot,@JsonKey(readValue: MaintenanceCapabilities._extras, fromJson: MaintenanceCapabilities._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$MaintenanceCapabilitiesCopyWithImpl<$Res>
    implements $MaintenanceCapabilitiesCopyWith<$Res> {
  _$MaintenanceCapabilitiesCopyWithImpl(this._self, this._then);

  final MaintenanceCapabilities _self;
  final $Res Function(MaintenanceCapabilities) _then;

/// Create a copy of MaintenanceCapabilities
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? reboot = null,Object? additionalProperties = null,}) {
  return _then(MaintenanceCapabilities(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as bool,reboot: null == reboot ? _self.reboot : reboot // ignore: cast_nullable_to_non_nullable
as bool,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [MaintenanceCapabilities].
extension MaintenanceCapabilitiesPatterns on MaintenanceCapabilities {
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
