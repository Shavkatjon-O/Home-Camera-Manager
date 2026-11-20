import 'package:flutter/material.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/manual_host/screen.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// Adds a camera by its address, which the connector identifies.
class ManualHostMethod extends PairingMethod {
  /// Creates the method.
  const ManualHostMethod();

  @override
  String get id => 'manual_host';

  @override
  PairingTarget get target => PairingTarget.camera;

  @override
  IconData get icon => Icons.edit_location_alt_outlined;

  @override
  bool supported(PairingContext context) => context.hasConnector;

  @override
  String title(AppLocalizations l10n) => l10n.methodManualHost;

  @override
  String subtitle(AppLocalizations l10n) => l10n.methodManualHostBody;

  @override
  Widget flow(PairingContext context, PairingSession session) =>
      ManualHostScreen(pairing: context, session: session);
}
