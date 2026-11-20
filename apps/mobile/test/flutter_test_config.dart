import 'dart:async';
import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The font files of each family declared in pubspec.yaml.
const fontFiles = <String, List<String>>{
  'Geist': [
    'assets/fonts/Geist-Regular.ttf',
    'assets/fonts/Geist-Medium.ttf',
    'assets/fonts/Geist-SemiBold.ttf',
    'assets/fonts/Geist-Bold.ttf',
  ],
  'GeistMono': [
    'assets/fonts/GeistMono-Regular.ttf',
    'assets/fonts/GeistMono-Medium.ttf',
    'assets/fonts/GeistMono-SemiBold.ttf',
  ],
};

/// Loads the fonts declared in pubspec.yaml so goldens render real text.
Future<void> loadAppFonts() async {
  for (final entry in fontFiles.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      final bytes = await File(path).readAsBytes();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}

/// Runs every test file after loading the fonts and configuring the golden tests.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadAppFonts();
  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(),
      ciGoldensConfig: CiGoldensConfig(enabled: false),
    ),
    run: testMain,
  );
}
