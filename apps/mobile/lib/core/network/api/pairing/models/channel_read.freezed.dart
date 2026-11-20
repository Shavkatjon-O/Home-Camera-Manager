// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'channel_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChannelRead {


/// Create a copy of ChannelRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelReadCopyWith<ChannelRead> get copyWith => _$ChannelReadCopyWithImpl<ChannelRead>(this as ChannelRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChannelRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelRead&&(identical(other.index, _this.index) || other.index == _this.index)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.mainPath, _this.mainPath) || other.mainPath == _this.mainPath)&&(identical(other.subPath, _this.subPath) || other.subPath == _this.subPath)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.encoding, _this.encoding) || other.encoding == _this.encoding)&&(identical(other.ptz, _this.ptz) || other.ptz == _this.ptz)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as ChannelRead;
  return Object.hash(runtimeType,_this.index,_this.name,_this.mainPath,_this.subPath,_this.width,_this.height,_this.encoding,_this.ptz,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as ChannelRead;
  return 'ChannelRead(index: ${_this.index}, name: ${_this.name}, mainPath: ${_this.mainPath}, subPath: ${_this.subPath}, width: ${_this.width}, height: ${_this.height}, encoding: ${_this.encoding}, ptz: ${_this.ptz}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $ChannelReadCopyWith<$Res>  {
  factory $ChannelReadCopyWith(ChannelRead value, $Res Function(ChannelRead) _then) = _$ChannelReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true, fromJson: ChannelRead._read_index, toJson: ChannelRead._write_index) int index,@JsonKey(required: true, disallowNullValue: true) String name,@JsonKey(name: "main_path", required: true) String? mainPath,@JsonKey(name: "sub_path", required: true) String? subPath,@JsonKey(required: true, fromJson: ChannelRead._read_width, toJson: ChannelRead._write_width) int? width,@JsonKey(required: true, fromJson: ChannelRead._read_height, toJson: ChannelRead._write_height) int? height,@JsonKey(required: true) String? encoding,@JsonKey(required: true, disallowNullValue: true) bool ptz,@JsonKey(readValue: ChannelRead._extras, fromJson: ChannelRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$ChannelReadCopyWithImpl<$Res>
    implements $ChannelReadCopyWith<$Res> {
  _$ChannelReadCopyWithImpl(this._self, this._then);

  final ChannelRead _self;
  final $Res Function(ChannelRead) _then;

/// Create a copy of ChannelRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? name = null,Object? mainPath = freezed,Object? subPath = freezed,Object? width = freezed,Object? height = freezed,Object? encoding = freezed,Object? ptz = null,Object? additionalProperties = null,}) {
  return _then(ChannelRead(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mainPath: freezed == mainPath ? _self.mainPath : mainPath // ignore: cast_nullable_to_non_nullable
as String?,subPath: freezed == subPath ? _self.subPath : subPath // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,encoding: freezed == encoding ? _self.encoding : encoding // ignore: cast_nullable_to_non_nullable
as String?,ptz: null == ptz ? _self.ptz : ptz // ignore: cast_nullable_to_non_nullable
as bool,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChannelRead].
extension ChannelReadPatterns on ChannelRead {
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
