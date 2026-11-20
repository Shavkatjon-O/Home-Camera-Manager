import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/theme.dart';
import '../../data/models/account.dart';
import '../../data/models/camera.dart';
import '../../l10n/l10n.dart';
import '../../widgets/media_view.dart';
import '../../widgets/states.dart';
import '../../widgets/surfaces.dart';
import '../site_data.dart';
import 'live_video.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  late int layout = ref.read(preferencesProvider).liveLayout;

  int columns(int count) => switch (layout) {
    1 => 1,
    2 => 2,
    3 => 3,
    _ => count <= 2 ? 1 : 2,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final site = ref.watch(currentSiteProvider).value;
    final layouts = [
      (Icons.auto_awesome_mosaic_outlined, l10n.liveLayoutAuto),
      (Icons.view_agenda_outlined, l10n.liveLayoutOne),
      (Icons.grid_view_rounded, l10n.liveLayoutTwo),
      (Icons.apps_rounded, l10n.liveLayoutThree),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.liveTitle),
        actions: [
          PopupMenuButton<int>(
            tooltip: l10n.liveLayout,
            icon: Icon(layouts[layout].$1),
            initialValue: layout,
            onSelected: (value) {
              setState(() => layout = value);
              ref.read(preferencesProvider).setLiveLayout(value);
            },
            itemBuilder: (context) => [
              for (var i = 0; i < layouts.length; i++)
                PopupMenuItem(
                  value: i,
                  child: Row(children: [Icon(layouts[i].$1, size: 20), const SizedBox(width: 12), Text(layouts[i].$2)]),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: site == null
          ? const SizedBox.shrink()
          : Consumer(
              builder: (context, ref, _) {
                final tiles = ref.watch(tilesProvider(site.site.id));
                return AsyncBody(
                  value: tiles,
                  onRetry: () => ref.invalidate(camerasProvider(site.site.id)),
                  loading: GridSkeleton(columns: columns(4)),
                  data: (tiles) => tiles.isEmpty
                      ? EmptyState(
                          icon: Icons.videocam_off_outlined,
                          title: l10n.liveNoCameras,
                          body: l10n.liveNoCamerasBody,
                          action: site.can(Role.admin)
                              ? FilledButton(
                                  onPressed: () => const CamerasRoute().go(context),
                                  child: Text(l10n.liveAddCamera),
                                )
                              : null,
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(camerasProvider(site.site.id));
                            await ref.read(tilesProvider(site.site.id).future);
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.xs, Gaps.page, Gaps.xl),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns(tiles.length),
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: columns(tiles.length) == 1 ? 16 / 10.4 : 16 / 11.2,
                            ),
                            itemCount: tiles.length,
                            itemBuilder: (context, index) => LiveTile(
                              key: ValueKey(tiles[index].key),
                              tile: tiles[index],
                              compact: columns(tiles.length) == 3,
                            ),
                          ),
                        ),
                );
              },
            ),
    );
  }
}

class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key, required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) => GridView.count(
    padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.xs, Gaps.page, Gaps.xl),
    crossAxisCount: columns,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 16 / 11.2,
    physics: const NeverScrollableScrollPhysics(),
    children: List.generate(6, (_) => const Skeleton(radius: Radii.large)),
  );
}

class LiveTile extends StatelessWidget {
  const LiveTile({super.key, required this.tile, this.compact = false});

  final CameraTile tile;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final camera = tile.camera;
    final title = tile.split ? '${camera.name}, ${l10n.liveLens(tile.lens + 1)}' : camera.name;
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: p.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.large), side: BorderSide(color: p.border)),
        child: InkWell(
          onTap: () => CameraRoute(cameraId: camera.id, lens: tile.lens).push<void>(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.large - 1)),
                  child: ColoredBox(
                    color: p.frame,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: tile.aspect,
                        child: LiveVideo(camera: camera, lens: tile.split ? tile.lens : null),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 6 : 9),
                child: Row(
                  children: [
                    StatusDot(online: camera.online),
                    SizedBox(width: compact ? 6 : 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: (compact ? context.text.labelMedium : context.text.bodyMedium)?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: p.text,
                        ),
                      ),
                    ),
                    if (!compact && camera.ptz) Icon(Icons.control_camera_rounded, size: 16, color: p.text3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LiveFrame extends StatelessWidget {
  const LiveFrame({super.key, required this.camera, this.lens});

  final Camera camera;
  final int? lens;

  @override
  Widget build(BuildContext context) => Frame(
    aspect: lens == null ? camera.aspect : camera.aspect * camera.lenses,
    child: LiveVideo(camera: camera, lens: lens),
  );
}
