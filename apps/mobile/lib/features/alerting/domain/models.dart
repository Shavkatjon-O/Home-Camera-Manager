import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
enum ArmMode { disarmed, home, away, schedule }

@freezed
abstract class NotificationPrefs with _$NotificationPrefs {
  const factory NotificationPrefs({
    required String siteId,
    @Default(true) bool enabled,
    @Default(true) bool alertsOnly,
    @Default(<String>{}) Set<String> mutedKinds,
    String? quietFrom,
    String? quietUntil,
  }) = _NotificationPrefs;
}

@freezed
abstract class TelegramChat with _$TelegramChat {
  const factory TelegramChat({
    required String id,
    required String title,
    @Default(false) bool group,
    required DateTime linkedAt,
    String? linkedBy,
  }) = _TelegramChat;
}

@freezed
abstract class TelegramLink with _$TelegramLink {
  const factory TelegramLink({required String url, required DateTime expiresAt}) = _TelegramLink;
}
