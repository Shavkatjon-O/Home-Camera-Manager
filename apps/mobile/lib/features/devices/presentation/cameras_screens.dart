import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/app/settings/appearance.dart';
import 'package:smart_surveillance/app/theme/theme.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/format.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/analytics/presentation/providers.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/devices/presentation/providers.dart';
import 'package:smart_surveillance/features/events/presentation/providers.dart';
import 'package:smart_surveillance/features/identity/presentation/session.dart';
import 'package:smart_surveillance/features/insights/presentation/providers.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';
final cameraSettingsProvider = FutureProvider.autoDispose.family<CameraSettings, String>(
  (ref, id) => ref.read(backendProvider).devices.settings(id),
);

String brandName(CameraBrand brand) => switch (brand) {
  CameraBrand.ezviz => 'EZVIZ',
  CameraBrand.v380 => 'V380',
  CameraBrand.onvif => 'ONVIF',
  CameraBrand.rtsp => 'RTSP',
};

Future<void> addCamera(BuildContext context, WidgetRef ref, String siteId) async {
  final connectors = await ref.read(connectorsProvider(siteId).future);
  if (!context.mounted) return;
  final online = connectors.where((c) => c.state == ConnectorState.online).toList();
  if (online.isEmpty) {
    await OnboardingConnectorRoute(siteId: siteId, first: false).push<void>(context);
  } else {
    await OnboardingCamerasRoute(siteId: siteId, connectorId: online.first.id, first: false).push<void>(context);
  }
  ref.invalidate(camerasProvider(siteId));
}

class CamerasScreen extends ConsumerStatefulWidget {
  const CamerasScreen({super.key});

  @override
  ConsumerState<CamerasScreen> createState() => _CamerasScreenState();
}

class _CamerasScreenState extends ConsumerState<CamerasScreen> {
  List<Camera>? order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final site = ref.watch(currentSiteProvider).value;
    if (site == null) return const Scaffold();
    final id = site.site.id;
    final value = ref.watch(camerasProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.camerasTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => addCamera(context, ref, id),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.camerasAdd),
      ),
      body: AsyncBody(
        value: value,
        onRetry: () => ref.invalidate(camerasProvider(id)),
        loading: const ListSkeleton(thumbnail: false),
        data: (cameras) {
          final list = order ?? cameras;
          if (list.isEmpty) {
            return EmptyState(icon: Icons.videocam_off_outlined, title: l10n.liveNoCameras, body: l10n.liveNoCamerasBody);
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            header: Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.page, Gaps.sm),
              child: Text(l10n.camerasReorder, style: context.text.bodySmall),
            ),
            itemCount: list.length,
            onReorder: (from, to) async {
              final next = List.of(list);
              final moved = next.removeAt(from);
              next.insert(to > from ? to - 1 : to, moved);
              setState(() => order = next);
              try {
                await ref.read(backendProvider).devices.orderCameras(id, [for (final c in next) c.id]);
                ref.invalidate(camerasProvider(id));
              } catch (failure) {
                if (context.mounted) showFailure(context, failure);
              }
              if (mounted) setState(() => order = null);
            },
            itemBuilder: (context, index) {
              final camera = list[index];
              return Material(
                key: ValueKey(camera.id),
                color: p.background,
                child: ListTile(
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconBadge(icon: camera.ptz ? Icons.control_camera_rounded : Icons.videocam_outlined),
                      Positioned(right: -2, bottom: -2, child: StatusDot(online: camera.online, size: 10)),
                    ],
                  ),
                  title: Text(camera.name),
                  subtitle: Text(
                    [brandName(camera.brand), if (camera.model != null) camera.model!, if (camera.lenses > 1) l10n.lensesTwo].join(', '),
                  ),
                  trailing: ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle_rounded)),
                  onTap: () => CameraSettingsRoute(cameraId: camera.id).go(context),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CameraSettingsScreen extends ConsumerStatefulWidget {
  const CameraSettingsScreen({super.key, required this.cameraId});

  final String cameraId;

  @override
  ConsumerState<CameraSettingsScreen> createState() => _CameraSettingsScreenState();
}

class _CameraSettingsScreenState extends ConsumerState<CameraSettingsScreen> {
  ImageSettings? image;
  MotionSettings? motion;

