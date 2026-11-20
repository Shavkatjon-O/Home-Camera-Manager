import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/format.dart';

/// The moment the formatter treats as now.
final now = DateTime(2026, 3, 14, 12);

/// Pumps a tiny app in [locale] and returns a formatter built inside it.
Future<Formats> formats(WidgetTester tester, {String locale = 'en'}) async {
  late Formats result;
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) {
          result = Formats(context, now);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return result;
}

/// Runs the formatting tests.
void main() {
  testWidgets('formats times and dates', (tester) async {
    final f = await formats(tester);
    final at = DateTime(2026, 3, 14, 9, 5, 7);
    expect(f.locale, 'en');
    expect(f.time(at), '09:05');
    expect(f.timeSeconds(at), '09:05:07');
    expect(f.date(at), 'Mar 14, 2026');
    expect(f.weekday(at), 'Sat');
    expect(f.dayMonth(at), 'Mar 14');
  });

  testWidgets('names today and yesterday in day headers', (tester) async {
    final f = await formats(tester);
    expect(f.dayHeader(DateTime(2026, 3, 14, 1)), 'Today');
    expect(f.dayHeader(DateTime(2026, 3, 13, 23)), 'Yesterday');
    expect(f.dayHeader(DateTime(2026, 3, 10)), 'Tuesday, March 10');
  });

  testWidgets('describes when something happened', (tester) async {
    final f = await formats(tester);
    expect(f.when(DateTime(2026, 3, 14, 8, 30)), '08:30');
    expect(f.when(DateTime(2026, 3, 13, 8, 30)), 'Yesterday, 08:30');
    expect(f.when(DateTime(2026, 3, 1, 8, 30)), 'Mar 1, 08:30');
  });

  testWidgets('describes how long ago something happened', (tester) async {
    final f = await formats(tester);
    expect(f.ago(now.subtract(const Duration(seconds: 30))), 'just now');
    expect(f.agoStart(now.subtract(const Duration(seconds: 30))), 'Just now');
    expect(f.ago(now.subtract(const Duration(seconds: 50))), '1 min ago');
    expect(f.ago(now.subtract(const Duration(minutes: 12))), '12 min ago');
    expect(f.ago(now.subtract(const Duration(hours: 5))), '5 h ago');
    expect(f.ago(now.subtract(const Duration(days: 3))), '3 d ago');
  });

  testWidgets('formats durations by size', (tester) async {
    final f = await formats(tester);
    expect(f.duration(const Duration(seconds: 42)), '42 s');
    expect(f.duration(const Duration(minutes: 3, seconds: 9)), '3 min 9 s');
    expect(f.duration(const Duration(hours: 2, minutes: 15)), '2 h 15 min');
  });

  testWidgets('formats numbers with the locale separators', (tester) async {
    final f = await formats(tester);
    expect(f.number(1234567), '1,234,567');
    expect(f.number(1234.5, digits: 2), '1,234.50');
  });

  testWidgets('follows the locale of the context', (tester) async {
    final f = await formats(tester, locale: 'ru');
    expect(f.locale, 'ru');
    expect(f.l10n.commonToday, isNot('Today'));
  });
}
