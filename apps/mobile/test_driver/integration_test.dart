import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Runs the integration tests and saves each screenshot under
/// `SCREENSHOT_DIR`, or `build/screenshots` when it is not set.
Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    final folder = Directory(Platform.environment['SCREENSHOT_DIR'] ?? 'build/screenshots');
    await folder.create(recursive: true);
    await File('${folder.path}/$name.png').writeAsBytes(bytes);
    return true;
  },
);
