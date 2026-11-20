// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventBox {

 int get object; String get label; Rect get box; double get at;
/// Create a copy of EventBox
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventBoxCopyWith<EventBox> get copyWith => _$EventBoxCopyWithImpl<EventBox>(this as EventBox, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventBox;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventBox&&(identical(other.object, _this.object) || other.object == _this.object)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.box, _this.box) || other.box == _this.box)&&(identical(other.at, _this.at) || other.at == _this.at));
}


@override
int get hashCode {
  final _this = this as EventBox;
  return Object.hash(runtimeType,_this.object,_this.label,_this.box,_this.at);
}

@override
String toString() {
  final _this = this as EventBox;
  return 'EventBox(object: ${_this.object}, label: ${_this.label}, box: ${_this.box}, at: ${_this.at})';
}


}

/// @nodoc
abstract mixin class $EventBoxCopyWith<$Res>  {
  factory $EventBoxCopyWith(EventBox value, $Res Function(EventBox) _then) = _$EventBoxCopyWithImpl;
@useResult
$Res call({
 int object, String label, Rect box, double at
});




}
/// @nodoc
class _$EventBoxCopyWithImpl<$Res>
    implements $EventBoxCopyWith<$Res> {
  _$EventBoxCopyWithImpl(this._self, this._then);

  final EventBox _self;
  final $Res Function(EventBox) _then;

/// Create a copy of EventBox
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? object = null,Object? label = null,Object? box = null,Object? at = null,}) {
  return _then(EventBox(
object: null == object ? _self.object : object // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,box: null == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as Rect,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [EventBox].
extension EventBoxPatterns on EventBox {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventBox value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventBox() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventBox value)  $default,){
final _that = this;
switch (_that) {
case _EventBox():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventBox value)?  $default,){
final _that = this;
switch (_that) {
case _EventBox() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int object,  String label,  Rect box,  double at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventBox() when $default != null:
return $default(_that.object,_that.label,_that.box,_that.at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int object,  String label,  Rect box,  double at)  $default,) {final _that = this;
switch (_that) {
case _EventBox():
return $default(_that.object,_that.label,_that.box,_that.at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int object,  String label,  Rect box,  double at)?  $default,) {final _that = this;
switch (_that) {
case _EventBox() when $default != null:
return $default(_that.object,_that.label,_that.box,_that.at);case _:
  return null;

}
}

}

/// @nodoc


class _EventBox implements EventBox {
  const _EventBox({required this.object, required this.label, required this.box, this.at = 0.0});
  

@override final  int object;
@override final  String label;
@override final  Rect box;
@override@JsonKey() final  double at;

/// Create a copy of EventBox
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventBoxCopyWith<_EventBox> get copyWith => __$EventBoxCopyWithImpl<_EventBox>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventBox&&(identical(other.object, object) || other.object == object)&&(identical(other.label, label) || other.label == label)&&(identical(other.box, box) || other.box == box)&&(identical(other.at, at) || other.at == at));
}


@override
int get hashCode {
    return Object.hash(runtimeType,object,label,box,at);
}

@override
String toString() {
    return 'EventBox(object: $object, label: $label, box: $box, at: $at)';
}


}

/// @nodoc
abstract mixin class _$EventBoxCopyWith<$Res> implements $EventBoxCopyWith<$Res> {
  factory _$EventBoxCopyWith(_EventBox value, $Res Function(_EventBox) _then) = __$EventBoxCopyWithImpl;
@override @useResult
$Res call({
 int object, String label, Rect box, double at
});




}
/// @nodoc
class __$EventBoxCopyWithImpl<$Res>
    implements _$EventBoxCopyWith<$Res> {
  __$EventBoxCopyWithImpl(this._self, this._then);

  final _EventBox _self;
  final $Res Function(_EventBox) _then;

/// Create a copy of EventBox
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? object = null,Object? label = null,Object? box = null,Object? at = null,}) {
  return _then(_EventBox(
object: null == object ? _self.object : object // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,box: null == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as Rect,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$PlateCandidate {

 String get text; String get display; String? get format; double get score; int get reads;
/// Create a copy of PlateCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlateCandidateCopyWith<PlateCandidate> get copyWith => _$PlateCandidateCopyWithImpl<PlateCandidate>(this as PlateCandidate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlateCandidate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlateCandidate&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.display, _this.display) || other.display == _this.display)&&(identical(other.format, _this.format) || other.format == _this.format)&&(identical(other.score, _this.score) || other.score == _this.score)&&(identical(other.reads, _this.reads) || other.reads == _this.reads));
}


@override
int get hashCode {
  final _this = this as PlateCandidate;
  return Object.hash(runtimeType,_this.text,_this.display,_this.format,_this.score,_this.reads);
}

@override
String toString() {
  final _this = this as PlateCandidate;
  return 'PlateCandidate(text: ${_this.text}, display: ${_this.display}, format: ${_this.format}, score: ${_this.score}, reads: ${_this.reads})';
}


}

/// @nodoc
abstract mixin class $PlateCandidateCopyWith<$Res>  {
  factory $PlateCandidateCopyWith(PlateCandidate value, $Res Function(PlateCandidate) _then) = _$PlateCandidateCopyWithImpl;
@useResult
$Res call({
 String text, String display, String? format, double score, int reads
});




}
/// @nodoc
class _$PlateCandidateCopyWithImpl<$Res>
    implements $PlateCandidateCopyWith<$Res> {
  _$PlateCandidateCopyWithImpl(this._self, this._then);

  final PlateCandidate _self;
  final $Res Function(PlateCandidate) _then;

/// Create a copy of PlateCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? display = null,Object? format = freezed,Object? score = null,Object? reads = null,}) {
  return _then(PlateCandidate(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as String,format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,reads: null == reads ? _self.reads : reads // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlateCandidate].
extension PlateCandidatePatterns on PlateCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlateCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlateCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlateCandidate value)  $default,){
final _that = this;
switch (_that) {
case _PlateCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlateCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _PlateCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  String display,  String? format,  double score,  int reads)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlateCandidate() when $default != null:
return $default(_that.text,_that.display,_that.format,_that.score,_that.reads);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  String display,  String? format,  double score,  int reads)  $default,) {final _that = this;
switch (_that) {
case _PlateCandidate():
return $default(_that.text,_that.display,_that.format,_that.score,_that.reads);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  String display,  String? format,  double score,  int reads)?  $default,) {final _that = this;
switch (_that) {
case _PlateCandidate() when $default != null:
return $default(_that.text,_that.display,_that.format,_that.score,_that.reads);case _:
  return null;

}
}

}

/// @nodoc


class _PlateCandidate implements PlateCandidate {
  const _PlateCandidate({required this.text, required this.display, this.format, required this.score, required this.reads});
  

@override final  String text;
@override final  String display;
@override final  String? format;
@override final  double score;
@override final  int reads;

/// Create a copy of PlateCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlateCandidateCopyWith<_PlateCandidate> get copyWith => __$PlateCandidateCopyWithImpl<_PlateCandidate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlateCandidate&&(identical(other.text, text) || other.text == text)&&(identical(other.display, display) || other.display == display)&&(identical(other.format, format) || other.format == format)&&(identical(other.score, score) || other.score == score)&&(identical(other.reads, reads) || other.reads == reads));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text,display,format,score,reads);
}

