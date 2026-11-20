import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';

/// Manages organisations, sites, members and invitations.
abstract interface class TenancyRepository {
  /// Returns the organisations the user belongs to.
  Future<List<Organisation>> organisations();

  /// Creates an organisation named [name].
  Future<Organisation> createOrganisation(String name);

  /// Returns the sites of the organisation [organisationId].
  Future<List<Site>> sites(String organisationId);

  /// Creates a site named [name] of [kind] in [timezone] for the organisation [organisationId].
  Future<Site> createSite({
    required String organisationId,
    required String name,
    required SiteKind kind,
    required String timezone,
  });

  /// Saves [site] and returns the stored site.
  Future<Site> updateSite(Site site);

  /// Sets the arm [mode] of the site [siteId] and returns the updated site.
  Future<Site> setArmMode(String siteId, ArmMode mode);

  /// Returns the current face recognition consent text and its version.
  Future<({String version, String? text})> facesConsent();

  /// Turns face recognition on or off for [organisationId], recording [consentVersion] when
  /// enabling.
  Future<Organisation> setFaces(String organisationId, bool enabled, {String? consentVersion});

  /// Returns the members of the organisation [organisationId].
  Future<List<Member>> members(String organisationId);

  /// Returns the open and past invitations of the organisation [organisationId].
  Future<List<Invitation>> invitations(String organisationId);

  /// Invites [email] to [organisationId] as [role], limited to [siteIds] when given.
  Future<Invitation> invite({
    required String organisationId,
    required String email,
    required Role role,
    List<String>? siteIds,
  });

  /// Cancels the invitation [invitationId] of [organisationId].
  Future<void> revokeInvitation(String organisationId, String invitationId);

  /// Changes the [role] and [siteIds] of the member [userId] of [organisationId].
  Future<Member> updateMember(
    String organisationId,
    String userId, {
    required Role role,
    List<String>? siteIds,
  });

  /// Removes the member [userId] from [organisationId].
  Future<void> removeMember(String organisationId, String userId);

  /// Returns what the invitation identified by [token] offers.
  Future<InvitationPreview> previewInvitation(String token);

  /// Accepts the invitation identified by [token] and returns the organisation joined.
  Future<Organisation> acceptInvitation(String token);
}
