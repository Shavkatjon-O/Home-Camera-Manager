import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/features/analytics/presentation/providers.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';

part 'providers.g.dart';
@riverpod
Future<List<Camera>> cameras(Ref ref, String siteId) => ref.watch(backendProvider).devices.cameras(siteId);

@riverpod
Future<List<CameraTile>> tiles(Ref ref, String siteId) async {
  final cameras = await ref.watch(camerasProvider(siteId).future);
  final views = await ref.watch(viewsProvider(siteId).future);
  return [
    for (final camera in cameras.where((c) => c.enabled))
      for (var lens = 0; lens < camera.lenses; lens++)
        CameraTile(
          camera: camera,
          lens: lens,
          viewId: views.where((v) => v.cameraId == camera.id && v.lens == lens).firstOrNull?.id,
        ),
  ];
}

@riverpod
Future<List<Connector>> connectors(Ref ref, String siteId) => ref.watch(backendProvider).devices.connectors(siteId);