@override
String toString() {
    return 'PlateCandidate(text: $text, display: $display, format: $format, score: $score, reads: $reads)';
}


}

/// @nodoc
abstract mixin class _$PlateCandidateCopyWith<$Res> implements $PlateCandidateCopyWith<$Res> {
  factory _$PlateCandidateCopyWith(_PlateCandidate value, $Res Function(_PlateCandidate) _then) = __$PlateCandidateCopyWithImpl;
@override @useResult
$Res call({
 String text, String display, String? format, double score, int reads
});




}
/// @nodoc
class __$PlateCandidateCopyWithImpl<$Res>
    implements _$PlateCandidateCopyWith<$Res> {
  __$PlateCandidateCopyWithImpl(this._self, this._then);

  final _PlateCandidate _self;
  final $Res Function(_PlateCandidate) _then;

/// Create a copy of PlateCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? display = null,Object? format = freezed,Object? score = null,Object? reads = null,}) {
  return _then(_PlateCandidate(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as String,format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,reads: null == reads ? _self.reads : reads // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$FaceInfo {

 FaceStatus get status; String? get personId; String? get personName; int? get personColor; String? get clusterId; String? get clusterLabel; double? get confidence; String? get sampleId;
/// Create a copy of FaceInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FaceInfoCopyWith<FaceInfo> get copyWith => _$FaceInfoCopyWithImpl<FaceInfo>(this as FaceInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FaceInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FaceInfo&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.personId, _this.personId) || other.personId == _this.personId)&&(identical(other.personName, _this.personName) || other.personName == _this.personName)&&(identical(other.personColor, _this.personColor) || other.personColor == _this.personColor)&&(identical(other.clusterId, _this.clusterId) || other.clusterId == _this.clusterId)&&(identical(other.clusterLabel, _this.clusterLabel) || other.clusterLabel == _this.clusterLabel)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.sampleId, _this.sampleId) || other.sampleId == _this.sampleId));
}


@override
int get hashCode {
  final _this = this as FaceInfo;
  return Object.hash(runtimeType,_this.status,_this.personId,_this.personName,_this.personColor,_this.clusterId,_this.clusterLabel,_this.confidence,_this.sampleId);
}

@override
String toString() {
  final _this = this as FaceInfo;
  return 'FaceInfo(status: ${_this.status}, personId: ${_this.personId}, personName: ${_this.personName}, personColor: ${_this.personColor}, clusterId: ${_this.clusterId}, clusterLabel: ${_this.clusterLabel}, confidence: ${_this.confidence}, sampleId: ${_this.sampleId})';
}


}

/// @nodoc
abstract mixin class $FaceInfoCopyWith<$Res>  {
  factory $FaceInfoCopyWith(FaceInfo value, $Res Function(FaceInfo) _then) = _$FaceInfoCopyWithImpl;
@useResult
$Res call({
 FaceStatus status, String? personId, String? personName, int? personColor, String? clusterId, String? clusterLabel, double? confidence, String? sampleId
});




}
/// @nodoc
class _$FaceInfoCopyWithImpl<$Res>
    implements $FaceInfoCopyWith<$Res> {
  _$FaceInfoCopyWithImpl(this._self, this._then);

  final FaceInfo _self;
  final $Res Function(FaceInfo) _then;

/// Create a copy of FaceInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? personId = freezed,Object? personName = freezed,Object? personColor = freezed,Object? clusterId = freezed,Object? clusterLabel = freezed,Object? confidence = freezed,Object? sampleId = freezed,}) {
  return _then(FaceInfo(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FaceStatus,personId: freezed == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String?,personName: freezed == personName ? _self.personName : personName // ignore: cast_nullable_to_non_nullable
as String?,personColor: freezed == personColor ? _self.personColor : personColor // ignore: cast_nullable_to_non_nullable
as int?,clusterId: freezed == clusterId ? _self.clusterId : clusterId // ignore: cast_nullable_to_non_nullable
as String?,clusterLabel: freezed == clusterLabel ? _self.clusterLabel : clusterLabel // ignore: cast_nullable_to_non_nullable
as String?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,sampleId: freezed == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FaceInfo].
extension FaceInfoPatterns on FaceInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FaceInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FaceInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FaceInfo value)  $default,){
final _that = this;
switch (_that) {
case _FaceInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FaceInfo value)?  $default,){
final _that = this;
switch (_that) {
case _FaceInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FaceStatus status,  String? personId,  String? personName,  int? personColor,  String? clusterId,  String? clusterLabel,  double? confidence,  String? sampleId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FaceInfo() when $default != null:
return $default(_that.status,_that.personId,_that.personName,_that.personColor,_that.clusterId,_that.clusterLabel,_that.confidence,_that.sampleId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FaceStatus status,  String? personId,  String? personName,  int? personColor,  String? clusterId,  String? clusterLabel,  double? confidence,  String? sampleId)  $default,) {final _that = this;
switch (_that) {
case _FaceInfo():
return $default(_that.status,_that.personId,_that.personName,_that.personColor,_that.clusterId,_that.clusterLabel,_that.confidence,_that.sampleId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FaceStatus status,  String? personId,  String? personName,  int? personColor,  String? clusterId,  String? clusterLabel,  double? confidence,  String? sampleId)?  $default,) {final _that = this;
switch (_that) {
case _FaceInfo() when $default != null:
return $default(_that.status,_that.personId,_that.personName,_that.personColor,_that.clusterId,_that.clusterLabel,_that.confidence,_that.sampleId);case _:
  return null;

}
}

}

/// @nodoc


class _FaceInfo implements FaceInfo {
  const _FaceInfo({required this.status, this.personId, this.personName, this.personColor, this.clusterId, this.clusterLabel, this.confidence, this.sampleId});
  

@override final  FaceStatus status;
@override final  String? personId;
@override final  String? personName;
@override final  int? personColor;
@override final  String? clusterId;
@override final  String? clusterLabel;
@override final  double? confidence;
@override final  String? sampleId;

/// Create a copy of FaceInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FaceInfoCopyWith<_FaceInfo> get copyWith => __$FaceInfoCopyWithImpl<_FaceInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FaceInfo&&(identical(other.status, status) || other.status == status)&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.personName, personName) || other.personName == personName)&&(identical(other.personColor, personColor) || other.personColor == personColor)&&(identical(other.clusterId, clusterId) || other.clusterId == clusterId)&&(identical(other.clusterLabel, clusterLabel) || other.clusterLabel == clusterLabel)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,personId,personName,personColor,clusterId,clusterLabel,confidence,sampleId);
}

@override
String toString() {
    return 'FaceInfo(status: $status, personId: $personId, personName: $personName, personColor: $personColor, clusterId: $clusterId, clusterLabel: $clusterLabel, confidence: $confidence, sampleId: $sampleId)';
}


}

/// @nodoc
abstract mixin class _$FaceInfoCopyWith<$Res> implements $FaceInfoCopyWith<$Res> {
  factory _$FaceInfoCopyWith(_FaceInfo value, $Res Function(_FaceInfo) _then) = __$FaceInfoCopyWithImpl;
@override @useResult
$Res call({
 FaceStatus status, String? personId, String? personName, int? personColor, String? clusterId, String? clusterLabel, double? confidence, String? sampleId
});




}
/// @nodoc
class __$FaceInfoCopyWithImpl<$Res>
    implements _$FaceInfoCopyWith<$Res> {
  __$FaceInfoCopyWithImpl(this._self, this._then);

  final _FaceInfo _self;
  final $Res Function(_FaceInfo) _then;

/// Create a copy of FaceInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? personId = freezed,Object? personName = freezed,Object? personColor = freezed,Object? clusterId = freezed,Object? clusterLabel = freezed,Object? confidence = freezed,Object? sampleId = freezed,}) {
  return _then(_FaceInfo(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FaceStatus,personId: freezed == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String?,personName: freezed == personName ? _self.personName : personName // ignore: cast_nullable_to_non_nullable
as String?,personColor: freezed == personColor ? _self.personColor : personColor // ignore: cast_nullable_to_non_nullable
as int?,clusterId: freezed == clusterId ? _self.clusterId : clusterId // ignore: cast_nullable_to_non_nullable
as String?,clusterLabel: freezed == clusterLabel ? _self.clusterLabel : clusterLabel // ignore: cast_nullable_to_non_nullable
as String?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,sampleId: freezed == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CameraEvent {

 String get id; String get siteId; String get cameraId; String get cameraName; String? get viewId; String? get viewName; EventKind get kind; EventSource get source; String? get label; bool get alert; bool get acknowledged; DateTime get startedAt; DateTime? get endedAt; bool get ongoing; bool get hasSnapshot; bool get hasClip; String? get zoneName; String? get lineName; String? get direction; List<EventBox> get boxes; int? get count; String? get profile; List<PlateCandidate> get plates; String? get plateStatus; FaceInfo? get face; double get aspect;
/// Create a copy of CameraEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraEventCopyWith<CameraEvent> get copyWith => _$CameraEventCopyWithImpl<CameraEvent>(this as CameraEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CameraEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraEvent&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.siteId, _this.siteId) || other.siteId == _this.siteId)&&(identical(other.cameraId, _this.cameraId) || other.cameraId == _this.cameraId)&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName)&&(identical(other.viewId, _this.viewId) || other.viewId == _this.viewId)&&(identical(other.viewName, _this.viewName) || other.viewName == _this.viewName)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.alert, _this.alert) || other.alert == _this.alert)&&(identical(other.acknowledged, _this.acknowledged) || other.acknowledged == _this.acknowledged)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.ongoing, _this.ongoing) || other.ongoing == _this.ongoing)&&(identical(other.hasSnapshot, _this.hasSnapshot) || other.hasSnapshot == _this.hasSnapshot)&&(identical(other.hasClip, _this.hasClip) || other.hasClip == _this.hasClip)&&(identical(other.zoneName, _this.zoneName) || other.zoneName == _this.zoneName)&&(identical(other.lineName, _this.lineName) || other.lineName == _this.lineName)&&(identical(other.direction, _this.direction) || other.direction == _this.direction)&&const DeepCollectionEquality().equals(other.boxes, _this.boxes)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&const DeepCollectionEquality().equals(other.plates, _this.plates)&&(identical(other.plateStatus, _this.plateStatus) || other.plateStatus == _this.plateStatus)&&(identical(other.face, _this.face) || other.face == _this.face)&&(identical(other.aspect, _this.aspect) || other.aspect == _this.aspect));
}


@override
int get hashCode {
  final _this = this as CameraEvent;
  return Object.hashAll([runtimeType,_this.id,_this.siteId,_this.cameraId,_this.cameraName,_this.viewId,_this.viewName,_this.kind,_this.source,_this.label,_this.alert,_this.acknowledged,_this.startedAt,_this.endedAt,_this.ongoing,_this.hasSnapshot,_this.hasClip,_this.zoneName,_this.lineName,_this.direction,const DeepCollectionEquality().hash(_this.boxes),_this.count,_this.profile,const DeepCollectionEquality().hash(_this.plates),_this.plateStatus,_this.face,_this.aspect]);
}

@override
String toString() {
  final _this = this as CameraEvent;
  return 'CameraEvent(id: ${_this.id}, siteId: ${_this.siteId}, cameraId: ${_this.cameraId}, cameraName: ${_this.cameraName}, viewId: ${_this.viewId}, viewName: ${_this.viewName}, kind: ${_this.kind}, source: ${_this.source}, label: ${_this.label}, alert: ${_this.alert}, acknowledged: ${_this.acknowledged}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt}, ongoing: ${_this.ongoing}, hasSnapshot: ${_this.hasSnapshot}, hasClip: ${_this.hasClip}, zoneName: ${_this.zoneName}, lineName: ${_this.lineName}, direction: ${_this.direction}, boxes: ${_this.boxes}, count: ${_this.count}, profile: ${_this.profile}, plates: ${_this.plates}, plateStatus: ${_this.plateStatus}, face: ${_this.face}, aspect: ${_this.aspect})';
}


}

/// @nodoc
abstract mixin class $CameraEventCopyWith<$Res>  {
  factory $CameraEventCopyWith(CameraEvent value, $Res Function(CameraEvent) _then) = _$CameraEventCopyWithImpl;
@useResult
$Res call({
 String id, String siteId, String cameraId, String cameraName, String? viewId, String? viewName, EventKind kind, EventSource source, String? label, bool alert, bool acknowledged, DateTime startedAt, DateTime? endedAt, bool ongoing, bool hasSnapshot, bool hasClip, String? zoneName, String? lineName, String? direction, List<EventBox> boxes, int? count, String? profile, List<PlateCandidate> plates, String? plateStatus, FaceInfo? face, double aspect
});


$FaceInfoCopyWith<$Res>? get face;

}
/// @nodoc
class _$CameraEventCopyWithImpl<$Res>
    implements $CameraEventCopyWith<$Res> {
  _$CameraEventCopyWithImpl(this._self, this._then);

  final CameraEvent _self;
  final $Res Function(CameraEvent) _then;

/// Create a copy of CameraEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? siteId = null,Object? cameraId = null,Object? cameraName = null,Object? viewId = freezed,Object? viewName = freezed,Object? kind = null,Object? source = null,Object? label = freezed,Object? alert = null,Object? acknowledged = null,Object? startedAt = null,Object? endedAt = freezed,Object? ongoing = null,Object? hasSnapshot = null,Object? hasClip = null,Object? zoneName = freezed,Object? lineName = freezed,Object? direction = freezed,Object? boxes = null,Object? count = freezed,Object? profile = freezed,Object? plates = null,Object? plateStatus = freezed,Object? face = freezed,Object? aspect = null,}) {
  return _then(CameraEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,cameraId: null == cameraId ? _self.cameraId : cameraId // ignore: cast_nullable_to_non_nullable
as String,cameraName: null == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String,viewId: freezed == viewId ? _self.viewId : viewId // ignore: cast_nullable_to_non_nullable
as String?,viewName: freezed == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as EventKind,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as EventSource,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,alert: null == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as bool,acknowledged: null == acknowledged ? _self.acknowledged : acknowledged // ignore: cast_nullable_to_non_nullable
as bool,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ongoing: null == ongoing ? _self.ongoing : ongoing // ignore: cast_nullable_to_non_nullable
as bool,hasSnapshot: null == hasSnapshot ? _self.hasSnapshot : hasSnapshot // ignore: cast_nullable_to_non_nullable
as bool,hasClip: null == hasClip ? _self.hasClip : hasClip // ignore: cast_nullable_to_non_nullable
as bool,zoneName: freezed == zoneName ? _self.zoneName : zoneName // ignore: cast_nullable_to_non_nullable
as String?,lineName: freezed == lineName ? _self.lineName : lineName // ignore: cast_nullable_to_non_nullable
as String?,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String?,boxes: null == boxes ? _self.boxes : boxes // ignore: cast_nullable_to_non_nullable
as List<EventBox>,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String?,plates: null == plates ? _self.plates : plates // ignore: cast_nullable_to_non_nullable
as List<PlateCandidate>,plateStatus: freezed == plateStatus ? _self.plateStatus : plateStatus // ignore: cast_nullable_to_non_nullable
as String?,face: freezed == face ? _self.face : face // ignore: cast_nullable_to_non_nullable
as FaceInfo?,aspect: null == aspect ? _self.aspect : aspect // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of CameraEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FaceInfoCopyWith<$Res>? get face {
    if (_self.face == null) {
    return null;
  }

  return $FaceInfoCopyWith<$Res>(_self.face!, (value) {
    return _then(_self.copyWith(face: value));
  });
}
}


/// Adds pattern-matching-related methods to [CameraEvent].
extension CameraEventPatterns on CameraEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CameraEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CameraEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CameraEvent value)  $default,){
final _that = this;
switch (_that) {
case _CameraEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CameraEvent value)?  $default,){
final _that = this;
switch (_that) {
case _CameraEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String siteId,  String cameraId,  String cameraName,  String? viewId,  String? viewName,  EventKind kind,  EventSource source,  String? label,  bool alert,  bool acknowledged,  DateTime startedAt,  DateTime? endedAt,  bool ongoing,  bool hasSnapshot,  bool hasClip,  String? zoneName,  String? lineName,  String? direction,  List<EventBox> boxes,  int? count,  String? profile,  List<PlateCandidate> plates,  String? plateStatus,  FaceInfo? face,  double aspect)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CameraEvent() when $default != null:
return $default(_that.id,_that.siteId,_that.cameraId,_that.cameraName,_that.viewId,_that.viewName,_that.kind,_that.source,_that.label,_that.alert,_that.acknowledged,_that.startedAt,_that.endedAt,_that.ongoing,_that.hasSnapshot,_that.hasClip,_that.zoneName,_that.lineName,_that.direction,_that.boxes,_that.count,_that.profile,_that.plates,_that.plateStatus,_that.face,_that.aspect);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String siteId,  String cameraId,  String cameraName,  String? viewId,  String? viewName,  EventKind kind,  EventSource source,  String? label,  bool alert,  bool acknowledged,  DateTime startedAt,  DateTime? endedAt,  bool ongoing,  bool hasSnapshot,  bool hasClip,  String? zoneName,  String? lineName,  String? direction,  List<EventBox> boxes,  int? count,  String? profile,  List<PlateCandidate> plates,  String? plateStatus,  FaceInfo? face,  double aspect)  $default,) {final _that = this;
switch (_that) {
case _CameraEvent():
return $default(_that.id,_that.siteId,_that.cameraId,_that.cameraName,_that.viewId,_that.viewName,_that.kind,_that.source,_that.label,_that.alert,_that.acknowledged,_that.startedAt,_that.endedAt,_that.ongoing,_that.hasSnapshot,_that.hasClip,_that.zoneName,_that.lineName,_that.direction,_that.boxes,_that.count,_that.profile,_that.plates,_that.plateStatus,_that.face,_that.aspect);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String siteId,  String cameraId,  String cameraName,  String? viewId,  String? viewName,  EventKind kind,  EventSource source,  String? label,  bool alert,  bool acknowledged,  DateTime startedAt,  DateTime? endedAt,  bool ongoing,  bool hasSnapshot,  bool hasClip,  String? zoneName,  String? lineName,  String? direction,  List<EventBox> boxes,  int? count,  String? profile,  List<PlateCandidate> plates,  String? plateStatus,  FaceInfo? face,  double aspect)?  $default,) {final _that = this;
switch (_that) {
case _CameraEvent() when $default != null:
return $default(_that.id,_that.siteId,_that.cameraId,_that.cameraName,_that.viewId,_that.viewName,_that.kind,_that.source,_that.label,_that.alert,_that.acknowledged,_that.startedAt,_that.endedAt,_that.ongoing,_that.hasSnapshot,_that.hasClip,_that.zoneName,_that.lineName,_that.direction,_that.boxes,_that.count,_that.profile,_that.plates,_that.plateStatus,_that.face,_that.aspect);case _:
  return null;

}
}

}

