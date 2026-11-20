import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/config.dart';
import '../core/preferences.dart';
import '../data/models/account.dart';
import '../data/repositories.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
AppConfig config(Ref ref) => throw UnimplementedError();

@Riverpod(keepAlive: true)
Preferences preferences(Ref ref) => throw UnimplementedError();

@Riverpod(keepAlive: true)
Backend backend(Ref ref) => throw UnimplementedError();

@Riverpod(keepAlive: true)
DateTime Function() clock(Ref ref) => DateTime.now;

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

sealed class SessionState {
  const SessionState();
}

class SignedOut extends SessionState {
  const SignedOut();
}

class AwaitingVerification extends SessionState {
  const AwaitingVerification(this.email);

  final String email;
}

class SignedIn extends SessionState {
  const SignedIn(this.user);

  final User user;
}

@Riverpod(keepAlive: true)
class Session extends _$Session {
  ({String email, String password})? pending;

  @override
  Future<SessionState> build() async {
    final user = await ref.read(backendProvider).auth.restore();
    return user == null ? const SignedOut() : SignedIn(user);
  }

  AuthRepository get auth => ref.read(backendProvider).auth;

  Future<void> signIn(String email, String password) async {
    try {
      final user = await auth.signIn(email: email, password: password);
      pending = null;
      state = AsyncData(SignedIn(user));
    } on ApiFailure catch (failure) {
      if (failure.kind == FailureKind.unverified) {
        pending = (email: email, password: password);
        state = AsyncData(AwaitingVerification(email));
        return;
      }
      rethrow;
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    final result = await auth.signUp(name: name, email: email, password: password);
    pending = (email: result.email, password: password);
    state = AsyncData(AwaitingVerification(result.email));
  }

  Future<bool> verify(String token) async {
    await auth.verifyEmail(token: token);
    final credentials = pending;
    if (credentials == null) {
      state = const AsyncData(SignedOut());
      return false;
    }
    await signIn(credentials.email, credentials.password);
    return true;
  }

  void cancelVerification() {
    pending = null;
    state = const AsyncData(SignedOut());
  }

  void updateUser(User user) => state = AsyncData(SignedIn(user));

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } finally {
      await ref.read(preferencesProvider).setSiteId(null);
      state = const AsyncData(SignedOut());
    }
  }

  void expired() => state = const AsyncData(SignedOut());

  Future<void> deleteAccount(String password) async {
    await auth.deleteAccount(password);
    await ref.read(preferencesProvider).setSiteId(null);
    state = const AsyncData(SignedOut());
  }
}

User? signedInUser(WidgetRef ref) {
  final value = ref.watch(sessionProvider).value;
  return value is SignedIn ? value.user : null;
}

@Riverpod(keepAlive: true)
Future<List<Organisation>> organisations(Ref ref) async {
  final session = await ref.watch(sessionProvider.future);
  if (session is! SignedIn) return const [];
  return ref.read(backendProvider).tenancy.organisations();
}

@Riverpod(keepAlive: true)
Future<List<Site>> allSites(Ref ref) async {
  final organisations = await ref.watch(organisationsProvider.future);
  final tenancy = ref.read(backendProvider).tenancy;
  final lists = await Future.wait([for (final organisation in organisations) tenancy.sites(organisation.id)]);
  return [for (final list in lists) ...list];
}

@Riverpod(keepAlive: true)
class SelectedSite extends _$SelectedSite {
  @override
  String? build() => ref.read(preferencesProvider).siteId;

  Future<void> select(String id) async {
    state = id;
    await ref.read(preferencesProvider).setSiteId(id);
  }
}

class SiteContext {
  const SiteContext({required this.site, required this.organisation});

  final Site site;
  final Organisation organisation;

  Role get role => organisation.role;

  bool can(Role needed) => role.atLeast(needed);
}

@Riverpod(keepAlive: true)
Future<SiteContext?> currentSite(Ref ref) async {
  final sites = await ref.watch(allSitesProvider.future);
  final organisations = await ref.watch(organisationsProvider.future);
  if (sites.isEmpty) return null;
  final selected = ref.watch(selectedSiteProvider);
  final site = sites.where((s) => s.id == selected).firstOrNull ?? sites.first;
  final organisation = organisations.firstWhere((o) => o.id == site.organisationId);
  return SiteContext(site: site, organisation: organisation);
}
