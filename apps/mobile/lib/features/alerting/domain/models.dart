import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';

/// How a site's cameras react to activity.
enum ArmMode {
  /// Alerts are off.
  disarmed,

  /// Alerts are on while people are at home.
  home,

  /// Alerts are on while nobody is home.
  away,

  /// Alerts follow a weekly schedule.
  schedule,
}

/// A user's notification preferences for one site.
@freezed
abstract class NotificationPrefs with _$NotificationPrefs {
  /// Creates preferences for the site [siteId].
  const factory NotificationPrefs({
    required String siteId,
    @Default(true) bool enabled,
    @Default(true) bool alertsOnly,
    @Default(<String>{}) Set<String> mutedKinds,
    String? quietFrom,
    String? quietUntil,
  }) = _NotificationPrefs;
}

/// A Telegram chat linked to a site to receive alerts.
@freezed
abstract class TelegramChat with _$TelegramChat {
  /// Creates a linked chat with the Telegram id [id] and the display name [title].
  const factory TelegramChat({
    required String id,
    required String title,
    @Default(false) bool group,
    required DateTime linkedAt,
    String? linkedBy,
  }) = _TelegramChat;
}

/// A one-time link that connects a Telegram chat to a site.
@freezed
abstract class TelegramLink with _$TelegramLink {
  /// Creates a link that opens at [url] and stops working at [expiresAt].
  const factory TelegramLink({required String url, required DateTime expiresAt}) = _TelegramLink;
}