/// @nodoc


class _CameraEvent extends CameraEvent {
  const _CameraEvent({required this.id, required this.siteId, required this.cameraId, required this.cameraName, this.viewId, this.viewName, required this.kind, required this.source, this.label, this.alert = false, this.acknowledged = false, required this.startedAt, this.endedAt, this.ongoing = false, this.hasSnapshot = true, this.hasClip = false, this.zoneName, this.lineName, this.direction,  List<EventBox> boxes = const <EventBox>[], this.count, this.profile,  List<PlateCandidate> plates = const <PlateCandidate>[], this.plateStatus, this.face, this.aspect = 16 / 9}): _boxes = boxes,_plates = plates,super._();
  

@override final  String id;
@override final  String siteId;
@override final  String cameraId;
@override final  String cameraName;
@override final  String? viewId;
@override final  String? viewName;
@override final  EventKind kind;
@override final  EventSource source;
@override final  String? label;
@override@JsonKey() final  bool alert;
@override@JsonKey() final  bool acknowledged;
@override final  DateTime startedAt;
@override final  DateTime? endedAt;
@override@JsonKey() final  bool ongoing;
@override@JsonKey() final  bool hasSnapshot;
@override@JsonKey() final  bool hasClip;
@override final  String? zoneName;
@override final  String? lineName;
@override final  String? direction;
 final  List<EventBox> _boxes;
@override@JsonKey() List<EventBox> get boxes {
  if (_boxes is EqualUnmodifiableListView) return _boxes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_boxes);
}

