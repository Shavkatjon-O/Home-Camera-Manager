// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_read.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MemberRead {


/// Create a copy of MemberRead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberReadCopyWith<MemberRead> get copyWith => _$MemberReadCopyWithImpl<MemberRead>(this as MemberRead, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MemberRead;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberRead&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.allSites, _this.allSites) || other.allSites == _this.allSites)&&const DeepCollectionEquality().equals(other.sites, _this.sites)&&(identical(other.joinedAt, _this.joinedAt) || other.joinedAt == _this.joinedAt)&&(identical(other.you, _this.you) || other.you == _this.you)&&const DeepCollectionEquality().equals(other.additionalProperties, _this.additionalProperties));
}


@override
int get hashCode {
  final _this = this as MemberRead;
  return Object.hash(runtimeType,_this.uuid,_this.user,_this.email,_this.name,_this.role,_this.allSites,const DeepCollectionEquality().hash(_this.sites),_this.joinedAt,_this.you,const DeepCollectionEquality().hash(_this.additionalProperties));
}

@override
String toString() {
  final _this = this as MemberRead;
  return 'MemberRead(uuid: ${_this.uuid}, user: ${_this.user}, email: ${_this.email}, name: ${_this.name}, role: ${_this.role}, allSites: ${_this.allSites}, sites: ${_this.sites}, joinedAt: ${_this.joinedAt}, you: ${_this.you}, additionalProperties: ${_this.additionalProperties})';
}


}

/// @nodoc
abstract mixin class $MemberReadCopyWith<$Res>  {
  factory $MemberReadCopyWith(MemberRead value, $Res Function(MemberRead) _then) = _$MemberReadCopyWithImpl;
@useResult
$Res call({
@JsonKey(required: true, disallowNullValue: true) String uuid,@JsonKey(required: true, disallowNullValue: true) String user,@JsonKey(required: true) String? email,@JsonKey(required: true) String? name,@JsonKey(required: true, disallowNullValue: true, fromJson: MemberRead._read_role, toJson: MemberRead._write_role) Role role,@JsonKey(name: "all_sites", required: true, disallowNullValue: true) bool allSites,@JsonKey(required: true, disallowNullValue: true) List<String> sites,@JsonKey(name: "joined_at", required: true, disallowNullValue: true, fromJson: MemberRead._read_joinedAt, toJson: MemberRead._write_joinedAt) DateTime joinedAt,@JsonKey(required: true, disallowNullValue: true) bool you,@JsonKey(readValue: MemberRead._extras, fromJson: MemberRead._readExtras, includeToJson: false) Map<String, Object?> additionalProperties
});




}
/// @nodoc
class _$MemberReadCopyWithImpl<$Res>
    implements $MemberReadCopyWith<$Res> {
  _$MemberReadCopyWithImpl(this._self, this._then);

  final MemberRead _self;
  final $Res Function(MemberRead) _then;

/// Create a copy of MemberRead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? user = null,Object? email = freezed,Object? name = freezed,Object? role = null,Object? allSites = null,Object? sites = null,Object? joinedAt = null,Object? you = null,Object? additionalProperties = null,}) {
  return _then(MemberRead(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,allSites: null == allSites ? _self.allSites : allSites // ignore: cast_nullable_to_non_nullable
as bool,sites: null == sites ? _self.sites : sites // ignore: cast_nullable_to_non_nullable
as List<String>,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,you: null == you ? _self.you : you // ignore: cast_nullable_to_non_nullable
as bool,additionalProperties: null == additionalProperties ? _self.additionalProperties : additionalProperties // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberRead].
extension MemberReadPatterns on MemberRead {
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
