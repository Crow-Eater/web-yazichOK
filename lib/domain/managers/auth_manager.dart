import '../../data/models/user.dart';

/// Interface for authentication operations
/// Mock implementation uses in-memory storage, real implementation will use Firebase/JWT
abstract class AuthManager {
  /// Sign in with email and password
  Future<User> signIn(String email, String password);

  /// Sign up with email and password
  Future<User> signUp(String email, String password, {String? fullName});

  /// Sign out current user
  Future<void> signOut();

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated();

  /// Get current user (null if not authenticated)
  Future<User?> getCurrentUser();

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;
}
