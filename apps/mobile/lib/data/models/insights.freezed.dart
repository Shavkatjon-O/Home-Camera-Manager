// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insights.dart';

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

/// @nodoc
mixin _$HealthBucket {

 DateTime get start; double? get availability; double? get latencyMs;
/// Create a copy of HealthBucket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthBucketCopyWith<HealthBucket> get copyWith => _$HealthBucketCopyWithImpl<HealthBucket>(this as HealthBucket, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HealthBucket;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthBucket&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.availability, _this.availability) || other.availability == _this.availability)&&(identical(other.latencyMs, _this.latencyMs) || other.latencyMs == _this.latencyMs));
}


@override
int get hashCode {
  final _this = this as HealthBucket;
  return Object.hash(runtimeType,_this.start,_this.availability,_this.latencyMs);
}

@override
String toString() {
  final _this = this as HealthBucket;
  return 'HealthBucket(start: ${_this.start}, availability: ${_this.availability}, latencyMs: ${_this.latencyMs})';
}


}

/// @nodoc
abstract mixin class $HealthBucketCopyWith<$Res>  {
  factory $HealthBucketCopyWith(HealthBucket value, $Res Function(HealthBucket) _then) = _$HealthBucketCopyWithImpl;
@useResult
$Res call({
 DateTime start, double? availability, double? latencyMs
});




}
/// @nodoc
class _$HealthBucketCopyWithImpl<$Res>
    implements $HealthBucketCopyWith<$Res> {
  _$HealthBucketCopyWithImpl(this._self, this._then);

  final HealthBucket _self;
  final $Res Function(HealthBucket) _then;

/// Create a copy of HealthBucket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? availability = freezed,Object? latencyMs = freezed,}) {
  return _then(HealthBucket(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,availability: freezed == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as double?,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthBucket].
extension HealthBucketPatterns on HealthBucket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthBucket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthBucket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthBucket value)  $default,){
final _that = this;
switch (_that) {
case _HealthBucket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthBucket value)?  $default,){
final _that = this;
switch (_that) {
case _HealthBucket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime start,  double? availability,  double? latencyMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthBucket() when $default != null:
return $default(_that.start,_that.availability,_that.latencyMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime start,  double? availability,  double? latencyMs)  $default,) {final _that = this;
switch (_that) {
case _HealthBucket():
return $default(_that.start,_that.availability,_that.latencyMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime start,  double? availability,  double? latencyMs)?  $default,) {final _that = this;
switch (_that) {
case _HealthBucket() when $default != null:
return $default(_that.start,_that.availability,_that.latencyMs);case _:
  return null;

}
}

}

/// @nodoc


class _HealthBucket implements HealthBucket {
  const _HealthBucket({required this.start, this.availability, this.latencyMs});
  

@override final  DateTime start;
@override final  double? availability;
@override final  double? latencyMs;

/// Create a copy of HealthBucket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthBucketCopyWith<_HealthBucket> get copyWith => __$HealthBucketCopyWithImpl<_HealthBucket>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthBucket&&(identical(other.start, start) || other.start == start)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,start,availability,latencyMs);
}

@override
String toString() {
    return 'HealthBucket(start: $start, availability: $availability, latencyMs: $latencyMs)';
}


}

