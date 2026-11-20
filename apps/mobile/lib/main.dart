import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/config.dart';
import 'core/preferences.dart';
import 'data/backend_factory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  final preferences = await Preferences.open();
  final backend = await createBackend(config, preferences);
  runApp(
    ProviderScope(
      retry: (count, error) => null,
      overrides: [
        configProvider.overrideWithValue(config),
        preferencesProvider.overrideWithValue(preferences),
        backendProvider.overrideWithValue(backend),
      ],
      child: const SurveillanceApp(),
    ),
  );
}