@override final  int? count;
@override final  String? profile;
 final  List<PlateCandidate> _plates;
@override@JsonKey() List<PlateCandidate> get plates {
  if (_plates is EqualUnmodifiableListView) return _plates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_plates);
}

@override final  String? plateStatus;
@override final  FaceInfo? face;
@override@JsonKey() final  double aspect;

/// Create a copy of CameraEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CameraEventCopyWith<_CameraEvent> get copyWith => __$CameraEventCopyWithImpl<_CameraEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CameraEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.cameraId, cameraId) || other.cameraId == cameraId)&&(identical(other.cameraName, cameraName) || other.cameraName == cameraName)&&(identical(other.viewId, viewId) || other.viewId == viewId)&&(identical(other.viewName, viewName) || other.viewName == viewName)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.source, source) || other.source == source)&&(identical(other.label, label) || other.label == label)&&(identical(other.alert, alert) || other.alert == alert)&&(identical(other.acknowledged, acknowledged) || other.acknowledged == acknowledged)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.ongoing, ongoing) || other.ongoing == ongoing)&&(identical(other.hasSnapshot, hasSnapshot) || other.hasSnapshot == hasSnapshot)&&(identical(other.hasClip, hasClip) || other.hasClip == hasClip)&&(identical(other.zoneName, zoneName) || other.zoneName == zoneName)&&(identical(other.lineName, lineName) || other.lineName == lineName)&&(identical(other.direction, direction) || other.direction == direction)&&const DeepCollectionEquality().equals(other.boxes, _boxes)&&(identical(other.count, count) || other.count == count)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.plates, _plates)&&(identical(other.plateStatus, plateStatus) || other.plateStatus == plateStatus)&&(identical(other.face, face) || other.face == face)&&(identical(other.aspect, aspect) || other.aspect == aspect));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,siteId,cameraId,cameraName,viewId,viewName,kind,source,label,alert,acknowledged,startedAt,endedAt,ongoing,hasSnapshot,hasClip,zoneName,lineName,direction,const DeepCollectionEquality().hash(_boxes),count,profile,const DeepCollectionEquality().hash(_plates),plateStatus,face,aspect]);
}

