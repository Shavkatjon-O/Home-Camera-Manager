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
mixin _$NotificationPrefs {

 String get siteId; bool get enabled; bool get alertsOnly; Set<String> get mutedKinds; String? get quietFrom; String? get quietUntil;
/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPrefsCopyWith<NotificationPrefs> get copyWith => _$NotificationPrefsCopyWithImpl<NotificationPrefs>(this as NotificationPrefs, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NotificationPrefs;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPrefs&&(identical(other.siteId, _this.siteId) || other.siteId == _this.siteId)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.alertsOnly, _this.alertsOnly) || other.alertsOnly == _this.alertsOnly)&&const DeepCollectionEquality().equals(other.mutedKinds, _this.mutedKinds)&&(identical(other.quietFrom, _this.quietFrom) || other.quietFrom == _this.quietFrom)&&(identical(other.quietUntil, _this.quietUntil) || other.quietUntil == _this.quietUntil));
}


@override
int get hashCode {
  final _this = this as NotificationPrefs;
  return Object.hash(runtimeType,_this.siteId,_this.enabled,_this.alertsOnly,const DeepCollectionEquality().hash(_this.mutedKinds),_this.quietFrom,_this.quietUntil);
}

@override
String toString() {
  final _this = this as NotificationPrefs;
  return 'NotificationPrefs(siteId: ${_this.siteId}, enabled: ${_this.enabled}, alertsOnly: ${_this.alertsOnly}, mutedKinds: ${_this.mutedKinds}, quietFrom: ${_this.quietFrom}, quietUntil: ${_this.quietUntil})';
}


}

/// @nodoc
abstract mixin class $NotificationPrefsCopyWith<$Res>  {
  factory $NotificationPrefsCopyWith(NotificationPrefs value, $Res Function(NotificationPrefs) _then) = _$NotificationPrefsCopyWithImpl;
@useResult
$Res call({
 String siteId, bool enabled, bool alertsOnly, Set<String> mutedKinds, String? quietFrom, String? quietUntil
});




}
/// @nodoc
class _$NotificationPrefsCopyWithImpl<$Res>
    implements $NotificationPrefsCopyWith<$Res> {
  _$NotificationPrefsCopyWithImpl(this._self, this._then);

  final NotificationPrefs _self;
  final $Res Function(NotificationPrefs) _then;

/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? siteId = null,Object? enabled = null,Object? alertsOnly = null,Object? mutedKinds = null,Object? quietFrom = freezed,Object? quietUntil = freezed,}) {
  return _then(NotificationPrefs(
siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,alertsOnly: null == alertsOnly ? _self.alertsOnly : alertsOnly // ignore: cast_nullable_to_non_nullable
as bool,mutedKinds: null == mutedKinds ? _self.mutedKinds : mutedKinds // ignore: cast_nullable_to_non_nullable
as Set<String>,quietFrom: freezed == quietFrom ? _self.quietFrom : quietFrom // ignore: cast_nullable_to_non_nullable
as String?,quietUntil: freezed == quietUntil ? _self.quietUntil : quietUntil // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPrefs].
extension NotificationPrefsPatterns on NotificationPrefs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPrefs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPrefs value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPrefs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPrefs value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String siteId,  bool enabled,  bool alertsOnly,  Set<String> mutedKinds,  String? quietFrom,  String? quietUntil)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
return $default(_that.siteId,_that.enabled,_that.alertsOnly,_that.mutedKinds,_that.quietFrom,_that.quietUntil);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String siteId,  bool enabled,  bool alertsOnly,  Set<String> mutedKinds,  String? quietFrom,  String? quietUntil)  $default,) {final _that = this;
switch (_that) {
case _NotificationPrefs():
return $default(_that.siteId,_that.enabled,_that.alertsOnly,_that.mutedKinds,_that.quietFrom,_that.quietUntil);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String siteId,  bool enabled,  bool alertsOnly,  Set<String> mutedKinds,  String? quietFrom,  String? quietUntil)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
return $default(_that.siteId,_that.enabled,_that.alertsOnly,_that.mutedKinds,_that.quietFrom,_that.quietUntil);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationPrefs implements NotificationPrefs {
  const _NotificationPrefs({required this.siteId, this.enabled = true, this.alertsOnly = true,  Set<String> mutedKinds = const <String>{}, this.quietFrom, this.quietUntil}): _mutedKinds = mutedKinds;
  

@override final  String siteId;
@override@JsonKey() final  bool enabled;
@override@JsonKey() final  bool alertsOnly;
 final  Set<String> _mutedKinds;
@override@JsonKey() Set<String> get mutedKinds {
  if (_mutedKinds is EqualUnmodifiableSetView) return _mutedKinds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_mutedKinds);
}

@override final  String? quietFrom;
@override final  String? quietUntil;

/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPrefsCopyWith<_NotificationPrefs> get copyWith => __$NotificationPrefsCopyWithImpl<_NotificationPrefs>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPrefs&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.alertsOnly, alertsOnly) || other.alertsOnly == alertsOnly)&&const DeepCollectionEquality().equals(other.mutedKinds, _mutedKinds)&&(identical(other.quietFrom, quietFrom) || other.quietFrom == quietFrom)&&(identical(other.quietUntil, quietUntil) || other.quietUntil == quietUntil));
}


