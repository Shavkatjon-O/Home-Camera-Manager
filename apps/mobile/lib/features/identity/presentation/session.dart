import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/features/identity/domain/auth_repository.dart';
import 'package:smart_surveillance/features/identity/domain/models.dart';

part 'session.g.dart';

/// The authentication state of the app.
sealed class SessionState {
  const SessionState();
}

/// No user is signed in.
class SignedOut extends SessionState {
  /// Creates the signed-out state.
  const SignedOut();
}

/// A user signed up or signed in but has not confirmed the email address yet.
class AwaitingVerification extends SessionState {
  /// Creates the state for the unverified address [email].
  const AwaitingVerification(this.email);

  /// The address that still has to be confirmed.
  final String email;
}

/// A user is signed in.
class SignedIn extends SessionState {
  /// Creates the state for [user].
  const SignedIn(this.user);

  /// The signed-in user.
  final User user;
}

/// Holds the authentication state and the actions that change it.
@Riverpod(keepAlive: true)
class Session extends _$Session {
  /// The credentials kept while the email is unverified, so the user is signed in once it is
  /// confirmed.
  ({String email, String password})? pending;

  @override
  Future<SessionState> build() async {
    final user = await ref.read(backendProvider).auth.restore();
    return user == null ? const SignedOut() : SignedIn(user);
  }

  /// The authentication repository of the current backend.
  AuthRepository get auth => ref.read(backendProvider).auth;

  /// Signs in with [email] and [password], waiting for verification when the address is
  /// unconfirmed.
  Future<void> signIn(String email, String password) async {
    try {
      final user = await auth.signIn(email: email, password: password);
      pending = null;
      state = AsyncData(SignedIn(user));
    } on ApiFailure catch (failure) {
      if (failure.kind == FailureKind.unverified) {
        pending = (email: email, password: password);
        state = AsyncData(AwaitingVerification(email));
        return;
      }
      rethrow;
    }
  }

  /// Creates an account for [name] and waits for the address [email] to be verified.
  Future<void> signUp(String name, String email, String password) async {
    final result = await auth.signUp(name: name, email: email, password: password);
    pending = (email: result.email, password: password);
    state = AsyncData(AwaitingVerification(result.email));
  }

  /// Confirms the email with [token] and signs in; returns false when no credentials were kept.
  Future<bool> verify(String token) async {
    await auth.verifyEmail(token: token);
    final credentials = pending;
    if (credentials == null) {
      state = const AsyncData(SignedOut());
      return false;
    }
    await signIn(credentials.email, credentials.password);
    return true;
  }

  /// Abandons verification and returns to the signed-out state.
  void cancelVerification() {
    pending = null;
    state = const AsyncData(SignedOut());
  }

  /// Replaces the signed-in user with the updated [user].
  void updateUser(User user) => state = AsyncData(SignedIn(user));

  /// Signs out and forgets the selected site.
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } finally {
      await ref.read(preferencesProvider).setSiteId(null);
      state = const AsyncData(SignedOut());
    }
  }

  /// Marks the session as signed out after the server rejected it.
  void expired() => state = const AsyncData(SignedOut());

  /// Deletes the account after checking [password] and signs out.
  Future<void> deleteAccount(String password) async {
    await auth.deleteAccount(password);
    await ref.read(preferencesProvider).setSiteId(null);
    state = const AsyncData(SignedOut());
  }
}

/// Returns the signed-in user, or null when nobody is signed in.
User? signedInUser(WidgetRef ref) {
  final value = ref.watch(sessionProvider).value;
  return value is SignedIn ? value.user : null;
}
