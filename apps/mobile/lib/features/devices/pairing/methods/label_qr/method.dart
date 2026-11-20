import 'package:flutter/material.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/label_qr/screen.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// Scans the QR code on a camera's label and continues with the method the server picks for that model.
class LabelQrMethod extends PairingMethod {
  /// Creates the method.
  const LabelQrMethod();

  @override
  String get id => 'label_qr';

  @override
  PairingTarget get target => PairingTarget.camera;

  @override
  IconData get icon => Icons.qr_code_2_rounded;

  @override
  Set<PairingPermission> get requirements => const {PairingPermission.camera};

  @override
  bool supported(PairingContext context) => true;

  @override
  String title(AppLocalizations l10n) => l10n.methodLabelQr;

  @override
  String subtitle(AppLocalizations l10n) => l10n.methodLabelQrBody;

  @override
  Widget flow(PairingContext context, PairingSession session) =>
      LabelQrScreen(pairing: context, session: session);
}
