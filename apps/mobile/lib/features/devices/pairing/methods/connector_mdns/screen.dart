import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/pairing/common/claim.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/connector_code/screen.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/connector_mdns/scanner.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// The connectors found on the phone's Wi-Fi while the screen is open.
final foundConnectorsProvider = StreamProvider.autoDispose<List<FoundConnector>>(
  (ref) => ref.watch(connectorScannerProvider).scan(),
);

/// Lists connectors on the same Wi-Fi and pairs the one the user picks.
class ConnectorMdnsScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const ConnectorMdnsScreen({super.key, required this.pairing, required this.session});

  /// The pairing context.
  final PairingContext pairing;

  /// The attempt being reported.
  final PairingSession session;

  @override
  ConsumerState<ConnectorMdnsScreen> createState() => _ConnectorMdnsScreenState();
}

class _ConnectorMdnsScreenState extends ConsumerState<ConnectorMdnsScreen> {
  String? busy;

  Future<void> pick(FoundConnector found) async {
    final navigator = Navigator.of(context);
    widget.session.step('pick');
    if (found.code == null) {
      final result = await navigator.push<PairingResult>(
        MaterialPageRoute(
          builder: (_) => ConnectorCodeScreen(pairing: widget.pairing, session: widget.session, initialName: found.name),
        ),
      );
      if (result != null) navigator.pop(result);
      return;
    }
    setState(() => busy = found.host);
    try {
      final connector = await claim(ref, widget.pairing, widget.session, found.code!, name: found.name);
      navigator.pop(ConnectorPaired(connector));
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final found = ref.watch(foundConnectorsProvider);
    widget.session.step('scan');
    final list = found.value ?? const <FoundConnector>[];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mdnsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, Gaps.xxl),
        children: [
          Row(
            children: [
              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: Gaps.md),
              Expanded(child: Text(l10n.mdnsSearching, style: context.text.bodyMedium?.copyWith(color: p.text2))),
            ],
          ),
          const SizedBox(height: Gaps.lg),
          if (found.hasError)
            ErrorState(error: found.error!, compact: true, onRetry: () => ref.invalidate(foundConnectorsProvider))
          else if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Gaps.xl),
              child: Text(l10n.mdnsNone, textAlign: TextAlign.center, style: context.text.bodyMedium?.copyWith(color: p.text3)),
            )
          else
            for (final connector in list)
              Padding(
                padding: const EdgeInsets.only(bottom: Gaps.sm),
                child: Panel(
                  onTap: busy == null ? () => pick(connector) : null,
                  child: Row(
                    children: [
                      const IconBadge(icon: Icons.router_outlined),
                      const SizedBox(width: Gaps.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(connector.name, style: context.text.titleMedium),
                            Text(
                              [connector.host, ?connector.version].join(', '),
                              style: dataStyle(context, size: 12, color: p.text3),
                            ),
                          ],
                        ),
                      ),
                      busy == connector.host
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.onboardingPair, style: context.text.labelLarge),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
