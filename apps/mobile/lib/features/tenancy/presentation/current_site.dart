import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/features/identity/presentation/session.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';

part 'current_site.g.dart';
/// Loads the organisations of the signed-in user.
@Riverpod(keepAlive: true)
Future<List<Organisation>> organisations(Ref ref) async {
  // Watch the value, not the future: signing in replaces data with data, which leaves the future unchanged.
  final session = ref.watch(sessionProvider).value;
  if (session is! SignedIn) return const [];
  return ref.read(backendProvider).tenancy.organisations();
}

/// Loads the sites of every organisation of the user.
@Riverpod(keepAlive: true)
Future<List<Site>> allSites(Ref ref) async {
  final organisations = await ref.watch(organisationsProvider.future);
  final tenancy = ref.read(backendProvider).tenancy;
  final lists = await Future.wait([for (final organisation in organisations) tenancy.sites(organisation.id)]);
  return [for (final list in lists) ...list];
}

/// Holds the id of the site the user chose and remembers it.
@Riverpod(keepAlive: true)
class SelectedSite extends _$SelectedSite {
  @override
  String? build() => ref.read(preferencesProvider).siteId;

  /// Chooses the site [id] and saves the choice.
  Future<void> select(String id) async {
    state = id;
    await ref.read(preferencesProvider).setSiteId(id);
  }
}

/// A site together with the organisation that owns it and the user's role there.
class SiteContext {
  /// Creates the context of [site] in [organisation].
  const SiteContext({required this.site, required this.organisation});

  /// The site in use.
  final Site site;
  /// The organisation that owns the site.
  final Organisation organisation;

  /// The user's role in the organisation.
  Role get role => organisation.role;

  /// Returns whether the user's role is at least [needed].
  bool can(Role needed) => role.atLeast(needed);
}

/// Resolves the site in use, or null when the user has no site.
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
