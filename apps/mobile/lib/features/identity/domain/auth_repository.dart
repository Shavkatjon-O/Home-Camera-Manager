
import 'package:smart_surveillance/features/identity/domain/models.dart';
/// The outcome of creating an account.
class SignUpResult {
  /// Creates a result for the account [email] that may need [needsVerification].
  const SignUpResult({required this.email, required this.needsVerification});

  /// The email address the account was created with.
  final String email;
  /// Whether the user must confirm the email address before signing in.
  final bool needsVerification;
}

/// Signs users in and out and manages their account and sessions.
abstract interface class AuthRepository {
  /// Returns the user of the stored session, or null when nobody is signed in.
  Future<User?> restore();

  /// Signs in with [email] and [password] and returns the user.
  Future<User> signIn({required String email, required String password});

  /// Creates an account for [name] with [email] and [password].
  Future<SignUpResult> signUp({required String name, required String email, required String password});

  /// Sends the verification email to [email] again.
  Future<void> resendVerification(String email);

  /// Confirms an email address with the emailed [token] and returns the user.
  Future<User> verifyEmail({required String token});

  /// Sends a password reset email to [email].
  Future<void> requestPasswordReset(String email);

  /// Sets a new [password] using the emailed reset [token].
  Future<void> resetPassword({required String token, required String password});

  /// Ends the current session.
  Future<void> signOut();

  /// Deletes the account after checking [password].
  Future<void> deleteAccount(String password);

  /// Returns the devices signed in to the account.
  Future<List<DeviceSession>> sessions();

  /// Signs out the device session [id].
  Future<void> revokeSession(String id);

  /// Changes the user's display [name] and returns the updated user.
  Future<User> updateProfile({required String name});
}
