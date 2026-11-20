// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'people.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FaceSample {

 String get id; SampleSource get source; double get quality; DateTime get seenAt; String? get cameraName; String? get viewName; String? get eventId; MediaSource get crop;
/// Create a copy of FaceSample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FaceSampleCopyWith<FaceSample> get copyWith => _$FaceSampleCopyWithImpl<FaceSample>(this as FaceSample, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FaceSample;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FaceSample&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.quality, _this.quality) || other.quality == _this.quality)&&(identical(other.seenAt, _this.seenAt) || other.seenAt == _this.seenAt)&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName)&&(identical(other.viewName, _this.viewName) || other.viewName == _this.viewName)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.crop, _this.crop) || other.crop == _this.crop));
}


@override
int get hashCode {
  final _this = this as FaceSample;
  return Object.hash(runtimeType,_this.id,_this.source,_this.quality,_this.seenAt,_this.cameraName,_this.viewName,_this.eventId,_this.crop);
}

@override
String toString() {
  final _this = this as FaceSample;
  return 'FaceSample(id: ${_this.id}, source: ${_this.source}, quality: ${_this.quality}, seenAt: ${_this.seenAt}, cameraName: ${_this.cameraName}, viewName: ${_this.viewName}, eventId: ${_this.eventId}, crop: ${_this.crop})';
}


}

/// @nodoc
abstract mixin class $FaceSampleCopyWith<$Res>  {
  factory $FaceSampleCopyWith(FaceSample value, $Res Function(FaceSample) _then) = _$FaceSampleCopyWithImpl;
@useResult
$Res call({
 String id, SampleSource source, double quality, DateTime seenAt, String? cameraName, String? viewName, String? eventId, MediaSource crop
});




}
/// @nodoc
class _$FaceSampleCopyWithImpl<$Res>
    implements $FaceSampleCopyWith<$Res> {
  _$FaceSampleCopyWithImpl(this._self, this._then);

  final FaceSample _self;
  final $Res Function(FaceSample) _then;

/// Create a copy of FaceSample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? source = null,Object? quality = null,Object? seenAt = null,Object? cameraName = freezed,Object? viewName = freezed,Object? eventId = freezed,Object? crop = null,}) {
  return _then(FaceSample(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SampleSource,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as double,seenAt: null == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime,cameraName: freezed == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String?,viewName: freezed == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,crop: null == crop ? _self.crop : crop // ignore: cast_nullable_to_non_nullable
as MediaSource,
  ));
}

}


/// Adds pattern-matching-related methods to [FaceSample].
extension FaceSamplePatterns on FaceSample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FaceSample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FaceSample() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FaceSample value)  $default,){
final _that = this;
switch (_that) {
case _FaceSample():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FaceSample value)?  $default,){
final _that = this;
switch (_that) {
case _FaceSample() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  SampleSource source,  double quality,  DateTime seenAt,  String? cameraName,  String? viewName,  String? eventId,  MediaSource crop)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FaceSample() when $default != null:
return $default(_that.id,_that.source,_that.quality,_that.seenAt,_that.cameraName,_that.viewName,_that.eventId,_that.crop);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  SampleSource source,  double quality,  DateTime seenAt,  String? cameraName,  String? viewName,  String? eventId,  MediaSource crop)  $default,) {final _that = this;
switch (_that) {
case _FaceSample():
return $default(_that.id,_that.source,_that.quality,_that.seenAt,_that.cameraName,_that.viewName,_that.eventId,_that.crop);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  SampleSource source,  double quality,  DateTime seenAt,  String? cameraName,  String? viewName,  String? eventId,  MediaSource crop)?  $default,) {final _that = this;
switch (_that) {
case _FaceSample() when $default != null:
return $default(_that.id,_that.source,_that.quality,_that.seenAt,_that.cameraName,_that.viewName,_that.eventId,_that.crop);case _:
  return null;

}
}

}

/// @nodoc


class _FaceSample implements FaceSample {
  const _FaceSample({required this.id, required this.source, required this.quality, required this.seenAt, this.cameraName, this.viewName, this.eventId, required this.crop});
  

@override final  String id;
@override final  SampleSource source;
@override final  double quality;
@override final  DateTime seenAt;
@override final  String? cameraName;
@override final  String? viewName;
@override final  String? eventId;
@override final  MediaSource crop;

/// Create a copy of FaceSample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FaceSampleCopyWith<_FaceSample> get copyWith => __$FaceSampleCopyWithImpl<_FaceSample>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FaceSample&&(identical(other.id, id) || other.id == id)&&(identical(other.source, source) || other.source == source)&&(identical(other.quality, quality) || other.quality == quality)&&(identical(other.seenAt, seenAt) || other.seenAt == seenAt)&&(identical(other.cameraName, cameraName) || other.cameraName == cameraName)&&(identical(other.viewName, viewName) || other.viewName == viewName)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.crop, crop) || other.crop == crop));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,source,quality,seenAt,cameraName,viewName,eventId,crop);
}

@override
String toString() {
    return 'FaceSample(id: $id, source: $source, quality: $quality, seenAt: $seenAt, cameraName: $cameraName, viewName: $viewName, eventId: $eventId, crop: $crop)';
}


}

/// @nodoc
abstract mixin class _$FaceSampleCopyWith<$Res> implements $FaceSampleCopyWith<$Res> {
  factory _$FaceSampleCopyWith(_FaceSample value, $Res Function(_FaceSample) _then) = __$FaceSampleCopyWithImpl;
@override @useResult
$Res call({
 String id, SampleSource source, double quality, DateTime seenAt, String? cameraName, String? viewName, String? eventId, MediaSource crop
});




}
/// @nodoc
class __$FaceSampleCopyWithImpl<$Res>
    implements _$FaceSampleCopyWith<$Res> {
  __$FaceSampleCopyWithImpl(this._self, this._then);

  final _FaceSample _self;
  final $Res Function(_FaceSample) _then;

/// Create a copy of FaceSample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? source = null,Object? quality = null,Object? seenAt = null,Object? cameraName = freezed,Object? viewName = freezed,Object? eventId = freezed,Object? crop = null,}) {
  return _then(_FaceSample(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SampleSource,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as double,seenAt: null == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime,cameraName: freezed == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String?,viewName: freezed == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,crop: null == crop ? _self.crop : crop // ignore: cast_nullable_to_non_nullable
as MediaSource,
  ));
}


}

/// @nodoc
mixin _$Sighting {

 String? get eventId; String get sampleId; String? get cameraName; String? get viewName; DateTime get seenAt; double? get confidence; MediaSource get crop;
/// Create a copy of Sighting
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SightingCopyWith<Sighting> get copyWith => _$SightingCopyWithImpl<Sighting>(this as Sighting, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Sighting;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sighting&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.sampleId, _this.sampleId) || other.sampleId == _this.sampleId)&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName)&&(identical(other.viewName, _this.viewName) || other.viewName == _this.viewName)&&(identical(other.seenAt, _this.seenAt) || other.seenAt == _this.seenAt)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.crop, _this.crop) || other.crop == _this.crop));
}


