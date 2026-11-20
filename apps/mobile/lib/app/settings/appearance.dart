import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/core/providers.dart';

part 'appearance.g.dart';

/// The notifier holding the chosen theme mode and language, persisted in preferences.
@Riverpod(keepAlive: true)
class AppearanceSettings extends _$AppearanceSettings {
  @override
  ({ThemeMode theme, Locale? locale}) build() {
    final prefs = ref.watch(preferencesProvider);
    return (theme: prefs.themeMode, locale: prefs.locale);
  }

  /// Saves [mode] as the theme mode and updates the state.
  Future<void> setTheme(ThemeMode mode) async {
    await ref.read(preferencesProvider).setThemeMode(mode);
    state = (theme: mode, locale: state.locale);
  }

  /// Saves [locale] as the language, or follows the system language when null, and updates the
  /// state.
  Future<void> setLocale(Locale? locale) async {
    await ref.read(preferencesProvider).setLocale(locale);
    state = (theme: state.theme, locale: locale);
  }
}
