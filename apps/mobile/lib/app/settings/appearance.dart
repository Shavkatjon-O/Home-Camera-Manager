import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/core/providers.dart';

part 'appearance.g.dart';
@Riverpod(keepAlive: true)
class AppearanceSettings extends _$AppearanceSettings {
  @override
  ({ThemeMode theme, Locale? locale}) build() {
    final prefs = ref.watch(preferencesProvider);
    return (theme: prefs.themeMode, locale: prefs.locale);
  }

  Future<void> setTheme(ThemeMode mode) async {
    await ref.read(preferencesProvider).setThemeMode(mode);
    state = (theme: mode, locale: state.locale);
  }

  Future<void> setLocale(Locale? locale) async {
    await ref.read(preferencesProvider).setLocale(locale);
    state = (theme: state.theme, locale: locale);
  }
}