@override
int get hashCode {
  final _this = this as Sighting;
  return Object.hash(runtimeType,_this.eventId,_this.sampleId,_this.cameraName,_this.viewName,_this.seenAt,_this.confidence,_this.crop);
}

@override
String toString() {
  final _this = this as Sighting;
  return 'Sighting(eventId: ${_this.eventId}, sampleId: ${_this.sampleId}, cameraName: ${_this.cameraName}, viewName: ${_this.viewName}, seenAt: ${_this.seenAt}, confidence: ${_this.confidence}, crop: ${_this.crop})';
}


}

/// @nodoc
abstract mixin class $SightingCopyWith<$Res>  {
  factory $SightingCopyWith(Sighting value, $Res Function(Sighting) _then) = _$SightingCopyWithImpl;
@useResult
$Res call({
 String? eventId, String sampleId, String? cameraName, String? viewName, DateTime seenAt, double? confidence, MediaSource crop
});




}
/// @nodoc
class _$SightingCopyWithImpl<$Res>
    implements $SightingCopyWith<$Res> {
  _$SightingCopyWithImpl(this._self, this._then);

  final Sighting _self;
  final $Res Function(Sighting) _then;

/// Create a copy of Sighting
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventId = freezed,Object? sampleId = null,Object? cameraName = freezed,Object? viewName = freezed,Object? seenAt = null,Object? confidence = freezed,Object? crop = null,}) {
  return _then(Sighting(
eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,sampleId: null == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String,cameraName: freezed == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String?,viewName: freezed == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String?,seenAt: null == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,crop: null == crop ? _self.crop : crop // ignore: cast_nullable_to_non_nullable
as MediaSource,
  ));
}

}


/// Adds pattern-matching-related methods to [Sighting].
extension SightingPatterns on Sighting {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Sighting value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Sighting() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Sighting value)  $default,){
final _that = this;
switch (_that) {
case _Sighting():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Sighting value)?  $default,){
final _that = this;
switch (_that) {
case _Sighting() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? eventId,  String sampleId,  String? cameraName,  String? viewName,  DateTime seenAt,  double? confidence,  MediaSource crop)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sighting() when $default != null:
return $default(_that.eventId,_that.sampleId,_that.cameraName,_that.viewName,_that.seenAt,_that.confidence,_that.crop);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? eventId,  String sampleId,  String? cameraName,  String? viewName,  DateTime seenAt,  double? confidence,  MediaSource crop)  $default,) {final _that = this;
switch (_that) {
case _Sighting():
return $default(_that.eventId,_that.sampleId,_that.cameraName,_that.viewName,_that.seenAt,_that.confidence,_that.crop);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? eventId,  String sampleId,  String? cameraName,  String? viewName,  DateTime seenAt,  double? confidence,  MediaSource crop)?  $default,) {final _that = this;
switch (_that) {
case _Sighting() when $default != null:
return $default(_that.eventId,_that.sampleId,_that.cameraName,_that.viewName,_that.seenAt,_that.confidence,_that.crop);case _:
  return null;

}
}

}

/// @nodoc


class _Sighting implements Sighting {
  const _Sighting({this.eventId, required this.sampleId, this.cameraName, this.viewName, required this.seenAt, this.confidence, required this.crop});
  

@override final  String? eventId;
@override final  String sampleId;
@override final  String? cameraName;
@override final  String? viewName;
@override final  DateTime seenAt;
@override final  double? confidence;
@override final  MediaSource crop;

/// Create a copy of Sighting
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SightingCopyWith<_Sighting> get copyWith => __$SightingCopyWithImpl<_Sighting>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sighting&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId)&&(identical(other.cameraName, cameraName) || other.cameraName == cameraName)&&(identical(other.viewName, viewName) || other.viewName == viewName)&&(identical(other.seenAt, seenAt) || other.seenAt == seenAt)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.crop, crop) || other.crop == crop));
}


@override
int get hashCode {
    return Object.hash(runtimeType,eventId,sampleId,cameraName,viewName,seenAt,confidence,crop);
}

@override
String toString() {
    return 'Sighting(eventId: $eventId, sampleId: $sampleId, cameraName: $cameraName, viewName: $viewName, seenAt: $seenAt, confidence: $confidence, crop: $crop)';
}


}

/// @nodoc
abstract mixin class _$SightingCopyWith<$Res> implements $SightingCopyWith<$Res> {
  factory _$SightingCopyWith(_Sighting value, $Res Function(_Sighting) _then) = __$SightingCopyWithImpl;
@override @useResult
$Res call({
 String? eventId, String sampleId, String? cameraName, String? viewName, DateTime seenAt, double? confidence, MediaSource crop
});




}
/// @nodoc
class __$SightingCopyWithImpl<$Res>
    implements _$SightingCopyWith<$Res> {
  __$SightingCopyWithImpl(this._self, this._then);

  final _Sighting _self;
  final $Res Function(_Sighting) _then;

/// Create a copy of Sighting
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = freezed,Object? sampleId = null,Object? cameraName = freezed,Object? viewName = freezed,Object? seenAt = null,Object? confidence = freezed,Object? crop = null,}) {
  return _then(_Sighting(
eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,sampleId: null == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String,cameraName: freezed == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String?,viewName: freezed == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String?,seenAt: null == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,crop: null == crop ? _self.crop : crop // ignore: cast_nullable_to_non_nullable
as MediaSource,
  ));
}


}

/// @nodoc
mixin _$Person {

 String get id; String get name; String? get notes; int get color; List<FaceSample> get samples; DateTime? get lastSeenAt; List<Sighting> get sightings;
/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonCopyWith<Person> get copyWith => _$PersonCopyWithImpl<Person>(this as Person, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Person;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Person&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.color, _this.color) || other.color == _this.color)&&const DeepCollectionEquality().equals(other.samples, _this.samples)&&(identical(other.lastSeenAt, _this.lastSeenAt) || other.lastSeenAt == _this.lastSeenAt)&&const DeepCollectionEquality().equals(other.sightings, _this.sightings));
}


@override
int get hashCode {
  final _this = this as Person;
  return Object.hash(runtimeType,_this.id,_this.name,_this.notes,_this.color,const DeepCollectionEquality().hash(_this.samples),_this.lastSeenAt,const DeepCollectionEquality().hash(_this.sightings));
}

@override
String toString() {
  final _this = this as Person;
  return 'Person(id: ${_this.id}, name: ${_this.name}, notes: ${_this.notes}, color: ${_this.color}, samples: ${_this.samples}, lastSeenAt: ${_this.lastSeenAt}, sightings: ${_this.sightings})';
}


}

