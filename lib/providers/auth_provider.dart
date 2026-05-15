library;

import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';

import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../services/base_service.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final AuthUser? user;
  final String? errorMessage;
  final bool isInitialized;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
    this.isInitialized = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    AuthUser? user,
    String? errorMessage,
    bool clearError = false,
    bool? isInitialized,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    BaseService.onUnauthorized = handleUnauthorized;
    initialize();
  }

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await authService.restoreUser();
      state = AuthState(
        isLoading: false,
        isAuthenticated: user != null,
        user: user,
        isInitialized: true,
      );
    } catch (error) {
      state = AuthState(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: error.toString(),
        isInitialized: true,
      );
    }
  }

  Future<bool> login({
    required String login,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = await authService.login(login: login, password: password);
      state = AuthState(
        isLoading: false,
        isAuthenticated: true,
        user: session.user,
        isInitialized: true,
      );
      return true;
    } catch (error) {
      state = AuthState(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: error.toString(),
        isInitialized: true,
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = const AuthState(isInitialized: true);
    unawaited(authService.logout());
  }

  Future<void> handleUnauthorized() async {
    state = const AuthState(isInitialized: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
