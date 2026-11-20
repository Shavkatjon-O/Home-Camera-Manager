import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/core/network/client/http.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/domain/tenancy_repository.dart';

/// Reads and changes organisations, sites, members and invitations on the server.
class ApiTenancyRepository implements TenancyRepository {
  /// Creates the repository over [client].
  ApiTenancyRepository(this.client);

  /// The generated API.
  final api.SurveillanceApi client;

  /// Converts the server's role to the app's [Role].
  static Role roleOf(api.Role role) => Role.values.asNameMap()[role.toJson()] ?? Role.viewer;

  /// Converts the app's [role] to the server's.
  static api.Role wireRole(Role role) => api.Role.fromJson(role.name);

  /// Converts the server's organisation to the app's [Organisation].
  static Organisation organisationOf(api.OrganisationRead organisation) => Organisation(
    id: organisation.uuid,
    name: organisation.name,
    role: roleOf(organisation.role),
    facesEnabled: organisation.facesEnabled,
  );

  /// Converts the server's site, with its [armMode], to the app's [Site].
  static Site siteOf(api.SiteRead site, {ArmMode armMode = ArmMode.schedule}) => Site(
    id: site.uuid,
    organisationId: site.organisation,
    name: site.name,
    kind: SiteKind.values.asNameMap()[site.kind.toJson()] ?? SiteKind.other,
    timezone: site.timezone,
    armMode: armMode,
  );

  /// Reads the arm mode of [siteId], or schedule when the analytics settings cannot be read.
  Future<ArmMode> armModeOf(String siteId) async {
    try {
      final settings = await guarded(() => client.analytics.readAnalyticsSettings(xSite: siteId));
      return ArmMode.values.asNameMap()[settings.armMode.toJson()] ?? ArmMode.schedule;
    } on ApiFailure {
      return ArmMode.schedule;
    }
  }

  @override
  Future<List<Organisation>> organisations() async {
    final list = await guarded(() => client.organisations.listOrganisations());
    return [for (final organisation in list.items) organisationOf(organisation)];
  }

  @override
  Future<Organisation> createOrganisation(String name) async => organisationOf(
    await guarded(
      () => client.organisations.createOrganisation(body: api.OrganisationCreate(name: name)),
    ),
  );

  @override
  Future<List<Site>> sites(String organisationId) async {
    final list = await guarded(
      () => client.sites.listOrganisationSites(organisation: organisationId),
    );
    return Future.wait([
      for (final site in list.items)
        armModeOf(site.uuid).then((mode) => siteOf(site, armMode: mode)),
    ]);
  }

  @override
  Future<Site> createSite({
    required String organisationId,
    required String name,
    required SiteKind kind,
    required String timezone,
  }) async {
    final site = await guarded(
      () => client.sites.createSite(
        organisation: organisationId,
        body: api.SiteCreate(
          name: name,
          kind: api.SiteKind.fromJson(kind.name),
          timezone: timezone,
        ),
      ),
    );
    return siteOf(site, armMode: await armModeOf(site.uuid));
  }

  @override
  Future<Site> updateSite(Site site) async {
    final updated = await guarded(
      () => client.sites.updateSite(
        site: site.id,
        body: api.SiteUpdate(
          name: site.name,
          kind: api.SiteKind.fromJson(site.kind.name),
          timezone: site.timezone,
        ),
      ),
    );
    return siteOf(updated, armMode: site.armMode);
  }

  @override
  Future<Site> setArmMode(String siteId, ArmMode mode) async {
    await guarded(
      () => client.analytics.updateAnalyticsSettings(
        xSite: siteId,
        body: api.AnalyticsSettingsUpdate(armMode: api.ArmMode.fromJson(mode.name)),
      ),
    );
    final site = await guarded(() => client.sites.getSite(site: siteId));
    return siteOf(site, armMode: mode);
  }

  @override
  Future<({String version, String? text})> facesConsent() async {
    final consent = await guarded(() => client.organisations.getFacesConsent());
    return (version: consent.version, text: consent.text);
  }

