import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Preferences {
  Preferences(this.store);

  final SharedPreferencesWithCache store;

  static Future<Preferences> open() async => Preferences(
    await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions()),
  );

  ThemeMode get themeMode => ThemeMode.values.byName(store.getString('theme') ?? ThemeMode.system.name);

  Future<void> setThemeMode(ThemeMode mode) => store.setString('theme', mode.name);

  Locale? get locale {
    final code = store.getString('locale');
    return code == null ? null : Locale(code);
  }

  Future<void> setLocale(Locale? locale) =>
      locale == null ? store.remove('locale') : store.setString('locale', locale.languageCode);

  String? get siteId => store.getString('site');

  Future<void> setSiteId(String? id) => id == null ? store.remove('site') : store.setString('site', id);

  String? get serverUrl => store.getString('server');

  Future<void> setServerUrl(String? url) => url == null ? store.remove('server') : store.setString('server', url);

  int get liveLayout => store.getInt('layout') ?? 0;

  Future<void> setLiveLayout(int value) => store.setInt('layout', value);

  bool get appLock => store.getBool('lock') ?? false;

  Future<void> setAppLock(bool value) => store.setBool('lock', value);

  bool get onboardedNotifications => store.getBool('notifications-asked') ?? false;

  Future<void> setOnboardedNotifications(bool value) => store.setBool('notifications-asked', value);
}
