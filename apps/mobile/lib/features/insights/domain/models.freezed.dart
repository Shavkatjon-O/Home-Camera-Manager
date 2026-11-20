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
mixin _$CountLine {

 String get id; String get name; String get viewName; String get cameraName;
/// Create a copy of CountLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountLineCopyWith<CountLine> get copyWith => _$CountLineCopyWithImpl<CountLine>(this as CountLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CountLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountLine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.viewName, _this.viewName) || other.viewName == _this.viewName)&&(identical(other.cameraName, _this.cameraName) || other.cameraName == _this.cameraName));
}


@override
int get hashCode {
  final _this = this as CountLine;
  return Object.hash(runtimeType,_this.id,_this.name,_this.viewName,_this.cameraName);
}

@override
String toString() {
  final _this = this as CountLine;
  return 'CountLine(id: ${_this.id}, name: ${_this.name}, viewName: ${_this.viewName}, cameraName: ${_this.cameraName})';
}


}

/// @nodoc
abstract mixin class $CountLineCopyWith<$Res>  {
  factory $CountLineCopyWith(CountLine value, $Res Function(CountLine) _then) = _$CountLineCopyWithImpl;
@useResult
$Res call({
 String id, String name, String viewName, String cameraName
});




}
/// @nodoc
class _$CountLineCopyWithImpl<$Res>
    implements $CountLineCopyWith<$Res> {
  _$CountLineCopyWithImpl(this._self, this._then);

  final CountLine _self;
  final $Res Function(CountLine) _then;

/// Create a copy of CountLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? viewName = null,Object? cameraName = null,}) {
  return _then(CountLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,viewName: null == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String,cameraName: null == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CountLine].
extension CountLinePatterns on CountLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountLine value)  $default,){
final _that = this;
switch (_that) {
case _CountLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountLine value)?  $default,){
final _that = this;
switch (_that) {
case _CountLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String viewName,  String cameraName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountLine() when $default != null:
return $default(_that.id,_that.name,_that.viewName,_that.cameraName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String viewName,  String cameraName)  $default,) {final _that = this;
switch (_that) {
case _CountLine():
return $default(_that.id,_that.name,_that.viewName,_that.cameraName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String viewName,  String cameraName)?  $default,) {final _that = this;
switch (_that) {
case _CountLine() when $default != null:
return $default(_that.id,_that.name,_that.viewName,_that.cameraName);case _:
  return null;

}
}

}

/// @nodoc


class _CountLine implements CountLine {
  const _CountLine({required this.id, required this.name, required this.viewName, required this.cameraName});
  

@override final  String id;
@override final  String name;
@override final  String viewName;
@override final  String cameraName;

/// Create a copy of CountLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountLineCopyWith<_CountLine> get copyWith => __$CountLineCopyWithImpl<_CountLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountLine&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.viewName, viewName) || other.viewName == viewName)&&(identical(other.cameraName, cameraName) || other.cameraName == cameraName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,viewName,cameraName);
}

@override
String toString() {
    return 'CountLine(id: $id, name: $name, viewName: $viewName, cameraName: $cameraName)';
}


}

