import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/managers/auth_manager.dart';
import 'auth_state.dart';

/// Cubit for managing authentication state
class AuthCubit extends Cubit<AuthState> {
  final AuthManager _authManager;

  AuthCubit(this._authManager) : super(const AuthInitial()) {
    _checkAuthStatus();
  }

  /// Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    final isAuth = await _authManager.isAuthenticated();
    if (isAuth) {
      final user = await _authManager.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    try {
      emit(const AuthLoading());
      final user = await _authManager.signIn(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      // Keep error state - UI will handle transition
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Sign up with email and password
  Future<void> signUp(String email, String password) async {
    try {
      emit(const AuthLoading());
      final user = await _authManager.signUp(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      // Keep error state - UI will handle transition
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authManager.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      // Keep error state - UI will handle it
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Check session
  Future<void> checkSession() async {
    await _checkAuthStatus();
  }
}