/// @nodoc
abstract mixin class _$HealthBucketCopyWith<$Res> implements $HealthBucketCopyWith<$Res> {
  factory _$HealthBucketCopyWith(_HealthBucket value, $Res Function(_HealthBucket) _then) = __$HealthBucketCopyWithImpl;
@override @useResult
$Res call({
 DateTime start, double? availability, double? latencyMs
});




}
/// @nodoc
class __$HealthBucketCopyWithImpl<$Res>
    implements _$HealthBucketCopyWith<$Res> {
  __$HealthBucketCopyWithImpl(this._self, this._then);

  final _HealthBucket _self;
  final $Res Function(_HealthBucket) _then;

/// Create a copy of HealthBucket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? availability = freezed,Object? latencyMs = freezed,}) {
  return _then(_HealthBucket(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,availability: freezed == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as double?,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
mixin _$HealthTarget {

 String get id; String get name; String get kind; HealthStatus get status; double? get uptimePercent; double? get latencyMs; int get outageCount; String? get parentName; DateTime? get lastSampleAt; List<HealthBucket> get buckets;
/// Create a copy of HealthTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthTargetCopyWith<HealthTarget> get copyWith => _$HealthTargetCopyWithImpl<HealthTarget>(this as HealthTarget, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HealthTarget;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthTarget&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.uptimePercent, _this.uptimePercent) || other.uptimePercent == _this.uptimePercent)&&(identical(other.latencyMs, _this.latencyMs) || other.latencyMs == _this.latencyMs)&&(identical(other.outageCount, _this.outageCount) || other.outageCount == _this.outageCount)&&(identical(other.parentName, _this.parentName) || other.parentName == _this.parentName)&&(identical(other.lastSampleAt, _this.lastSampleAt) || other.lastSampleAt == _this.lastSampleAt)&&const DeepCollectionEquality().equals(other.buckets, _this.buckets));
}


@override
int get hashCode {
  final _this = this as HealthTarget;
  return Object.hash(runtimeType,_this.id,_this.name,_this.kind,_this.status,_this.uptimePercent,_this.latencyMs,_this.outageCount,_this.parentName,_this.lastSampleAt,const DeepCollectionEquality().hash(_this.buckets));
}

@override
String toString() {
  final _this = this as HealthTarget;
  return 'HealthTarget(id: ${_this.id}, name: ${_this.name}, kind: ${_this.kind}, status: ${_this.status}, uptimePercent: ${_this.uptimePercent}, latencyMs: ${_this.latencyMs}, outageCount: ${_this.outageCount}, parentName: ${_this.parentName}, lastSampleAt: ${_this.lastSampleAt}, buckets: ${_this.buckets})';
}


}

/// @nodoc
abstract mixin class $HealthTargetCopyWith<$Res>  {
  factory $HealthTargetCopyWith(HealthTarget value, $Res Function(HealthTarget) _then) = _$HealthTargetCopyWithImpl;
@useResult
$Res call({
 String id, String name, String kind, HealthStatus status, double? uptimePercent, double? latencyMs, int outageCount, String? parentName, DateTime? lastSampleAt, List<HealthBucket> buckets
});




}
/// @nodoc
class _$HealthTargetCopyWithImpl<$Res>
    implements $HealthTargetCopyWith<$Res> {
  _$HealthTargetCopyWithImpl(this._self, this._then);

  final HealthTarget _self;
  final $Res Function(HealthTarget) _then;

/// Create a copy of HealthTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? status = null,Object? uptimePercent = freezed,Object? latencyMs = freezed,Object? outageCount = null,Object? parentName = freezed,Object? lastSampleAt = freezed,Object? buckets = null,}) {
  return _then(HealthTarget(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HealthStatus,uptimePercent: freezed == uptimePercent ? _self.uptimePercent : uptimePercent // ignore: cast_nullable_to_non_nullable
as double?,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as double?,outageCount: null == outageCount ? _self.outageCount : outageCount // ignore: cast_nullable_to_non_nullable
as int,parentName: freezed == parentName ? _self.parentName : parentName // ignore: cast_nullable_to_non_nullable
as String?,lastSampleAt: freezed == lastSampleAt ? _self.lastSampleAt : lastSampleAt // ignore: cast_nullable_to_non_nullable
as DateTime?,buckets: null == buckets ? _self.buckets : buckets // ignore: cast_nullable_to_non_nullable
as List<HealthBucket>,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthTarget].
extension HealthTargetPatterns on HealthTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthTarget value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthTarget() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthTarget value)  $default,){
final _that = this;
switch (_that) {
case _HealthTarget():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthTarget value)?  $default,){
final _that = this;
switch (_that) {
case _HealthTarget() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String kind,  HealthStatus status,  double? uptimePercent,  double? latencyMs,  int outageCount,  String? parentName,  DateTime? lastSampleAt,  List<HealthBucket> buckets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthTarget() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.status,_that.uptimePercent,_that.latencyMs,_that.outageCount,_that.parentName,_that.lastSampleAt,_that.buckets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String kind,  HealthStatus status,  double? uptimePercent,  double? latencyMs,  int outageCount,  String? parentName,  DateTime? lastSampleAt,  List<HealthBucket> buckets)  $default,) {final _that = this;
switch (_that) {
case _HealthTarget():
return $default(_that.id,_that.name,_that.kind,_that.status,_that.uptimePercent,_that.latencyMs,_that.outageCount,_that.parentName,_that.lastSampleAt,_that.buckets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String kind,  HealthStatus status,  double? uptimePercent,  double? latencyMs,  int outageCount,  String? parentName,  DateTime? lastSampleAt,  List<HealthBucket> buckets)?  $default,) {final _that = this;
switch (_that) {
case _HealthTarget() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.status,_that.uptimePercent,_that.latencyMs,_that.outageCount,_that.parentName,_that.lastSampleAt,_that.buckets);case _:
  return null;

}
}

}

/// @nodoc


class _HealthTarget implements HealthTarget {
  const _HealthTarget({required this.id, required this.name, required this.kind, required this.status, this.uptimePercent, this.latencyMs, this.outageCount = 0, this.parentName, this.lastSampleAt,  List<HealthBucket> buckets = const <HealthBucket>[]}): _buckets = buckets;
  

@override final  String id;
@override final  String name;
@override final  String kind;
@override final  HealthStatus status;
@override final  double? uptimePercent;
@override final  double? latencyMs;
@override@JsonKey() final  int outageCount;
@override final  String? parentName;
@override final  DateTime? lastSampleAt;
 final  List<HealthBucket> _buckets;
@override@JsonKey() List<HealthBucket> get buckets {
  if (_buckets is EqualUnmodifiableListView) return _buckets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_buckets);
}


/// Create a copy of HealthTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthTargetCopyWith<_HealthTarget> get copyWith => __$HealthTargetCopyWithImpl<_HealthTarget>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthTarget&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.uptimePercent, uptimePercent) || other.uptimePercent == uptimePercent)&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs)&&(identical(other.outageCount, outageCount) || other.outageCount == outageCount)&&(identical(other.parentName, parentName) || other.parentName == parentName)&&(identical(other.lastSampleAt, lastSampleAt) || other.lastSampleAt == lastSampleAt)&&const DeepCollectionEquality().equals(other.buckets, _buckets));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,kind,status,uptimePercent,latencyMs,outageCount,parentName,lastSampleAt,const DeepCollectionEquality().hash(_buckets));
}