  Future<void> rename(Camera camera) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: camera.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.fieldCameraName),
        content: TextField(controller: controller, autofocus: true, onSubmitted: (value) => Navigator.of(context).pop(value)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: Text(l10n.commonSave)),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;
    await update(camera.copyWith(name: name.trim()));
  }

  Future<void> update(Camera camera) async {
    try {
      await ref.read(backendProvider).devices.updateCamera(camera);
      ref.invalidate(camerasProvider(camera.siteId));
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    }
  }

  Future<void> run(Future<void> Function() action, String done) async {
    try {
      await action();
      if (mounted) showMessage(context, done);
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final site = ref.watch(currentSiteProvider).value;
    if (site == null) return const Scaffold();
    final cameras = ref.watch(camerasProvider(site.site.id)).value ?? const [];
    final camera = cameras.where((c) => c.id == widget.cameraId).firstOrNull;
    final settings = ref.watch(cameraSettingsProvider(widget.cameraId));
    final devices = ref.read(backendProvider).devices;
    final format = Formats(context, ref.read(clockProvider)());
    if (camera == null) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
    return Scaffold(
      appBar: AppBar(title: Text(camera.name)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Gaps.xxl),
        children: [
          TileGroup(
            children: [
              ListTile(
                leading: const Icon(Icons.drive_file_rename_outline_rounded),
                title: Text(l10n.fieldCameraName),
                subtitle: Text(camera.name),
                onTap: () => rename(camera),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.power_settings_new_rounded),
                title: Text(l10n.camerasEnabled),
                value: camera.enabled,
                onChanged: (value) => update(camera.copyWith(enabled: value)),
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome_outlined),
                title: Text(l10n.cameraAnalytics),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => const AnalyticsRoute().go(context),
              ),
            ],
          ),
          settings.when(
            loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
            error: (error, _) => ErrorState(error: error, compact: true, onRetry: () => ref.invalidate(cameraSettingsProvider(widget.cameraId))),
            data: (data) {
              final img = image ?? data.image;
              final mot = motion ?? data.motion;
              Widget slider(String label, double? value, ImageSettings Function(double) apply) => Padding(
                padding: const EdgeInsets.fromLTRB(Gaps.page, 6, Gaps.sm, 0),
                child: Row(
                  children: [
                    SizedBox(width: 104, child: Text(label, style: context.text.bodyMedium)),
                    Expanded(
                      child: Slider(
                        value: (value ?? 50).clamp(0, 100),
                        max: 100,
                        onChanged: value == null ? null : (v) => setState(() => image = apply(v)),
                        onChangeEnd: value == null ? null : (v) => devices.updateImage(camera.id, apply(v)),
                      ),
                    ),
                    SizedBox(width: 32, child: Text('${(value ?? 0).round()}', style: dataStyle(context, size: 12, color: p.text2))),
                  ],
                ),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(l10n.settingsDevice),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
                    child: Panel(
                      padding: const EdgeInsets.symmetric(horizontal: Gaps.lg, vertical: Gaps.sm),
                      child: Column(
                        children: [
                          ReadOut(label: l10n.settingsManufacturer, value: data.device.manufacturer ?? '-'),
                          ReadOut(label: l10n.settingsModel, value: data.device.model ?? '-'),
                          ReadOut(label: l10n.settingsFirmware, value: data.device.firmware ?? '-', mono: true),
                        ],
                      ),
                    ),
                  ),
                  if (data.encoders.isNotEmpty) ...[
                    SectionHeader(l10n.settingsVideo),
                    TileGroup(
                      children: [
                        for (final encoder in data.encoders)
                          ListTile(
                            title: Text(encoder.name),
                            subtitle: Text(
                              [
                                ?encoder.encoding,
                                if (encoder.width != null) '${encoder.width} x ${encoder.height}',
                                if (encoder.fps != null) '${format.number(encoder.fps!)} fps',
                                if (encoder.bitrate != null) '${encoder.bitrate} kbps',
                              ].join(', '),
                              style: dataStyle(context, size: 12, color: p.text2),
                            ),
                          ),
                      ],
                    ),
                  ],
                  SectionHeader(l10n.settingsImage),
                  if (img == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
                      child: Text(l10n.settingsUnsupported, style: context.text.bodyMedium?.copyWith(color: p.text3)),
                    )
                  else
                    Panel(
                      padding: const EdgeInsets.only(bottom: Gaps.sm),
                      child: Column(
                        children: [
                          slider(l10n.settingsBrightness, img.brightness, (v) => img.copyWith(brightness: v)),
                          slider(l10n.settingsContrast, img.contrast, (v) => img.copyWith(contrast: v)),
                          slider(l10n.settingsSaturation, img.saturation, (v) => img.copyWith(saturation: v)),
                          slider(l10n.settingsSharpness, img.sharpness, (v) => img.copyWith(sharpness: v)),
                          if (img.irCutModes.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, 0),
                              child: Row(
                                children: [
                                  Expanded(child: Text(l10n.settingsIrCut, style: context.text.bodyMedium)),
                                  SegmentedButton<String>(
                                    showSelectedIcon: false,
                                    segments: [for (final mode in img.irCutModes) ButtonSegment(value: mode, label: Text(mode))],
                                    selected: {img.irCut ?? img.irCutModes.first},
                                    onSelectionChanged: (value) {
                                      final next = img.copyWith(irCut: value.first);
                                      setState(() => image = next);
                                      devices.updateImage(camera.id, next);
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ).paddedPage(),
                  SectionHeader(l10n.settingsMotion),
                  if (mot == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
                      child: Text(l10n.settingsUnsupported, style: context.text.bodyMedium?.copyWith(color: p.text3)),
                    )
                  else
                    TileGroup(
                      children: [
                        SwitchListTile(
                          title: Text(l10n.settingsMotion),
                          value: mot.enabled ?? false,
                          onChanged: (value) {
                            final next = mot.copyWith(enabled: value);
                            setState(() => motion = next);
                            devices.updateMotion(camera.id, next);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.sm, Gaps.sm),
                          child: Row(
                            children: [
                              SizedBox(width: 104, child: Text(l10n.settingsSensitivity, style: context.text.bodyMedium)),
                              Expanded(
                                child: Slider(
                                  value: (mot.sensitivity ?? 50).toDouble().clamp(mot.min.toDouble(), mot.max.toDouble()),
                                  min: mot.min.toDouble(),
                                  max: mot.max.toDouble(),
                                  onChanged: (v) => setState(() => motion = mot.copyWith(sensitivity: v.round())),
                                  onChangeEnd: (v) => devices.updateMotion(camera.id, mot.copyWith(sensitivity: v.round())),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  SectionHeader(l10n.settingsClock),
                  TileGroup(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.schedule_rounded),
                        title: Text(data.device.timezone ?? l10n.settingsClock),
                        subtitle: data.device.clockOffsetSeconds == null
                            ? null
                            : Text(l10n.settingsClockOffset(format.number(data.device.clockOffsetSeconds!, digits: 1))),
                        trailing: TextButton(
                          onPressed: () => run(() => devices.syncClock(camera.id), l10n.settingsClockSynced),
                          child: Text(l10n.settingsSyncClock),
                        ),
                      ),
                      if (data.device.canReboot)
                        ListTile(
                          leading: const Icon(Icons.restart_alt_rounded),
                          title: Text(l10n.settingsReboot),
                          subtitle: Text(l10n.settingsRebootBody),
                          onTap: () async {
                            final ok = await confirm(context, title: l10n.settingsReboot, body: l10n.settingsRebootBody, action: l10n.settingsReboot);
                            if (ok) await run(() => devices.reboot(camera.id), l10n.settingsRebooting);
                          },
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: Gaps.xl),
          TileGroup(
            children: [
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: p.dangerText),
                title: Text(l10n.camerasDelete, style: TextStyle(color: p.dangerText)),
                onTap: () async {
                  final ok = await confirm(
                    context,
                    title: l10n.camerasDelete,
                    body: l10n.camerasDeleteBody(camera.name),
                    action: l10n.commonDelete,
                    destructive: true,
                  );
                  if (!ok) return;
                  try {
                    await devices.deleteCamera(camera.id);
                    ref.invalidate(camerasProvider(camera.siteId));
                    if (context.mounted) Navigator.of(context).pop();
                  } catch (failure) {
                    if (context.mounted) showFailure(context, failure);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension PagePadding on Widget {
  Widget paddedPage() => Padding(padding: const EdgeInsets.symmetric(horizontal: Gaps.page), child: this);
}
