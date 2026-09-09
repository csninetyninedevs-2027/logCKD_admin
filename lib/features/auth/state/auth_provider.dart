import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/admin.dart';

class AuthState {
  const AuthState({
    this.admin,
    this.isLoading = false,
    this.errorMessage,
  });

  final Admin? admin;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => admin != null;

  AuthState copyWith({
    Admin? admin,
    bool clearAdmin = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      admin: clearAdmin ? null : (admin ?? this.admin),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState()) {
    _restoreSession();
  }

  final Ref _ref;

  Dio get _dio => _ref.read(dioProvider);

  Future<void> _restoreSession() async {
    final tokenStorage = _ref.read(tokenStorageProvider);
    final token = await tokenStorage.getAccessToken();

    if (token == null) return;

    try {
      final response = await _dio.get('/auth/me');
      final admin = Admin.fromJson(
        response.data['admin'] as Map<String, dynamic>,
      );
      state = state.copyWith(admin: admin);
    } catch (_) {
      await tokenStorage.clear();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final tokenStorage = _ref.read(tokenStorageProvider);
      await tokenStorage.saveTokens(
        accessToken: response.data['accessToken'] as String,
        refreshToken: response.data['refreshToken'] as String,
      );

      final admin = Admin.fromJson(
        response.data['admin'] as Map<String, dynamic>,
      );

      state = state.copyWith(admin: admin, isLoading: false);
    } on DioException catch (error) {
      final message = error.response?.data is Map
          ? (error.response?.data['error'] as String? ?? 'Login failed')
          : 'Unable to reach the server';

      state = state.copyWith(isLoading: false, errorMessage: message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> logout() async {
    final tokenStorage = _ref.read(tokenStorageProvider);
    final refreshToken = await tokenStorage.getRefreshToken();

    try {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (_) {}

    await tokenStorage.clear();
    state = state.copyWith(clearAdmin: true);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