/// @nodoc
abstract mixin class $PersonCopyWith<$Res>  {
  factory $PersonCopyWith(Person value, $Res Function(Person) _then) = _$PersonCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? notes, int color, List<FaceSample> samples, DateTime? lastSeenAt, List<Sighting> sightings
});




}
/// @nodoc
class _$PersonCopyWithImpl<$Res>
    implements $PersonCopyWith<$Res> {
  _$PersonCopyWithImpl(this._self, this._then);

  final Person _self;
  final $Res Function(Person) _then;

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? notes = freezed,Object? color = null,Object? samples = null,Object? lastSeenAt = freezed,Object? sightings = null,}) {
  return _then(Person(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,samples: null == samples ? _self.samples : samples // ignore: cast_nullable_to_non_nullable
as List<FaceSample>,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sightings: null == sightings ? _self.sightings : sightings // ignore: cast_nullable_to_non_nullable
as List<Sighting>,
  ));
}

}


/// Adds pattern-matching-related methods to [Person].
extension PersonPatterns on Person {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Person value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Person value)  $default,){
final _that = this;
switch (_that) {
case _Person():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Person value)?  $default,){
final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? notes,  int color,  List<FaceSample> samples,  DateTime? lastSeenAt,  List<Sighting> sightings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that.id,_that.name,_that.notes,_that.color,_that.samples,_that.lastSeenAt,_that.sightings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? notes,  int color,  List<FaceSample> samples,  DateTime? lastSeenAt,  List<Sighting> sightings)  $default,) {final _that = this;
switch (_that) {
case _Person():
return $default(_that.id,_that.name,_that.notes,_that.color,_that.samples,_that.lastSeenAt,_that.sightings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? notes,  int color,  List<FaceSample> samples,  DateTime? lastSeenAt,  List<Sighting> sightings)?  $default,) {final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that.id,_that.name,_that.notes,_that.color,_that.samples,_that.lastSeenAt,_that.sightings);case _:
  return null;

}
}

}

/// @nodoc


class _Person implements Person {
  const _Person({required this.id, required this.name, this.notes, required this.color,  List<FaceSample> samples = const <FaceSample>[], this.lastSeenAt,  List<Sighting> sightings = const <Sighting>[]}): _samples = samples,_sightings = sightings;
  

@override final  String id;
@override final  String name;
@override final  String? notes;
@override final  int color;
 final  List<FaceSample> _samples;
@override@JsonKey() List<FaceSample> get samples {
  if (_samples is EqualUnmodifiableListView) return _samples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_samples);
}

@override final  DateTime? lastSeenAt;
 final  List<Sighting> _sightings;
@override@JsonKey() List<Sighting> get sightings {
  if (_sightings is EqualUnmodifiableListView) return _sightings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sightings);
}


/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonCopyWith<_Person> get copyWith => __$PersonCopyWithImpl<_Person>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Person&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other.samples, _samples)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&const DeepCollectionEquality().equals(other.sightings, _sightings));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,notes,color,const DeepCollectionEquality().hash(_samples),lastSeenAt,const DeepCollectionEquality().hash(_sightings));
}

@override
String toString() {
    return 'Person(id: $id, name: $name, notes: $notes, color: $color, samples: $samples, lastSeenAt: $lastSeenAt, sightings: $sightings)';
}


}

/// @nodoc
abstract mixin class _$PersonCopyWith<$Res> implements $PersonCopyWith<$Res> {
  factory _$PersonCopyWith(_Person value, $Res Function(_Person) _then) = __$PersonCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? notes, int color, List<FaceSample> samples, DateTime? lastSeenAt, List<Sighting> sightings
});




}
/// @nodoc
class __$PersonCopyWithImpl<$Res>
    implements _$PersonCopyWith<$Res> {
  __$PersonCopyWithImpl(this._self, this._then);

  final _Person _self;
  final $Res Function(_Person) _then;

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? notes = freezed,Object? color = null,Object? samples = null,Object? lastSeenAt = freezed,Object? sightings = null,}) {
  return _then(_Person(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,samples: null == samples ? _self._samples : samples // ignore: cast_nullable_to_non_nullable
as List<FaceSample>,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sightings: null == sightings ? _self._sightings : sightings // ignore: cast_nullable_to_non_nullable
as List<Sighting>,
  ));
}


}

/// @nodoc
mixin _$FaceCluster {

 String get id; int get number; String get label; int get seenCount; DateTime get firstSeenAt; DateTime get lastSeenAt; List<FaceSample> get samples; List<Sighting> get sightings;
/// Create a copy of FaceCluster
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FaceClusterCopyWith<FaceCluster> get copyWith => _$FaceClusterCopyWithImpl<FaceCluster>(this as FaceCluster, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FaceCluster;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FaceCluster&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.seenCount, _this.seenCount) || other.seenCount == _this.seenCount)&&(identical(other.firstSeenAt, _this.firstSeenAt) || other.firstSeenAt == _this.firstSeenAt)&&(identical(other.lastSeenAt, _this.lastSeenAt) || other.lastSeenAt == _this.lastSeenAt)&&const DeepCollectionEquality().equals(other.samples, _this.samples)&&const DeepCollectionEquality().equals(other.sightings, _this.sightings));
}


@override
int get hashCode {
  final _this = this as FaceCluster;
  return Object.hash(runtimeType,_this.id,_this.number,_this.label,_this.seenCount,_this.firstSeenAt,_this.lastSeenAt,const DeepCollectionEquality().hash(_this.samples),const DeepCollectionEquality().hash(_this.sightings));
}

@override
String toString() {
  final _this = this as FaceCluster;
  return 'FaceCluster(id: ${_this.id}, number: ${_this.number}, label: ${_this.label}, seenCount: ${_this.seenCount}, firstSeenAt: ${_this.firstSeenAt}, lastSeenAt: ${_this.lastSeenAt}, samples: ${_this.samples}, sightings: ${_this.sightings})';
}


}

/// @nodoc
abstract mixin class $FaceClusterCopyWith<$Res>  {
  factory $FaceClusterCopyWith(FaceCluster value, $Res Function(FaceCluster) _then) = _$FaceClusterCopyWithImpl;
@useResult
$Res call({
 String id, int number, String label, int seenCount, DateTime firstSeenAt, DateTime lastSeenAt, List<FaceSample> samples, List<Sighting> sightings
});




}
/// @nodoc
class _$FaceClusterCopyWithImpl<$Res>
    implements $FaceClusterCopyWith<$Res> {
  _$FaceClusterCopyWithImpl(this._self, this._then);

  final FaceCluster _self;
  final $Res Function(FaceCluster) _then;

/// Create a copy of FaceCluster
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? label = null,Object? seenCount = null,Object? firstSeenAt = null,Object? lastSeenAt = null,Object? samples = null,Object? sightings = null,}) {
  return _then(FaceCluster(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,seenCount: null == seenCount ? _self.seenCount : seenCount // ignore: cast_nullable_to_non_nullable
as int,firstSeenAt: null == firstSeenAt ? _self.firstSeenAt : firstSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastSeenAt: null == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,samples: null == samples ? _self.samples : samples // ignore: cast_nullable_to_non_nullable
as List<FaceSample>,sightings: null == sightings ? _self.sightings : sightings // ignore: cast_nullable_to_non_nullable
as List<Sighting>,
  ));
}

}


