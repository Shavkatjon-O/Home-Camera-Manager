import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_surveillance/features/alerting/domain/models.dart';

part 'models.freezed.dart';
enum Role {
  viewer,
  operator,
  admin,
  owner;

  bool atLeast(Role other) => index >= other.index;
}

enum SiteKind { home, store, office, warehouse, other }

@freezed
abstract class Organisation with _$Organisation {
  const factory Organisation({
    required String id,
    required String name,
    required Role role,
    @Default(false) bool facesEnabled,
    List<String>? siteScope,
  }) = _Organisation;
}

@freezed
abstract class Site with _$Site {
  const factory Site({
    required String id,
    required String organisationId,
    required String name,
    required SiteKind kind,
    required String timezone,
    @Default(ArmMode.schedule) ArmMode armMode,
    @Default(30) int retentionDays,
  }) = _Site;
}

@freezed
abstract class Member with _$Member {
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

enum InvitationState { pending, accepted, expired, revoked }

@freezed
abstract class Invitation with _$Invitation {
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

@freezed
abstract class InvitationPreview with _$InvitationPreview {
  const factory InvitationPreview({
    required String token,
    required String organisationName,
    required String invitedBy,
    required Role role,
    required List<String> siteNames,
    required DateTime expiresAt,
  }) = _InvitationPreview;
}
