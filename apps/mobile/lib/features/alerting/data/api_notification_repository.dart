import 'dart:convert';

import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/core/network/client/http.dart';
import 'package:smart_surveillance/core/storage/preferences.dart';
import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/alerting/domain/notification_repository.dart';

/// Keeps this phone's alert filters on the phone and registers it for push on the server.
///
/// The filters decide which alerts this phone shows, so they belong to the
/// phone rather than to the member's account.
class ApiNotificationRepository implements NotificationRepository {
  /// Creates the repository over [client], keeping filters in [preferences].
  ApiNotificationRepository(this.client, this.preferences);

  /// The generated API.
  final api.SurveillanceApi client;

  /// The phone's settings store.
  final Preferences preferences;

  /// The key the filters of [siteId] are stored under.
  static String keyOf(String siteId) => 'notifications-$siteId';

  @override
  Future<NotificationPrefs> prefs(String siteId) async {
    final raw = preferences.store.getString(keyOf(siteId));
    if (raw == null) return NotificationPrefs(siteId: siteId);
    try {
      final json = jsonDecode(raw) as Map<String, Object?>;
      return NotificationPrefs(
        siteId: siteId,
        enabled: json['enabled'] as bool? ?? true,
        alertsOnly: json['alertsOnly'] as bool? ?? true,
        mutedKinds: {...(json['muted'] as List<Object?>? ?? const []).whereType<String>()},
        quietFrom: json['quietFrom'] as String?,
        quietUntil: json['quietUntil'] as String?,
      );
    } on FormatException {
      return NotificationPrefs(siteId: siteId);
    }
  }

  @override
  Future<NotificationPrefs> savePrefs(NotificationPrefs prefs) async {
    await preferences.store.setString(
      keyOf(prefs.siteId),
      jsonEncode({
        'enabled': prefs.enabled,
        'alertsOnly': prefs.alertsOnly,
        'muted': prefs.mutedKinds.toList(),
        'quietFrom': prefs.quietFrom,
        'quietUntil': prefs.quietUntil,
      }),
    );
    return prefs;
  }

  @override
  Future<void> registerPushTarget({required String provider, required String token}) => guarded(
    () => client.push.registerPushTarget(
      body: api.PushTargetCreate(provider: api.PushProvider.fromJson(provider), token: token),
    ),
  );
}
