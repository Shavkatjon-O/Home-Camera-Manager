import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_surveillance/core/network/client/http.dart';
import 'package:smart_surveillance/core/network/failure.dart';

/// Builds a Dio error with [status] and [body], or without a response when [status] is null.
DioException errorWith(int? status, [Object? body]) {
  final options = RequestOptions(path: '/things');
  return DioException(
    requestOptions: options,
    message: 'transport',
    response: status == null
        ? null
        : Response<Object?>(requestOptions: options, statusCode: status, data: body),
  );
}

/// Wraps [code] and [message] in the API's error body.
Map<String, Object?> detail(String code, [String message = 'Something went wrong']) => {
  'detail': {'code': code, 'message': message},
};

/// A client adapter that answers each request through [respond] after a short pause.
class ScriptedAdapter implements HttpClientAdapter {
  /// Creates an adapter that answers with [respond].
  ScriptedAdapter(this.respond);

  /// Chooses the response for a request.
  final ResponseBody Function(RequestOptions options) respond;

  /// The requests seen so far, in order.
  final requests = <RequestOptions>[];

  /// The Authorization header each request carried when it was sent.
  final sent = <String?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    sent.add(options.headers['Authorization'] as String?);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

/// Builds a JSON response body with [status].
ResponseBody jsonBody(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

/// A session that swaps its token on refresh.
class FakeSession implements ApiSession {
  /// Creates a session holding [token] whose refresh ends with [refreshes].
  FakeSession({this.token = 'old', this.refreshes = true, this.site});

  /// The current access token.
  String? token;

  /// Whether a refresh succeeds.
  final bool refreshes;

  /// The site header value.
  final String? site;

  /// How many times refresh was called.
  int refreshCalls = 0;

  /// How many times the session was reported expired.
  int expiredCalls = 0;

  @override
  String? get accessToken => token;

  @override
  String? get siteId => site;

  @override
  Future<bool> refresh() async {
    refreshCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    if (refreshes) token = 'new';
    return refreshes;
  }

  @override
  Future<void> expired() async => expiredCalls++;
}

/// Runs the HTTP client tests.
void main() {
  group('failureOf', () {
    test('maps a plain 401 to unauthorised', () {
      final failure = failureOf(errorWith(401, detail('invalid_credentials', 'Wrong password')));
      expect(failure.kind, FailureKind.unauthorised);
      expect(failure.detail, 'Wrong password');
    });

    test('maps a reused refresh token to expired', () {
      expect(failureOf(errorWith(401, detail('refresh_token_reused'))).kind, FailureKind.expired);
    });

    test('maps 403 by its code', () {
      expect(failureOf(errorWith(403, detail('email_not_verified'))).kind, FailureKind.unverified);
      expect(failureOf(errorWith(403, detail('role_too_low'))).kind, FailureKind.forbidden);
    });

    test('maps the other statuses', () {
      expect(failureOf(errorWith(404, detail('not_found'))).kind, FailureKind.notFound);
      expect(failureOf(errorWith(409, detail('exists'))).kind, FailureKind.conflict);
      expect(failureOf(errorWith(410, detail('gone'))).kind, FailureKind.expired);
      expect(failureOf(errorWith(429, detail('slow_down'))).kind, FailureKind.tooMany);
      expect(failureOf(errorWith(500)).kind, FailureKind.server);
      expect(failureOf(errorWith(503, 'Bad gateway')).kind, FailureKind.server);
      expect(failureOf(errorWith(418)).kind, FailureKind.unknown);
    });

    test('reads the first message of a FastAPI validation list', () {
      final failure = failureOf(
        errorWith(422, {
          'detail': [
            {
              'loc': ['body', 'email'],
              'msg': 'value is not a valid email address',
              'type': 'value_error',
            },
          ],
        }),
      );
      expect(failure.kind, FailureKind.invalid);
      expect(failure.detail, 'value is not a valid email address');
    });

    test('maps a connection error without a response to network', () {
      final failure = failureOf(errorWith(null));
      expect(failure.kind, FailureKind.network);
      expect(failure.detail, 'transport');
    });

    test('falls back to the code when there is no message', () {
      final failure = failureOf(
        errorWith(409, {
          'detail': {'code': 'site_exists'},
        }),
      );
      expect(failure.detail, 'site_exists');
    });
  });

  group('errorDetail', () {
    test('reads a detail object', () {
      expect(errorDetail(detail('code_a', 'Message A')), ('code_a', 'Message A'));
    });

    test('reads a detail string', () {
      expect(errorDetail({'detail': 'Not found'}), (null, 'Not found'));
    });

    test('reads a validation list as the validation code', () {
      expect(
        errorDetail({
          'detail': [
            {'msg': 'field required'},
          ],
        }),
        ('validation', 'field required'),
      );
    });

    test('ignores bodies of other shapes', () {
      expect(errorDetail(null), (null, null));
      expect(errorDetail('plain text'), (null, null));
      expect(errorDetail(<String, Object?>{}), (null, null));
      expect(errorDetail({'detail': <Object?>[]}), (null, null));
      expect(errorDetail({'detail': 7}), (null, null));
    });
  });

  group('guarded', () {
    test('turns a Dio error into an ApiFailure', () async {
      await expectLater(
        guarded<void>(() async => throw errorWith(404, detail('missing'))),
        throwsA(isA<ApiFailure>().having((f) => f.kind, 'kind', FailureKind.notFound)),
      );
    });

    test('returns the result of a call that works', () async {
      expect(await guarded(() async => 42), 42);
    });
  });

  group('AuthInterceptor', () {
    Dio build(FakeSession session, ScriptedAdapter adapter) {
      final dio = createDio('http://api.example.com', session);
      dio.httpClientAdapter = adapter;
      return dio;
    }

    test('adds the bearer token and the site header', () async {
      final session = FakeSession(site: 'site-1');
      final adapter = ScriptedAdapter((_) => jsonBody(200, {'ok': true}));
      await build(session, adapter).get<Object?>('/ping');
      expect(adapter.requests.single.headers['Authorization'], 'Bearer old');
      expect(adapter.requests.single.headers['X-Site'], 'site-1');
    });

    test('keeps the token off anonymous requests', () async {
      final session = FakeSession();
      final adapter = ScriptedAdapter((_) => jsonBody(200, {'ok': true}));
      await build(
        session,
        adapter,
      ).get<Object?>('/ping', options: Options(extra: {anonymousKey: true}));
      expect(adapter.requests.single.headers.containsKey('Authorization'), isFalse);
    });

    test('does not refresh an anonymous request that fails with 401', () async {
      final session = FakeSession();
      final adapter = ScriptedAdapter((_) => jsonBody(401, detail('invalid_credentials')));
      final dio = build(session, adapter);
      await expectLater(
        dio.post<Object?>('/login', options: Options(extra: {anonymousKey: true})),
        throwsA(isA<DioException>()),
      );
      expect(session.refreshCalls, 0);
      expect(adapter.requests, hasLength(1));
    });

    test('shares one refresh between concurrent 401 failures', () async {
      final session = FakeSession();
      final adapter = ScriptedAdapter(
        (options) => options.headers['Authorization'] == 'Bearer new'
            ? jsonBody(200, {'path': options.path})
            : jsonBody(401, detail('token_invalid')),
      );
      final dio = build(session, adapter);
      final results = await Future.wait([
        dio.get<Map<String, Object?>>('/first'),
        dio.get<Map<String, Object?>>('/second'),
      ]);
      expect(session.refreshCalls, 1);
      expect(session.expiredCalls, 0);
      expect(results.map((r) => r.statusCode), [200, 200]);
      expect(results.map((r) => r.data!['path']), ['/first', '/second']);
      expect(adapter.sent, ['Bearer old', 'Bearer old', 'Bearer new', 'Bearer new']);
    });

    test('reports the session expired when the refresh fails', () async {
      final session = FakeSession(refreshes: false);
      final adapter = ScriptedAdapter((_) => jsonBody(401, detail('token_invalid')));
      final dio = build(session, adapter);
      await expectLater(
        dio.get<Object?>('/things'),
        throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 401)),
      );
      expect(session.refreshCalls, 1);
      expect(session.expiredCalls, 1);
      expect(adapter.requests, hasLength(1));
    });

    test('retries a request only once', () async {
      final session = FakeSession();
      final adapter = ScriptedAdapter((_) => jsonBody(401, detail('token_invalid')));
      final dio = build(session, adapter);
      await expectLater(dio.get<Object?>('/things'), throwsA(isA<DioException>()));
      expect(session.refreshCalls, 1);
      expect(adapter.requests, hasLength(2));
    });

    test('passes other errors through without a refresh', () async {
      final session = FakeSession();
      final adapter = ScriptedAdapter((_) => jsonBody(500, detail('boom')));
      await expectLater(
        build(session, adapter).get<Object?>('/things'),
        throwsA(isA<DioException>()),
      );
      expect(session.refreshCalls, 0);
    });
  });
}
