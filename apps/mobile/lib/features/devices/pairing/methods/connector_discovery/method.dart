import 'package:flutter/material.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/connector_discovery/screen.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// Adds a camera from the list the site's connector found on its network.
class ConnectorDiscoveryMethod extends PairingMethod {
  /// Creates the method.
  const ConnectorDiscoveryMethod();

  @override
  String get id => 'connector_discovery';

  @override
  PairingTarget get target => PairingTarget.camera;

  @override
  IconData get icon => Icons.radar_rounded;

  @override
  bool supported(PairingContext context) => context.hasConnector;

  @override
  String title(AppLocalizations l10n) => l10n.methodConnectorDiscovery;

  @override
  String subtitle(AppLocalizations l10n) => l10n.methodConnectorDiscoveryBody;

  @override
  Widget flow(PairingContext context, PairingSession session) =>
      DiscoveredCamerasScreen(pairing: context, session: session);
}