@override
String toString() {
    return 'CameraEvent(id: $id, siteId: $siteId, cameraId: $cameraId, cameraName: $cameraName, viewId: $viewId, viewName: $viewName, kind: $kind, source: $source, label: $label, alert: $alert, acknowledged: $acknowledged, startedAt: $startedAt, endedAt: $endedAt, ongoing: $ongoing, hasSnapshot: $hasSnapshot, hasClip: $hasClip, zoneName: $zoneName, lineName: $lineName, direction: $direction, boxes: $boxes, count: $count, profile: $profile, plates: $plates, plateStatus: $plateStatus, face: $face, aspect: $aspect)';
}


}

/// @nodoc
abstract mixin class _$CameraEventCopyWith<$Res> implements $CameraEventCopyWith<$Res> {
  factory _$CameraEventCopyWith(_CameraEvent value, $Res Function(_CameraEvent) _then) = __$CameraEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String siteId, String cameraId, String cameraName, String? viewId, String? viewName, EventKind kind, EventSource source, String? label, bool alert, bool acknowledged, DateTime startedAt, DateTime? endedAt, bool ongoing, bool hasSnapshot, bool hasClip, String? zoneName, String? lineName, String? direction, List<EventBox> boxes, int? count, String? profile, List<PlateCandidate> plates, String? plateStatus, FaceInfo? face, double aspect
});


@override $FaceInfoCopyWith<$Res>? get face;

}
/// @nodoc
class __$CameraEventCopyWithImpl<$Res>
    implements _$CameraEventCopyWith<$Res> {
  __$CameraEventCopyWithImpl(this._self, this._then);

  final _CameraEvent _self;
  final $Res Function(_CameraEvent) _then;

/// Create a copy of CameraEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? siteId = null,Object? cameraId = null,Object? cameraName = null,Object? viewId = freezed,Object? viewName = freezed,Object? kind = null,Object? source = null,Object? label = freezed,Object? alert = null,Object? acknowledged = null,Object? startedAt = null,Object? endedAt = freezed,Object? ongoing = null,Object? hasSnapshot = null,Object? hasClip = null,Object? zoneName = freezed,Object? lineName = freezed,Object? direction = freezed,Object? boxes = null,Object? count = freezed,Object? profile = freezed,Object? plates = null,Object? plateStatus = freezed,Object? face = freezed,Object? aspect = null,}) {
  return _then(_CameraEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,cameraId: null == cameraId ? _self.cameraId : cameraId // ignore: cast_nullable_to_non_nullable
as String,cameraName: null == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String,viewId: freezed == viewId ? _self.viewId : viewId // ignore: cast_nullable_to_non_nullable
as String?,viewName: freezed == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as EventKind,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as EventSource,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,alert: null == alert ? _self.alert : alert // ignore: cast_nullable_to_non_nullable
as bool,acknowledged: null == acknowledged ? _self.acknowledged : acknowledged // ignore: cast_nullable_to_non_nullable
as bool,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ongoing: null == ongoing ? _self.ongoing : ongoing // ignore: cast_nullable_to_non_nullable
as bool,hasSnapshot: null == hasSnapshot ? _self.hasSnapshot : hasSnapshot // ignore: cast_nullable_to_non_nullable
as bool,hasClip: null == hasClip ? _self.hasClip : hasClip // ignore: cast_nullable_to_non_nullable
as bool,zoneName: freezed == zoneName ? _self.zoneName : zoneName // ignore: cast_nullable_to_non_nullable
as String?,lineName: freezed == lineName ? _self.lineName : lineName // ignore: cast_nullable_to_non_nullable
as String?,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String?,boxes: null == boxes ? _self._boxes : boxes // ignore: cast_nullable_to_non_nullable
as List<EventBox>,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String?,plates: null == plates ? _self._plates : plates // ignore: cast_nullable_to_non_nullable
as List<PlateCandidate>,plateStatus: freezed == plateStatus ? _self.plateStatus : plateStatus // ignore: cast_nullable_to_non_nullable
as String?,face: freezed == face ? _self.face : face // ignore: cast_nullable_to_non_nullable
as FaceInfo?,aspect: null == aspect ? _self.aspect : aspect // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of CameraEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FaceInfoCopyWith<$Res>? get face {
    if (_self.face == null) {
    return null;
  }

  return $FaceInfoCopyWith<$Res>(_self.face!, (value) {
    return _then(_self.copyWith(face: value));
  });
}
}

