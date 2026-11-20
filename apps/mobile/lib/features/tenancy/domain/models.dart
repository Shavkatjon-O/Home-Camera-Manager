import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_surveillance/features/alerting/domain/models.dart';

part 'models.freezed.dart';

/// What a member may do, from the least to the most.
enum Role {
  /// Can watch cameras and events.
  viewer,

  /// Can also control cameras and the arm mode.
  operator,

  /// Can also manage cameras, members and settings.
  admin,

  /// Has full control, including the organisation itself.
  owner;

  /// Returns whether this role is at least as powerful as [other].
  bool atLeast(Role other) => index >= other.index;
}

/// The kind of place a site is.
enum SiteKind {
  /// A home.
  home,

  /// A shop.
  store,

  /// An office.
  office,

  /// A warehouse.
  warehouse,

  /// Any other kind of place.
  other,
}

/// An organisation that owns sites and has members.
@freezed
abstract class Organisation with _$Organisation {
  /// Creates the organisation [id] named [name] where the user has [role].
  const factory Organisation({
    required String id,
    required String name,
    required Role role,
    @Default(false) bool facesEnabled,
    List<String>? siteScope,
  }) = _Organisation;
}

/// A place with cameras, such as a home or a shop.
@freezed
abstract class Site with _$Site {
  /// Creates the site [id] named [name] of the organisation [organisationId].
  ///
  /// [retentionDays] is how long events are kept; [ownRetentionDays] is the
  /// site's own choice, or null when the site follows the plan's limit.
  const factory Site({
    required String id,
    required String organisationId,
    required String name,
    required SiteKind kind,
    required String timezone,
    @Default(ArmMode.schedule) ArmMode armMode,
    @Default(30) int retentionDays,
    int? ownRetentionDays,
  }) = _Site;
}

/// A person who belongs to an organisation.
@freezed
abstract class Member with _$Member {
  /// Creates the member [userId] named [name] with [email] and [role].
  const factory Member({
    required String userId,
    required String name,
    required String email,
    required Role role,
    List<String>? siteIds,
    DateTime? lastActiveAt,
    @Default(false) bool you,
  }) = _Member;
}

/// Where an invitation stands.
enum InvitationState {
  /// The invitation can still be accepted.
  pending,

  /// The invitation was accepted.
  accepted,

  /// The invitation ran out of time.
  expired,

  /// The invitation was cancelled by an administrator.
  revoked,
}

/// An invitation to join an organisation.
@freezed
abstract class Invitation with _$Invitation {
  /// Creates the invitation [id] sent to [email] for [role] by [invitedBy].
  const factory Invitation({
    required String id,
    required String email,
    required Role role,
    List<String>? siteIds,
    required DateTime expiresAt,
    required String invitedBy,
    @Default(InvitationState.pending) InvitationState state,
  }) = _Invitation;
}

/// What an invited person sees before accepting.
@freezed
abstract class InvitationPreview with _$InvitationPreview {
  /// Creates a preview of the invitation identified by [token].
  const factory InvitationPreview({
    required String token,
    required String organisationName,
    required String invitedBy,
    required Role role,
    required List<String> siteNames,
    required DateTime expiresAt,
  }) = _InvitationPreview;
}