/// Adds pattern-matching-related methods to [FaceCluster].
extension FaceClusterPatterns on FaceCluster {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FaceCluster value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FaceCluster() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FaceCluster value)  $default,){
final _that = this;
switch (_that) {
case _FaceCluster():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FaceCluster value)?  $default,){
final _that = this;
switch (_that) {
case _FaceCluster() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int number,  String label,  int seenCount,  DateTime firstSeenAt,  DateTime lastSeenAt,  List<FaceSample> samples,  List<Sighting> sightings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FaceCluster() when $default != null:
return $default(_that.id,_that.number,_that.label,_that.seenCount,_that.firstSeenAt,_that.lastSeenAt,_that.samples,_that.sightings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int number,  String label,  int seenCount,  DateTime firstSeenAt,  DateTime lastSeenAt,  List<FaceSample> samples,  List<Sighting> sightings)  $default,) {final _that = this;
switch (_that) {
case _FaceCluster():
return $default(_that.id,_that.number,_that.label,_that.seenCount,_that.firstSeenAt,_that.lastSeenAt,_that.samples,_that.sightings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int number,  String label,  int seenCount,  DateTime firstSeenAt,  DateTime lastSeenAt,  List<FaceSample> samples,  List<Sighting> sightings)?  $default,) {final _that = this;
switch (_that) {
case _FaceCluster() when $default != null:
return $default(_that.id,_that.number,_that.label,_that.seenCount,_that.firstSeenAt,_that.lastSeenAt,_that.samples,_that.sightings);case _:
  return null;

}
}

}

/// @nodoc


class _FaceCluster implements FaceCluster {
  const _FaceCluster({required this.id, required this.number, required this.label, required this.seenCount, required this.firstSeenAt, required this.lastSeenAt,  List<FaceSample> samples = const <FaceSample>[],  List<Sighting> sightings = const <Sighting>[]}): _samples = samples,_sightings = sightings;
  

@override final  String id;
@override final  int number;
@override final  String label;
@override final  int seenCount;
@override final  DateTime firstSeenAt;
@override final  DateTime lastSeenAt;
 final  List<FaceSample> _samples;
@override@JsonKey() List<FaceSample> get samples {
  if (_samples is EqualUnmodifiableListView) return _samples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_samples);
}

 final  List<Sighting> _sightings;
@override@JsonKey() List<Sighting> get sightings {
  if (_sightings is EqualUnmodifiableListView) return _sightings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sightings);
}


/// Create a copy of FaceCluster
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FaceClusterCopyWith<_FaceCluster> get copyWith => __$FaceClusterCopyWithImpl<_FaceCluster>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FaceCluster&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.label, label) || other.label == label)&&(identical(other.seenCount, seenCount) || other.seenCount == seenCount)&&(identical(other.firstSeenAt, firstSeenAt) || other.firstSeenAt == firstSeenAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&const DeepCollectionEquality().equals(other.samples, _samples)&&const DeepCollectionEquality().equals(other.sightings, _sightings));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,number,label,seenCount,firstSeenAt,lastSeenAt,const DeepCollectionEquality().hash(_samples),const DeepCollectionEquality().hash(_sightings));
}

@override
String toString() {
    return 'FaceCluster(id: $id, number: $number, label: $label, seenCount: $seenCount, firstSeenAt: $firstSeenAt, lastSeenAt: $lastSeenAt, samples: $samples, sightings: $sightings)';
}


}

/// @nodoc
abstract mixin class _$FaceClusterCopyWith<$Res> implements $FaceClusterCopyWith<$Res> {
  factory _$FaceClusterCopyWith(_FaceCluster value, $Res Function(_FaceCluster) _then) = __$FaceClusterCopyWithImpl;
@override @useResult
$Res call({
 String id, int number, String label, int seenCount, DateTime firstSeenAt, DateTime lastSeenAt, List<FaceSample> samples, List<Sighting> sightings
});




}
/// @nodoc
class __$FaceClusterCopyWithImpl<$Res>
    implements _$FaceClusterCopyWith<$Res> {
  __$FaceClusterCopyWithImpl(this._self, this._then);

  final _FaceCluster _self;
  final $Res Function(_FaceCluster) _then;

/// Create a copy of FaceCluster
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? label = null,Object? seenCount = null,Object? firstSeenAt = null,Object? lastSeenAt = null,Object? samples = null,Object? sightings = null,}) {
  return _then(_FaceCluster(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,seenCount: null == seenCount ? _self.seenCount : seenCount // ignore: cast_nullable_to_non_nullable
as int,firstSeenAt: null == firstSeenAt ? _self.firstSeenAt : firstSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastSeenAt: null == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,samples: null == samples ? _self._samples : samples // ignore: cast_nullable_to_non_nullable
as List<FaceSample>,sightings: null == sightings ? _self._sightings : sightings // ignore: cast_nullable_to_non_nullable
as List<Sighting>,
  ));
}


}

/// @nodoc
mixin _$SimilarFace {

 String get sampleId; double get score; DateTime get seenAt; String? get personId; String? get personName; String? get clusterId; String? get clusterLabel; String? get eventId; String? get cameraName; MediaSource get crop;
/// Create a copy of SimilarFace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SimilarFaceCopyWith<SimilarFace> get copyWith => _$SimilarFaceCopyWithImpl<SimilarFace>(this as SimilarFace, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SimilarFace;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SimilarFace&&(identical(other.sampleId, _this.sampleId) || other.sampleId == _this.sampleId)&&(identical(other.score, _this.score) || other.score == _this.score)&&(identical(other.seenAt, _this.seenAt) || other.seenAt == _this.seenAt)&&(identical(other.personId, _this.personId) || other.personId == _this.personId)&&(identical(other.personName, _this.personName) || other.personName == _this.personName)&&(identical(other.clusterId, _this.clusterId) || other.clusterId == _this.clusterId)&&(identical(other.clusterLabel, _this.clusterLabel) || other.clusterLabel == _this.clusterLabel)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName)&&(identical(other.crop, _this.crop) || other.crop == _this.crop));
}


@override
int get hashCode {
  final _this = this as SimilarFace;
  return Object.hash(runtimeType,_this.sampleId,_this.score,_this.seenAt,_this.personId,_this.personName,_this.clusterId,_this.clusterLabel,_this.eventId,_this.cameraName,_this.crop);
}

@override
String toString() {
  final _this = this as SimilarFace;
  return 'SimilarFace(sampleId: ${_this.sampleId}, score: ${_this.score}, seenAt: ${_this.seenAt}, personId: ${_this.personId}, personName: ${_this.personName}, clusterId: ${_this.clusterId}, clusterLabel: ${_this.clusterLabel}, eventId: ${_this.eventId}, cameraName: ${_this.cameraName}, crop: ${_this.crop})';
}


}

