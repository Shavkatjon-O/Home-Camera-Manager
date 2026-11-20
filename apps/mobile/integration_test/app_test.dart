import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const screenshots = bool.fromEnvironment('SCREENSHOTS');

  Future<void> shot(WidgetTester tester, String name) async {
    if (screenshots) await shoot(binding, tester, name);
  }

  Future<void> back(WidgetTester tester) async {
    await tester.pageBack();
    await settle(tester);
  }

  testWidgets('signs in, sets up, tours every tab and reviews an alert on the simulated site', (tester) async {
    final container = await launch(tester);
    if (screenshots) await binding.convertFlutterSurfaceToImage();
    await settle(tester);
    expect(find.text('Create account'), findsOneWidget);
    await shot(tester, 'a1-welcome');

    await tester.tap(find.text('Create account'));
    await settle(tester);
    tester.testTextInput.register();
    await tester.enterText(find.byType(TextFormField).at(0), 'Demo owner');
    await tester.enterText(find.byType(TextFormField).at(1), 'owner@demo.example');
    await tester.enterText(find.byType(TextFormField).at(2), 'Demo-Pass-2026');
    await settle(tester, const Duration(milliseconds: 600));
    await shot(tester, 'b1-sign-up');
    await back(tester);

    await tester.tap(find.text('I have an account'));
    await settle(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'owner@demo.example');
    await tester.enterText(find.byType(TextFormField).at(1), 'demo-password');
    await settle(tester, const Duration(milliseconds: 600));
    await shot(tester, 'b2-sign-in');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester, const Duration(seconds: 3));
    expect(find.text('Arm mode'), findsOneWidget);
    await shot(tester, 'a2-home');

    await open(tester, container, '/invite/demo-invitation', push: true);
    expect(find.text('Accept invitation'), findsOneWidget);
    await shot(tester, 'b3-invite');
    await open(tester, container, '/setup/site?first=false', push: true);
    await shot(tester, 'b4-site');
    await open(tester, container, '/setup/connector/site-home?first=false', push: true);
    await shot(tester, 'b5-connector');
    await tester.tap(find.text('Type the code'));
    await settle(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'DEMO2468');
    await settle(tester, const Duration(milliseconds: 600));
    await shot(tester, 'b6-connector-code');
    await back(tester);
    await open(tester, container, '/setup/add/site-home?first=false', push: true);
    expect(find.text('How do you want to add it?'), findsOneWidget);
    await shot(tester, 'b7-add-camera');
    await tester.tap(find.text('Cameras on the network'));
    await settle(tester, const Duration(seconds: 2));
    await shot(tester, 'b8-discovered');
    await tester.tap(find.text('Generic IPC-B140'));
    await settle(tester);
    await tester.enterText(find.byType(TextFormField).at(1), 'demo-camera-password');
    await tester.tap(find.text('Test the stream'));
    await settle(tester, const Duration(seconds: 3));
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await settle(tester);
    await shot(tester, 'b9-camera-details');
    await back(tester);
    await back(tester);
    await tester.tap(find.text('Import from a recorder'));
    await settle(tester, const Duration(seconds: 2));
    await tester.tap(find.text('Generic NVR 8 channels'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).at(1), 'demo-recorder-password');
    await tester.tap(find.text('Show channels'));
    await settle(tester, const Duration(seconds: 2));
    await shot(tester, 'b10-recorder');
    await back(tester);

    await open(tester, container, '/live');
    expect(find.text('Front gate'), findsWidgets);
    await shot(tester, 'a3-live');
    await open(tester, container, '/camera/cam-porch?lens=1', push: true);
    expect(find.text('Pan and tilt'), findsOneWidget);
    await shot(tester, 'c1-camera');
    await tester.tap(find.byTooltip('Show detections'));
    await settle(tester, const Duration(seconds: 2));
    await shot(tester, 'c2-camera-boxes');

    await open(tester, container, '/events');
    expect(find.text('Events'), findsWidgets);
    await shot(tester, 'c3-events');
    await open(tester, container, '/event/event-2', push: true);
    expect(find.text('Mark reviewed'), findsOneWidget);
    await shot(tester, 'c4-event');
    await tester.tap(find.text('Mark reviewed'));
    await settle(tester);
    expect(find.text('Reviewed'), findsWidgets);
    await tester.tap(find.text('Clip'));
    await settle(tester, const Duration(seconds: 3));
    await shot(tester, 'c5-clip');

    await open(tester, container, '/more/counts');
    await shot(tester, 'd1-counts');
    await tester.tap(find.text('By day'));
    await settle(tester);
    await shot(tester, 'd2-counts-daily');
    await open(tester, container, '/editor/view-gate', push: true);
    expect(find.text('Zones and lines'), findsWidgets);
    await shot(tester, 'd3-editor');
    await open(tester, container, '/more/analytics');
    await shot(tester, 'd4-analytics');
    await open(tester, container, '/more/analytics/view-porch-2');
    await shot(tester, 'd5-view');
    await open(tester, container, '/setup/analytics/site-home/cam-drive?first=false', push: true);
    await shot(tester, 'd6-preset');

    await open(tester, container, '/search?tab=1');
    expect(find.text('Known people'), findsOneWidget);
    await shot(tester, 'e1-people');
    await open(tester, container, '/person/person-alex', push: true);
    await shot(tester, 'e2-person');
    await open(tester, container, '/cluster/cluster-3', push: true);
    await shot(tester, 'e3-who');
    await open(tester, container, '/find-person/event-2', push: true);
    await shot(tester, 'e4-find-person');
    await open(tester, container, '/event/event-5', push: true);
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await settle(tester);
    await shot(tester, 'e5-plate');
    await open(tester, container, '/event/event-4', push: true);
    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await settle(tester);
    await shot(tester, 'e6-journey');
    await open(tester, container, '/search?tab=2');
    await tester.tap(find.text('Demo data'));
    await settle(tester, const Duration(seconds: 2));
    await shot(tester, 'e7-faces');
    await open(tester, container, '/search?tab=0');
    await settle(tester, const Duration(seconds: 2));
    await shot(tester, 'e8-search');

    await open(tester, container, '/more');
    await shot(tester, 'a4-more');
    await open(tester, container, '/more/plan');
    await shot(tester, 'f1-plan');
    await open(tester, container, '/more/activity');
    await shot(tester, 'f2-activity');
    await open(tester, container, '/more/notifications');
    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await settle(tester);
    await shot(tester, 'f3-telegram');
    await open(tester, container, '/more/members');
    await shot(tester, 'f4-members');
    await open(tester, container, '/more/health');
    await shot(tester, 'f5-health');

    await setTheme(tester, container, ThemeMode.dark);
    await open(tester, container, '/home');
    await shot(tester, 'a5-home-dark');
    await open(tester, container, '/live');
    await shot(tester, 'a6-live-dark');
    await open(tester, container, '/event/event-1', push: true);
    await shot(tester, 'c6-event-dark');
    await open(tester, container, '/editor/view-porch-2', push: true);
    await shot(tester, 'd7-editor-dark');
    await open(tester, container, '/more/counts');
    await shot(tester, 'd8-counts-dark');
    await open(tester, container, '/search?tab=1');
    await shot(tester, 'e9-people-dark');
    await open(tester, container, '/setup/add/site-home?first=false', push: true);
    await shot(tester, 'b11-add-camera-dark');
  });
}
