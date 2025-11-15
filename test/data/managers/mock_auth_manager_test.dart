import 'package:flutter_test/flutter_test.dart';
import 'package:yazich_ok/data/managers/mock_auth_manager.dart';

void main() {
  group('MockAuthManager', () {
    late MockAuthManager authManager;

    setUp(() {
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
      authManager.authStateChanges.listen(expectAsync1((user) {
        expect(user, isNotNull);
        expect(user!.email, 'test@example.com');
      }));

      await authManager.signIn('test@example.com', 'Password123');
    });
  });
}