/// @nodoc
abstract mixin class $SimilarFaceCopyWith<$Res>  {
  factory $SimilarFaceCopyWith(SimilarFace value, $Res Function(SimilarFace) _then) = _$SimilarFaceCopyWithImpl;
@useResult
$Res call({
 String sampleId, double score, DateTime seenAt, String? personId, String? personName, String? clusterId, String? clusterLabel, String? eventId, String? cameraName, MediaSource crop
});




}
/// @nodoc
class _$SimilarFaceCopyWithImpl<$Res>
    implements $SimilarFaceCopyWith<$Res> {
  _$SimilarFaceCopyWithImpl(this._self, this._then);

  final SimilarFace _self;
  final $Res Function(SimilarFace) _then;

/// Create a copy of SimilarFace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sampleId = null,Object? score = null,Object? seenAt = null,Object? personId = freezed,Object? personName = freezed,Object? clusterId = freezed,Object? clusterLabel = freezed,Object? eventId = freezed,Object? cameraName = freezed,Object? crop = null,}) {
  return _then(SimilarFace(
sampleId: null == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,seenAt: null == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime,personId: freezed == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String?,personName: freezed == personName ? _self.personName : personName // ignore: cast_nullable_to_non_nullable
as String?,clusterId: freezed == clusterId ? _self.clusterId : clusterId // ignore: cast_nullable_to_non_nullable
as String?,clusterLabel: freezed == clusterLabel ? _self.clusterLabel : clusterLabel // ignore: cast_nullable_to_non_nullable
as String?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,cameraName: freezed == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String?,crop: null == crop ? _self.crop : crop // ignore: cast_nullable_to_non_nullable
as MediaSource,
  ));
}

}


/// Adds pattern-matching-related methods to [SimilarFace].
extension SimilarFacePatterns on SimilarFace {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SimilarFace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SimilarFace() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SimilarFace value)  $default,){
final _that = this;
switch (_that) {
case _SimilarFace():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SimilarFace value)?  $default,){
final _that = this;
switch (_that) {
case _SimilarFace() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sampleId,  double score,  DateTime seenAt,  String? personId,  String? personName,  String? clusterId,  String? clusterLabel,  String? eventId,  String? cameraName,  MediaSource crop)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SimilarFace() when $default != null:
return $default(_that.sampleId,_that.score,_that.seenAt,_that.personId,_that.personName,_that.clusterId,_that.clusterLabel,_that.eventId,_that.cameraName,_that.crop);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sampleId,  double score,  DateTime seenAt,  String? personId,  String? personName,  String? clusterId,  String? clusterLabel,  String? eventId,  String? cameraName,  MediaSource crop)  $default,) {final _that = this;
switch (_that) {
case _SimilarFace():
return $default(_that.sampleId,_that.score,_that.seenAt,_that.personId,_that.personName,_that.clusterId,_that.clusterLabel,_that.eventId,_that.cameraName,_that.crop);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sampleId,  double score,  DateTime seenAt,  String? personId,  String? personName,  String? clusterId,  String? clusterLabel,  String? eventId,  String? cameraName,  MediaSource crop)?  $default,) {final _that = this;
switch (_that) {
case _SimilarFace() when $default != null:
return $default(_that.sampleId,_that.score,_that.seenAt,_that.personId,_that.personName,_that.clusterId,_that.clusterLabel,_that.eventId,_that.cameraName,_that.crop);case _:
  return null;

}
}

}

/// @nodoc


class _SimilarFace implements SimilarFace {
  const _SimilarFace({required this.sampleId, required this.score, required this.seenAt, this.personId, this.personName, this.clusterId, this.clusterLabel, this.eventId, this.cameraName, required this.crop});
  

@override final  String sampleId;
@override final  double score;
@override final  DateTime seenAt;
@override final  String? personId;
@override final  String? personName;
@override final  String? clusterId;
@override final  String? clusterLabel;
@override final  String? eventId;
@override final  String? cameraName;
@override final  MediaSource crop;

/// Create a copy of SimilarFace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SimilarFaceCopyWith<_SimilarFace> get copyWith => __$SimilarFaceCopyWithImpl<_SimilarFace>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SimilarFace&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId)&&(identical(other.score, score) || other.score == score)&&(identical(other.seenAt, seenAt) || other.seenAt == seenAt)&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.personName, personName) || other.personName == personName)&&(identical(other.clusterId, clusterId) || other.clusterId == clusterId)&&(identical(other.clusterLabel, clusterLabel) || other.clusterLabel == clusterLabel)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.cameraName, cameraName) || other.cameraName == cameraName)&&(identical(other.crop, crop) || other.crop == crop));
}


@override
int get hashCode {
    return Object.hash(runtimeType,sampleId,score,seenAt,personId,personName,clusterId,clusterLabel,eventId,cameraName,crop);
}

@override
String toString() {
    return 'SimilarFace(sampleId: $sampleId, score: $score, seenAt: $seenAt, personId: $personId, personName: $personName, clusterId: $clusterId, clusterLabel: $clusterLabel, eventId: $eventId, cameraName: $cameraName, crop: $crop)';
}


}

/// @nodoc
abstract mixin class _$SimilarFaceCopyWith<$Res> implements $SimilarFaceCopyWith<$Res> {
  factory _$SimilarFaceCopyWith(_SimilarFace value, $Res Function(_SimilarFace) _then) = __$SimilarFaceCopyWithImpl;
@override @useResult
$Res call({
 String sampleId, double score, DateTime seenAt, String? personId, String? personName, String? clusterId, String? clusterLabel, String? eventId, String? cameraName, MediaSource crop
});




}
/// @nodoc
class __$SimilarFaceCopyWithImpl<$Res>
    implements _$SimilarFaceCopyWith<$Res> {
  __$SimilarFaceCopyWithImpl(this._self, this._then);

  final _SimilarFace _self;
  final $Res Function(_SimilarFace) _then;

/// Create a copy of SimilarFace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sampleId = null,Object? score = null,Object? seenAt = null,Object? personId = freezed,Object? personName = freezed,Object? clusterId = freezed,Object? clusterLabel = freezed,Object? eventId = freezed,Object? cameraName = freezed,Object? crop = null,}) {
  return _then(_SimilarFace(
sampleId: null == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,seenAt: null == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime,personId: freezed == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String?,personName: freezed == personName ? _self.personName : personName // ignore: cast_nullable_to_non_nullable
as String?,clusterId: freezed == clusterId ? _self.clusterId : clusterId // ignore: cast_nullable_to_non_nullable
as String?,clusterLabel: freezed == clusterLabel ? _self.clusterLabel : clusterLabel // ignore: cast_nullable_to_non_nullable
as String?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,cameraName: freezed == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String?,crop: null == crop ? _self.crop : crop // ignore: cast_nullable_to_non_nullable
as MediaSource,
  ));
}


}

