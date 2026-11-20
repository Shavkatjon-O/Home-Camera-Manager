


class ApiFailure implements Exception {
  const ApiFailure(this.kind, [this.detail]);

  final FailureKind kind;
  final String? detail;

  @override
  String toString() => 'ApiFailure($kind, $detail)';
}

enum FailureKind {
  network,
  unauthorised,
  forbidden,
  notFound,
  conflict,
  invalid,
  unverified,
  expired,
  server,
  unknown,
}
