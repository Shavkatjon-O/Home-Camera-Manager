import 'package:flutter/material.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/connector_qr/screen.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// Pairs a connector by scanning the QR code it shows.
class ConnectorQrMethod extends PairingMethod {
  /// Creates the method.
  const ConnectorQrMethod();

  @override
  String get id => 'connector_qr';

  @override
  PairingTarget get target => PairingTarget.connector;

  @override
  IconData get icon => Icons.qr_code_scanner_rounded;

  @override
  Set<PairingPermission> get requirements => const {PairingPermission.camera};

  @override
  bool supported(PairingContext context) => true;

  @override
  String title(AppLocalizations l10n) => l10n.methodConnectorQr;

  @override
  String subtitle(AppLocalizations l10n) => l10n.methodConnectorQrBody;

  @override
  Widget flow(PairingContext context, PairingSession session) => ConnectorQrScreen(pairing: context, session: session);
}
