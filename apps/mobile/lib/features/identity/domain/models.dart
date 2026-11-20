import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    @Default(true) bool verified,
  }) = _User;
}

@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String access,
    required String refresh,
    required String sessionId,
    required DateTime accessExpiresAt,
  }) = _AuthTokens;
}

@freezed
abstract class DeviceSession with _$DeviceSession {
  const factory DeviceSession({
    required String id,
    required String deviceName,
    required String platform,
    required DateTime createdAt,
    required DateTime lastUsedAt,
    @Default(false) bool current,
  }) = _DeviceSession;
}
