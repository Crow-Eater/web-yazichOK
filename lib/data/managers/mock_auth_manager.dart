import 'dart:async';
import '../../domain/managers/auth_manager.dart';
import '../models/user.dart';
import '../mock_data/mock_auth_data.dart';

/// Mock implementation of AuthManager using in-memory storage
class MockAuthManager implements AuthManager {
  // In-memory storage for registered users
  final Map<String, String> _users = Map.from(mockUserCredentials);

  // Currently authenticated user
  User? _currentUser;

  // Stream controller for auth state changes
  final _authStateController = StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<User> signIn(String email, String password) async {
    await _simulateDelay();

    final storedPassword = _users[email];
    if (storedPassword == null || storedPassword != password) {
      throw Exception('Invalid email or password');
    }

    final user = User(
      id: 'user-${email.hashCode}',
      email: email,
      displayName: email.split('@').first,
    );

    _currentUser = user;
    _authStateController.add(user);

    return user;
  }

  @override
  Future<User> signUp(String email, String password) async {
    await _simulateDelay();

    if (_users.containsKey(email)) {
      throw Exception('Email already registered');
    }

    _users[email] = password;

    final user = User(
      id: 'user-${email.hashCode}',
      email: email,
      displayName: email.split('@').first,
    );

    _currentUser = user;
    _authStateController.add(user);

    return user;
  }

  @override
  Future<void> signOut() async {
    await _simulateDelay();
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<bool> isAuthenticated() async {
    return _currentUser != null;
  }

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  void dispose() {
    _authStateController.close();
  }
}
