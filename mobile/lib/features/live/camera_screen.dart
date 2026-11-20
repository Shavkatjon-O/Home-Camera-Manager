import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/theme.dart';
import '../../data/models/account.dart';
import '../../data/models/analytics.dart';
import '../../data/models/camera.dart';
import '../../data/models/event.dart';
import '../../l10n/l10n.dart';
import '../../widgets/event_tiles.dart';
import '../../widgets/labels.dart';
import '../../widgets/media_view.dart';
import '../../widgets/states.dart';
import '../../widgets/surfaces.dart';
import '../site_data.dart';
import 'live_video.dart';
import 'ptz_pad.dart';

final cameraControlsProvider = FutureProvider.autoDispose.family<CameraControls, String>(
  (ref, id) => ref.read(backendProvider).devices.controls(id),
);

final cameraEventsProvider = FutureProvider.autoDispose.family<List<CameraEvent>, (String, String)>((ref, key) async {
  final page = await ref
      .read(backendProvider)
      .events
      .events(key.$1, EventFilter(cameraIds: {key.$2}), pageSize: 6);
  return page.items;
});

final liveObjectsProvider = StreamProvider.autoDispose.family<List<LiveObject>, String>(
  (ref, viewId) => ref.read(backendProvider).analytics.liveObjects(viewId),
);

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key, required this.cameraId, this.lens = 0});

  final String cameraId;
  final int lens;

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  StreamQuality quality = StreamQuality.main;
  bool boxes = false;
  bool sound = false;
  bool whole = false;
  double speed = 0.5;
  bool light = false;
  bool sirenBusy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final site = ref.watch(currentSiteProvider).value;
    if (site == null) return const Scaffold();
    final cameras = ref.watch(camerasProvider(site.site.id));
    final views = ref.watch(viewsProvider(site.site.id)).value ?? const <AnalyticsView>[];
    return AsyncBody(
      value: cameras,
      onRetry: () => ref.invalidate(camerasProvider(site.site.id)),
      loading: const Scaffold(body: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      data: (list) {
        final camera = list.where((c) => c.id == widget.cameraId).firstOrNull;
        if (camera == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(icon: Icons.videocam_off_outlined, title: l10n.errorNotFound),
          );
        }
        final lens = camera.lenses > 1 && !whole ? widget.lens : null;
        final view = views.where((v) => v.cameraId == camera.id && v.lens == (lens ?? 0)).firstOrNull;
        return body(context, site, camera, lens, view);
      },
    );
  }

  Widget body(BuildContext context, SiteContext site, Camera camera, int? lens, AnalyticsView? view) {
    final l10n = context.l10n;
    final p = context.palette;
    final controls = ref.watch(cameraControlsProvider(camera.id)).value;
    final operator = site.can(Role.operator);
    final title = camera.lenses > 1 && lens != null ? '${camera.name}, ${l10n.liveLens(lens + 1)}' : camera.name;
    final aspect = lens == null ? camera.aspect : camera.aspect * camera.lenses;
    final devices = ref.read(backendProvider).devices;
    Future<void> move(double pan, double tilt, double zoom) => devices.move(camera.id, pan: pan, tilt: tilt, zoom: zoom);
    Future<void> stop() => devices.stop(camera.id);
    final overlay = boxes && view != null ? LiveBoxes(viewId: view.id) : null;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.text.titleMedium, overflow: TextOverflow.ellipsis),
            Row(
              children: [
                StatusDot(online: camera.online, size: 7),
                const SizedBox(width: 6),
                Text(
                  camera.online == false ? l10n.commonOffline : l10n.commonOnline,
                  style: context.text.labelSmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (camera.lenses > 1)
            IconButton(
              tooltip: whole ? l10n.liveLens(widget.lens + 1) : l10n.commonAll,
              onPressed: () => setState(() => whole = !whole),
              icon: Icon(whole ? Icons.crop_7_5_rounded : Icons.view_day_outlined),
            ),
          if (site.can(Role.admin))
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'settings') CameraSettingsRoute(cameraId: camera.id).go(context);
                if (value == 'analytics' && view != null) ViewRoute(viewId: view.id).go(context);
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'settings', child: Text(l10n.cameraSettings)),
                if (view != null) PopupMenuItem(value: 'analytics', child: Text(l10n.cameraAnalytics)),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Gaps.xxl),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
            child: Frame(
              aspect: aspect,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LiveVideo(camera: camera, lens: lens, quality: quality, audio: sound, overlay: overlay),
                  Positioned(left: 10, top: 10, child: Tag(l10n.liveBadge, tone: TagTone.alert, icon: Icons.circle, dense: true)),
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: IconButton.filledTonal(
                      tooltip: l10n.cameraFullscreen,
                      style: IconButton.styleFrom(backgroundColor: const Color(0x99000000), foregroundColor: const Color(0xFFFFFFFF)),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          fullscreenDialog: true,
                          builder: (_) => FullscreenLive(camera: camera, lens: lens, quality: quality, viewId: view?.id),
                        ),
                      ),
                      icon: const Icon(Icons.fullscreen_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gaps.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<StreamQuality>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: StreamQuality.main, label: Text(l10n.cameraMain)),
                      ButtonSegment(value: StreamQuality.sub, label: Text(l10n.cameraSub), enabled: camera.hasSub),
                    ],
                    selected: {quality},
                    onSelectionChanged: (value) => setState(() => quality = value.first),
                  ),
                ),
                const SizedBox(width: 8),
                ToggleIcon(
                  icon: Icons.crop_free_rounded,
                  label: l10n.cameraBoxes,
                  selected: boxes,
                  onTap: view == null ? null : () => setState(() => boxes = !boxes),
                ),
                const SizedBox(width: 8),
                ToggleIcon(
                  icon: sound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  label: l10n.cameraSound,
                  selected: sound,
                  onTap: controls?.audio == true ? () => setState(() => sound = !sound) : null,
                ),
              ],
            ),
          ),
          if (camera.ptz && operator) ...[
            SectionHeader(l10n.cameraPtz),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
              child: Panel(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        PtzPad(
                          onMove: move,
                          onStop: stop,
                          speed: speed,
                          onHome: controls?.homeSupported == true ? () => devices.gotoHome(camera.id) : null,
                        ),
                        ZoomButtons(onMove: move, onStop: stop, speed: speed),
                      ],
                    ),
                    const SizedBox(height: Gaps.md),
                    Row(
                      children: [
                        Text(l10n.cameraSpeed, style: context.text.labelMedium),
                        Expanded(
                          child: Slider(
                            value: speed,
                            min: 0.1,
                            max: 1,
                            divisions: 9,
                            label: '${(speed * 100).round()}%',
                            onChanged: (value) => setState(() => speed = value),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            PresetsRow(camera: camera, presets: controls?.presets ?? const []),
          ],
          if (controls?.extrasSupported == true && operator) ...[
            SectionHeader(l10n.cameraLight),
            TileGroup(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.light_mode_outlined),
                  title: Text(l10n.cameraLight),
                  value: light,
                  onChanged: (value) async {
                    setState(() => light = value);
                    try {
                      await devices.setLight(camera.id, value);
                    } catch (failure) {
                      if (context.mounted) showFailure(context, failure);
                      setState(() => light = !value);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.campaign_outlined, color: p.dangerText),
                  title: Text(l10n.cameraSiren),
                  trailing: sirenBusy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : null,
                  onTap: sirenBusy
                      ? null
                      : () async {
                          final ok = await confirm(
                            context,
                            title: l10n.cameraSirenConfirm,
                            action: l10n.cameraSiren,
                            destructive: true,
                          );
                          if (!ok) return;
                          setState(() => sirenBusy = true);
                          try {
                            await devices.sirenFor(camera.id, const Duration(seconds: 10));
                            if (context.mounted) showMessage(context, l10n.cameraSirenOn);
                          } catch (failure) {
                            if (context.mounted) showFailure(context, failure);
                          } finally {
                            if (mounted) setState(() => sirenBusy = false);
                          }
                        },
                ),
              ],
            ),
          ],
          SectionHeader(l10n.cameraRecent),
          RecentForCamera(siteId: site.site.id, cameraId: camera.id),
        ],
      ),
    );
  }
}