/// @nodoc
abstract mixin class _$CountLineCopyWith<$Res> implements $CountLineCopyWith<$Res> {
  factory _$CountLineCopyWith(_CountLine value, $Res Function(_CountLine) _then) = __$CountLineCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String viewName, String cameraName
});




}
/// @nodoc
class __$CountLineCopyWithImpl<$Res>
    implements _$CountLineCopyWith<$Res> {
  __$CountLineCopyWithImpl(this._self, this._then);

  final _CountLine _self;
  final $Res Function(_CountLine) _then;

/// Create a copy of CountLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? viewName = null,Object? cameraName = null,}) {
  return _then(_CountLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,viewName: null == viewName ? _self.viewName : viewName // ignore: cast_nullable_to_non_nullable
as String,cameraName: null == cameraName ? _self.cameraName : cameraName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CountBucket {

 String get lineId; DateTime get at; String get label; int get inward; int get outward;
/// Create a copy of CountBucket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountBucketCopyWith<CountBucket> get copyWith => _$CountBucketCopyWithImpl<CountBucket>(this as CountBucket, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CountBucket;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountBucket&&(identical(other.lineId, _this.lineId) || other.lineId == _this.lineId)&&(identical(other.at, _this.at) || other.at == _this.at)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.inward, _this.inward) || other.inward == _this.inward)&&(identical(other.outward, _this.outward) || other.outward == _this.outward));
}


@override
int get hashCode {
  final _this = this as CountBucket;
  return Object.hash(runtimeType,_this.lineId,_this.at,_this.label,_this.inward,_this.outward);
}

@override
String toString() {
  final _this = this as CountBucket;
  return 'CountBucket(lineId: ${_this.lineId}, at: ${_this.at}, label: ${_this.label}, inward: ${_this.inward}, outward: ${_this.outward})';
}


}

/// @nodoc
abstract mixin class $CountBucketCopyWith<$Res>  {
  factory $CountBucketCopyWith(CountBucket value, $Res Function(CountBucket) _then) = _$CountBucketCopyWithImpl;
@useResult
$Res call({
 String lineId, DateTime at, String label, int inward, int outward
});




}
/// @nodoc
class _$CountBucketCopyWithImpl<$Res>
    implements $CountBucketCopyWith<$Res> {
  _$CountBucketCopyWithImpl(this._self, this._then);

  final CountBucket _self;
  final $Res Function(CountBucket) _then;

/// Create a copy of CountBucket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineId = null,Object? at = null,Object? label = null,Object? inward = null,Object? outward = null,}) {
  return _then(CountBucket(
lineId: null == lineId ? _self.lineId : lineId // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,inward: null == inward ? _self.inward : inward // ignore: cast_nullable_to_non_nullable
as int,outward: null == outward ? _self.outward : outward // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CountBucket].
extension CountBucketPatterns on CountBucket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountBucket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountBucket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountBucket value)  $default,){
final _that = this;
switch (_that) {
case _CountBucket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountBucket value)?  $default,){
final _that = this;
switch (_that) {
case _CountBucket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String lineId,  DateTime at,  String label,  int inward,  int outward)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountBucket() when $default != null:
return $default(_that.lineId,_that.at,_that.label,_that.inward,_that.outward);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String lineId,  DateTime at,  String label,  int inward,  int outward)  $default,) {final _that = this;
switch (_that) {
case _CountBucket():
return $default(_that.lineId,_that.at,_that.label,_that.inward,_that.outward);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String lineId,  DateTime at,  String label,  int inward,  int outward)?  $default,) {final _that = this;
switch (_that) {
case _CountBucket() when $default != null:
return $default(_that.lineId,_that.at,_that.label,_that.inward,_that.outward);case _:
  return null;

}
}

}

/// @nodoc


class _CountBucket implements CountBucket {
  const _CountBucket({required this.lineId, required this.at, required this.label, required this.inward, required this.outward});
  

@override final  String lineId;
@override final  DateTime at;
@override final  String label;
@override final  int inward;
@override final  int outward;

/// Create a copy of CountBucket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountBucketCopyWith<_CountBucket> get copyWith => __$CountBucketCopyWithImpl<_CountBucket>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountBucket&&(identical(other.lineId, lineId) || other.lineId == lineId)&&(identical(other.at, at) || other.at == at)&&(identical(other.label, label) || other.label == label)&&(identical(other.inward, inward) || other.inward == inward)&&(identical(other.outward, outward) || other.outward == outward));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lineId,at,label,inward,outward);
}

@override
String toString() {
    return 'CountBucket(lineId: $lineId, at: $at, label: $label, inward: $inward, outward: $outward)';
}


}

