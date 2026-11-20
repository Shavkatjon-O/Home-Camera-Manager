import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smart_surveillance/app/app.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/backend_factory.dart';
import 'package:smart_surveillance/app/demo/fake_backend.dart';
import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/app/router.dart';
import 'package:smart_surveillance/app/settings/appearance.dart';
import 'package:smart_surveillance/core/config.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/storage/preferences.dart';
import 'package:smart_surveillance/features/identity/data/token_store.dart';

/// Starts the app on the simulated site and returns its provider container.
Future<ProviderContainer> launch(WidgetTester tester, {ThemeMode theme = ThemeMode.light}) async {
  final preferences = await Preferences.open();
  await preferences.setSiteId(null);
  await preferences.setThemeMode(theme);
  await preferences.setLocale(const Locale('en'));
  final store = FakeStore(clock: () => DateTime.now());
  final container = ProviderContainer(
    retry: (count, error) => null,
    overrides: [
      configProvider.overrideWithValue(
        const AppConfig(mode: BackendMode.fake, apiUrl: '', flavor: 'foss'),
      ),
      preferencesProvider.overrideWithValue(preferences),
      backendProvider.overrideWithValue(fakeBackend(store)),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const SurveillanceApp()),
  );
  await settle(tester);
  return container;
}

/// Starts the app against the server at [url] with no saved session and
/// returns its provider container.
Future<ProviderContainer> launchApi(
  WidgetTester tester,
  String url, {
  ThemeMode theme = ThemeMode.light,
}) async {
  final preferences = await Preferences.open();
  await preferences.setSiteId(null);
  await preferences.setServerUrl(null);
  await preferences.setThemeMode(theme);
  await preferences.setLocale(const Locale('en'));
  await TokenStore().clear();
  final config = AppConfig(mode: BackendMode.api, apiUrl: url, flavor: 'foss');
  final container = ProviderContainer(
    retry: (count, error) => null,
    overrides: [
      configProvider.overrideWithValue(config),
      preferencesProvider.overrideWithValue(preferences),
      backendProvider.overrideWithValue(apiBackend(config, preferences)),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const SurveillanceApp()),
  );
  await settle(tester);
  return container;
}

/// Pumps frames until [finder] finds a widget or [timeout] passes, and returns whether it did.
Future<bool> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return true;
  }
  return false;
}

/// Pumps frames for [time], because the live scenes never settle.
Future<void> settle(
  WidgetTester tester, [
  Duration time = const Duration(milliseconds: 1500),
]) async {
  final end = DateTime.now().add(time);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Opens [location] in the app's router and waits for it to load.
Future<void> open(
  WidgetTester tester,
  ProviderContainer container,
  String location, {
  bool push = false,
}) async {
  final router = container.read(routerProvider);
  if (push) {
    unawaited(router.push<void>(location));
  } else {
    router.go(location);
  }
  await settle(tester);
}

/// Switches the theme while the app runs.
Future<void> setTheme(WidgetTester tester, ProviderContainer container, ThemeMode mode) async {
  await container.read(appearanceSettingsProvider.notifier).setTheme(mode);
  await settle(tester, const Duration(milliseconds: 600));
}

/// Takes a named screenshot of the whole screen.
Future<void> shoot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  await settle(tester, const Duration(milliseconds: 400));
  await binding.takeScreenshot(name);
}