/// @nodoc
mixin _$PhotoResult {

 int get added; List<String> get rejected;
/// Create a copy of PhotoResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoResultCopyWith<PhotoResult> get copyWith => _$PhotoResultCopyWithImpl<PhotoResult>(this as PhotoResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PhotoResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoResult&&(identical(other.added, _this.added) || other.added == _this.added)&&const DeepCollectionEquality().equals(other.rejected, _this.rejected));
}


@override
int get hashCode {
  final _this = this as PhotoResult;
  return Object.hash(runtimeType,_this.added,const DeepCollectionEquality().hash(_this.rejected));
}

@override
String toString() {
  final _this = this as PhotoResult;
  return 'PhotoResult(added: ${_this.added}, rejected: ${_this.rejected})';
}


}

/// @nodoc
abstract mixin class $PhotoResultCopyWith<$Res>  {
  factory $PhotoResultCopyWith(PhotoResult value, $Res Function(PhotoResult) _then) = _$PhotoResultCopyWithImpl;
@useResult
$Res call({
 int added, List<String> rejected
});




}
/// @nodoc
class _$PhotoResultCopyWithImpl<$Res>
    implements $PhotoResultCopyWith<$Res> {
  _$PhotoResultCopyWithImpl(this._self, this._then);

  final PhotoResult _self;
  final $Res Function(PhotoResult) _then;

/// Create a copy of PhotoResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? added = null,Object? rejected = null,}) {
  return _then(PhotoResult(
added: null == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoResult].
extension PhotoResultPatterns on PhotoResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoResult() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoResult value)  $default,){
final _that = this;
switch (_that) {
case _PhotoResult():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoResult value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoResult() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int added,  List<String> rejected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoResult() when $default != null:
return $default(_that.added,_that.rejected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int added,  List<String> rejected)  $default,) {final _that = this;
switch (_that) {
case _PhotoResult():
return $default(_that.added,_that.rejected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int added,  List<String> rejected)?  $default,) {final _that = this;
switch (_that) {
case _PhotoResult() when $default != null:
return $default(_that.added,_that.rejected);case _:
  return null;

}
}

}

/// @nodoc


class _PhotoResult implements PhotoResult {
  const _PhotoResult({required this.added,  List<String> rejected = const <String>[]}): _rejected = rejected;
  

@override final  int added;
 final  List<String> _rejected;
@override@JsonKey() List<String> get rejected {
  if (_rejected is EqualUnmodifiableListView) return _rejected;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rejected);
}


/// Create a copy of PhotoResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoResultCopyWith<_PhotoResult> get copyWith => __$PhotoResultCopyWithImpl<_PhotoResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoResult&&(identical(other.added, added) || other.added == added)&&const DeepCollectionEquality().equals(other.rejected, _rejected));
}


@override
int get hashCode {
    return Object.hash(runtimeType,added,const DeepCollectionEquality().hash(_rejected));
}

@override
String toString() {
    return 'PhotoResult(added: $added, rejected: $rejected)';
}


}

