import 'package:smart_surveillance/features/alerting/domain/models.dart';

/// Reads and saves notification preferences and registers push targets.
abstract interface class NotificationRepository {
  /// Returns the notification preferences of the site [siteId].
  Future<NotificationPrefs> prefs(String siteId);

  /// Saves [prefs] and returns the stored preferences.
  Future<NotificationPrefs> savePrefs(NotificationPrefs prefs);

  /// Registers the push [token] issued by [provider] so alerts reach this device.
  Future<void> registerPushTarget({required String provider, required String token});
}
