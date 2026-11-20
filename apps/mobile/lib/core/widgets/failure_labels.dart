import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/network/failure.dart';

extension FailureLabels on AppLocalizations {
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
      FailureKind.server => errorServer,
      FailureKind.unknown => errorUnknown,
    };
  }
}
