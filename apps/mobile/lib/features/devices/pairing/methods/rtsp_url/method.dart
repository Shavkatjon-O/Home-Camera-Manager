import 'package:flutter/material.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/rtsp_url/screen.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// Adds a camera from a pasted RTSP stream link.
class RtspUrlMethod extends PairingMethod {
  /// Creates the method.
  const RtspUrlMethod();

  @override
  String get id => 'rtsp_url';

  @override
  PairingTarget get target => PairingTarget.camera;

  @override
  IconData get icon => Icons.link_rounded;

  @override
  bool supported(PairingContext context) => context.hasConnector;

  @override
  String title(AppLocalizations l10n) => l10n.methodRtspUrl;

  @override
  String subtitle(AppLocalizations l10n) => l10n.methodRtspUrlBody;

  @override
  Widget flow(PairingContext context, PairingSession session) =>
      RtspUrlScreen(pairing: context, session: session);
}
