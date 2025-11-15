import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yazich_ok/domain/managers/auth_manager.dart';
import 'package:yazich_ok/data/models/user.dart';
import 'package:yazich_ok/presentation/auth/cubit/auth_cubit.dart';
import 'package:yazich_ok/presentation/auth/cubit/auth_state.dart';

class MockAuthManager extends Mock implements AuthManager {}

void main() {
  group('AuthCubit', () {
    late AuthManager authManager;
    late User testUser;

    setUp(() {
      authManager = MockAuthManager();
      testUser = const User(
        id: '1',
        email: 'test@example.com',
        displayName: 'Test User',
      );
    });

    test('initial state is AuthInitial', () {
      when(() => authManager.isAuthenticated()).thenAnswer((_) async => false);
      final cubit = AuthCubit(authManager);
      expect(cubit.state, isA<AuthInitial>());
    });

    blocTest<AuthCubit, AuthState>(
      'emits [AuthUnauthenticated] when user is not authenticated on init',
      build: () {
        when(() => authManager.isAuthenticated()).thenAnswer((_) async => false);
        return AuthCubit(authManager);
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthAuthenticated] when user is already authenticated on init',
      build: () {
        when(() => authManager.isAuthenticated()).thenAnswer((_) async => true);
        when(() => authManager.getCurrentUser()).thenAnswer((_) async => testUser);
        return AuthCubit(authManager);
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        AuthAuthenticated(testUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signIn emits [AuthLoading, AuthAuthenticated] when successful',
      build: () {
        when(() => authManager.isAuthenticated()).thenAnswer((_) async => false);
        when(() => authManager.signIn(any(), any())).thenAnswer((_) async => testUser);
        return AuthCubit(authManager);
      },
      wait: const Duration(milliseconds: 100),
      act: (cubit) => cubit.signIn('test@example.com', 'password123'),
      skip: 1, // Skip the AuthUnauthenticated from constructor
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(testUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signIn emits [AuthLoading, AuthError, AuthUnauthenticated] when fails',
      build: () {
        when(() => authManager.isAuthenticated()).thenAnswer((_) async => false);
        when(() => authManager.signIn(any(), any()))
            .thenThrow(Exception('Invalid credentials'));
        return AuthCubit(authManager);
      },
      wait: const Duration(milliseconds: 100),
      act: (cubit) => cubit.signIn('test@example.com', 'wrongpassword'),
      skip: 1, // Skip the AuthUnauthenticated from constructor
      expect: () => [
        const AuthLoading(),
        const AuthError('Invalid credentials'),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signUp emits [AuthLoading, AuthAuthenticated] when successful',
      build: () {
        when(() => authManager.isAuthenticated()).thenAnswer((_) async => false);
        when(() => authManager.signUp(any(), any())).thenAnswer((_) async => testUser);
        return AuthCubit(authManager);
      },
      wait: const Duration(milliseconds: 100),
      act: (cubit) => cubit.signUp('test@example.com', 'password123', fullName: 'Test User'),
      skip: 1, // Skip the AuthUnauthenticated from constructor
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(testUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signUp emits [AuthLoading, AuthError, AuthUnauthenticated] when fails',
      build: () {
        when(() => authManager.isAuthenticated()).thenAnswer((_) async => false);
        when(() => authManager.signUp(any(), any()))
            .thenThrow(Exception('Email already exists'));
        return AuthCubit(authManager);
      },
      wait: const Duration(milliseconds: 100),
      act: (cubit) => cubit.signUp('test@example.com', 'password123'),
      skip: 1, // Skip the AuthUnauthenticated from constructor
      expect: () => [
        const AuthLoading(),
        const AuthError('Email already exists'),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signOut emits [AuthUnauthenticated] when successful',
      build: () {
        when(() => authManager.isAuthenticated()).thenAnswer((_) async => true);
        when(() => authManager.getCurrentUser()).thenAnswer((_) async => testUser);
        when(() => authManager.signOut()).thenAnswer((_) async => {});
        return AuthCubit(authManager);
      },
      wait: const Duration(milliseconds: 100),
      act: (cubit) => cubit.signOut(),
      skip: 1, // Skip the AuthAuthenticated from constructor
      expect: () => [
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signOut emits [AuthError] when fails',
      build: () {
        when(() => authManager.isAuthenticated()).thenAnswer((_) async => true);
        when(() => authManager.getCurrentUser()).thenAnswer((_) async => testUser);
        when(() => authManager.signOut()).thenThrow(Exception('Sign out failed'));
        return AuthCubit(authManager);
      },
      wait: const Duration(milliseconds: 100),
      act: (cubit) => cubit.signOut(),
      skip: 1, // Skip the AuthAuthenticated from constructor
      expect: () => [
        const AuthError('Sign out failed'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'checkSession checks authentication status',
      build: () {
        when(() => authManager.isAuthenticated()).thenAnswer((_) async => true);
        when(() => authManager.getCurrentUser()).thenAnswer((_) async => testUser);
        return AuthCubit(authManager);
      },
      act: (cubit) => cubit.checkSession(),
      verify: (_) {
        verify(() => authManager.isAuthenticated()).called(greaterThan(1));
      },
    );
  });
}
