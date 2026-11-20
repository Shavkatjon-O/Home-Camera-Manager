/// An error from the server or network, reduced to a [FailureKind] the UI can explain.
class ApiFailure implements Exception {
  /// Creates a failure of [kind] with an optional technical [detail].
  const ApiFailure(this.kind, [this.detail]);

  /// The category of the failure.
  final FailureKind kind;

  /// The technical message from the server or client, when there is one.
  final String? detail;

  @override
  String toString() => 'ApiFailure($kind, $detail)';
}

/// The category of an [ApiFailure].
enum FailureKind {
  /// The server could not be reached.
  network,

  /// The user is not signed in or the session is invalid.
  unauthorised,

  /// The user is signed in but not allowed to do this.
  forbidden,

  /// The requested item does not exist.
  notFound,

  /// The change clashes with the current state, such as a duplicate.
  conflict,

  /// The server rejected the submitted data.
  invalid,

  /// The user's email address is not verified yet.
  unverified,

  /// A code or link has expired.
  expired,

  /// The server failed to handle the request.
  server,

  /// Any other failure.
  unknown,
}
