import 'dart:async';

import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/alerting/domain/notification_repository.dart';
class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository(this.store);

  final FakeStore store;

  @override
  Future<NotificationPrefs> prefs(String siteId) =>
      store.delay(() => store.data.prefs[siteId] ?? NotificationPrefs(siteId: siteId));

  @override
  Future<NotificationPrefs> savePrefs(NotificationPrefs prefs) => store.delay(() {
    store.data.prefs[prefs.siteId] = prefs;
    return prefs;
  });

  @override
  Future<void> registerPushTarget({required String provider, required String token}) => store.delay(() {});
}