  @override
  Future<Organisation> setFaces(
    String organisationId,
    bool enabled, {
    String? consentVersion,
  }) async => organisationOf(
    await guarded(
      () => client.organisations.updateOrganisation(
        organisation: organisationId,
        body: api.OrganisationUpdate(
          facesEnabled: enabled,
          facesConsent: enabled ? true : null,
          consentVersion: enabled ? consentVersion : null,
        ),
      ),
    ),
  );

  /// Converts the server's member to the app's [Member].
  static Member memberOf(api.MemberRead member) => Member(
    userId: member.user,
    name: member.name ?? member.email ?? '',
    email: member.email ?? '',
    role: roleOf(member.role),
    siteIds: member.allSites ? null : member.sites,
    you: member.you,
  );

  @override
  Future<List<Member>> members(String organisationId) async {
    final list = await guarded(() => client.members.listMembers(organisation: organisationId));
    return [for (final member in list.items) memberOf(member)];
  }

  /// Converts the server's invitation to the app's [Invitation].
  static Invitation invitationOf(api.InvitationRead invitation) => Invitation(
    id: invitation.uuid,
    email: invitation.email,
    role: roleOf(invitation.role),
    siteIds: invitation.allSites ? null : invitation.sites,
    expiresAt: invitation.expiresAt,
    invitedBy: invitation.invitedBy ?? '',
    state:
        InvitationState.values.asNameMap()[invitation.status.toJson()] ?? InvitationState.pending,
  );

  @override
  Future<List<Invitation>> invitations(String organisationId) async {
    final list = await guarded(
      () => client.invitations.listInvitations(organisation: organisationId),
    );
    return [for (final invitation in list.items) invitationOf(invitation)];
  }

  @override
  Future<Invitation> invite({
    required String organisationId,
    required String email,
    required Role role,
    List<String>? siteIds,
  }) async => invitationOf(
    await guarded(
      () => client.invitations.createInvitation(
        organisation: organisationId,
        body: api.InvitationCreate(
          email: email,
          role: wireRole(role),
          allSites: siteIds == null,
          sites: siteIds ?? const [],
        ),
      ),
    ),
  );

  @override
  Future<void> revokeInvitation(String organisationId, String invitationId) => guarded(
    () =>
        client.invitations.revokeInvitation(organisation: organisationId, invitation: invitationId),
  );

  @override
  Future<Member> updateMember(
    String organisationId,
    String userId, {
    required Role role,
    List<String>? siteIds,
  }) async {
    final list = await guarded(() => client.members.listMembers(organisation: organisationId));
    final member = list.items.firstWhere(
      (m) => m.user == userId,
      orElse: () => throw const ApiFailure(FailureKind.notFound),
    );
    return memberOf(
      await guarded(
        () => client.members.updateMember(
          organisation: organisationId,
          member: member.uuid,
          body: api.MemberUpdate(role: wireRole(role), allSites: siteIds == null, sites: siteIds),
        ),
      ),
    );
  }

  @override
  Future<void> removeMember(String organisationId, String userId) async {
    final list = await guarded(() => client.members.listMembers(organisation: organisationId));
    final member = list.items.firstWhere(
      (m) => m.user == userId,
      orElse: () => throw const ApiFailure(FailureKind.notFound),
    );
    await guarded(
      () => client.members.removeMember(organisation: organisationId, member: member.uuid),
    );
  }

  @override
  Future<InvitationPreview> previewInvitation(String token) async {
    final preview = await guarded(() => client.invitations.previewInvitation(token: token));
    if (preview.status.toJson() == 'expired') throw const ApiFailure(FailureKind.expired);
    return InvitationPreview(
      token: token,
      organisationName: preview.organisation,
      invitedBy: preview.invitedBy ?? '',
      role: roleOf(preview.role),
      siteNames: const [],
      expiresAt: preview.expiresAt,
    );
  }

  @override
  Future<Organisation> acceptInvitation(String token) async =>
      organisationOf(await guarded(() => client.invitations.acceptInvitation(token: token)));
}
