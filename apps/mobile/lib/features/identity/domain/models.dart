import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
/// A signed-in person.
@freezed
abstract class User with _$User {
  /// Creates the user [id] named [name] with the address [email].
  const factory User({
    required String id,
    required String name,
    required String email,
    @Default(true) bool verified,
  }) = _User;
}

/// The access and refresh tokens of a session.
@freezed
abstract class AuthTokens with _$AuthTokens {
  /// Creates tokens where [access] expires at [accessExpiresAt] and [refresh] renews it.
  const factory AuthTokens({
    required String access,
    required String refresh,
    required String sessionId,
    required DateTime accessExpiresAt,
  }) = _AuthTokens;
}

/// A device that is signed in to an account.
@freezed
abstract class DeviceSession with _$DeviceSession {
  /// Creates the session [id] of the device [deviceName] running [platform].
  const factory DeviceSession({
    required String id,
    required String deviceName,
    required String platform,
    required DateTime createdAt,
    required DateTime lastUsedAt,
    @Default(false) bool current,
  }) = _DeviceSession;
}
