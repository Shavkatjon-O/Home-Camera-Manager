import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/features/identity/presentation/session.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';

part 'current_site.g.dart';
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
