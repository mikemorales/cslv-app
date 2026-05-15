library;

import '../config/api_config.dart';
import '../models/auth_user.dart';
import 'base_service.dart';

class AuthSession {
  final String token;
  final AuthUser user;

  const AuthSession({required this.token, required this.user});
}

class AuthService extends BaseService {
  Future<AuthSession> login({
    required String login,
    required String password,
  }) async {
    final response = await post(
      ApiConfig.login,
      data: {'login': login, 'password': password},
    );

    final token = response['token'] as String;
    final user = AuthUser.fromJson(
      Map<String, dynamic>.from(response['user'] as Map),
    );

    await BaseService.saveToken(token);
    await BaseService.saveUser(user.toJson());

    return AuthSession(token: token, user: user);
  }

  Future<void> logout() async {
    final token = await BaseService.readToken();

    await BaseService.clearSession();

    if (token == null || token.isEmpty) {
      return;
    }

    try {
      await post(
        ApiConfig.logout,
        headers: {
          'Authorization': 'Bearer $token',
          'X-Mobile-Token': token,
        },
      );
    } catch (_) {
      // Local logout should still proceed if backend token is already invalid.
    }
  }

  Future<AuthUser?> restoreUser() async {
    final token = await BaseService.readToken();
    final rawUser = await BaseService.readUser();

    if (token == null || token.isEmpty || rawUser == null) {
      return null;
    }

    return AuthUser.fromJson(rawUser);
  }
}

final authService = AuthService();