/// @nodoc
abstract mixin class _$PhotoResultCopyWith<$Res> implements $PhotoResultCopyWith<$Res> {
  factory _$PhotoResultCopyWith(_PhotoResult value, $Res Function(_PhotoResult) _then) = __$PhotoResultCopyWithImpl;
@override @useResult
$Res call({
 int added, List<String> rejected
});




}
/// @nodoc
class __$PhotoResultCopyWithImpl<$Res>
    implements _$PhotoResultCopyWith<$Res> {
  __$PhotoResultCopyWithImpl(this._self, this._then);

  final _PhotoResult _self;
  final $Res Function(_PhotoResult) _then;

/// Create a copy of PhotoResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? added = null,Object? rejected = null,}) {
  return _then(_PhotoResult(
added: null == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self._rejected : rejected // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$JourneyStep {

 String get cameraName; String? get viewName; DateTime get startedAt; DateTime get endedAt; double? get similarity; String? get eventId;
/// Create a copy of JourneyStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JourneyStepCopyWith<JourneyStep> get copyWith => _$JourneyStepCopyWithImpl<JourneyStep>(this as JourneyStep, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as JourneyStep;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JourneyStep&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName)&&(identical(other.viewName, _this.viewName) || other.viewName == _this.viewName)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.similarity, _this.similarity) || other.similarity == _this.similarity)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId));
}


@override
int get hashCode {
  final _this = this as JourneyStep;
  return Object.hash(runtimeType,_this.cameraName,_this.viewName,_this.startedAt,_this.endedAt,_this.similarity,_this.eventId);
}

@override
String toString() {
  final _this = this as JourneyStep;
  return 'JourneyStep(cameraName: ${_this.cameraName}, viewName: ${_this.viewName}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt}, similarity: ${_this.similarity}, eventId: ${_this.eventId})';
}


}

/// @nodoc
abstract mixin class $JourneyStepCopyWith<$Res>  {
  factory $JourneyStepCopyWith(JourneyStep value, $Res Function(JourneyStep) _then) = _$JourneyStepCopyWithImpl;
@useResult
$Res call({
 String cameraName, String? viewName, DateTime startedAt, DateTime endedAt, double? similarity, String? eventId
});




}
/// @nodoc
class _$JourneyStepCopyWithImpl<$Res>
    implements $JourneyStepCopyWith<$Res> {
  _$JourneyStepCopyWithImpl(this._self, this._then);

  final JourneyStep _self;
  final $Res Function(JourneyStep) _then;

/// Create a copy of JourneyStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cameraName = null,Object? viewName = freezed,Object? startedAt = null,Object? endedAt = null,Object? similarity = freezed,Object? eventId = freezed,}) {
  return _then(JourneyStep(
cameraName: null == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String,viewName: freezed == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime,similarity: freezed == similarity ? _self.similarity : similarity // ignore: cast_nullable_to_non_nullable
as double?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [JourneyStep].
extension JourneyStepPatterns on JourneyStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JourneyStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JourneyStep() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JourneyStep value)  $default,){
final _that = this;
switch (_that) {
case _JourneyStep():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JourneyStep value)?  $default,){
final _that = this;
switch (_that) {
case _JourneyStep() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String cameraName,  String? viewName,  DateTime startedAt,  DateTime endedAt,  double? similarity,  String? eventId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JourneyStep() when $default != null:
return $default(_that.cameraName,_that.viewName,_that.startedAt,_that.endedAt,_that.similarity,_that.eventId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String cameraName,  String? viewName,  DateTime startedAt,  DateTime endedAt,  double? similarity,  String? eventId)  $default,) {final _that = this;
switch (_that) {
case _JourneyStep():
return $default(_that.cameraName,_that.viewName,_that.startedAt,_that.endedAt,_that.similarity,_that.eventId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String cameraName,  String? viewName,  DateTime startedAt,  DateTime endedAt,  double? similarity,  String? eventId)?  $default,) {final _that = this;
switch (_that) {
case _JourneyStep() when $default != null:
return $default(_that.cameraName,_that.viewName,_that.startedAt,_that.endedAt,_that.similarity,_that.eventId);case _:
  return null;

}
}

}

/// @nodoc


class _JourneyStep implements JourneyStep {
  const _JourneyStep({required this.cameraName, this.viewName, required this.startedAt, required this.endedAt, this.similarity, this.eventId});
  

@override final  String cameraName;
@override final  String? viewName;
@override final  DateTime startedAt;
@override final  DateTime endedAt;
@override final  double? similarity;
@override final  String? eventId;

/// Create a copy of JourneyStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JourneyStepCopyWith<_JourneyStep> get copyWith => __$JourneyStepCopyWithImpl<_JourneyStep>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _JourneyStep&&(identical(other.cameraName, cameraName) || other.cameraName == cameraName)&&(identical(other.viewName, viewName) || other.viewName == viewName)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.similarity, similarity) || other.similarity == similarity)&&(identical(other.eventId, eventId) || other.eventId == eventId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cameraName,viewName,startedAt,endedAt,similarity,eventId);
}

@override
String toString() {
    return 'JourneyStep(cameraName: $cameraName, viewName: $viewName, startedAt: $startedAt, endedAt: $endedAt, similarity: $similarity, eventId: $eventId)';
}


}

/// @nodoc
abstract mixin class _$JourneyStepCopyWith<$Res> implements $JourneyStepCopyWith<$Res> {
  factory _$JourneyStepCopyWith(_JourneyStep value, $Res Function(_JourneyStep) _then) = __$JourneyStepCopyWithImpl;
@override @useResult
$Res call({
 String cameraName, String? viewName, DateTime startedAt, DateTime endedAt, double? similarity, String? eventId
});




}
/// @nodoc
class __$JourneyStepCopyWithImpl<$Res>
    implements _$JourneyStepCopyWith<$Res> {
  __$JourneyStepCopyWithImpl(this._self, this._then);

  final _JourneyStep _self;
  final $Res Function(_JourneyStep) _then;

/// Create a copy of JourneyStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cameraName = null,Object? viewName = freezed,Object? startedAt = null,Object? endedAt = null,Object? similarity = freezed,Object? eventId = freezed,}) {
  return _then(_JourneyStep(
cameraName: null == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String,viewName: freezed == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime,similarity: freezed == similarity ? _self.similarity : similarity // ignore: cast_nullable_to_non_nullable
as double?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Journey {

 String get id; String get description; DateTime get startedAt; DateTime get endedAt; List<JourneyStep> get steps;
/// Create a copy of Journey
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JourneyCopyWith<Journey> get copyWith => _$JourneyCopyWithImpl<Journey>(this as Journey, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Journey;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Journey&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&const DeepCollectionEquality().equals(other.steps, _this.steps));
}


@override
int get hashCode {
  final _this = this as Journey;
  return Object.hash(runtimeType,_this.id,_this.description,_this.startedAt,_this.endedAt,const DeepCollectionEquality().hash(_this.steps));
}

@override
String toString() {
  final _this = this as Journey;
  return 'Journey(id: ${_this.id}, description: ${_this.description}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt}, steps: ${_this.steps})';
}


}

/// @nodoc
abstract mixin class $JourneyCopyWith<$Res>  {
  factory $JourneyCopyWith(Journey value, $Res Function(Journey) _then) = _$JourneyCopyWithImpl;
@useResult
$Res call({
 String id, String description, DateTime startedAt, DateTime endedAt, List<JourneyStep> steps
});




}
/// @nodoc
class _$JourneyCopyWithImpl<$Res>
    implements $JourneyCopyWith<$Res> {
  _$JourneyCopyWithImpl(this._self, this._then);

  final Journey _self;
  final $Res Function(Journey) _then;

/// Create a copy of Journey
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? description = null,Object? startedAt = null,Object? endedAt = null,Object? steps = null,}) {
  return _then(Journey(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<JourneyStep>,
  ));
}

}


/// Adds pattern-matching-related methods to [Journey].
extension JourneyPatterns on Journey {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Journey value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Journey() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Journey value)  $default,){
final _that = this;
switch (_that) {
case _Journey():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Journey value)?  $default,){
final _that = this;
switch (_that) {
case _Journey() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String description,  DateTime startedAt,  DateTime endedAt,  List<JourneyStep> steps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Journey() when $default != null:
return $default(_that.id,_that.description,_that.startedAt,_that.endedAt,_that.steps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String description,  DateTime startedAt,  DateTime endedAt,  List<JourneyStep> steps)  $default,) {final _that = this;
switch (_that) {
case _Journey():
return $default(_that.id,_that.description,_that.startedAt,_that.endedAt,_that.steps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String description,  DateTime startedAt,  DateTime endedAt,  List<JourneyStep> steps)?  $default,) {final _that = this;
switch (_that) {
case _Journey() when $default != null:
return $default(_that.id,_that.description,_that.startedAt,_that.endedAt,_that.steps);case _:
  return null;

}
}

}

/// @nodoc


class _Journey implements Journey {
  const _Journey({required this.id, required this.description, required this.startedAt, required this.endedAt, required  List<JourneyStep> steps}): _steps = steps;
  

@override final  String id;
@override final  String description;
@override final  DateTime startedAt;
@override final  DateTime endedAt;
 final  List<JourneyStep> _steps;
@override List<JourneyStep> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}


/// Create a copy of Journey
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JourneyCopyWith<_Journey> get copyWith => __$JourneyCopyWithImpl<_Journey>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Journey&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&const DeepCollectionEquality().equals(other.steps, _steps));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,description,startedAt,endedAt,const DeepCollectionEquality().hash(_steps));
}

@override
String toString() {
    return 'Journey(id: $id, description: $description, startedAt: $startedAt, endedAt: $endedAt, steps: $steps)';
}


}

/// @nodoc
abstract mixin class _$JourneyCopyWith<$Res> implements $JourneyCopyWith<$Res> {
  factory _$JourneyCopyWith(_Journey value, $Res Function(_Journey) _then) = __$JourneyCopyWithImpl;
@override @useResult
$Res call({
 String id, String description, DateTime startedAt, DateTime endedAt, List<JourneyStep> steps
});




}
/// @nodoc
class __$JourneyCopyWithImpl<$Res>
    implements _$JourneyCopyWith<$Res> {
  __$JourneyCopyWithImpl(this._self, this._then);

  final _Journey _self;
  final $Res Function(_Journey) _then;

/// Create a copy of Journey
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? startedAt = null,Object? endedAt = null,Object? steps = null,}) {
  return _then(_Journey(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<JourneyStep>,
  ));
}


}

/// @nodoc
mixin _$AppearanceMatch {

 String get id; String get cameraName; String? get viewName; DateTime get startedAt; DateTime get endedAt; double get similarity; String? get eventId; String? get journeyId; MediaSource? get thumbnail;
/// Create a copy of AppearanceMatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppearanceMatchCopyWith<AppearanceMatch> get copyWith => _$AppearanceMatchCopyWithImpl<AppearanceMatch>(this as AppearanceMatch, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AppearanceMatch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppearanceMatch&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName)&&(identical(other.viewName, _this.viewName) || other.viewName == _this.viewName)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.similarity, _this.similarity) || other.similarity == _this.similarity)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.journeyId, _this.journeyId) || other.journeyId == _this.journeyId)&&(identical(other.thumbnail, _this.thumbnail) || other.thumbnail == _this.thumbnail));
}