/// @nodoc
abstract mixin class _$CountBucketCopyWith<$Res> implements $CountBucketCopyWith<$Res> {
  factory _$CountBucketCopyWith(_CountBucket value, $Res Function(_CountBucket) _then) = __$CountBucketCopyWithImpl;
@override @useResult
$Res call({
 String lineId, DateTime at, String label, int inward, int outward
});




}
/// @nodoc
class __$CountBucketCopyWithImpl<$Res>
    implements _$CountBucketCopyWith<$Res> {
  __$CountBucketCopyWithImpl(this._self, this._then);

  final _CountBucket _self;
  final $Res Function(_CountBucket) _then;

/// Create a copy of CountBucket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineId = null,Object? at = null,Object? label = null,Object? inward = null,Object? outward = null,}) {
  return _then(_CountBucket(
lineId: null == lineId ? _self.lineId : lineId // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,inward: null == inward ? _self.inward : inward // ignore: cast_nullable_to_non_nullable
as int,outward: null == outward ? _self.outward : outward // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CountsReport {

 DateTime get start; DateTime get end; Bucket get bucket; List<CountLine> get lines; List<CountBucket> get buckets;
/// Create a copy of CountsReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountsReportCopyWith<CountsReport> get copyWith => _$CountsReportCopyWithImpl<CountsReport>(this as CountsReport, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CountsReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountsReport&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.bucket, _this.bucket) || other.bucket == _this.bucket)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&const DeepCollectionEquality().equals(other.buckets, _this.buckets));
}


@override
int get hashCode {
  final _this = this as CountsReport;
  return Object.hash(runtimeType,_this.start,_this.end,_this.bucket,const DeepCollectionEquality().hash(_this.lines),const DeepCollectionEquality().hash(_this.buckets));
}

@override
String toString() {
  final _this = this as CountsReport;
  return 'CountsReport(start: ${_this.start}, end: ${_this.end}, bucket: ${_this.bucket}, lines: ${_this.lines}, buckets: ${_this.buckets})';
}


}

/// @nodoc
abstract mixin class $CountsReportCopyWith<$Res>  {
  factory $CountsReportCopyWith(CountsReport value, $Res Function(CountsReport) _then) = _$CountsReportCopyWithImpl;
@useResult
$Res call({
 DateTime start, DateTime end, Bucket bucket, List<CountLine> lines, List<CountBucket> buckets
});




}
/// @nodoc
class _$CountsReportCopyWithImpl<$Res>
    implements $CountsReportCopyWith<$Res> {
  _$CountsReportCopyWithImpl(this._self, this._then);

  final CountsReport _self;
  final $Res Function(CountsReport) _then;

/// Create a copy of CountsReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = null,Object? bucket = null,Object? lines = null,Object? buckets = null,}) {
  return _then(CountsReport(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as Bucket,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CountLine>,buckets: null == buckets ? _self.buckets : buckets // ignore: cast_nullable_to_non_nullable
as List<CountBucket>,
  ));
}

}


/// Adds pattern-matching-related methods to [CountsReport].
extension CountsReportPatterns on CountsReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountsReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountsReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountsReport value)  $default,){
final _that = this;
switch (_that) {
case _CountsReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountsReport value)?  $default,){
final _that = this;
switch (_that) {
case _CountsReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime start,  DateTime end,  Bucket bucket,  List<CountLine> lines,  List<CountBucket> buckets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountsReport() when $default != null:
return $default(_that.start,_that.end,_that.bucket,_that.lines,_that.buckets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime start,  DateTime end,  Bucket bucket,  List<CountLine> lines,  List<CountBucket> buckets)  $default,) {final _that = this;
switch (_that) {
case _CountsReport():
return $default(_that.start,_that.end,_that.bucket,_that.lines,_that.buckets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime start,  DateTime end,  Bucket bucket,  List<CountLine> lines,  List<CountBucket> buckets)?  $default,) {final _that = this;
switch (_that) {
case _CountsReport() when $default != null:
return $default(_that.start,_that.end,_that.bucket,_that.lines,_that.buckets);case _:
  return null;

}
}

}

/// @nodoc


class _CountsReport implements CountsReport {
  const _CountsReport({required this.start, required this.end, required this.bucket, required  List<CountLine> lines, required  List<CountBucket> buckets}): _lines = lines,_buckets = buckets;
  

@override final  DateTime start;
@override final  DateTime end;
@override final  Bucket bucket;
 final  List<CountLine> _lines;
@override List<CountLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

 final  List<CountBucket> _buckets;
@override List<CountBucket> get buckets {
  if (_buckets is EqualUnmodifiableListView) return _buckets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_buckets);
}


/// Create a copy of CountsReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountsReportCopyWith<_CountsReport> get copyWith => __$CountsReportCopyWithImpl<_CountsReport>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountsReport&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.bucket, bucket) || other.bucket == bucket)&&const DeepCollectionEquality().equals(other.lines, _lines)&&const DeepCollectionEquality().equals(other.buckets, _buckets));
}


@override
int get hashCode {
    return Object.hash(runtimeType,start,end,bucket,const DeepCollectionEquality().hash(_lines),const DeepCollectionEquality().hash(_buckets));
}

@override
String toString() {
    return 'CountsReport(start: $start, end: $end, bucket: $bucket, lines: $lines, buckets: $buckets)';
}


}

