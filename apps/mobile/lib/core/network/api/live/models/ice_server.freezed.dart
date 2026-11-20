// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ice_server.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IceServer {


/// Create a copy of IceServer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IceServerCopyWith<IceServer> get copyWith => _$IceServerCopyWithImpl<IceServer>(this as IceServer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as IceServer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IceServer&&const DeepCollectionEquality().equals(other.urls, _this.urls)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.credential, _this.credential) || other.credential == _this.credential)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as IceServer;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.urls),_this.username,_this.credential,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as IceServer;
  return 'IceServer(urls: ${_this.urls}, username: ${_this.username}, credential: ${_this.credential}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $IceServerCopyWith<$Res>  {
  factory $IceServerCopyWith(IceServer value, $Res Function(IceServer) _then) = _$IceServerCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) List<String> urls,@JsonKey(includeIfNull: false) String? username,@JsonKey(includeIfNull: false) String? credential,@JsonKey(readValue: IceServer._extras, fromJson: IceServer._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$IceServerCopyWithImpl<$Res>
    implements $IceServerCopyWith<$Res> {
  _$IceServerCopyWithImpl(this._self, this._then);

  final IceServer _self;
  final $Res Function(IceServer) _then;

/// Create a copy of IceServer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? urls = null,Object? username = freezed,Object? credential = freezed,Object? additionalProperties = null,}) {
  return _then(IceServer(
urls: null == urls ? _self.urls : urls // ignore: cast_nullable_to_non_nullable
as List<String>,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,credential: freezed == credential ? _self.credential : credential // ignore: cast_nullable_to_non_nullable
as String?,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [IceServer].
extension IceServerPatterns on IceServer {
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
