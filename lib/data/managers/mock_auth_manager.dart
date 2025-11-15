import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/managers/auth_manager.dart';
import '../models/user.dart';
import '../mock_data/mock_auth_data.dart';

/// Mock implementation of AuthManager with SharedPreferences persistence
class MockAuthManager implements AuthManager {
  // In-memory storage for registered users
  final Map<String, String> _users = Map.from(mockUserCredentials);

  // Currently authenticated user
  User? _currentUser;

  // Stream controller for auth state changes
  final _authStateController = StreamController<User?>.broadcast();

  // SharedPreferences keys
  static const String _userKey = 'auth_user';
  static const String _emailKey = 'auth_email';

  // Flag to track if we've loaded from persistence
  bool _hasLoadedFromPersistence = false;

  MockAuthManager();

  /// Load persisted user from SharedPreferences
  Future<void> _loadPersistedUser() async {
    if (_hasLoadedFromPersistence) return;

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
        _authStateController.add(_currentUser);
      } catch (e) {
        // If parsing fails, clear stored data
        await _clearPersistedUser();
      }
    }

    _hasLoadedFromPersistence = true;
  }

  /// Persist user to SharedPreferences
  Future<void> _persistUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setString(_emailKey, user.email);
  }

  /// Clear persisted user from SharedPreferences
  Future<void> _clearPersistedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_emailKey);
  }

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
    await _persistUser(user);
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
    await _persistUser(user);
    _authStateController.add(user);

    return user;
  }

  @override
  Future<void> signOut() async {
    await _simulateDelay();
    _currentUser = null;
    await _clearPersistedUser();
    _authStateController.add(null);
  }

  @override
  Future<bool> isAuthenticated() async {
    await _loadPersistedUser();
    return _currentUser != null;
  }

  @override
  Future<User?> getCurrentUser() async {
    await _loadPersistedUser();
    return _currentUser;
  }

  void dispose() {
    _authStateController.close();
  }
}