class ToggleIcon extends StatelessWidget {
  const ToggleIcon({super.key, required this.icon, required this.label, required this.selected, this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tooltip(
      message: label,
      child: Semantics(
        toggled: selected,
        label: label,
        button: true,
        child: Material(
          color: selected ? p.surface3 : const Color(0x00000000),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.medium), side: BorderSide(color: p.borderInput)),
          child: InkWell(
            borderRadius: BorderRadius.circular(Radii.medium),
            onTap: onTap,
            child: SizedBox(
              width: 48,
              height: 44,
              child: Icon(icon, size: 20, color: onTap == null ? p.text3.withValues(alpha: 0.5) : (selected ? p.text : p.text2)),
            ),
          ),
        ),
      ),
    );
  }
}

class LiveBoxes extends ConsumerWidget {
  const LiveBoxes({super.key, required this.viewId});

  final String viewId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final objects = ref.watch(liveObjectsProvider(viewId)).value ?? const [];
    return BoxOverlay(
      boxes: [
        for (final object in objects) (box: object.box, label: object.label, caption: object.name ?? l10n.label(object.label)),
      ],
    );
  }
}

class PresetsRow extends ConsumerWidget {
  const PresetsRow({super.key, required this.camera, required this.presets});

  final Camera camera;
  final List<PtzPreset> presets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final devices = ref.read(backendProvider).devices;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          l10n.cameraPresets,
          padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.lg, Gaps.sm, 0),
          action: TextButton.icon(
            onPressed: () async {
              final controller = TextEditingController();
              final name = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.cameraSavePreset),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(labelText: l10n.cameraPresetName),
                    onSubmitted: (value) => Navigator.of(context).pop(value),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
                    FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: Text(l10n.commonSave)),
                  ],
                ),
              );
              controller.dispose();
              if (name == null || name.trim().isEmpty) return;
              try {
                await devices.savePreset(camera.id, name.trim());
                ref.invalidate(cameraControlsProvider(camera.id));
              } catch (failure) {
                if (context.mounted) showFailure(context, failure);
              }
            },
            icon: const Icon(Icons.bookmark_add_outlined, size: 18),
            label: Text(l10n.cameraSavePreset),
          ),
        ),
        if (presets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
            child: Text(l10n.cameraNoPresets, style: context.text.bodyMedium?.copyWith(color: context.palette.text3)),
          )
        else
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
              itemCount: presets.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) => ActionChip(
                avatar: const Icon(Icons.place_outlined, size: 16),
                label: Text(presets[index].name),
                onPressed: () => devices.gotoPreset(camera.id, presets[index].token),
              ),
            ),
          ),
      ],
    );
  }
}

