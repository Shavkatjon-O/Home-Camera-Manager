import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/features/devices/pairing/common/claim.dart';
import 'package:smart_surveillance/features/devices/pairing/common/qr_scanner.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// Pairs a connector by scanning the QR code it shows.
class ConnectorQrScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const ConnectorQrScreen({super.key, required this.pairing, required this.session});

  /// The pairing context.
  final PairingContext pairing;

  /// The attempt being reported.
  final PairingSession session;

  @override
  ConsumerState<ConnectorQrScreen> createState() => _ConnectorQrScreenState();
}

class _ConnectorQrScreenState extends ConsumerState<ConnectorQrScreen> {
  int attempt = 0;

  Future<void> scanned(String value) async {
    final navigator = Navigator.of(context);
    try {
      final connector = await claim(ref, widget.pairing, widget.session, value);
      navigator.pop(ConnectorPaired(connector));
    } catch (failure) {
      if (!mounted) return;
      showFailure(context, failure);
      setState(() => attempt++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    widget.session.step('scan');
    return QrScanner(
      key: ValueKey(attempt),
      title: l10n.scanTitle,
      hint: l10n.scanHint,
      demoValue: 'https://demo.invalid/connect?code=DEMO-1357',
      onScanned: scanned,
    );
  }
}