/// @nodoc
mixin _$EventFilter {

 DateTime? get day; Set<String> get cameraIds; Set<String> get viewIds; Set<EventKind> get kinds; Set<String> get labels; Set<String> get zones; Set<String> get lines; String? get personId; String? get clusterId; String? get plate; bool get alertsOnly; DateTime? get from; DateTime? get until;
/// Create a copy of EventFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventFilterCopyWith<EventFilter> get copyWith => _$EventFilterCopyWithImpl<EventFilter>(this as EventFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventFilter&&(identical(other.day, _this.day) || other.day == _this.day)&&const DeepCollectionEquality().equals(other.cameraIds, _this.cameraIds)&&const DeepCollectionEquality().equals(other.viewIds, _this.viewIds)&&const DeepCollectionEquality().equals(other.kinds, _this.kinds)&&const DeepCollectionEquality().equals(other.labels, _this.labels)&&const DeepCollectionEquality().equals(other.zones, _this.zones)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.personId, _this.personId) || other.personId == _this.personId)&&(identical(other.clusterId, _this.clusterId) || other.clusterId == _this.clusterId)&&(identical(other.plate, _this.plate) || other.plate == _this.plate)&&(identical(other.alertsOnly, _this.alertsOnly) || other.alertsOnly == _this.alertsOnly)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.until, _this.until) || other.until == _this.until));
}


@override
int get hashCode {
  final _this = this as EventFilter;
  return Object.hash(runtimeType,_this.day,const DeepCollectionEquality().hash(_this.cameraIds),const DeepCollectionEquality().hash(_this.viewIds),const DeepCollectionEquality().hash(_this.kinds),const DeepCollectionEquality().hash(_this.labels),const DeepCollectionEquality().hash(_this.zones),const DeepCollectionEquality().hash(_this.lines),_this.personId,_this.clusterId,_this.plate,_this.alertsOnly,_this.from,_this.until);
}

@override
String toString() {
  final _this = this as EventFilter;
  return 'EventFilter(day: ${_this.day}, cameraIds: ${_this.cameraIds}, viewIds: ${_this.viewIds}, kinds: ${_this.kinds}, labels: ${_this.labels}, zones: ${_this.zones}, lines: ${_this.lines}, personId: ${_this.personId}, clusterId: ${_this.clusterId}, plate: ${_this.plate}, alertsOnly: ${_this.alertsOnly}, from: ${_this.from}, until: ${_this.until})';
}


}

/// @nodoc
abstract mixin class $EventFilterCopyWith<$Res>  {
  factory $EventFilterCopyWith(EventFilter value, $Res Function(EventFilter) _then) = _$EventFilterCopyWithImpl;
@useResult
$Res call({
 DateTime? day, Set<String> cameraIds, Set<String> viewIds, Set<EventKind> kinds, Set<String> labels, Set<String> zones, Set<String> lines, String? personId, String? clusterId, String? plate, bool alertsOnly, DateTime? from, DateTime? until
});




}
/// @nodoc
class _$EventFilterCopyWithImpl<$Res>
    implements $EventFilterCopyWith<$Res> {
  _$EventFilterCopyWithImpl(this._self, this._then);

  final EventFilter _self;
  final $Res Function(EventFilter) _then;

/// Create a copy of EventFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = freezed,Object? cameraIds = null,Object? viewIds = null,Object? kinds = null,Object? labels = null,Object? zones = null,Object? lines = null,Object? personId = freezed,Object? clusterId = freezed,Object? plate = freezed,Object? alertsOnly = null,Object? from = freezed,Object? until = freezed,}) {
  return _then(EventFilter(
day: freezed == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime?,cameraIds: null == cameraIds ? _self.cameraIds : cameraIds // ignore: cast_nullable_to_non_nullable
as Set<String>,viewIds: null == viewIds ? _self.viewIds : viewIds // ignore: cast_nullable_to_non_nullable
as Set<String>,kinds: null == kinds ? _self.kinds : kinds // ignore: cast_nullable_to_non_nullable
as Set<EventKind>,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as Set<String>,zones: null == zones ? _self.zones : zones // ignore: cast_nullable_to_non_nullable
as Set<String>,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as Set<String>,personId: freezed == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String?,clusterId: freezed == clusterId ? _self.clusterId : clusterId // ignore: cast_nullable_to_non_nullable
as String?,plate: freezed == plate ? _self.plate : plate // ignore: cast_nullable_to_non_nullable
as String?,alertsOnly: null == alertsOnly ? _self.alertsOnly : alertsOnly // ignore: cast_nullable_to_non_nullable
as bool,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,until: freezed == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventFilter].
extension EventFilterPatterns on EventFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventFilter value)  $default,){
final _that = this;
switch (_that) {
case _EventFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventFilter value)?  $default,){
final _that = this;
switch (_that) {
case _EventFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? day,  Set<String> cameraIds,  Set<String> viewIds,  Set<EventKind> kinds,  Set<String> labels,  Set<String> zones,  Set<String> lines,  String? personId,  String? clusterId,  String? plate,  bool alertsOnly,  DateTime? from,  DateTime? until)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventFilter() when $default != null:
return $default(_that.day,_that.cameraIds,_that.viewIds,_that.kinds,_that.labels,_that.zones,_that.lines,_that.personId,_that.clusterId,_that.plate,_that.alertsOnly,_that.from,_that.until);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? day,  Set<String> cameraIds,  Set<String> viewIds,  Set<EventKind> kinds,  Set<String> labels,  Set<String> zones,  Set<String> lines,  String? personId,  String? clusterId,  String? plate,  bool alertsOnly,  DateTime? from,  DateTime? until)  $default,) {final _that = this;
switch (_that) {
case _EventFilter():
return $default(_that.day,_that.cameraIds,_that.viewIds,_that.kinds,_that.labels,_that.zones,_that.lines,_that.personId,_that.clusterId,_that.plate,_that.alertsOnly,_that.from,_that.until);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? day,  Set<String> cameraIds,  Set<String> viewIds,  Set<EventKind> kinds,  Set<String> labels,  Set<String> zones,  Set<String> lines,  String? personId,  String? clusterId,  String? plate,  bool alertsOnly,  DateTime? from,  DateTime? until)?  $default,) {final _that = this;
switch (_that) {
case _EventFilter() when $default != null:
return $default(_that.day,_that.cameraIds,_that.viewIds,_that.kinds,_that.labels,_that.zones,_that.lines,_that.personId,_that.clusterId,_that.plate,_that.alertsOnly,_that.from,_that.until);case _:
  return null;

}
}

}

/// @nodoc


class _EventFilter extends EventFilter {
  const _EventFilter({this.day,  Set<String> cameraIds = const <String>{},  Set<String> viewIds = const <String>{},  Set<EventKind> kinds = const <EventKind>{},  Set<String> labels = const <String>{},  Set<String> zones = const <String>{},  Set<String> lines = const <String>{}, this.personId, this.clusterId, this.plate, this.alertsOnly = false, this.from, this.until}): _cameraIds = cameraIds,_viewIds = viewIds,_kinds = kinds,_labels = labels,_zones = zones,_lines = lines,super._();
  

@override final  DateTime? day;
 final  Set<String> _cameraIds;
@override@JsonKey() Set<String> get cameraIds {
  if (_cameraIds is EqualUnmodifiableSetView) return _cameraIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_cameraIds);
}

 final  Set<String> _viewIds;
@override@JsonKey() Set<String> get viewIds {
  if (_viewIds is EqualUnmodifiableSetView) return _viewIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_viewIds);
}

 final  Set<EventKind> _kinds;
