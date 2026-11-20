import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/core/widgets/logo.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/analytics/presentation/providers.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';
import 'package:smart_surveillance/features/devices/pairing/registry.dart';
import 'package:smart_surveillance/features/devices/presentation/providers.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';

/// The server's ranked pairing methods for a site.
final catalogProvider = FutureProvider.autoDispose.family<List<PairingCatalogEntry>, String>(
  (ref, siteId) => ref.read(backendProvider).pairing.catalog(siteId),
);

/// One method in a method list.
class MethodCard extends StatelessWidget {
  /// Creates a card for [ranked].
  const MethodCard({super.key, required this.ranked, required this.onTap, this.busy = false});

  /// The method and its catalog entry.
  final RankedMethod ranked;

  /// Starts the method.
  final VoidCallback? onTap;

  /// Whether the method is running.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final method = ranked.method;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gaps.sm),
      child: Panel(
        onTap: onTap,
        child: Row(
          children: [
            IconBadge(icon: method.icon, size: 42, color: ranked.entry.recommended ? p.text : null),
            const SizedBox(width: Gaps.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(method.title(l10n), style: context.text.titleMedium)),
                      if (ranked.entry.recommended) ...[
                        const SizedBox(width: 8),
                        Tag(l10n.pairingRecommended, tone: TagTone.info, dense: true),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(method.subtitle(l10n), style: context.text.bodySmall),
                ],
              ),
            ),
            busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.chevron_right_rounded, color: p.text3),
          ],
        ),
      ),
    );
  }
}

/// Explains the connector and lets the user pick how to pair it.
class ConnectorPairingScreen extends ConsumerStatefulWidget {
  /// Creates the screen for [siteId].
  const ConnectorPairingScreen({super.key, required this.siteId, this.first = false, this.code});

  /// The site the connector joins.
  final String siteId;

  /// Whether this is part of the first setup flow.
  final bool first;

  /// A code from a scanned or opened link, which starts pairing at once.
  final String? code;

  @override
  ConsumerState<ConnectorPairingScreen> createState() => _ConnectorPairingScreenState();
}

