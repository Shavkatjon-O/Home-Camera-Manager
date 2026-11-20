import 'package:flutter/material.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/nvr_import/screen.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// Adds several channels of a recorder at once.
class NvrImportMethod extends PairingMethod {
  /// Creates the method.
  const NvrImportMethod();

  @override
  String get id => 'nvr_import';

  @override
  PairingTarget get target => PairingTarget.camera;

  @override
  IconData get icon => Icons.dns_outlined;

  @override
  bool supported(PairingContext context) => context.hasConnector;

  @override
  String title(AppLocalizations l10n) => l10n.methodNvrImport;

  @override
  String subtitle(AppLocalizations l10n) => l10n.methodNvrImportBody;

  @override
  Widget flow(PairingContext context, PairingSession session) =>
      NvrImportScreen(pairing: context, session: session);
}
