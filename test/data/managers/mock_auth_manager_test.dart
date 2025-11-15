import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yazich_ok/data/managers/mock_auth_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockAuthManager', () {
    late MockAuthManager authManager;

    setUp(() async {
      // Initialize SharedPreferences with empty values for testing
      SharedPreferences.setMockInitialValues({});
      authManager = MockAuthManager();
    });

    tearDown(() {
      authManager.dispose();
    });

    test('signIn with valid credentials succeeds', () async {
      final user = await authManager.signIn('test@example.com', 'Password123');

      expect(user.email, 'test@example.com');
      expect(user.displayName, 'test');
    });

    test('signIn with invalid credentials fails', () async {
      expect(
        () => authManager.signIn('test@example.com', 'WrongPassword'),
        throwsException,
      );
    });

    test('signUp with new email succeeds', () async {
      final user = await authManager.signUp('new@test.com', 'password123');

      expect(user.email, 'new@test.com');
      expect(user.displayName, 'new');
    });

    test('signUp with existing email fails', () async {
      expect(
        () => authManager.signUp('test@example.com', 'password123'),
        throwsException,
      );
    });

    test('isAuthenticated returns false initially', () async {
      final isAuth = await authManager.isAuthenticated();
      expect(isAuth, isFalse);
    });

    test('isAuthenticated returns true after sign in', () async {
      await authManager.signIn('test@example.com', 'Password123');
      final isAuth = await authManager.isAuthenticated();
      expect(isAuth, isTrue);
    });

    test('getCurrentUser returns null initially', () async {
      final user = await authManager.getCurrentUser();
      expect(user, isNull);
    });

    test('getCurrentUser returns user after sign in', () async {
      await authManager.signIn('test@example.com', 'Password123');
      final user = await authManager.getCurrentUser();
      expect(user, isNotNull);
      expect(user!.email, 'test@example.com');
    });

    test('signOut clears current user', () async {
      await authManager.signIn('test@example.com', 'Password123');
      await authManager.signOut();

      final isAuth = await authManager.isAuthenticated();
      expect(isAuth, isFalse);

      final user = await authManager.getCurrentUser();
      expect(user, isNull);
    });

    test('authStateChanges emits user on sign in', () async {
      // Listen to the stream before signing in
      final streamFuture = authManager.authStateChanges.first;

      await authManager.signIn('test@example.com', 'Password123');

      // Wait for the stream to emit
      final user = await streamFuture.timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );

      expect(user, isNotNull);
      expect(user!.email, 'test@example.com');
    });
  });
}
