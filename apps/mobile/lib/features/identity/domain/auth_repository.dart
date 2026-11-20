
import 'package:smart_surveillance/features/identity/domain/models.dart';
class SignUpResult {
  const SignUpResult({required this.email, required this.needsVerification});

  final String email;
  final bool needsVerification;
}

abstract interface class AuthRepository {
  Future<User?> restore();

  Future<User> signIn({required String email, required String password});

  Future<SignUpResult> signUp({required String name, required String email, required String password});

  Future<void> resendVerification(String email);

  Future<User> verifyEmail({required String token});

  Future<void> requestPasswordReset(String email);

  Future<void> resetPassword({required String token, required String password});

  Future<void> signOut();

  Future<void> deleteAccount(String password);

  Future<List<DeviceSession>> sessions();

  Future<void> revokeSession(String id);

  Future<User> updateProfile({required String name});
}
