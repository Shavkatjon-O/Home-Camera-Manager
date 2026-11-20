@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_surveillance/app/app.dart';

import '../support/app_harness.dart';

/// The size of the phone every screen is drawn on.
const phone = BoxConstraints.tightFor(width: 390, height: 844);

/// The moment the simulated site treats as now, so relative times never change.
final fixedNow = DateTime(2026, 3, 14, 12);

/// One screen of the simulated site and how to reach it.
class Screen {
  /// Creates a screen named [name] at [path], signed in unless [signedIn] is false.
  const Screen(this.name, this.path, {this.signedIn = true});

  /// The golden file name.
  final String name;

  /// The router location, or a marker resolved in [locationOf].
  final String path;

  /// Whether the demo user is signed in.
  final bool signedIn;
}

const screens = [
  Screen('welcome', '/welcome', signedIn: false),
  Screen('home', '/home'),
  Screen('live', '/live'),
  Screen('events', '/events'),
  Screen('event_detail', 'event'),
  Screen('counts', '/more/counts'),
  Screen('more', '/more'),
];

/// Registers the golden test of [screen] in [mode].
void screenGolden(Screen screen, ThemeMode mode) {
  late AppUnderTest app;
  goldenTest(
    '${screen.name} in the ${mode.name} theme',
    fileName: '${screen.name}_${mode.name}',
    constraints: phone,
    pumpWidget: (tester, widget) async {
      app = await buildApp(signedIn: screen.signedIn, theme: mode, now: fixedNow);
      await tester.pumpWidget(UncontrolledProviderScope(container: app.container, child: widget));
    },
    pumpBeforeTest: (tester) async {
      await settle(tester);
      final path = screen.path == 'event'
          ? '/event/${app.store.data.events.firstWhere((e) => e.siteId == 'site-home').id}'
          : screen.path;
      if (screen.signedIn) await app.open(tester, path);
      await settle(tester, const Duration(seconds: 2));
    },
    builder: () => const SurveillanceApp(),
  );
}

/// Runs the golden tests of the simulated site's screens.
void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final screen in screens) {
      screenGolden(screen, mode);
    }
  }
}
