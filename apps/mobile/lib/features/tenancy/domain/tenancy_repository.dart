
import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
abstract interface class TenancyRepository {
  Future<List<Organisation>> organisations();

  Future<Organisation> createOrganisation(String name);

  Future<List<Site>> sites(String organisationId);

  Future<Site> createSite({
    required String organisationId,
    required String name,
    required SiteKind kind,
    required String timezone,
  });

  Future<Site> updateSite(Site site);

  Future<Site> setArmMode(String siteId, ArmMode mode);

  Future<({String version, String? text})> facesConsent();

  Future<Organisation> setFaces(String organisationId, bool enabled, {String? consentVersion});

  Future<List<Member>> members(String organisationId);

  Future<List<Invitation>> invitations(String organisationId);

  Future<Invitation> invite({
    required String organisationId,
    required String email,
    required Role role,
    List<String>? siteIds,
  });

  Future<void> revokeInvitation(String organisationId, String invitationId);

  Future<Member> updateMember(String organisationId, String userId, {required Role role, List<String>? siteIds});

  Future<void> removeMember(String organisationId, String userId);

  Future<InvitationPreview> previewInvitation(String token);

  Future<Organisation> acceptInvitation(String token);
}
