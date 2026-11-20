import 'package:flutter/material.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/connector_code/screen.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// Pairs a connector by typing the code it shows.
class ConnectorCodeMethod extends PairingMethod {
  /// Creates the method.
  const ConnectorCodeMethod();

  @override
  String get id => 'connector_code';

  @override
  PairingTarget get target => PairingTarget.connector;

  @override
  IconData get icon => Icons.pin_outlined;

  @override
  bool supported(PairingContext context) => true;

  @override
  String title(AppLocalizations l10n) => l10n.methodConnectorCode;

  @override
  String subtitle(AppLocalizations l10n) => l10n.methodConnectorCodeBody;

  @override
  Widget flow(PairingContext context, PairingSession session) => ConnectorCodeScreen(pairing: context, session: session);
}