@override@JsonKey() Set<EventKind> get kinds {
  if (_kinds is EqualUnmodifiableSetView) return _kinds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_kinds);
}

 final  Set<String> _labels;
@override@JsonKey() Set<String> get labels {
  if (_labels is EqualUnmodifiableSetView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_labels);
}

 final  Set<String> _zones;
@override@JsonKey() Set<String> get zones {
  if (_zones is EqualUnmodifiableSetView) return _zones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_zones);
}

 final  Set<String> _lines;
@override@JsonKey() Set<String> get lines {
  if (_lines is EqualUnmodifiableSetView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_lines);
}

@override final  String? personId;
@override final  String? clusterId;
@override final  String? plate;
@override@JsonKey() final  bool alertsOnly;
@override final  DateTime? from;
@override final  DateTime? until;

/// Create a copy of EventFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventFilterCopyWith<_EventFilter> get copyWith => __$EventFilterCopyWithImpl<_EventFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventFilter&&(identical(other.day, day) || other.day == day)&&const DeepCollectionEquality().equals(other.cameraIds, _cameraIds)&&const DeepCollectionEquality().equals(other.viewIds, _viewIds)&&const DeepCollectionEquality().equals(other.kinds, _kinds)&&const DeepCollectionEquality().equals(other.labels, _labels)&&const DeepCollectionEquality().equals(other.zones, _zones)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.clusterId, clusterId) || other.clusterId == clusterId)&&(identical(other.plate, plate) || other.plate == plate)&&(identical(other.alertsOnly, alertsOnly) || other.alertsOnly == alertsOnly)&&(identical(other.from, from) || other.from == from)&&(identical(other.until, until) || other.until == until));
}


@override
int get hashCode {
    return Object.hash(runtimeType,day,const DeepCollectionEquality().hash(_cameraIds),const DeepCollectionEquality().hash(_viewIds),const DeepCollectionEquality().hash(_kinds),const DeepCollectionEquality().hash(_labels),const DeepCollectionEquality().hash(_zones),const DeepCollectionEquality().hash(_lines),personId,clusterId,plate,alertsOnly,from,until);
}

@override
String toString() {
    return 'EventFilter(day: $day, cameraIds: $cameraIds, viewIds: $viewIds, kinds: $kinds, labels: $labels, zones: $zones, lines: $lines, personId: $personId, clusterId: $clusterId, plate: $plate, alertsOnly: $alertsOnly, from: $from, until: $until)';
}


}

