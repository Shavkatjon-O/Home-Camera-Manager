import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/app.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/backend_factory.dart';
import 'package:smart_surveillance/app/settings/about_screen.dart';
import 'package:smart_surveillance/core/config.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/storage/preferences.dart';

/// Starts the app with the backend chosen by the build's configuration.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerLicences();
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
