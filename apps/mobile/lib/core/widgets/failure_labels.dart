import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/network/failure.dart';

/// Adds translated messages for failures to [AppLocalizations].
extension FailureLabels on AppLocalizations {
  /// Returns the message describing [error], or a generic one when it is not an [ApiFailure].
  String failure(Object error) {
    if (error is! ApiFailure) return errorUnknown;
    return switch (error.kind) {
      FailureKind.network => errorNetwork,
      FailureKind.unauthorised => errorUnauthorised,
      FailureKind.forbidden => errorForbidden,
      FailureKind.notFound => errorNotFound,
      FailureKind.conflict => errorConflict,
      FailureKind.invalid => errorInvalid,
      FailureKind.unverified => errorUnauthorised,
      FailureKind.expired => errorExpired,
      FailureKind.tooMany => errorTooMany,
      FailureKind.planFeature => errorPlanFeature,
      FailureKind.planLimit => errorPlanLimit,
      FailureKind.suspended => errorSuspended,
      FailureKind.server => errorServer,
      FailureKind.unknown => errorUnknown,
    };
  }
}
