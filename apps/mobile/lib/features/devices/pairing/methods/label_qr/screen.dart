import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/pairing/common/qr_scanner.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// Scans a camera label and hands over to the method the server picks.
class LabelQrScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const LabelQrScreen({super.key, required this.pairing, required this.session});

  /// The pairing context.
  final PairingContext pairing;

  /// The attempt being reported.
  final PairingSession session;

  @override
  ConsumerState<LabelQrScreen> createState() => _LabelQrScreenState();
}

class _LabelQrScreenState extends ConsumerState<LabelQrScreen> {
  int attempt = 0;

  Future<void> scanned(String payload) async {
    final navigator = Navigator.of(context);
    final l10n = context.l10n;
    widget.session.step('identify');
    try {
      final backend = ref.read(backendProvider);
      final identity = await backend.pairing.identifyLabel(widget.pairing.siteId, payload);
      DiscoveredCamera? discovered;
      final connector = widget.pairing.connector;
      if (identity.discoveredId != null && connector != null) {
        final list = await backend.devices.discovered(connector.id);
        discovered = list.where((d) => d.id == identity.discoveredId).firstOrNull;
      }
      await widget.session.finish(PairingOutcome.success);
      navigator.pop(
        ContinueWith(
          identity.method,
          widget.pairing.copyWith(label: identity, discovered: discovered),
        ),
      );
    } catch (failure) {
      final unknown = failure is ApiFailure && failure.kind == FailureKind.notFound;
      if (unknown) await widget.session.finish(PairingOutcome.failure, errorCode: 'unknown_label');
      if (!mounted) return;
      if (unknown) {
        showMessage(context, l10n.labelUnknown);
      } else {
        showFailure(context, failure);
      }
      setState(() => attempt++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    widget.session.step('scan');
    return QrScanner(
      key: ValueKey(attempt),
      title: l10n.labelTitle,
      hint: l10n.labelHint,
      demoValue: 'EZVIZ SN:DEMO00001 VC:ABCDEF',
      onScanned: scanned,
    );
  }
}
