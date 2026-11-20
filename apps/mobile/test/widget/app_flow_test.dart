import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/events/presentation/labels.dart';

import '../support/app_harness.dart';

/// Runs the widget tests of the simulated site's screens.
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets('the welcome screen offers to create an account or sign in', (tester) async {
    final app = await buildApp();
    await pumpApp(tester, app);
    expect(find.text(l10n.welcomeTitle), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('I have an account'), findsOneWidget);
    expect(find.text(l10n.commonDemo), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('sign in asks for both fields before it calls the server', (tester) async {
    final app = await buildApp();
    await pumpApp(tester, app);
    await tapAndSettle(tester, find.text('I have an account'));
    expect(find.text(l10n.signInTitle), findsWidgets);
    await tapAndSettle(tester, find.widgetWithText(FilledButton, l10n.signInAction));
    expect(find.text(l10n.validationEmail), findsOneWidget);
    expect(find.text(l10n.validationRequired), findsOneWidget);
    expect(app.store.signedIn, isFalse);
    await disposeApp(tester);
  });

  testWidgets('sign in rejects a malformed email address', (tester) async {
    final app = await buildApp();
    await pumpApp(tester, app);
    await tapAndSettle(tester, find.text('I have an account'));
    await tester.enterText(find.byType(TextFormField).at(0), 'not-an-address');
    await tester.enterText(find.byType(TextFormField).at(1), 'demo-password');
    await tapAndSettle(tester, find.widgetWithText(FilledButton, l10n.signInAction));
    expect(find.text(l10n.validationEmail), findsOneWidget);
    expect(find.text(l10n.validationRequired), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('the demo account signs in and lands on Home with the arm mode card', (tester) async {
    final app = await buildApp();
    await pumpApp(tester, app);
    await tapAndSettle(tester, find.text('I have an account'));
    await tester.enterText(find.byType(TextFormField).at(0), 'owner@demo.example');
    await tester.enterText(find.byType(TextFormField).at(1), 'demo-password');
    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, l10n.signInAction),
      const Duration(seconds: 3),
    );
    expect(app.store.signedIn, isTrue);
    expect(find.text(l10n.armTitle), findsOneWidget);
    expect(find.byType(SegmentedButton<ArmMode>), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('a signed-in user starts on Home and the owner can change the arm mode', (
    tester,
  ) async {
    final app = await buildApp(signedIn: true);
    await pumpApp(tester, app);
    expect(find.text(l10n.armTitle), findsOneWidget);
    final button = tester.widget<SegmentedButton<ArmMode>>(find.byType(SegmentedButton<ArmMode>));
    expect(button.onSelectionChanged, isNotNull);
    await tapAndSettle(tester, find.text(l10n.armAway).first);
    expect(find.text(l10n.armAwayBody), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('the Events tab lists the site events', (tester) async {
    final app = await buildApp(signedIn: true);
    await pumpApp(tester, app);
    await tapAndSettle(tester, find.text(l10n.navEvents));
    final newest = app.store.data.events.firstWhere((e) => e.siteId == 'site-home');
    expect(find.text(l10n.eventTitle(newest)), findsWidgets);
    await disposeApp(tester);
  });

  testWidgets('the bottom bar switches between the tabs', (tester) async {
    final app = await buildApp(signedIn: true);
    await pumpApp(tester, app);
    await tapAndSettle(tester, find.text(l10n.navLive));
    expect(find.text(l10n.liveTitle), findsWidgets);
    await tapAndSettle(tester, find.text(l10n.navMore));
    expect(find.text(l10n.moreTitle), findsWidgets);
    await tapAndSettle(tester, find.text(l10n.navHome));
    expect(find.text(l10n.armTitle), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('a deep link to an event opens its detail', (tester) async {
    final app = await buildApp(signedIn: true);
    await pumpApp(tester, app);
    final event = app.store.data.events.firstWhere((e) => e.siteId == 'site-home');
    await app.open(tester, '/event/${event.id}');
    expect(find.text(l10n.eventTitle(event)), findsWidgets);
    await disposeApp(tester);
  });
}