@override
String toString() {
    return 'HealthTarget(id: $id, name: $name, kind: $kind, status: $status, uptimePercent: $uptimePercent, latencyMs: $latencyMs, outageCount: $outageCount, parentName: $parentName, lastSampleAt: $lastSampleAt, buckets: $buckets)';
}


}

/// @nodoc
abstract mixin class _$HealthTargetCopyWith<$Res> implements $HealthTargetCopyWith<$Res> {
  factory _$HealthTargetCopyWith(_HealthTarget value, $Res Function(_HealthTarget) _then) = __$HealthTargetCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String kind, HealthStatus status, double? uptimePercent, double? latencyMs, int outageCount, String? parentName, DateTime? lastSampleAt, List<HealthBucket> buckets
});




}
/// @nodoc
class __$HealthTargetCopyWithImpl<$Res>
    implements _$HealthTargetCopyWith<$Res> {
  __$HealthTargetCopyWithImpl(this._self, this._then);

  final _HealthTarget _self;
  final $Res Function(_HealthTarget) _then;

/// Create a copy of HealthTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? status = null,Object? uptimePercent = freezed,Object? latencyMs = freezed,Object? outageCount = null,Object? parentName = freezed,Object? lastSampleAt = freezed,Object? buckets = null,}) {
  return _then(_HealthTarget(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HealthStatus,uptimePercent: freezed == uptimePercent ? _self.uptimePercent : uptimePercent // ignore: cast_nullable_to_non_nullable
as double?,latencyMs: freezed == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as double?,outageCount: null == outageCount ? _self.outageCount : outageCount // ignore: cast_nullable_to_non_nullable
as int,parentName: freezed == parentName ? _self.parentName : parentName // ignore: cast_nullable_to_non_nullable
as String?,lastSampleAt: freezed == lastSampleAt ? _self.lastSampleAt : lastSampleAt // ignore: cast_nullable_to_non_nullable
as DateTime?,buckets: null == buckets ? _self._buckets : buckets // ignore: cast_nullable_to_non_nullable
as List<HealthBucket>,
  ));
}


}

/// @nodoc
mixin _$Outage {

 String get id; String get targetName; DateTime get startedAt; DateTime? get endedAt; bool get ongoing; String? get causeName;
/// Create a copy of Outage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutageCopyWith<Outage> get copyWith => _$OutageCopyWithImpl<Outage>(this as Outage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Outage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Outage&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.targetName, _this.targetName) || other.targetName == _this.targetName)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.ongoing, _this.ongoing) || other.ongoing == _this.ongoing)&&(identical(other.causeName, _this.causeName) || other.causeName == _this.causeName));
}


