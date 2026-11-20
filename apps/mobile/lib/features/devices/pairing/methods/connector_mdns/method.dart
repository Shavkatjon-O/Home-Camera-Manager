import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/connector_mdns/screen.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// Pairs a connector found on the same Wi-Fi through its _sss-connector._tcp service.
class ConnectorMdnsMethod extends PairingMethod {
  /// Creates the method.
  const ConnectorMdnsMethod();

  @override
  String get id => 'connector_mdns';

  @override
  PairingTarget get target => PairingTarget.connector;

  @override
  IconData get icon => Icons.wifi_find_rounded;

  @override
  bool supported(PairingContext context) =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  String title(AppLocalizations l10n) => l10n.methodConnectorMdns;

  @override
  String subtitle(AppLocalizations l10n) => l10n.methodConnectorMdnsBody;

  @override
  Widget flow(PairingContext context, PairingSession session) =>
      ConnectorMdnsScreen(pairing: context, session: session);
}