@override
int get hashCode {
  final _this = this as AppearanceMatch;
  return Object.hash(runtimeType,_this.id,_this.cameraName,_this.viewName,_this.startedAt,_this.endedAt,_this.similarity,_this.eventId,_this.journeyId,_this.thumbnail);
}

@override
String toString() {
  final _this = this as AppearanceMatch;
  return 'AppearanceMatch(id: ${_this.id}, cameraName: ${_this.cameraName}, viewName: ${_this.viewName}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt}, similarity: ${_this.similarity}, eventId: ${_this.eventId}, journeyId: ${_this.journeyId}, thumbnail: ${_this.thumbnail})';
}


}

/// @nodoc
abstract mixin class $AppearanceMatchCopyWith<$Res>  {
  factory $AppearanceMatchCopyWith(AppearanceMatch value, $Res Function(AppearanceMatch) _then) = _$AppearanceMatchCopyWithImpl;
@useResult
$Res call({
 String id, String cameraName, String? viewName, DateTime startedAt, DateTime endedAt, double similarity, String? eventId, String? journeyId, MediaSource? thumbnail
});




}
/// @nodoc
class _$AppearanceMatchCopyWithImpl<$Res>
    implements $AppearanceMatchCopyWith<$Res> {
  _$AppearanceMatchCopyWithImpl(this._self, this._then);

  final AppearanceMatch _self;
  final $Res Function(AppearanceMatch) _then;

/// Create a copy of AppearanceMatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cameraName = null,Object? viewName = freezed,Object? startedAt = null,Object? endedAt = null,Object? similarity = null,Object? eventId = freezed,Object? journeyId = freezed,Object? thumbnail = freezed,}) {
  return _then(AppearanceMatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cameraName: null == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String,viewName: freezed == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime,similarity: null == similarity ? _self.similarity : similarity // ignore: cast_nullable_to_non_nullable
as double,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,journeyId: freezed == journeyId ? _self.journeyId : journeyId // ignore: cast_nullable_to_non_nullable
as String?,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as MediaSource?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppearanceMatch].
extension AppearanceMatchPatterns on AppearanceMatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppearanceMatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppearanceMatch() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppearanceMatch value)  $default,){
final _that = this;
switch (_that) {
case _AppearanceMatch():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppearanceMatch value)?  $default,){
final _that = this;
switch (_that) {
case _AppearanceMatch() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String cameraName,  String? viewName,  DateTime startedAt,  DateTime endedAt,  double similarity,  String? eventId,  String? journeyId,  MediaSource? thumbnail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppearanceMatch() when $default != null:
return $default(_that.id,_that.cameraName,_that.viewName,_that.startedAt,_that.endedAt,_that.similarity,_that.eventId,_that.journeyId,_that.thumbnail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String cameraName,  String? viewName,  DateTime startedAt,  DateTime endedAt,  double similarity,  String? eventId,  String? journeyId,  MediaSource? thumbnail)  $default,) {final _that = this;
switch (_that) {
case _AppearanceMatch():
return $default(_that.id,_that.cameraName,_that.viewName,_that.startedAt,_that.endedAt,_that.similarity,_that.eventId,_that.journeyId,_that.thumbnail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String cameraName,  String? viewName,  DateTime startedAt,  DateTime endedAt,  double similarity,  String? eventId,  String? journeyId,  MediaSource? thumbnail)?  $default,) {final _that = this;
switch (_that) {
case _AppearanceMatch() when $default != null:
return $default(_that.id,_that.cameraName,_that.viewName,_that.startedAt,_that.endedAt,_that.similarity,_that.eventId,_that.journeyId,_that.thumbnail);case _:
  return null;

}
}

}

/// @nodoc


class _AppearanceMatch implements AppearanceMatch {
  const _AppearanceMatch({required this.id, required this.cameraName, this.viewName, required this.startedAt, required this.endedAt, required this.similarity, this.eventId, this.journeyId, this.thumbnail});
  

@override final  String id;
@override final  String cameraName;
@override final  String? viewName;
@override final  DateTime startedAt;
@override final  DateTime endedAt;
@override final  double similarity;
@override final  String? eventId;
@override final  String? journeyId;
@override final  MediaSource? thumbnail;

/// Create a copy of AppearanceMatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppearanceMatchCopyWith<_AppearanceMatch> get copyWith => __$AppearanceMatchCopyWithImpl<_AppearanceMatch>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppearanceMatch&&(identical(other.id, id) || other.id == id)&&(identical(other.cameraName, cameraName) || other.cameraName == cameraName)&&(identical(other.viewName, viewName) || other.viewName == viewName)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.similarity, similarity) || other.similarity == similarity)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.journeyId, journeyId) || other.journeyId == journeyId)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,cameraName,viewName,startedAt,endedAt,similarity,eventId,journeyId,thumbnail);
}

@override
String toString() {
    return 'AppearanceMatch(id: $id, cameraName: $cameraName, viewName: $viewName, startedAt: $startedAt, endedAt: $endedAt, similarity: $similarity, eventId: $eventId, journeyId: $journeyId, thumbnail: $thumbnail)';
}


}

/// @nodoc
abstract mixin class _$AppearanceMatchCopyWith<$Res> implements $AppearanceMatchCopyWith<$Res> {
  factory _$AppearanceMatchCopyWith(_AppearanceMatch value, $Res Function(_AppearanceMatch) _then) = __$AppearanceMatchCopyWithImpl;
@override @useResult
$Res call({
 String id, String cameraName, String? viewName, DateTime startedAt, DateTime endedAt, double similarity, String? eventId, String? journeyId, MediaSource? thumbnail
});




}
/// @nodoc
class __$AppearanceMatchCopyWithImpl<$Res>
    implements _$AppearanceMatchCopyWith<$Res> {
  __$AppearanceMatchCopyWithImpl(this._self, this._then);

  final _AppearanceMatch _self;
  final $Res Function(_AppearanceMatch) _then;

/// Create a copy of AppearanceMatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cameraName = null,Object? viewName = freezed,Object? startedAt = null,Object? endedAt = null,Object? similarity = null,Object? eventId = freezed,Object? journeyId = freezed,Object? thumbnail = freezed,}) {
  return _then(_AppearanceMatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cameraName: null == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String,viewName: freezed == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime,similarity: null == similarity ? _self.similarity : similarity // ignore: cast_nullable_to_non_nullable
as double,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,journeyId: freezed == journeyId ? _self.journeyId : journeyId // ignore: cast_nullable_to_non_nullable
as String?,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as MediaSource?,
  ));
}


}

// dart format on
