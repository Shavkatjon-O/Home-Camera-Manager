import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/identity/presentation/session.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';

import 'harness.dart';

/// Tours the app against a running server, such as the development kit, with
/// the demo members at --dart-define=SSS_TEST_DOMAIN who share SSS_TEST_PASSWORD.
///
/// With SSS_TEST_CAMERA_HOST and SSS_TEST_CAMERA_PASSWORD it also identifies
/// a camera by address on the site the server reaches directly.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const screenshots = bool.fromEnvironment('SCREENSHOTS');
  const api = String.fromEnvironment('SSS_API_URL', defaultValue: 'http://10.0.2.2:18700');
  const mailpit = String.fromEnvironment('SSS_MAILPIT_URL', defaultValue: 'http://10.0.2.2:18725');
  const password = String.fromEnvironment('SSS_TEST_PASSWORD');
  const domain = String.fromEnvironment('SSS_TEST_DOMAIN', defaultValue: 'example.com');
  const cameraHost = String.fromEnvironment('SSS_TEST_CAMERA_HOST');
  const cameraPassword = String.fromEnvironment('SSS_TEST_CAMERA_PASSWORD');
  var surface = false;

  Future<void> shot(WidgetTester tester, String name) async {
    if (!screenshots) return;
    if (!surface) {
      await binding.convertFlutterSurfaceToImage();
      surface = true;
    }
    await shoot(binding, tester, name);
  }

  Future<Object?> getJson(String url) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      return jsonDecode(await response.transform(utf8.decoder).join());
    } finally {
      client.close();
    }
  }

  Future<String?> verificationToken(String address) async {
    for (var i = 0; i < 30; i++) {
      final list = await getJson('$mailpit/api/v1/messages?limit=50') as Map<String, Object?>;
      for (final message
          in (list['messages'] as List<Object?>? ?? const []).cast<Map<String, Object?>>()) {
        final to = (message['To'] as List<Object?>? ?? const []).cast<Map<String, Object?>>();
        if (!to.any((recipient) => recipient['Address'] == address)) continue;
        final full =
            await getJson('$mailpit/api/v1/message/${message['ID']}') as Map<String, Object?>;
        final text = '${full['Text']} ${full['HTML']}';
        final match = RegExp(r'/verify-email/([A-Za-z0-9_\-.]+)').firstMatch(text);
        if (match != null) return match[1];
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return null;
  }

  testWidgets('signs up, verifies through the mail and starts setting up a site', (tester) async {
    surface = false;
    final container = await launchApi(tester, api);
    expect(await waitFor(tester, find.text('Create account')), isTrue);
    await tester.tap(find.text('Create account'));
    await settle(tester);
    tester.testTextInput.register();
    final address = 'mobile-${DateTime.now().millisecondsSinceEpoch}@$domain';
    await tester.enterText(find.byType(TextFormField).at(0), 'Mobile tester');
    await tester.enterText(find.byType(TextFormField).at(1), address);
    await tester.enterText(find.byType(TextFormField).at(2), 'Mobile-Tester-2026-pass');
    await settle(tester, const Duration(milliseconds: 600));
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    expect(await waitFor(tester, find.text('Check your email')), isTrue);
    await shot(tester, 'r1-verify');

    final token = await verificationToken(address);
    expect(token, isNotNull);
    await open(tester, container, '/verify-email/$token');
    expect(await waitFor(tester, find.text('Set up your first site')), isTrue);
    await shot(tester, 'r2-first-site');
    await tester.enterText(find.byType(TextFormField).at(0), 'Mobile test');
    await tester.enterText(find.byType(TextFormField).at(1), 'Mobile test home');
    await settle(tester, const Duration(milliseconds: 600));
    await tester.tap(find.text('Continue'));
    expect(await waitFor(tester, find.text('Pair a connector')), isTrue);
    await shot(tester, 'r3-connector');
    await container.read(sessionProvider.notifier).signOut();
    await settle(tester);
    container.dispose();
  });

  testWidgets('signs in and tours live, events, cameras, members and connectors', (tester) async {
    surface = false;
    final container = await launchApi(tester, api);
    expect(await waitFor(tester, find.text('I have an account')), isTrue);
    await tester.tap(find.text('I have an account'));
    await settle(tester);
    tester.testTextInput.register();
    await tester.enterText(find.byType(TextFormField).at(0), 'owner@$domain');
    await tester.enterText(find.byType(TextFormField).at(1), password);
    await settle(tester, const Duration(milliseconds: 600));
    await shot(tester, 'r4-sign-in');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(await waitFor(tester, find.text('Arm mode')), isTrue);
    await settle(tester, const Duration(seconds: 3));
    await shot(tester, 'r5-home');

    await open(tester, container, '/live');
    await settle(tester, const Duration(seconds: 15));
    await shot(tester, 'r6-live');

    final site = (await container.read(currentSiteProvider.future))!.site.id;
    final cameras = await container.read(backendProvider).devices.cameras(site);
    expect(cameras, isNotEmpty);
    final camera = cameras.firstWhere((c) => c.ptz, orElse: () => cameras.first);
    await open(tester, container, '/camera/${camera.id}', push: true);
    await settle(tester, const Duration(seconds: 15));
    await shot(tester, 'r7-camera');
    await tester.pageBack();
    await settle(tester);

    await open(tester, container, '/events');
    await settle(tester, const Duration(seconds: 3));
    await shot(tester, 'r8-events');
    final events = await container.read(backendProvider).events.events(site, const EventFilter());
    if (events.items.isNotEmpty) {
      await open(tester, container, '/event/${events.items.first.id}', push: true);
      await settle(tester, const Duration(seconds: 3));
      await shot(tester, 'r9-event');
      await tester.pageBack();
      await settle(tester);
    }

    await open(tester, container, '/more/cameras');
    await settle(tester, const Duration(seconds: 2));
    await shot(tester, 'r10-cameras');
    await open(tester, container, '/more/connectors');
    await settle(tester, const Duration(seconds: 2));
    await shot(tester, 'r11-connectors');
    await open(tester, container, '/more/members');
    await settle(tester, const Duration(seconds: 2));
    await shot(tester, 'r12-members');
    await open(tester, container, '/more/site');
    await settle(tester, const Duration(seconds: 2));
    await shot(tester, 'r13-site');
    await open(tester, container, '/more/counts');
    await settle(tester, const Duration(seconds: 3));
    await shot(tester, 'r16-counts');
    await open(tester, container, '/more/analytics');
    await settle(tester, const Duration(seconds: 3));
    await shot(tester, 'r17-analytics');
    await open(tester, container, '/more/health');
    await settle(tester, const Duration(seconds: 3));
    await shot(tester, 'r18-health');

    if (cameraHost.isNotEmpty) {
      final sites = await container.read(allSitesProvider.future);
      final direct = sites.firstWhere((s) => s.name == 'Store');
      await container.read(selectedSiteProvider.notifier).select(direct.id);
      await settle(tester);
      await open(tester, container, '/setup/add/${direct.id}?first=false', push: true);
      expect(await waitFor(tester, find.text('Enter its address')), isTrue);
      await shot(tester, 'r22-direct-methods');
      await tester.tap(find.text('Enter its address'));
      await settle(tester);
      await tester.enterText(find.byType(TextFormField).at(0), cameraHost);
      await settle(tester, const Duration(milliseconds: 600));
      await tester.tap(find.text('Identify camera'));
      expect(await waitFor(tester, find.text('Test the stream')), isTrue);
      await settle(tester);
      await tester.enterText(find.byType(TextFormField).at(1), cameraPassword);
      await tester.tap(find.text('Test the stream'));
      expect(await waitFor(tester, find.textContaining('Stream works')), isTrue);
      await settle(tester);
      await shot(tester, 'r23-direct-test');
      await tester.pageBack();
      await settle(tester);
      await tester.pageBack();
      await settle(tester);
      await tester.pageBack();
      await settle(tester);
      final home = sites.firstWhere((s) => s.name == 'Home');
      await container.read(selectedSiteProvider.notifier).select(home.id);
      await open(tester, container, '/home');
    }

    await setTheme(tester, container, ThemeMode.dark);
    await open(tester, container, '/live');
    await settle(tester, const Duration(seconds: 15));
    await shot(tester, 'r14-live-dark');
    await open(tester, container, '/home');
    await settle(tester, const Duration(seconds: 3));
    await shot(tester, 'r15-home-dark');
    await container.read(sessionProvider.notifier).signOut();
    await settle(tester);
    container.dispose();
  });

  testWidgets('signs in as a viewer, who sees no operator controls', (tester) async {
    surface = false;
    final container = await launchApi(tester, api);
    expect(await waitFor(tester, find.text('I have an account')), isTrue);
    await tester.tap(find.text('I have an account'));
    await settle(tester);
    tester.testTextInput.register();
    await tester.enterText(find.byType(TextFormField).at(0), 'viewer@$domain');
    await tester.enterText(find.byType(TextFormField).at(1), password);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(await waitFor(tester, find.text('Arm mode')), isTrue);
    await settle(tester, const Duration(seconds: 3));
    await shot(tester, 'r19-viewer-home');
    final site = (await container.read(currentSiteProvider.future))!.site.id;
    final events = await container.read(backendProvider).events.events(site, const EventFilter());
    if (events.items.isNotEmpty) {
      await open(tester, container, '/event/${events.items.first.id}', push: true);
      await settle(tester, const Duration(seconds: 3));
      expect(find.text('Mark reviewed'), findsNothing);
      await shot(tester, 'r20-viewer-event');
      await tester.pageBack();
      await settle(tester);
    }
    await open(tester, container, '/more');
    await settle(tester, const Duration(seconds: 2));
    await shot(tester, 'r21-viewer-more');
    await container.read(sessionProvider.notifier).signOut();
    await settle(tester);
    container.dispose();
  });
}
