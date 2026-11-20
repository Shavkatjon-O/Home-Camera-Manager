import 'dart:io';

import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/demo/fake_backend.dart';
import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/core/config.dart';
import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/core/network/client/http.dart';
import 'package:smart_surveillance/core/storage/preferences.dart';
import 'package:smart_surveillance/features/alerting/data/api_notification_repository.dart';
import 'package:smart_surveillance/features/analytics/data/api_analytics_repository.dart';
import 'package:smart_surveillance/features/devices/data/api_device_repository.dart';
import 'package:smart_surveillance/features/devices/data/api_pairing_repository.dart';
import 'package:smart_surveillance/features/events/data/api_event_repository.dart';
import 'package:smart_surveillance/features/identity/data/api_auth_repository.dart';
import 'package:smart_surveillance/features/identity/data/token_store.dart';
import 'package:smart_surveillance/features/investigation/data/api_people_repository.dart';
import 'package:smart_surveillance/features/investigation/data/api_search_repository.dart';
import 'package:smart_surveillance/features/media/data/api_live_repository.dart';
import 'package:smart_surveillance/features/operations/data/api_health_repository.dart';
import 'package:smart_surveillance/features/tenancy/data/api_tenancy_repository.dart';

/// Builds the backend the build's [config] asks for: the simulated site or the server.
Future<Backend> createBackend(AppConfig config, Preferences preferences) async =>
    config.mode == BackendMode.fake ? fakeBackend(FakeStore()) : apiBackend(config, preferences);

/// Builds the backend that talks to the server at the saved address or [AppConfig.apiUrl].
///
/// Plans, Telegram and the activity log are not in the contract yet, so they
/// stay on the simulated store.
Backend apiBackend(AppConfig config, Preferences preferences) {
  final auth = ApiAuthRepository(
    store: TokenStore(),
    site: () => preferences.siteId,
    platform: Platform.operatingSystem,
  );
  final dio = createDio(preferences.serverUrl ?? config.apiUrl, auth);
  final client = api.SurveillanceApi(dio);
  auth.client = client;
  String base() => dio.options.baseUrl;
  final devices = ApiDeviceRepository(client);
  final business = fakeBackend(FakeStore()).business;
  return Backend(
    auth: auth,
    tenancy: ApiTenancyRepository(client),
    devices: devices,
    pairing: ApiPairingRepository(client, devices),
    live: ApiLiveRepository(client, base),
    events: ApiEventRepository(client, dio, base, () => preferences.siteId),
    analytics: ApiAnalyticsRepository(client, base),
    people: ApiPeopleRepository(client, base),
    search: ApiSearchRepository(client, base),
    health: ApiHealthRepository(client),
    notifications: ApiNotificationRepository(client, preferences),
    business: business,
    demo: false,
    mediaHeaders: () => {
      if (auth.accessToken != null) 'Authorization': 'Bearer ${auth.accessToken}',
      if (preferences.siteId != null) 'X-Site': preferences.siteId!,
    },
    server: base,
    setServer: (url) => dio.options.baseUrl = url,
    expirations: auth.expirations,
  );
}
