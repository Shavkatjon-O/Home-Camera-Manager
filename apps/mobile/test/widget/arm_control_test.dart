import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/demo/fake_backend.dart';
import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/theme/theme.dart';
import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/alerting/presentation/arm_control.dart';
import 'package:smart_surveillance/features/alerting/presentation/labels.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';

import '../support/app_harness.dart';

/// Builds a site context where the user holds [role].
SiteContext contextFor(Role role, {ArmMode mode = ArmMode.home}) => SiteContext(
  site: Site(
    id: 'site-home',
    organisationId: 'org-demo',
    name: 'Demo home',
    kind: SiteKind.home,
    timezone: 'Asia/Tashkent',
    armMode: mode,
  ),
  organisation: Organisation(id: 'org-demo', name: 'Demo organisation', role: role),
);

/// Pumps the arm control for [context] over a fake backend.
Future<void> pumpControl(WidgetTester tester, SiteContext context) async {
  final store = FakeStore(latency: Duration.zero, live: false);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [backendProvider.overrideWithValue(fakeBackend(store))],
      child: MaterialApp(
        theme: buildTheme(Brightness.light),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ArmControl(site: context)),
      ),
    ),
  );
  await settle(tester, const Duration(milliseconds: 300));
}

/// Runs the arm control tests.
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets('a viewer cannot change the arm mode', (tester) async {
    await pumpControl(tester, contextFor(Role.viewer));
    final button = tester.widget<SegmentedButton<ArmMode>>(find.byType(SegmentedButton<ArmMode>));
    expect(button.onSelectionChanged, isNull);
    expect(find.text(l10n.commonPermissionNeeded), findsOneWidget);
    expect(find.text(l10n.armAwayBody), findsNothing);
  });

  testWidgets('an operator can change the arm mode', (tester) async {
    await pumpControl(tester, contextFor(Role.operator));
    final button = tester.widget<SegmentedButton<ArmMode>>(find.byType(SegmentedButton<ArmMode>));
    expect(button.onSelectionChanged, isNotNull);
    expect(find.text(l10n.armHomeBody), findsOneWidget);
    await tester.tap(find.text(l10n.armAway));
    await settle(tester, const Duration(milliseconds: 600));
    expect(find.text(l10n.armAwayBody), findsOneWidget);
  });

  testWidgets('every arm mode is offered as a segment', (tester) async {
    await pumpControl(tester, contextFor(Role.owner, mode: ArmMode.disarmed));
    for (final mode in ArmMode.values) {
      expect(find.text(l10n.arm(mode)), findsWidgets);
    }
    expect(find.text(l10n.armDisarmedBody), findsOneWidget);
  });

  testWidgets('the demo bakery organisation gives its member the viewer role', (tester) async {
    final store = FakeStore(latency: Duration.zero, live: false);
    final bakery = store.data.organisations.firstWhere((o) => o.id == 'org-corner');
    expect(bakery.role, Role.viewer);
    expect(bakery.role.atLeast(Role.operator), isFalse);
  });
}