@override
int get hashCode {
  final _this = this as Outage;
  return Object.hash(runtimeType,_this.id,_this.targetName,_this.startedAt,_this.endedAt,_this.ongoing,_this.causeName);
}

@override
String toString() {
  final _this = this as Outage;
  return 'Outage(id: ${_this.id}, targetName: ${_this.targetName}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt}, ongoing: ${_this.ongoing}, causeName: ${_this.causeName})';
}


}

/// @nodoc
abstract mixin class $OutageCopyWith<$Res>  {
  factory $OutageCopyWith(Outage value, $Res Function(Outage) _then) = _$OutageCopyWithImpl;
@useResult
$Res call({
 String id, String targetName, DateTime startedAt, DateTime? endedAt, bool ongoing, String? causeName
});




}
/// @nodoc
class _$OutageCopyWithImpl<$Res>
    implements $OutageCopyWith<$Res> {
  _$OutageCopyWithImpl(this._self, this._then);

  final Outage _self;
  final $Res Function(Outage) _then;

/// Create a copy of Outage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? targetName = null,Object? startedAt = null,Object? endedAt = freezed,Object? ongoing = null,Object? causeName = freezed,}) {
  return _then(Outage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetName: null == targetName ? _self.targetName : targetName // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ongoing: null == ongoing ? _self.ongoing : ongoing // ignore: cast_nullable_to_non_nullable
as bool,causeName: freezed == causeName ? _self.causeName : causeName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Outage].
extension OutagePatterns on Outage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Outage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Outage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Outage value)  $default,){
final _that = this;
switch (_that) {
case _Outage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Outage value)?  $default,){
final _that = this;
switch (_that) {
case _Outage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String targetName,  DateTime startedAt,  DateTime? endedAt,  bool ongoing,  String? causeName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Outage() when $default != null:
return $default(_that.id,_that.targetName,_that.startedAt,_that.endedAt,_that.ongoing,_that.causeName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String targetName,  DateTime startedAt,  DateTime? endedAt,  bool ongoing,  String? causeName)  $default,) {final _that = this;
switch (_that) {
case _Outage():
return $default(_that.id,_that.targetName,_that.startedAt,_that.endedAt,_that.ongoing,_that.causeName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String targetName,  DateTime startedAt,  DateTime? endedAt,  bool ongoing,  String? causeName)?  $default,) {final _that = this;
switch (_that) {
case _Outage() when $default != null:
return $default(_that.id,_that.targetName,_that.startedAt,_that.endedAt,_that.ongoing,_that.causeName);case _:
  return null;

}
}

}

/// @nodoc


class _Outage implements Outage {
  const _Outage({required this.id, required this.targetName, required this.startedAt, this.endedAt, this.ongoing = false, this.causeName});
  

@override final  String id;
@override final  String targetName;
@override final  DateTime startedAt;
@override final  DateTime? endedAt;
@override@JsonKey() final  bool ongoing;
@override final  String? causeName;

/// Create a copy of Outage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutageCopyWith<_Outage> get copyWith => __$OutageCopyWithImpl<_Outage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Outage&&(identical(other.id, id) || other.id == id)&&(identical(other.targetName, targetName) || other.targetName == targetName)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.ongoing, ongoing) || other.ongoing == ongoing)&&(identical(other.causeName, causeName) || other.causeName == causeName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,targetName,startedAt,endedAt,ongoing,causeName);
}

@override
String toString() {
    return 'Outage(id: $id, targetName: $targetName, startedAt: $startedAt, endedAt: $endedAt, ongoing: $ongoing, causeName: $causeName)';
}


}

/// @nodoc
abstract mixin class _$OutageCopyWith<$Res> implements $OutageCopyWith<$Res> {
  factory _$OutageCopyWith(_Outage value, $Res Function(_Outage) _then) = __$OutageCopyWithImpl;
@override @useResult
$Res call({
 String id, String targetName, DateTime startedAt, DateTime? endedAt, bool ongoing, String? causeName
});




}
/// @nodoc
class __$OutageCopyWithImpl<$Res>
    implements _$OutageCopyWith<$Res> {
  __$OutageCopyWithImpl(this._self, this._then);

  final _Outage _self;
  final $Res Function(_Outage) _then;

/// Create a copy of Outage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? targetName = null,Object? startedAt = null,Object? endedAt = freezed,Object? ongoing = null,Object? causeName = freezed,}) {
  return _then(_Outage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,targetName: null == targetName ? _self.targetName : targetName // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ongoing: null == ongoing ? _self.ongoing : ongoing // ignore: cast_nullable_to_non_nullable
as bool,causeName: freezed == causeName ? _self.causeName : causeName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$HealthReport {

 List<HealthTarget> get targets; List<Outage> get outages;
/// Create a copy of HealthReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthReportCopyWith<HealthReport> get copyWith => _$HealthReportCopyWithImpl<HealthReport>(this as HealthReport, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HealthReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthReport&&const DeepCollectionEquality().equals(other.targets, _this.targets)&&const DeepCollectionEquality().equals(other.outages, _this.outages));
}


@override
int get hashCode {
  final _this = this as HealthReport;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.targets),const DeepCollectionEquality().hash(_this.outages));
}

