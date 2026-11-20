import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_surveillance/features/identity/domain/models.dart';

/// The signed-in session as stored on the phone: its tokens and the account
/// they belong to, so the app can open offline with the last known account.
class StoredSession {
  /// Creates a stored session.
  const StoredSession(this.tokens, this.user);

  /// The access and refresh tokens.
  final AuthTokens tokens;

  /// The account the tokens belong to, if it was loaded.
  final User? user;
}

/// Keeps the session in the platform's secure storage, the Android keystore on
/// Android, and never in shared preferences.
class TokenStore {
  /// Creates a store over [storage], or over the default secure storage.
  TokenStore([FlutterSecureStorage? storage]) : storage = storage ?? const FlutterSecureStorage();

  /// The secure storage the session is written to.
  final FlutterSecureStorage storage;

  /// The key the session is stored under.
  static const key = 'sss-session';

  /// Reads the stored session, or returns null when there is none or it is unreadable.
  Future<StoredSession?> read() async {
    try {
      final raw = await storage.read(key: key);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, Object?>;
      final tokens = AuthTokens(
        access: json['access']! as String,
        refresh: json['refresh']! as String,
        sessionId: json['session']! as String,
        accessExpiresAt: DateTime.parse(json['expires']! as String),
      );
      final user = json['user'] as Map<String, Object?>?;
      return StoredSession(
        tokens,
        user == null
            ? null
            : User(
                id: user['id']! as String,
                name: user['name']! as String,
                email: user['email']! as String,
                verified: user['verified'] as bool? ?? true,
              ),
      );
    } on Object {
      return null;
    }
  }

  /// Writes [tokens] and [user] in place of the stored session.
  Future<void> write(AuthTokens tokens, User? user) => storage.write(
    key: key,
    value: jsonEncode({
      'access': tokens.access,
      'refresh': tokens.refresh,
      'session': tokens.sessionId,
      'expires': tokens.accessExpiresAt.toIso8601String(),
      if (user != null)
        'user': {'id': user.id, 'name': user.name, 'email': user.email, 'verified': user.verified},
    }),
  );

  /// Removes the stored session.
  Future<void> clear() => storage.delete(key: key);
}
