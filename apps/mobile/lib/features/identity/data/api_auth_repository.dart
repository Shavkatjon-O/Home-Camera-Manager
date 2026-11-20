import 'dart:async';

import 'package:dio/dio.dart';
import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/core/network/client/http.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/features/identity/data/token_store.dart';
import 'package:smart_surveillance/features/identity/domain/auth_repository.dart';
import 'package:smart_surveillance/features/identity/domain/models.dart';

/// Signs in against the server with bearer tokens and keeps them in the
/// [TokenStore]. It is also the [ApiSession] the HTTP client authenticates with.
class ApiAuthRepository implements AuthRepository, ApiSession {
  /// Creates the repository; [site] reads the site requests act on.
  ApiAuthRepository({required this.store, required this.site, required this.platform});

  /// Where the session is kept between launches.
  final TokenStore store;

  /// Reads the selected site.
  final String? Function() site;

  /// The platform name sent with a new session, such as android.
  final String platform;

  /// The generated API, set once the HTTP client exists.
  late api.SurveillanceApi client;

  /// The current tokens, or null when signed out.
  AuthTokens? tokens;

  /// The signed-in account, or null when signed out.
  User? user;

  /// Announces that the session expired.
  final StreamController<void> expiredController = StreamController<void>.broadcast();

  /// Fires when the server refuses to refresh the session and the user must sign in again.
  Stream<void> get expirations => expiredController.stream;

  /// Options for calls that must go out without the bearer token.
  static final anonymous = Options(extra: {anonymousKey: true});

  @override
  String? get accessToken => tokens?.access;

  @override
  String? get siteId => site();

  @override
  Future<bool> refresh() async {
    final current = tokens;
    if (current == null) return false;
    try {
      final pair = await client.auth.refreshToken(
        body: api.RefreshRequest(refreshToken: current.refresh),
        options: anonymous,
      );
      await keep(pair);
      return true;
    } on DioException {
      return false;
    }
  }

  @override
  Future<void> expired() async {
    tokens = null;
    user = null;
    await store.clear();
    expiredController.add(null);
  }

  /// Stores the tokens from [pair] with the current account.
  Future<void> keep(api.TokenPair pair) async {
    tokens = AuthTokens(
      access: pair.accessToken,
      refresh: pair.refreshToken,
      sessionId: pair.session.uuid,
      accessExpiresAt: DateTime.now().add(Duration(seconds: pair.expiresIn)),
    );
    await store.write(tokens!, user);
  }

  /// Converts the server's account to the app's [User].
  static User userOf(api.AccountRead account) => User(
    id: account.uuid,
    name: account.name ?? account.username,
    email: account.email ?? account.username,
    verified: account.emailVerified,
  );

  @override
  Future<User?> restore() async {
    final stored = await store.read();
    if (stored == null) return null;
    tokens = stored.tokens;
    user = stored.user;
    try {
      final account = await guarded(() => client.auth.getAccount());
      user = userOf(account);
      await store.write(tokens!, user);
      return user;
    } on ApiFailure catch (failure) {
      if (failure.kind == FailureKind.network || failure.kind == FailureKind.server) {
        return stored.user;
      }
      tokens = null;
      user = null;
      await store.clear();
      return null;
    }
  }

  @override
  Future<User> signIn({required String email, required String password}) async {
    final pair = await guarded(
      () => client.auth.createToken(
        body: api.TokenRequest(
          email: email,
          password: password,
          deviceName: 'Smart Surveillance app',
          platform: platform,
        ),
        options: anonymous,
      ),
    );
    await keep(pair);
    final account = await guarded(() => client.auth.getAccount());
    user = userOf(account);
    await store.write(tokens!, user);
    return user!;
  }

  @override
  Future<SignUpResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final account = await guarded(
      () => client.auth.register(
        body: api.AccountRegister(email: email, password: password, name: name),
        options: anonymous,
      ),
    );
    return SignUpResult(email: account.email ?? email, needsVerification: !account.emailVerified);
  }

  @override
  Future<void> resendVerification(String email) => guarded(
    () => client.auth.resendVerification(
      body: api.EmailRequest(email: email),
      options: anonymous,
    ),
  );

  @override
  Future<User> verifyEmail({required String token}) async {
    final account = await guarded(
      () => client.auth.verifyEmail(
        body: api.VerifyEmail(token: token),
        options: anonymous,
      ),
    );
    return userOf(account);
  }

  @override
  Future<void> requestPasswordReset(String email) => guarded(
    () => client.auth.forgotPassword(
      body: api.EmailRequest(email: email),
      options: anonymous,
    ),
  );

  @override
  Future<void> resetPassword({required String token, required String password}) => guarded(
    () => client.auth.resetPassword(
      body: api.PasswordReset(token: token, password: password),
      options: anonymous,
    ),
  );

  @override
  Future<void> signOut() async {
    try {
      if (tokens != null) await guarded(() => client.auth.revokeToken());
    } on ApiFailure {
      // The local session goes either way; the server forgets it when the token expires.
    } finally {
      tokens = null;
      user = null;
      await store.clear();
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    await guarded(() => client.auth.deleteAccount(body: api.AccountDelete(password: password)));
    tokens = null;
    user = null;
    await store.clear();
  }

  @override
  Future<List<DeviceSession>> sessions() async {
    final list = await guarded(() => client.auth.listSessions());
    return [
      for (final session in list.items)
        DeviceSession(
          id: session.uuid,
          deviceName: session.name,
          platform: session.platform,
          createdAt: session.createdAt,
          lastUsedAt: session.lastUsedAt,
          current: session.current,
        ),
    ];
  }

  @override
  Future<void> revokeSession(String id) => guarded(() => client.auth.revokeSession(session: id));

  @override
  Future<User> updateProfile({required String name}) async {
    final account = await guarded(
      () => client.auth.updateAccount(body: api.AccountUpdate(name: name)),
    );
    user = userOf(account);
    if (tokens != null) await store.write(tokens!, user);
    return user!;
  }
}
