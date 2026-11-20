import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smart_surveillance/app/app.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/demo/fake_backend.dart';
import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/app/router.dart';
import 'package:smart_surveillance/core/config.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/storage/preferences.dart';
import 'package:smart_surveillance/features/alerting/data/alert_center.dart';

/// The simulated site's app, its provider container and its store.
class AppUnderTest {
  /// Creates the handle.
  AppUnderTest(this.container, this.store);

  /// The provider container the app runs in.
  final ProviderContainer container;

  /// The store behind the fake repositories.
  final FakeStore store;

  /// Opens [location] in the app's router and lets it load.
  Future<void> open(WidgetTester tester, String location) async {
    container.read(routerProvider).go(location);
    await settle(tester);
  }
}

/// Builds the provider container of the simulated site.
///
/// The demo user starts signed in when [signedIn] is true. Live events are off
/// and calls answer without delay, so no timers outlive a test.
Future<AppUnderTest> buildApp({
  bool signedIn = false,
  ThemeMode theme = ThemeMode.light,
  DateTime? now,
}) async {
  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  final preferences = await Preferences.open();
  await preferences.setThemeMode(theme);
  await preferences.setLocale(const Locale('en'));
  final store = FakeStore(
    clock: now == null ? DateTime.now : () => now,
    latency: Duration.zero,
    live: false,
  )..signedIn = signedIn;
  final container = ProviderContainer(
    retry: (count, error) => null,
    overrides: [
      configProvider.overrideWithValue(
        const AppConfig(mode: BackendMode.fake, apiUrl: '', flavor: 'foss'),
      ),
      preferencesProvider.overrideWithValue(preferences),
      backendProvider.overrideWithValue(fakeBackend(store)),
      notificationsEnabledProvider.overrideWithValue(false),
      if (now != null) clockProvider.overrideWithValue(() => now),
    ],
  );
  addTearDown(container.dispose);
  return AppUnderTest(container, store);
}

/// Pumps the app inside [app]'s container and lets it start.
Future<void> pumpApp(WidgetTester tester, AppUnderTest app) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(container: app.container, child: const SurveillanceApp()),
  );
  await settle(tester);
}

/// Pumps frames for [time], because the live scenes never settle.
Future<void> settle(
  WidgetTester tester, [
  Duration time = const Duration(milliseconds: 1500),
]) async {
  var elapsed = Duration.zero;
  const step = Duration(milliseconds: 100);
  while (elapsed < time) {
    await tester.pump(step);
    elapsed += step;
  }
}

/// Taps [finder] and lets the app react.
Future<void> tapAndSettle(
  WidgetTester tester,
  Finder finder, [
  Duration time = const Duration(milliseconds: 1000),
]) async {
  await tester.tap(finder);
  await settle(tester, time);
}

/// Disposes the app so no ticker or timer outlives the test.
Future<void> disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}
