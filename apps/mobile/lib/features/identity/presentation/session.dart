import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/features/identity/domain/auth_repository.dart';
import 'package:smart_surveillance/features/identity/domain/models.dart';

part 'session.g.dart';
sealed class SessionState {
  const SessionState();
}

class SignedOut extends SessionState {
  const SignedOut();
}

class AwaitingVerification extends SessionState {
  const AwaitingVerification(this.email);

  final String email;
}

class SignedIn extends SessionState {
  const SignedIn(this.user);

  final User user;
}

@Riverpod(keepAlive: true)
class Session extends _$Session {
  ({String email, String password})? pending;

  @override
  Future<SessionState> build() async {
    final user = await ref.read(backendProvider).auth.restore();
    return user == null ? const SignedOut() : SignedIn(user);
  }

  AuthRepository get auth => ref.read(backendProvider).auth;

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

  Future<void> signUp(String name, String email, String password) async {
    final result = await auth.signUp(name: name, email: email, password: password);
    pending = (email: result.email, password: password);
    state = AsyncData(AwaitingVerification(result.email));
  }

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

  void cancelVerification() {
    pending = null;
    state = const AsyncData(SignedOut());
  }

  void updateUser(User user) => state = AsyncData(SignedIn(user));

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } finally {
      await ref.read(preferencesProvider).setSiteId(null);
      state = const AsyncData(SignedOut());
    }
  }

  void expired() => state = const AsyncData(SignedOut());

  Future<void> deleteAccount(String password) async {
    await auth.deleteAccount(password);
    await ref.read(preferencesProvider).setSiteId(null);
    state = const AsyncData(SignedOut());
  }
}

User? signedInUser(WidgetRef ref) {
  final value = ref.watch(sessionProvider).value;
  return value is SignedIn ? value.user : null;
}