/// @nodoc
abstract mixin class _$CountsReportCopyWith<$Res> implements $CountsReportCopyWith<$Res> {
  factory _$CountsReportCopyWith(_CountsReport value, $Res Function(_CountsReport) _then) = __$CountsReportCopyWithImpl;
@override @useResult
$Res call({
 DateTime start, DateTime end, Bucket bucket, List<CountLine> lines, List<CountBucket> buckets
});




}
/// @nodoc
class __$CountsReportCopyWithImpl<$Res>
    implements _$CountsReportCopyWith<$Res> {
  __$CountsReportCopyWithImpl(this._self, this._then);

  final _CountsReport _self;
  final $Res Function(_CountsReport) _then;

/// Create a copy of CountsReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = null,Object? bucket = null,Object? lines = null,Object? buckets = null,}) {
  return _then(_CountsReport(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as Bucket,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CountLine>,buckets: null == buckets ? _self._buckets : buckets // ignore: cast_nullable_to_non_nullable
as List<CountBucket>,
  ));
}


}

/// @nodoc
mixin _$Area {

 String get id; String get name; int get occupancy; int get entered; int get exited; DateTime get since; String? get resetAt; List<String> get labels; List<String> get lineNames; int? get capacity;
/// Create a copy of Area
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AreaCopyWith<Area> get copyWith => _$AreaCopyWithImpl<Area>(this as Area, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Area;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Area&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.occupancy, _this.occupancy) || other.occupancy == _this.occupancy)&&(identical(other.entered, _this.entered) || other.entered == _this.entered)&&(identical(other.exited, _this.exited) || other.exited == _this.exited)&&(identical(other.since, _this.since) || other.since == _this.since)&&(identical(other.resetAt, _this.resetAt) || other.resetAt == _this.resetAt)&&const DeepCollectionEquality().equals(other.labels, _this.labels)&&const DeepCollectionEquality().equals(other.lineNames, _this.lineNames)&&(identical(other.capacity, _this.capacity) || other.capacity == _this.capacity));
}


@override
int get hashCode {
  final _this = this as Area;
  return Object.hash(runtimeType,_this.id,_this.name,_this.occupancy,_this.entered,_this.exited,_this.since,_this.resetAt,const DeepCollectionEquality().hash(_this.labels),const DeepCollectionEquality().hash(_this.lineNames),_this.capacity);
}

@override
String toString() {
  final _this = this as Area;
  return 'Area(id: ${_this.id}, name: ${_this.name}, occupancy: ${_this.occupancy}, entered: ${_this.entered}, exited: ${_this.exited}, since: ${_this.since}, resetAt: ${_this.resetAt}, labels: ${_this.labels}, lineNames: ${_this.lineNames}, capacity: ${_this.capacity})';
}


}

