import 'dart:async';

import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/features/identity/domain/auth_repository.dart';
import 'package:smart_surveillance/features/identity/domain/models.dart';

/// An in-memory authentication repository backed by a [FakeStore].
class FakeAuthRepository implements AuthRepository {
  /// Creates a repository that keeps its accounts in [store].
  FakeAuthRepository(this.store);

  /// The shared fake data store.
  final FakeStore store;

  @override
  Future<User?> restore() => store.delay(() => store.signedIn ? store.data.user : null);

  @override
  Future<User> signIn({required String email, required String password}) => store.delay(() {
    if (password.length < 4) throw const ApiFailure(FailureKind.unauthorised);
    store.signedIn = true;
    return store.data.user;
  });

  @override
  Future<SignUpResult> signUp({
    required String name,
    required String email,
    required String password,
  }) => store.delay(() {
    if (email.startsWith('taken@')) throw const ApiFailure(FailureKind.conflict);
    store.data.user = User(id: 'user-new', name: name, email: email, verified: false);
    store.fresh = true;
    return SignUpResult(email: email, needsVerification: true);
  });

  @override
  Future<void> resendVerification(String email) => store.delay(() {});

  @override
  Future<User> verifyEmail({required String token}) => store.delay(() {
    if (token.length < 6) throw const ApiFailure(FailureKind.invalid);
    store.data.user = store.data.user.copyWith(verified: true);
    return store.data.user;
  });

  @override
  Future<void> requestPasswordReset(String email) => store.delay(() {});

  @override
  Future<void> resetPassword({required String token, required String password}) => store.delay(() {
    if (token.length < 6) throw const ApiFailure(FailureKind.invalid);
  });

  @override
  Future<void> signOut() => store.delay(() => store.signedIn = false);

  @override
  Future<void> deleteAccount(String password) => store.delay(() {
    if (password.isEmpty) throw const ApiFailure(FailureKind.unauthorised);
    store.signedIn = false;
  });

  @override
  Future<List<DeviceSession>> sessions() => store.delay(() => List.of(store.data.sessions));

  @override
  Future<void> revokeSession(String id) =>
      store.delay(() => store.data.sessions.removeWhere((s) => s.id == id));

  @override
  Future<User> updateProfile({required String name}) => store.delay(() {
    store.data.user = store.data.user.copyWith(name: name);
    return store.data.user;
  });
}
