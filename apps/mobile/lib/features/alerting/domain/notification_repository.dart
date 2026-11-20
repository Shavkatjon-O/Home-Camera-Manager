
import 'package:smart_surveillance/features/alerting/domain/models.dart';
abstract interface class NotificationRepository {
  Future<NotificationPrefs> prefs(String siteId);

  Future<NotificationPrefs> savePrefs(NotificationPrefs prefs);

  Future<void> registerPushTarget({required String provider, required String token});
}