@override
int get hashCode {
    return Object.hash(runtimeType,siteId,enabled,alertsOnly,const DeepCollectionEquality().hash(_mutedKinds),quietFrom,quietUntil);
}

@override
String toString() {
    return 'NotificationPrefs(siteId: $siteId, enabled: $enabled, alertsOnly: $alertsOnly, mutedKinds: $mutedKinds, quietFrom: $quietFrom, quietUntil: $quietUntil)';
}


}

/// @nodoc
abstract mixin class _$NotificationPrefsCopyWith<$Res> implements $NotificationPrefsCopyWith<$Res> {
  factory _$NotificationPrefsCopyWith(_NotificationPrefs value, $Res Function(_NotificationPrefs) _then) = __$NotificationPrefsCopyWithImpl;
@override @useResult
$Res call({
 String siteId, bool enabled, bool alertsOnly, Set<String> mutedKinds, String? quietFrom, String? quietUntil
});




}
/// @nodoc
class __$NotificationPrefsCopyWithImpl<$Res>
    implements _$NotificationPrefsCopyWith<$Res> {
  __$NotificationPrefsCopyWithImpl(this._self, this._then);

  final _NotificationPrefs _self;
  final $Res Function(_NotificationPrefs) _then;

/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? siteId = null,Object? enabled = null,Object? alertsOnly = null,Object? mutedKinds = null,Object? quietFrom = freezed,Object? quietUntil = freezed,}) {
  return _then(_NotificationPrefs(
siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,alertsOnly: null == alertsOnly ? _self.alertsOnly : alertsOnly // ignore: cast_nullable_to_non_nullable
as bool,mutedKinds: null == mutedKinds ? _self._mutedKinds : mutedKinds // ignore: cast_nullable_to_non_nullable
as Set<String>,quietFrom: freezed == quietFrom ? _self.quietFrom : quietFrom // ignore: cast_nullable_to_non_nullable
as String?,quietUntil: freezed == quietUntil ? _self.quietUntil : quietUntil // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$TelegramChat {

 String get id; String get title; bool get group; DateTime get linkedAt; String? get linkedBy;
/// Create a copy of TelegramChat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TelegramChatCopyWith<TelegramChat> get copyWith => _$TelegramChatCopyWithImpl<TelegramChat>(this as TelegramChat, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TelegramChat;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TelegramChat&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.group, _this.group) || other.group == _this.group)&&(identical(other.linkedAt, _this.linkedAt) || other.linkedAt == _this.linkedAt)&&(identical(other.linkedBy, _this.linkedBy) || other.linkedBy == _this.linkedBy));
}


@override
int get hashCode {
  final _this = this as TelegramChat;
  return Object.hash(runtimeType,_this.id,_this.title,_this.group,_this.linkedAt,_this.linkedBy);
}

@override
String toString() {
  final _this = this as TelegramChat;
  return 'TelegramChat(id: ${_this.id}, title: ${_this.title}, group: ${_this.group}, linkedAt: ${_this.linkedAt}, linkedBy: ${_this.linkedBy})';
}


}

/// @nodoc
abstract mixin class $TelegramChatCopyWith<$Res>  {
  factory $TelegramChatCopyWith(TelegramChat value, $Res Function(TelegramChat) _then) = _$TelegramChatCopyWithImpl;
@useResult
$Res call({
 String id, String title, bool group, DateTime linkedAt, String? linkedBy
});




}
/// @nodoc
class _$TelegramChatCopyWithImpl<$Res>
    implements $TelegramChatCopyWith<$Res> {
  _$TelegramChatCopyWithImpl(this._self, this._then);

  final TelegramChat _self;
  final $Res Function(TelegramChat) _then;

/// Create a copy of TelegramChat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? group = null,Object? linkedAt = null,Object? linkedBy = freezed,}) {
  return _then(TelegramChat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as bool,linkedAt: null == linkedAt ? _self.linkedAt : linkedAt // ignore: cast_nullable_to_non_nullable
as DateTime,linkedBy: freezed == linkedBy ? _self.linkedBy : linkedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TelegramChat].
extension TelegramChatPatterns on TelegramChat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TelegramChat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TelegramChat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TelegramChat value)  $default,){
final _that = this;
switch (_that) {
case _TelegramChat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TelegramChat value)?  $default,){
final _that = this;
switch (_that) {
case _TelegramChat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  bool group,  DateTime linkedAt,  String? linkedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TelegramChat() when $default != null:
return $default(_that.id,_that.title,_that.group,_that.linkedAt,_that.linkedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  bool group,  DateTime linkedAt,  String? linkedBy)  $default,) {final _that = this;
switch (_that) {
case _TelegramChat():
return $default(_that.id,_that.title,_that.group,_that.linkedAt,_that.linkedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  bool group,  DateTime linkedAt,  String? linkedBy)?  $default,) {final _that = this;
switch (_that) {
case _TelegramChat() when $default != null:
return $default(_that.id,_that.title,_that.group,_that.linkedAt,_that.linkedBy);case _:
  return null;

}
}

}

/// @nodoc


class _TelegramChat implements TelegramChat {
  const _TelegramChat({required this.id, required this.title, this.group = false, required this.linkedAt, this.linkedBy});
  

@override final  String id;
@override final  String title;
@override@JsonKey() final  bool group;
@override final  DateTime linkedAt;
@override final  String? linkedBy;

/// Create a copy of TelegramChat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TelegramChatCopyWith<_TelegramChat> get copyWith => __$TelegramChatCopyWithImpl<_TelegramChat>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TelegramChat&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.group, group) || other.group == group)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt)&&(identical(other.linkedBy, linkedBy) || other.linkedBy == linkedBy));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,group,linkedAt,linkedBy);
}

@override
String toString() {
    return 'TelegramChat(id: $id, title: $title, group: $group, linkedAt: $linkedAt, linkedBy: $linkedBy)';
}


}