class RecentForCamera extends ConsumerWidget {
  const RecentForCamera({super.key, required this.siteId, required this.cameraId});

  final String siteId;
  final String cameraId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(cameraEventsProvider((siteId, cameraId)));
    return value.when(
      loading: () => const SizedBox(height: 240, child: ListSkeleton(rows: 3)),
      error: (error, _) => ErrorState(error: error, compact: true, onRetry: () => ref.invalidate(cameraEventsProvider((siteId, cameraId)))),
      data: (events) => events.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
              child: Text(context.l10n.homeNoEvents, style: context.text.bodyMedium?.copyWith(color: context.palette.text3)),
            )
          : Column(
              children: [
                for (final event in events) EventRow(event: event),
                TextButton(
                  onPressed: () => EventsRoute(camera: cameraId).go(context),
                  child: Text(context.l10n.commonSeeAll),
                ),
              ],
            ),
    );
  }
}

class FullscreenLive extends StatefulWidget {
  const FullscreenLive({super.key, required this.camera, this.lens, required this.quality, this.viewId});

  final Camera camera;
  final int? lens;
  final StreamQuality quality;
  final String? viewId;

  @override
  State<FullscreenLive> createState() => _FullscreenLiveState();
}

class _FullscreenLiveState extends State<FullscreenLive> {
  bool chrome = true;

  @override
  void initState() {
    super.initState();
    unawaited(SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]));
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky));
  }

  @override
  void dispose() {
    unawaited(SystemChrome.setPreferredOrientations(DeviceOrientation.values));
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aspect = widget.lens == null ? widget.camera.aspect : widget.camera.aspect * widget.camera.lenses;
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: GestureDetector(
        onTap: () => setState(() => chrome = !chrome),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                maxScale: 4,
                child: AspectRatio(
                  aspectRatio: aspect,
                  child: LiveVideo(camera: widget.camera, lens: widget.lens, quality: widget.quality),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: chrome ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      color: const Color(0xFFFFFFFF),
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    Text(widget.camera.name, style: const TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600)),
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
