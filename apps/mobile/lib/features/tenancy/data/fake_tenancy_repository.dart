import 'dart:async';

import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/app/demo/fixtures.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/domain/tenancy_repository.dart';

/// An in-memory tenancy repository backed by a [FakeStore].
class FakeTenancyRepository implements TenancyRepository {
  /// Creates a repository that keeps its data in [store].
  FakeTenancyRepository(this.store);

  /// The shared fake data store.
  final FakeStore store;

  @override
  Future<List<Organisation>> organisations() => store.delay(
    () => store.fresh
        ? store.data.organisations.where((o) => store.createdOrganisations.contains(o.id)).toList()
        : List.of(store.data.organisations),
  );

  @override
  Future<Organisation> createOrganisation(String name) => store.delay(() {
    final organisation = Organisation(
      id: 'org-${store.sequence++}',
      name: name,
      role: Role.owner,
      facesEnabled: false,
    );
    store.data.organisations.add(organisation);
    store.createdOrganisations.add(organisation.id);
    store.data.members[organisation.id] = [
      Member(
        userId: store.data.user.id,
        name: store.data.user.name,
        email: store.data.user.email,
        role: Role.owner,
        you: true,
        lastActiveAt: store.clock(),
      ),
    ];
    return organisation;
  });

  @override
  Future<List<Site>> sites(String organisationId) =>
      store.delay(() => store.data.sites.where((s) => s.organisationId == organisationId).toList());

  @override
  Future<Site> createSite({
    required String organisationId,
    required String name,
    required SiteKind kind,
    required String timezone,
  }) => store.delay(() {
    final site = Site(
      id: 'site-${store.sequence++}',
      organisationId: organisationId,
      name: name,
      kind: kind,
      timezone: timezone,
    );
    store.data.sites.add(site);
    store.data.prefs[site.id] = NotificationPrefs(siteId: site.id);
    return site;
  });

  @override
  Future<Site> updateSite(Site site) => store.delay(() {
    final index = store.data.sites.indexWhere((s) => s.id == site.id);
    store.data.sites[index] = site;
    return site;
  });

  @override
  Future<Site> setArmMode(String siteId, ArmMode mode) => store.delay(() {
    final index = store.data.sites.indexWhere((s) => s.id == siteId);
    final site = store.data.sites[index].copyWith(armMode: mode);
    store.data.sites[index] = site;
    store.controllers[siteId]?.add(ArmChanged(siteId));
    return site;
  });

  @override
  Future<({String version, String? text})> facesConsent() =>
      store.delay(() => (version: 'demo-1', text: null));

  @override
  Future<Organisation> setFaces(String organisationId, bool enabled, {String? consentVersion}) =>
      store.delay(() {
        final index = store.data.organisations.indexWhere((o) => o.id == organisationId);
        final organisation = store.data.organisations[index].copyWith(facesEnabled: enabled);
        store.data.organisations[index] = organisation;
        return organisation;
      });

  @override
  Future<List<Member>> members(String organisationId) =>
      store.delay(() => List.of(store.data.members[organisationId] ?? const []));

  @override
  Future<List<Invitation>> invitations(String organisationId) =>
      store.delay(() => List.of(store.data.invitations[organisationId] ?? const []));

  @override
  Future<Invitation> invite({
    required String organisationId,
    required String email,
    required Role role,
    List<String>? siteIds,
  }) => store.delay(() {
    final invitation = Invitation(
      id: 'inv-${store.sequence++}',
      email: email,
      role: role,
      siteIds: siteIds,
      expiresAt: store.clock().add(const Duration(days: 7)),
      invitedBy: store.data.user.name,
    );
    (store.data.invitations[organisationId] ??= []).insert(0, invitation);
    return invitation;
  });

  @override
  Future<void> revokeInvitation(String organisationId, String invitationId) => store.delay(
    () => store.data.invitations[organisationId]?.removeWhere((i) => i.id == invitationId),
  );

  @override
  Future<Member> updateMember(
    String organisationId,
    String userId, {
    required Role role,
    List<String>? siteIds,
  }) => store.delay(() {
    final list = store.data.members[organisationId]!;
    final index = list.indexWhere((m) => m.userId == userId);
    final member = list[index].copyWith(role: role, siteIds: siteIds);
    list[index] = member;
    return member;
  });

  @override
  Future<void> removeMember(String organisationId, String userId) =>
      store.delay(() => store.data.members[organisationId]?.removeWhere((m) => m.userId == userId));

  @override
  Future<InvitationPreview> previewInvitation(String token) => store.delay(() {
    if (token == 'expired') throw const ApiFailure(FailureKind.expired);
    return InvitationPreview(
      token: token,
      organisationName: 'Demo organisation',
      invitedBy: 'Demo owner',
      role: Role.operator,
      siteNames: const ['Demo store'],
      expiresAt: store.clock().add(const Duration(days: 5)),
    );
  });

  @override
  Future<Organisation> acceptInvitation(String token) => store.delay(() {
    store.fresh = false;
    return store.organisation(Fixtures.demoOrg);
  });
}
