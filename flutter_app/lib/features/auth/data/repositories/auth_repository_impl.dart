import 'package:egranja_flutter/core/auth/auth_service.dart';
import 'package:egranja_flutter/features/auth/domain/repositories/auth_repository.dart';

/// Implementacao concreta do [AuthRepository].
///
/// Delega todas as operacoes para o [AuthService] do core, que gerencia
/// tokens JWT, armazenamento seguro e comunicacao com a API.
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl({required AuthService authService})
      : _authService = authService;

  @override
  Future<User> login(String username, String password) {
    return _authService.login(username, password);
  }

  @override
  Future<void> logout() {
    return _authService.logout();
  }

  @override
  Future<bool> isAuthenticated() {
    return _authService.isAuthenticated();
  }

  @override
  Future<User?> getCurrentUser() {
    return _authService.getUserFromToken();
  }
}
