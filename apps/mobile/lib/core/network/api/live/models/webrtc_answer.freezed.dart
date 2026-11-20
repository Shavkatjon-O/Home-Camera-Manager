// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'webrtc_answer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WebrtcAnswer {


/// Create a copy of WebrtcAnswer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebrtcAnswerCopyWith<WebrtcAnswer> get copyWith => _$WebrtcAnswerCopyWithImpl<WebrtcAnswer>(this as WebrtcAnswer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WebrtcAnswer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebrtcAnswer&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.sdp, _this.sdp) || other.sdp == _this.sdp)&&(identical(other.stream, _this.stream) || other.stream == _this.stream)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as WebrtcAnswer;
  return Object.hash(runtimeType,_this.type,_this.sdp,_this.stream,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as WebrtcAnswer;
  return 'WebrtcAnswer(type: ${_this.type}, sdp: ${_this.sdp}, stream: ${_this.stream}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $WebrtcAnswerCopyWith<$Res>  {
  factory $WebrtcAnswerCopyWith(WebrtcAnswer value, $Res Function(WebrtcAnswer) _then) = _$WebrtcAnswerCopyWithImpl;
@useResult
$Res call({
@JsonKey(disallowNullValue: true, readValue: WebrtcAnswer._presentValue, fromJson: WebrtcAnswer._read_type, toJson: WebrtcAnswer._write_type) String type,@JsonKey(required: true, disallowNullValue: true) String sdp,@JsonKey(required: true, disallowNullValue: true, fromJson: WebrtcAnswer._read_stream, toJson: WebrtcAnswer._write_stream) ViewStream stream,@JsonKey(readValue: WebrtcAnswer._extras, fromJson: WebrtcAnswer._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$WebrtcAnswerCopyWithImpl<$Res>
    implements $WebrtcAnswerCopyWith<$Res> {
  _$WebrtcAnswerCopyWithImpl(this._self, this._then);

  final WebrtcAnswer _self;
  final $Res Function(WebrtcAnswer) _then;

/// Create a copy of WebrtcAnswer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? sdp = null,Object? stream = null,Object? additionalProperties = null,}) {
  return _then(WebrtcAnswer(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,sdp: null == sdp ? _self.sdp : sdp // ignore: cast_nullable_to_non_nullable
as String,stream: null == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as ViewStream,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [WebrtcAnswer].
extension WebrtcAnswerPatterns on WebrtcAnswer {
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