class _ConnectorPairingScreenState extends ConsumerState<ConnectorPairingScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.code != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final method = methodById('connector_code');
        if (method != null) run(method);
      });
    }
  }

  Future<void> run(PairingMethod method) async {
    final l10n = context.l10n;
    final connectors = await ref.read(connectorsProvider(widget.siteId).future);
    if (!mounted) return;
    final pairing = PairingContext(siteId: widget.siteId, connectors: connectors, code: widget.code, first: widget.first);
    final result = await runPairing(context, ref, method, pairing);
    if (result is! ConnectorPaired || !mounted) return;
    ref.invalidate(connectorsProvider(widget.siteId));
    ref.invalidate(catalogProvider(widget.siteId));
    final sites = ref.read(allSitesProvider).value ?? const [];
    final site = sites.where((s) => s.id == widget.siteId).firstOrNull;
    showMessage(context, l10n.onboardingPaired(result.connector.name, site?.name ?? ''));
    if (widget.first) {
      OnboardingAddRoute(siteId: widget.siteId, first: true).pushReplacement(context);
    } else {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final catalog = ref.watch(catalogProvider(widget.siteId));
    final pairing = PairingContext(siteId: widget.siteId, connectors: const [], first: widget.first);
    return FlowScaffold(
      title: l10n.onboardingConnectorTitle,
      subtitle: l10n.onboardingConnectorBody,
      step: widget.first ? l10n.onboardingStep(2, 4) : null,
      children: [
        Bullet(number: 1, text: l10n.onboardingConnectorStep1),
        Bullet(number: 2, text: l10n.onboardingConnectorStep2),
        Bullet(number: 3, text: l10n.onboardingConnectorStep3),
        const SizedBox(height: Gaps.xl),
        AsyncBody(
          value: catalog,
          onRetry: () => ref.invalidate(catalogProvider(widget.siteId)),
          data: (entries) => Column(
            children: [
              for (final ranked in rankMethods(entries, PairingTarget.connector, pairing))
                MethodCard(ranked: ranked, onTap: () => run(ranked.method)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Asks how a camera should be added and runs the chosen method.
class AddCameraScreen extends ConsumerStatefulWidget {
  /// Creates the screen for [siteId].
  const AddCameraScreen({super.key, required this.siteId, this.first = false});

  /// The site the camera joins.
  final String siteId;

  /// Whether this is part of the first setup flow.
  final bool first;

  @override
  ConsumerState<AddCameraScreen> createState() => _AddCameraScreenState();
}

class _AddCameraScreenState extends ConsumerState<AddCameraScreen> {
  String? running;

  Future<void> run(PairingMethod method, List<Connector> connectors) async {
    final l10n = context.l10n;
    setState(() => running = method.id);
    final result = await runPairing(
      context,
      ref,
      method,
      PairingContext(siteId: widget.siteId, connectors: connectors, first: widget.first),
    );
    if (mounted) setState(() => running = null);
    if (result is! CamerasAdded || result.cameras.isEmpty || !mounted) return;
    ref.invalidate(camerasProvider(widget.siteId));
    ref.invalidate(viewsProvider(widget.siteId));
    ref.invalidate(catalogProvider(widget.siteId));
    ref.invalidate(allSitesProvider);
    showMessage(context, l10n.pairingCamerasAdded(result.cameras.length));
    OnboardingAnalyticsRoute(
      siteId: widget.siteId,
      cameraId: result.cameras.first.id,
      first: widget.first,
    ).pushReplacement(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final connectors = ref.watch(connectorsProvider(widget.siteId));
    final catalog = ref.watch(catalogProvider(widget.siteId));
    final list = connectors.value ?? const <Connector>[];
    final pairing = PairingContext(siteId: widget.siteId, connectors: list, first: widget.first);
    return FlowScaffold(
      title: l10n.pairingAddTitle,
      subtitle: l10n.pairingAddBody,
      step: widget.first ? l10n.onboardingStep(3, 4) : null,
      bottom: widget.first
          ? SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => const OnboardingNotificationsRoute().pushReplacement(context),
                child: Text(l10n.commonSkip),
              ),
            )
          : null,
      children: [
        if (connectors.hasValue && !pairing.hasConnector)
          Padding(
            padding: const EdgeInsets.only(bottom: Gaps.lg),
            child: Panel(
              color: p.warning.withValues(alpha: 0.07),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.router_outlined, color: p.warning),
                      const SizedBox(width: Gaps.md),
                      Expanded(child: Text(l10n.camerasNoConnector, style: context.text.titleMedium)),
                    ],
                  ),
                  const SizedBox(height: Gaps.sm),
                  Text(l10n.camerasNoConnectorBody, style: context.text.bodyMedium?.copyWith(color: p.text2)),
                  const SizedBox(height: Gaps.md),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await OnboardingConnectorRoute(siteId: widget.siteId, first: false).push<void>(context);
                      ref.invalidate(connectorsProvider(widget.siteId));
                      ref.invalidate(catalogProvider(widget.siteId));
                    },
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                    label: Text(l10n.connectorsPair),
                  ),
                ],
              ),
            ),
          ),
        AsyncBody(
          value: catalog,
          onRetry: () => ref.invalidate(catalogProvider(widget.siteId)),
          data: (entries) => Column(
            children: [
              for (final ranked in rankMethods(entries, PairingTarget.camera, pairing))
                MethodCard(
                  ranked: ranked,
                  busy: running == ranked.method.id,
                  onTap: running == null ? () => run(ranked.method, list) : null,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Opens connector pairing for the current site from a connect link.
class ConnectLinkScreen extends ConsumerStatefulWidget {
  /// Creates the screen for the link's [code].
  const ConnectLinkScreen({super.key, this.code});

  /// The connector code in the link.
  final String? code;

  @override
  ConsumerState<ConnectLinkScreen> createState() => _ConnectLinkScreenState();
}

class _ConnectLinkScreenState extends ConsumerState<ConnectLinkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final site = await ref.read(currentSiteProvider.future);
      if (!mounted) return;
      if (site == null) {
        const OnboardingSiteRoute().pushReplacement(context);
      } else {
        OnboardingConnectorRoute(siteId: site.site.id, first: false, code: widget.code).pushReplacement(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: LogoMark(size: 64)));
}
