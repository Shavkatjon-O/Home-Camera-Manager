import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The settings stored on this device, such as theme, language and the chosen site.
class Preferences {
  /// Creates preferences backed by [store].
  Preferences(this.store);

  /// The underlying key-value store.
  final SharedPreferencesWithCache store;

  /// Opens the device store and returns the preferences backed by it.
  static Future<Preferences> open() async => Preferences(
    await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    ),
  );

  /// The chosen theme mode, following the system by default.
  ThemeMode get themeMode =>
      ThemeMode.values.byName(store.getString('theme') ?? ThemeMode.system.name);

  /// Saves [mode] as the theme mode.
  Future<void> setThemeMode(ThemeMode mode) => store.setString('theme', mode.name);

  /// The chosen language, or null to follow the system language.
  Locale? get locale {
    final code = store.getString('locale');
    return code == null ? null : Locale(code);
  }

  /// Saves [locale] as the language, or removes the choice when null.
  Future<void> setLocale(Locale? locale) =>
      locale == null ? store.remove('locale') : store.setString('locale', locale.languageCode);

  /// The id of the site last selected, or null when none was chosen.
  String? get siteId => store.getString('site');

  /// Saves [id] as the selected site, or removes the choice when null.
  Future<void> setSiteId(String? id) =>
      id == null ? store.remove('site') : store.setString('site', id);

  /// The address of the server the app connects to, or null when none was chosen.
  String? get serverUrl => store.getString('server');

  /// Saves [url] as the server address, or removes it when null.
  Future<void> setServerUrl(String? url) =>
      url == null ? store.remove('server') : store.setString('server', url);

  /// The index of the layout last chosen for the live grid.
  int get liveLayout => store.getInt('layout') ?? 0;

  /// Saves [value] as the live grid layout.
  Future<void> setLiveLayout(int value) => store.setInt('layout', value);

  /// Whether the app asks for device authentication when it opens.
  bool get appLock => store.getBool('lock') ?? false;

  /// Saves whether the app lock is on.
  Future<void> setAppLock(bool value) => store.setBool('lock', value);

  /// Whether the notification permission prompt has already been shown during setup.
  bool get onboardedNotifications => store.getBool('notifications-asked') ?? false;

  /// Saves whether the notification permission prompt has been shown.
  Future<void> setOnboardedNotifications(bool value) => store.setBool('notifications-asked', value);
}
