import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../core/format.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/theme.dart';
import '../../data/models/camera.dart';
import '../../l10n/l10n.dart';
import '../../widgets/states.dart';
import '../../widgets/surfaces.dart';
import '../site_data.dart';

class ConnectorsScreen extends ConsumerWidget {
  const ConnectorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final site = ref.watch(currentSiteProvider).value;
    if (site == null) return const Scaffold();
    final id = site.site.id;
    final value = ref.watch(connectorsProvider(id));
    final format = Formats(context, ref.read(clockProvider)());
    Future<void> pair() async {
      await OnboardingConnectorRoute(siteId: id, first: false).push<void>(context);
      ref.invalidate(connectorsProvider(id));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.connectorsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: pair,
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: Text(l10n.connectorsPair),
      ),
      body: AsyncBody(
        value: value,
        onRetry: () => ref.invalidate(connectorsProvider(id)),
        loading: const ListSkeleton(thumbnail: false),
        data: (connectors) => connectors.isEmpty
            ? EmptyState(icon: Icons.router_outlined, title: l10n.connectorsEmpty, body: l10n.connectorsEmptyBody)
            : ListView(
                padding: const EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.page, 96),
                children: [
                  for (final connector in connectors)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Gaps.md),
                      child: Panel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const IconBadge(icon: Icons.router_outlined),
                                const SizedBox(width: Gaps.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(connector.name, style: context.text.titleMedium),
                                      Row(
                                        children: [
                                          StatusDot(online: connector.state == ConnectorState.online, size: 7),
                                          const SizedBox(width: 6),
                                          Text(
                                            connector.state == ConnectorState.online ? l10n.commonOnline : l10n.commonOffline,
                                            style: context.text.labelSmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (action) async {
                                    if (action == 'find') {
                                      await OnboardingAddRoute(siteId: id, first: false).push<void>(context);
                                      ref.invalidate(camerasProvider(id));
                                    }
                                    if (action == 'remove' && context.mounted) {
                                      final ok = await confirm(
                                        context,
                                        title: l10n.connectorsRemove,
                                        body: l10n.connectorsRemoveBody,
                                        action: l10n.commonRemove,
                                        destructive: true,
                                      );
                                      if (!ok) return;
                                      try {
                                        await ref.read(backendProvider).devices.removeConnector(connector.id);
                                        ref.invalidate(connectorsProvider(id));
                                      } catch (failure) {
                                        if (context.mounted) showFailure(context, failure);
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(value: 'find', child: Text(l10n.connectorsFind)),
                                    PopupMenuItem(
                                      value: 'remove',
                                      child: Text(l10n.connectorsRemove, style: TextStyle(color: p.dangerText)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: Gaps.md),
                            ReadOut(label: l10n.moreCameras, value: '${connector.cameraCount}', mono: true),
                            if (connector.version != null)
                              ReadOut(label: l10n.connectorsVersionLabel, value: connector.version!, mono: true),
                            ReadOut(
                              label: l10n.connectorsConnection,
                              value: connector.mode == 'tunnel' ? l10n.connectorsTunnel : l10n.connectorsMode,
                            ),
                            if (connector.lastSeenAt != null)
                              ReadOut(label: l10n.connectorsLastSeen, value: format.ago(connector.lastSeenAt!)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
