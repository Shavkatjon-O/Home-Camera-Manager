import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/devices/pairing/common/camera_details.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// Lists the cameras the connector found and adds the one the user picks.
class DiscoveredCamerasScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const DiscoveredCamerasScreen({super.key, required this.pairing, required this.session});

  /// The pairing context.
  final PairingContext pairing;

  /// The attempt being reported.
  final PairingSession session;

  @override
  ConsumerState<DiscoveredCamerasScreen> createState() => _DiscoveredCamerasScreenState();
}

class _DiscoveredCamerasScreenState extends ConsumerState<DiscoveredCamerasScreen> {
  late Future<List<DiscoveredCamera>> cameras = load(false);

  Future<List<DiscoveredCamera>> load(bool rescan) =>
      ref.read(backendProvider).devices.discovered(widget.pairing.connector!.id, rescan: rescan);

  @override
  void initState() {
    super.initState();
    final preset = widget.pairing.discovered;
    if (preset != null) WidgetsBinding.instance.addPostFrameCallback((_) => pick(preset));
  }

  Future<void> pick(DiscoveredCamera camera) async {
    final navigator = Navigator.of(context);
    if (camera.nvr) {
      navigator.pop(ContinueWith('nvr_import', widget.pairing.copyWith(discovered: camera)));
      return;
    }
    widget.session.step('pick');
    final result = await navigator.push<PairingResult>(
      MaterialPageRoute(
        builder: (_) =>
            CameraDetailsScreen(pairing: widget.pairing, session: widget.session, camera: camera),
      ),
    );
    if (result != null) navigator.pop(result);
  }

  String title(DiscoveredCamera camera) {
    final name = [camera.manufacturer, camera.model].whereType<String>().join(' ').trim();
    return name.isEmpty ? camera.host : name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    widget.session.step('list');
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingCamerasTitle),
        actions: [
          IconButton(
            tooltip: l10n.onboardingRescan,
            onPressed: () => setState(() => cameras = load(true)),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<DiscoveredCamera>>(
        future: cameras,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(
              error: snapshot.error!,
              onRetry: () => setState(() => cameras = load(true)),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(height: Gaps.lg),
                  Text(
                    l10n.onboardingSearching,
                    style: context.text.bodyMedium?.copyWith(color: p.text2),
                  ),
                ],
              ),
            );
          }
          final list = snapshot.data!;
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.radar_rounded,
              title: l10n.onboardingNoCameras,
              body: l10n.onboardingNoCamerasBody,
              action: OutlinedButton(
                onPressed: () => setState(() => cameras = load(true)),
                child: Text(l10n.onboardingRescan),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.page, Gaps.xxl),
            children: [
              Text(
                l10n.onboardingCamerasBody,
                style: context.text.bodyMedium?.copyWith(color: p.text2),
              ),
              const SizedBox(height: Gaps.lg),
              for (final camera in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: Gaps.sm),
                  child: Panel(
                    onTap: camera.cameraId == null ? () => pick(camera) : null,
                    child: Row(
                      children: [
                        IconBadge(
                          icon: camera.nvr
                              ? Icons.dns_outlined
                              : (camera.ptz
                                    ? Icons.control_camera_rounded
                                    : Icons.videocam_outlined),
                        ),
                        const SizedBox(width: Gaps.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title(camera), style: context.text.titleMedium),
                              Text(
                                '${camera.host}, ${camera.ports.join(' ')}',
                                style: dataStyle(context, size: 12, color: p.text3),
                              ),
                            ],
                          ),
                        ),
                        if (camera.cameraId != null)
                          Tag(l10n.onboardingAdded, tone: TagTone.ok, icon: Icons.check_rounded)
                        else
                          Text(
                            camera.nvr ? l10n.discoveredImport : l10n.onboardingAddCamera,
                            style: context.text.labelLarge,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