/// @nodoc
abstract mixin class $AreaCopyWith<$Res>  {
  factory $AreaCopyWith(Area value, $Res Function(Area) _then) = _$AreaCopyWithImpl;
@useResult
$Res call({
 String id, String name, int occupancy, int entered, int exited, DateTime since, String? resetAt, List<String> labels, List<String> lineNames, int? capacity
});




}
/// @nodoc
class _$AreaCopyWithImpl<$Res>
    implements $AreaCopyWith<$Res> {
  _$AreaCopyWithImpl(this._self, this._then);

  final Area _self;
  final $Res Function(Area) _then;

/// Create a copy of Area
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? occupancy = null,Object? entered = null,Object? exited = null,Object? since = null,Object? resetAt = freezed,Object? labels = null,Object? lineNames = null,Object? capacity = freezed,}) {
  return _then(Area(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,occupancy: null == occupancy ? _self.occupancy : occupancy // ignore: cast_nullable_to_non_nullable
as int,entered: null == entered ? _self.entered : entered // ignore: cast_nullable_to_non_nullable
as int,exited: null == exited ? _self.exited : exited // ignore: cast_nullable_to_non_nullable
as int,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as DateTime,resetAt: freezed == resetAt ? _self.resetAt : resetAt // ignore: cast_nullable_to_non_nullable
as String?,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,lineNames: null == lineNames ? _self.lineNames : lineNames // ignore: cast_nullable_to_non_nullable
as List<String>,capacity: freezed == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Area].
extension AreaPatterns on Area {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Area value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Area() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Area value)  $default,){
final _that = this;
switch (_that) {
case _Area():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Area value)?  $default,){
final _that = this;
switch (_that) {
case _Area() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int occupancy,  int entered,  int exited,  DateTime since,  String? resetAt,  List<String> labels,  List<String> lineNames,  int? capacity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Area() when $default != null:
return $default(_that.id,_that.name,_that.occupancy,_that.entered,_that.exited,_that.since,_that.resetAt,_that.labels,_that.lineNames,_that.capacity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int occupancy,  int entered,  int exited,  DateTime since,  String? resetAt,  List<String> labels,  List<String> lineNames,  int? capacity)  $default,) {final _that = this;
switch (_that) {
case _Area():
return $default(_that.id,_that.name,_that.occupancy,_that.entered,_that.exited,_that.since,_that.resetAt,_that.labels,_that.lineNames,_that.capacity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int occupancy,  int entered,  int exited,  DateTime since,  String? resetAt,  List<String> labels,  List<String> lineNames,  int? capacity)?  $default,) {final _that = this;
switch (_that) {
case _Area() when $default != null:
return $default(_that.id,_that.name,_that.occupancy,_that.entered,_that.exited,_that.since,_that.resetAt,_that.labels,_that.lineNames,_that.capacity);case _:
  return null;

}
}

}

/// @nodoc


class _Area implements Area {
  const _Area({required this.id, required this.name, required this.occupancy, required this.entered, required this.exited, required this.since, this.resetAt,  List<String> labels = const <String>['person'],  List<String> lineNames = const <String>[], this.capacity}): _labels = labels,_lineNames = lineNames;
  

@override final  String id;
@override final  String name;
@override final  int occupancy;
@override final  int entered;
@override final  int exited;
@override final  DateTime since;
@override final  String? resetAt;
 final  List<String> _labels;
@override@JsonKey() List<String> get labels {
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labels);
}

 final  List<String> _lineNames;
@override@JsonKey() List<String> get lineNames {
  if (_lineNames is EqualUnmodifiableListView) return _lineNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lineNames);
}

@override final  int? capacity;

/// Create a copy of Area
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AreaCopyWith<_Area> get copyWith => __$AreaCopyWithImpl<_Area>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Area&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.occupancy, occupancy) || other.occupancy == occupancy)&&(identical(other.entered, entered) || other.entered == entered)&&(identical(other.exited, exited) || other.exited == exited)&&(identical(other.since, since) || other.since == since)&&(identical(other.resetAt, resetAt) || other.resetAt == resetAt)&&const DeepCollectionEquality().equals(other.labels, _labels)&&const DeepCollectionEquality().equals(other.lineNames, _lineNames)&&(identical(other.capacity, capacity) || other.capacity == capacity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,occupancy,entered,exited,since,resetAt,const DeepCollectionEquality().hash(_labels),const DeepCollectionEquality().hash(_lineNames),capacity);
}

@override
String toString() {
    return 'Area(id: $id, name: $name, occupancy: $occupancy, entered: $entered, exited: $exited, since: $since, resetAt: $resetAt, labels: $labels, lineNames: $lineNames, capacity: $capacity)';
}


}

/// @nodoc
abstract mixin class _$AreaCopyWith<$Res> implements $AreaCopyWith<$Res> {
  factory _$AreaCopyWith(_Area value, $Res Function(_Area) _then) = __$AreaCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int occupancy, int entered, int exited, DateTime since, String? resetAt, List<String> labels, List<String> lineNames, int? capacity
});




}
/// @nodoc
class __$AreaCopyWithImpl<$Res>
    implements _$AreaCopyWith<$Res> {
  __$AreaCopyWithImpl(this._self, this._then);

  final _Area _self;
  final $Res Function(_Area) _then;

/// Create a copy of Area
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? occupancy = null,Object? entered = null,Object? exited = null,Object? since = null,Object? resetAt = freezed,Object? labels = null,Object? lineNames = null,Object? capacity = freezed,}) {
  return _then(_Area(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,occupancy: null == occupancy ? _self.occupancy : occupancy // ignore: cast_nullable_to_non_nullable
as int,entered: null == entered ? _self.entered : entered // ignore: cast_nullable_to_non_nullable
as int,exited: null == exited ? _self.exited : exited // ignore: cast_nullable_to_non_nullable
as int,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as DateTime,resetAt: freezed == resetAt ? _self.resetAt : resetAt // ignore: cast_nullable_to_non_nullable
as String?,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,lineNames: null == lineNames ? _self._lineNames : lineNames // ignore: cast_nullable_to_non_nullable
as List<String>,capacity: freezed == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