/// @nodoc
abstract mixin class _$EventFilterCopyWith<$Res> implements $EventFilterCopyWith<$Res> {
  factory _$EventFilterCopyWith(_EventFilter value, $Res Function(_EventFilter) _then) = __$EventFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTime? day, Set<String> cameraIds, Set<String> viewIds, Set<EventKind> kinds, Set<String> labels, Set<String> zones, Set<String> lines, String? personId, String? clusterId, String? plate, bool alertsOnly, DateTime? from, DateTime? until
});




}
/// @nodoc
class __$EventFilterCopyWithImpl<$Res>
    implements _$EventFilterCopyWith<$Res> {
  __$EventFilterCopyWithImpl(this._self, this._then);

  final _EventFilter _self;
  final $Res Function(_EventFilter) _then;

/// Create a copy of EventFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = freezed,Object? cameraIds = null,Object? viewIds = null,Object? kinds = null,Object? labels = null,Object? zones = null,Object? lines = null,Object? personId = freezed,Object? clusterId = freezed,Object? plate = freezed,Object? alertsOnly = null,Object? from = freezed,Object? until = freezed,}) {
  return _then(_EventFilter(
day: freezed == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime?,cameraIds: null == cameraIds ? _self._cameraIds : cameraIds // ignore: cast_nullable_to_non_nullable
as Set<String>,viewIds: null == viewIds ? _self._viewIds : viewIds // ignore: cast_nullable_to_non_nullable
as Set<String>,kinds: null == kinds ? _self._kinds : kinds // ignore: cast_nullable_to_non_nullable
as Set<EventKind>,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as Set<String>,zones: null == zones ? _self._zones : zones // ignore: cast_nullable_to_non_nullable
as Set<String>,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as Set<String>,personId: freezed == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String?,clusterId: freezed == clusterId ? _self.clusterId : clusterId // ignore: cast_nullable_to_non_nullable
as String?,plate: freezed == plate ? _self.plate : plate // ignore: cast_nullable_to_non_nullable
as String?,alertsOnly: null == alertsOnly ? _self.alertsOnly : alertsOnly // ignore: cast_nullable_to_non_nullable
as bool,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,until: freezed == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$EventPage {

 List<CameraEvent> get items; int get total; int get page; int get pageSize;
/// Create a copy of EventPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventPageCopyWith<EventPage> get copyWith => _$EventPageCopyWithImpl<EventPage>(this as EventPage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventPage&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.pageSize, _this.pageSize) || other.pageSize == _this.pageSize));
}


@override
int get hashCode {
  final _this = this as EventPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.total,_this.page,_this.pageSize);
}

@override
String toString() {
  final _this = this as EventPage;
  return 'EventPage(items: ${_this.items}, total: ${_this.total}, page: ${_this.page}, pageSize: ${_this.pageSize})';
}


}

/// @nodoc
abstract mixin class $EventPageCopyWith<$Res>  {
  factory $EventPageCopyWith(EventPage value, $Res Function(EventPage) _then) = _$EventPageCopyWithImpl;
@useResult
$Res call({
 List<CameraEvent> items, int total, int page, int pageSize
});




}
/// @nodoc
class _$EventPageCopyWithImpl<$Res>
    implements $EventPageCopyWith<$Res> {
  _$EventPageCopyWithImpl(this._self, this._then);

  final EventPage _self;
  final $Res Function(EventPage) _then;

/// Create a copy of EventPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? page = null,Object? pageSize = null,}) {
  return _then(EventPage(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CameraEvent>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [EventPage].
extension EventPagePatterns on EventPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventPage value)  $default,){
final _that = this;
switch (_that) {
case _EventPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventPage value)?  $default,){
final _that = this;
switch (_that) {
case _EventPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CameraEvent> items,  int total,  int page,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventPage() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.pageSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CameraEvent> items,  int total,  int page,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _EventPage():
return $default(_that.items,_that.total,_that.page,_that.pageSize);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CameraEvent> items,  int total,  int page,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _EventPage() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc


class _EventPage implements EventPage {
  const _EventPage({required  List<CameraEvent> items, required this.total, required this.page, required this.pageSize}): _items = items;
  

 final  List<CameraEvent> _items;
@override List<CameraEvent> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;
@override final  int page;
@override final  int pageSize;

/// Create a copy of EventPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventPageCopyWith<_EventPage> get copyWith => __$EventPageCopyWithImpl<_EventPage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventPage&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,page,pageSize);
}

@override
String toString() {
    return 'EventPage(items: $items, total: $total, page: $page, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$EventPageCopyWith<$Res> implements $EventPageCopyWith<$Res> {
  factory _$EventPageCopyWith(_EventPage value, $Res Function(_EventPage) _then) = __$EventPageCopyWithImpl;
@override @useResult
$Res call({
 List<CameraEvent> items, int total, int page, int pageSize
});




}
/// @nodoc
class __$EventPageCopyWithImpl<$Res>
    implements _$EventPageCopyWith<$Res> {
  __$EventPageCopyWithImpl(this._self, this._then);

  final _EventPage _self;
  final $Res Function(_EventPage) _then;

/// Create a copy of EventPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? page = null,Object? pageSize = null,}) {
  return _then(_EventPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CameraEvent>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$EventCounts {

 int get total; int get alerts; int get unacknowledged; Map<EventKind, int> get kinds; Map<String, int> get labels;
/// Create a copy of EventCounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCountsCopyWith<EventCounts> get copyWith => _$EventCountsCopyWithImpl<EventCounts>(this as EventCounts, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventCounts;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventCounts&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.alerts, _this.alerts) || other.alerts == _this.alerts)&&(identical(other.unacknowledged, _this.unacknowledged) || other.unacknowledged == _this.unacknowledged)&&const DeepCollectionEquality().equals(other.kinds, _this.kinds)&&const DeepCollectionEquality().equals(other.labels, _this.labels));
}


@override
int get hashCode {
  final _this = this as EventCounts;
  return Object.hash(runtimeType,_this.total,_this.alerts,_this.unacknowledged,const DeepCollectionEquality().hash(_this.kinds),const DeepCollectionEquality().hash(_this.labels));
}

@override
String toString() {
  final _this = this as EventCounts;
  return 'EventCounts(total: ${_this.total}, alerts: ${_this.alerts}, unacknowledged: ${_this.unacknowledged}, kinds: ${_this.kinds}, labels: ${_this.labels})';
}


}

/// @nodoc
abstract mixin class $EventCountsCopyWith<$Res>  {
  factory $EventCountsCopyWith(EventCounts value, $Res Function(EventCounts) _then) = _$EventCountsCopyWithImpl;
@useResult
$Res call({
 int total, int alerts, int unacknowledged, Map<EventKind, int> kinds, Map<String, int> labels
});




}
/// @nodoc
class _$EventCountsCopyWithImpl<$Res>
    implements $EventCountsCopyWith<$Res> {
  _$EventCountsCopyWithImpl(this._self, this._then);

  final EventCounts _self;
  final $Res Function(EventCounts) _then;

/// Create a copy of EventCounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? alerts = null,Object? unacknowledged = null,Object? kinds = null,Object? labels = null,}) {
  return _then(EventCounts(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,alerts: null == alerts ? _self.alerts : alerts // ignore: cast_nullable_to_non_nullable
as int,unacknowledged: null == unacknowledged ? _self.unacknowledged : unacknowledged // ignore: cast_nullable_to_non_nullable
as int,kinds: null == kinds ? _self.kinds : kinds // ignore: cast_nullable_to_non_nullable
as Map<EventKind, int>,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [EventCounts].
extension EventCountsPatterns on EventCounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventCounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventCounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventCounts value)  $default,){
final _that = this;
switch (_that) {
case _EventCounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventCounts value)?  $default,){
final _that = this;
switch (_that) {
case _EventCounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  int alerts,  int unacknowledged,  Map<EventKind, int> kinds,  Map<String, int> labels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventCounts() when $default != null:
return $default(_that.total,_that.alerts,_that.unacknowledged,_that.kinds,_that.labels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  int alerts,  int unacknowledged,  Map<EventKind, int> kinds,  Map<String, int> labels)  $default,) {final _that = this;
switch (_that) {
case _EventCounts():
return $default(_that.total,_that.alerts,_that.unacknowledged,_that.kinds,_that.labels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  int alerts,  int unacknowledged,  Map<EventKind, int> kinds,  Map<String, int> labels)?  $default,) {final _that = this;
switch (_that) {
case _EventCounts() when $default != null:
return $default(_that.total,_that.alerts,_that.unacknowledged,_that.kinds,_that.labels);case _:
  return null;

}
}

}

/// @nodoc


class _EventCounts implements EventCounts {
  const _EventCounts({this.total = 0, this.alerts = 0, this.unacknowledged = 0,  Map<EventKind, int> kinds = const <EventKind, int>{},  Map<String, int> labels = const <String, int>{}}): _kinds = kinds,_labels = labels;
  

@override@JsonKey() final  int total;
@override@JsonKey() final  int alerts;
@override@JsonKey() final  int unacknowledged;
 final  Map<EventKind, int> _kinds;
@override@JsonKey() Map<EventKind, int> get kinds {
  if (_kinds is EqualUnmodifiableMapView) return _kinds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_kinds);
}

 final  Map<String, int> _labels;
@override@JsonKey() Map<String, int> get labels {
  if (_labels is EqualUnmodifiableMapView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_labels);
}


/// Create a copy of EventCounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventCountsCopyWith<_EventCounts> get copyWith => __$EventCountsCopyWithImpl<_EventCounts>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventCounts&&(identical(other.total, total) || other.total == total)&&(identical(other.alerts, alerts) || other.alerts == alerts)&&(identical(other.unacknowledged, unacknowledged) || other.unacknowledged == unacknowledged)&&const DeepCollectionEquality().equals(other.kinds, _kinds)&&const DeepCollectionEquality().equals(other.labels, _labels));
}


@override
int get hashCode {
    return Object.hash(runtimeType,total,alerts,unacknowledged,const DeepCollectionEquality().hash(_kinds),const DeepCollectionEquality().hash(_labels));
}

@override
String toString() {
    return 'EventCounts(total: $total, alerts: $alerts, unacknowledged: $unacknowledged, kinds: $kinds, labels: $labels)';
}


}

/// @nodoc
abstract mixin class _$EventCountsCopyWith<$Res> implements $EventCountsCopyWith<$Res> {
  factory _$EventCountsCopyWith(_EventCounts value, $Res Function(_EventCounts) _then) = __$EventCountsCopyWithImpl;
@override @useResult
$Res call({
 int total, int alerts, int unacknowledged, Map<EventKind, int> kinds, Map<String, int> labels
});




}
/// @nodoc
class __$EventCountsCopyWithImpl<$Res>
    implements _$EventCountsCopyWith<$Res> {
  __$EventCountsCopyWithImpl(this._self, this._then);

  final _EventCounts _self;
  final $Res Function(_EventCounts) _then;

/// Create a copy of EventCounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? alerts = null,Object? unacknowledged = null,Object? kinds = null,Object? labels = null,}) {
  return _then(_EventCounts(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,alerts: null == alerts ? _self.alerts : alerts // ignore: cast_nullable_to_non_nullable
as int,unacknowledged: null == unacknowledged ? _self.unacknowledged : unacknowledged // ignore: cast_nullable_to_non_nullable
as int,kinds: null == kinds ? _self._kinds : kinds // ignore: cast_nullable_to_non_nullable
as Map<EventKind, int>,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
