import 'dart:async';

import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/media/domain/media_repository.dart';
class FakeLiveRepository implements LiveRepository {
  FakeLiveRepository(this.store);

  final FakeStore store;

  @override
  LiveSource live(Camera camera, {required StreamQuality quality, bool audio = false}) =>
      SyntheticLive([for (var lens = 0; lens < camera.lenses; lens++) store.sceneFor(camera.id, lens)]);

  @override
  Future<MediaSource> snapshot(Camera camera) => store.delay(() => store.sceneFor(camera.id, 0));
}
