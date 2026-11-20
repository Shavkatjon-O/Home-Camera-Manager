import 'dart:async';

import 'package:dio/dio.dart';
import 'package:smart_surveillance/core/network/failure.dart';

/// What the HTTP client needs from the signed-in session.
abstract interface class ApiSession {
  /// The current access token, or null when signed out.
  String? get accessToken;

  /// The site requests act on, sent as the X-Site header.
  String? get siteId;

  /// Exchanges the refresh token for new tokens and returns whether it worked.
  Future<bool> refresh();

  /// Forgets the session after the server refused to refresh it.
  Future<void> expired();
}

/// The request option that marks a request as already retried after a refresh.
const retriedKey = 'sss-retried';

/// The request option that keeps the bearer token and refresh away from a request.
const anonymousKey = 'sss-anonymous';

/// Builds the Dio client for the API at [baseUrl], authenticated through [session].
Dio createDio(String baseUrl, ApiSession session) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
  dio.interceptors.add(AuthInterceptor(dio, session));
  return dio;
}

/// Adds the bearer token and the site to each request and refreshes the
/// session once when the server answers 401.
///
/// Concurrent requests that fail together share one refresh, because the
/// server revokes the whole session when a refresh token is used twice.
class AuthInterceptor extends Interceptor {
  /// Creates the interceptor for [dio] and [session].
  AuthInterceptor(this.dio, this.session);

  /// The client that retries a request after a refresh.
  final Dio dio;

  /// The session that holds the tokens.
  final ApiSession session;

  /// The refresh in flight, which concurrent failures wait on.
  Future<bool>? refreshing;

  /// Refreshes the session and forgets it once when the server refuses.
  Future<bool> renew() async {
    final ok = await session.refresh();
    if (!ok) await session.expired();
    return ok;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = session.accessToken;
    if (token != null && options.extra[anonymousKey] != true) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    final site = session.siteId;
    if (site != null && !options.headers.containsKey('X-Site')) options.headers['X-Site'] = site;
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final unauthorised = err.response?.statusCode == 401;
    if (!unauthorised || options.extra[retriedKey] == true || options.extra[anonymousKey] == true) {
      handler.next(err);
      return;
    }
    final sent = options.headers['Authorization'];
    final current = session.accessToken;
    bool renewed;
    if (current != null && sent != 'Bearer $current') {
      renewed = true;
    } else {
      renewed = await (refreshing ??= renew().whenComplete(() => refreshing = null));
    }
    if (!renewed) {
      handler.next(err);
      return;
    }
    try {
      options.extra[retriedKey] = true;
      options.headers.remove('Authorization');
      handler.resolve(await dio.fetch<Object?>(options));
    } on DioException catch (again) {
      handler.next(again);
    }
  }
}

/// Runs [call] and turns any transport or HTTP error into an [ApiFailure].
Future<T> guarded<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (error) {
    throw failureOf(error);
  }
}

/// Maps a Dio error to the app's [ApiFailure], reading the server's error code
/// from its `{"detail": {"code", "message"}}` body.
ApiFailure failureOf(DioException error) {
  final response = error.response;
  if (response == null) return ApiFailure(FailureKind.network, error.message);
  final (code, message) = errorDetail(response.data);
  final kind = switch (response.statusCode ?? 0) {
    422 when code == 'retention_over_plan' => FailureKind.planLimit,
    400 || 422 => FailureKind.invalid,
    401 =>
      code == 'refresh_token_reused' || code == 'token_expired'
          ? FailureKind.expired
          : FailureKind.unauthorised,
    403 => switch (code) {
      'email_not_verified' => FailureKind.unverified,
      'feature_not_in_plan' => FailureKind.planFeature,
      'plan_limit_reached' => FailureKind.planLimit,
      'organisation_suspended' => FailureKind.suspended,
      _ => FailureKind.forbidden,
    },
    404 => FailureKind.notFound,
    409 => FailureKind.conflict,
    410 => FailureKind.expired,
    429 => FailureKind.tooMany,
    >= 500 => FailureKind.server,
    _ => FailureKind.unknown,
  };
  return ApiFailure(kind, message ?? code);
}

/// Reads the error code and message from an error body, which is either the
/// API's own detail object or a list of validation errors.
(String?, String?) errorDetail(Object? body) {
  if (body is! Map) return (null, null);
  final detail = body['detail'];
  if (detail is Map) return (detail['code'] as String?, detail['message'] as String?);
  if (detail is String) return (null, detail);
  if (detail is List && detail.isNotEmpty && detail.first is Map) {
    final first = detail.first as Map;
    return ('validation', first['msg'] as String?);
  }
  return (null, null);
}
