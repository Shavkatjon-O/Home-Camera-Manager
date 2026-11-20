import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/router.dart';
import 'package:smart_surveillance/app/settings/appearance.dart';
import 'package:smart_surveillance/app/theme/theme.dart';
import 'package:smart_surveillance/features/identity/presentation/app_lock.dart';
/// The root widget of the app, wiring the router, themes, locale and app lock.
class SurveillanceApp extends ConsumerWidget {
  /// Creates the root widget.
  const SurveillanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceSettingsProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: appearance.theme,
      locale: appearance.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) => AppLock(child: child ?? const SizedBox.shrink()),
    );
  }
}
