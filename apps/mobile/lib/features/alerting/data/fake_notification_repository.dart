import 'dart:async';

import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/alerting/domain/notification_repository.dart';
/// An in-memory notification repository backed by a [FakeStore].
class FakeNotificationRepository implements NotificationRepository {
  /// Creates a repository that keeps its data in [store].
  FakeNotificationRepository(this.store);

  /// The shared fake data store.
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
