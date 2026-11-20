import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/features/alerting/data/fake_notification_repository.dart';
import 'package:smart_surveillance/features/analytics/data/fake_analytics_repository.dart';
import 'package:smart_surveillance/features/billing/data/fake_business_repository.dart';
import 'package:smart_surveillance/features/devices/data/fake_device_repository.dart';
import 'package:smart_surveillance/features/devices/data/fake_pairing_repository.dart';
import 'package:smart_surveillance/features/events/data/fake_event_repository.dart';
import 'package:smart_surveillance/features/identity/data/fake_auth_repository.dart';
import 'package:smart_surveillance/features/investigation/data/fake_people_repository.dart';
import 'package:smart_surveillance/features/investigation/data/fake_search_repository.dart';
import 'package:smart_surveillance/features/media/data/fake_live_repository.dart';
import 'package:smart_surveillance/features/operations/data/fake_health_repository.dart';
import 'package:smart_surveillance/features/tenancy/data/fake_tenancy_repository.dart';
/// Builds a [Backend] whose repositories all read and write the in-memory [store].
Backend fakeBackend(FakeStore store) {
  final events = FakeEventRepository(store);
  final devices = FakeDeviceRepository(store);
  return Backend(
    auth: FakeAuthRepository(store),
    tenancy: FakeTenancyRepository(store),
    devices: devices,
    pairing: FakePairingRepository(store, devices),
    live: FakeLiveRepository(store),
    events: events,
    analytics: FakeAnalyticsRepository(store),
    people: FakePeopleRepository(store),
    search: FakeSearchRepository(store, events),
    health: FakeHealthRepository(store),
    notifications: FakeNotificationRepository(store),
    business: FakeBusinessRepository(store),
    demo: true,
  );
}