@override
String toString() {
  final _this = this as HealthReport;
  return 'HealthReport(targets: ${_this.targets}, outages: ${_this.outages})';
}


}

/// @nodoc
abstract mixin class $HealthReportCopyWith<$Res>  {
  factory $HealthReportCopyWith(HealthReport value, $Res Function(HealthReport) _then) = _$HealthReportCopyWithImpl;
@useResult
$Res call({
 List<HealthTarget> targets, List<Outage> outages
});




}
/// @nodoc
class _$HealthReportCopyWithImpl<$Res>
    implements $HealthReportCopyWith<$Res> {
  _$HealthReportCopyWithImpl(this._self, this._then);

  final HealthReport _self;
  final $Res Function(HealthReport) _then;

/// Create a copy of HealthReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targets = null,Object? outages = null,}) {
  return _then(HealthReport(
targets: null == targets ? _self.targets : targets // ignore: cast_nullable_to_non_nullable
as List<HealthTarget>,outages: null == outages ? _self.outages : outages // ignore: cast_nullable_to_non_nullable
as List<Outage>,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthReport].
extension HealthReportPatterns on HealthReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthReport value)  $default,){
final _that = this;
switch (_that) {
case _HealthReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthReport value)?  $default,){
final _that = this;
switch (_that) {
case _HealthReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HealthTarget> targets,  List<Outage> outages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthReport() when $default != null:
return $default(_that.targets,_that.outages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HealthTarget> targets,  List<Outage> outages)  $default,) {final _that = this;
switch (_that) {
case _HealthReport():
return $default(_that.targets,_that.outages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HealthTarget> targets,  List<Outage> outages)?  $default,) {final _that = this;
switch (_that) {
case _HealthReport() when $default != null:
return $default(_that.targets,_that.outages);case _:
  return null;

}
}

}

/// @nodoc


class _HealthReport implements HealthReport {
  const _HealthReport({required  List<HealthTarget> targets, required  List<Outage> outages}): _targets = targets,_outages = outages;
  

 final  List<HealthTarget> _targets;
@override List<HealthTarget> get targets {
  if (_targets is EqualUnmodifiableListView) return _targets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targets);
}

 final  List<Outage> _outages;
@override List<Outage> get outages {
  if (_outages is EqualUnmodifiableListView) return _outages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_outages);
}


/// Create a copy of HealthReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthReportCopyWith<_HealthReport> get copyWith => __$HealthReportCopyWithImpl<_HealthReport>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthReport&&const DeepCollectionEquality().equals(other.targets, _targets)&&const DeepCollectionEquality().equals(other.outages, _outages));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_targets),const DeepCollectionEquality().hash(_outages));
}

@override
String toString() {
    return 'HealthReport(targets: $targets, outages: $outages)';
}


}

/// @nodoc
abstract mixin class _$HealthReportCopyWith<$Res> implements $HealthReportCopyWith<$Res> {
  factory _$HealthReportCopyWith(_HealthReport value, $Res Function(_HealthReport) _then) = __$HealthReportCopyWithImpl;
@override @useResult
$Res call({
 List<HealthTarget> targets, List<Outage> outages
});




}
/// @nodoc
class __$HealthReportCopyWithImpl<$Res>
    implements _$HealthReportCopyWith<$Res> {
  __$HealthReportCopyWithImpl(this._self, this._then);

  final _HealthReport _self;
  final $Res Function(_HealthReport) _then;

/// Create a copy of HealthReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targets = null,Object? outages = null,}) {
  return _then(_HealthReport(
targets: null == targets ? _self._targets : targets // ignore: cast_nullable_to_non_nullable
as List<HealthTarget>,outages: null == outages ? _self._outages : outages // ignore: cast_nullable_to_non_nullable
as List<Outage>,
  ));
}


}

// dart format on