/// @nodoc
abstract mixin class _$TelegramChatCopyWith<$Res> implements $TelegramChatCopyWith<$Res> {
  factory _$TelegramChatCopyWith(_TelegramChat value, $Res Function(_TelegramChat) _then) = __$TelegramChatCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, bool group, DateTime linkedAt, String? linkedBy
});




}
/// @nodoc
class __$TelegramChatCopyWithImpl<$Res>
    implements _$TelegramChatCopyWith<$Res> {
  __$TelegramChatCopyWithImpl(this._self, this._then);

  final _TelegramChat _self;
  final $Res Function(_TelegramChat) _then;

/// Create a copy of TelegramChat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? group = null,Object? linkedAt = null,Object? linkedBy = freezed,}) {
  return _then(_TelegramChat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as bool,linkedAt: null == linkedAt ? _self.linkedAt : linkedAt // ignore: cast_nullable_to_non_nullable
as DateTime,linkedBy: freezed == linkedBy ? _self.linkedBy : linkedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$TelegramLink {

 String get url; DateTime get expiresAt;
/// Create a copy of TelegramLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TelegramLinkCopyWith<TelegramLink> get copyWith => _$TelegramLinkCopyWithImpl<TelegramLink>(this as TelegramLink, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TelegramLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TelegramLink&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}


@override
int get hashCode {
  final _this = this as TelegramLink;
  return Object.hash(runtimeType,_this.url,_this.expiresAt);
}

@override
String toString() {
  final _this = this as TelegramLink;
  return 'TelegramLink(url: ${_this.url}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $TelegramLinkCopyWith<$Res>  {
  factory $TelegramLinkCopyWith(TelegramLink value, $Res Function(TelegramLink) _then) = _$TelegramLinkCopyWithImpl;
@useResult
$Res call({
 String url, DateTime expiresAt
});




}
/// @nodoc
class _$TelegramLinkCopyWithImpl<$Res>
    implements $TelegramLinkCopyWith<$Res> {
  _$TelegramLinkCopyWithImpl(this._self, this._then);

  final TelegramLink _self;
  final $Res Function(TelegramLink) _then;

/// Create a copy of TelegramLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? expiresAt = null,}) {
  return _then(TelegramLink(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TelegramLink].
extension TelegramLinkPatterns on TelegramLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TelegramLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TelegramLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TelegramLink value)  $default,){
final _that = this;
switch (_that) {
case _TelegramLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TelegramLink value)?  $default,){
final _that = this;
switch (_that) {
case _TelegramLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TelegramLink() when $default != null:
return $default(_that.url,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _TelegramLink():
return $default(_that.url,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _TelegramLink() when $default != null:
return $default(_that.url,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _TelegramLink implements TelegramLink {
  const _TelegramLink({required this.url, required this.expiresAt});
  

@override final  String url;
@override final  DateTime expiresAt;

/// Create a copy of TelegramLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TelegramLinkCopyWith<_TelegramLink> get copyWith => __$TelegramLinkCopyWithImpl<_TelegramLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TelegramLink&&(identical(other.url, url) || other.url == url)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,url,expiresAt);
}

@override
String toString() {
    return 'TelegramLink(url: $url, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$TelegramLinkCopyWith<$Res> implements $TelegramLinkCopyWith<$Res> {
  factory _$TelegramLinkCopyWith(_TelegramLink value, $Res Function(_TelegramLink) _then) = __$TelegramLinkCopyWithImpl;
@override @useResult
$Res call({
 String url, DateTime expiresAt
});




}
/// @nodoc
class __$TelegramLinkCopyWithImpl<$Res>
    implements _$TelegramLinkCopyWith<$Res> {
  __$TelegramLinkCopyWithImpl(this._self, this._then);

  final _TelegramLink _self;
  final $Res Function(_TelegramLink) _then;

/// Create a copy of TelegramLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? expiresAt = null,}) {
  return _then(_TelegramLink(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
