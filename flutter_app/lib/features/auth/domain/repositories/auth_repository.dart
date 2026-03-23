import 'package:egranja_flutter/core/auth/auth_service.dart';

/// Contrato do repositorio de autenticacao.
///
/// Define as operacoes de autenticacao que a camada de apresentacao
/// pode invocar. A implementacao concreta delega para o [AuthService].
abstract class AuthRepository {
  /// Realiza login com credenciais do usuario.
  ///
  /// Retorna o [User] autenticado em caso de sucesso.
  /// Lanca [AuthException], [NetworkException] ou [ServerException] em caso de erro.
  Future<User> login(String username, String password);

  /// Registra um novo usuario no sistema.
  ///
  /// Retorna uma mensagem de sucesso.
  /// Lanca [ServerException] se o email ja estiver cadastrado.
  Future<String> register({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required String tipo,
  });

  /// Solicita reset de senha via email.
  ///
  /// Retorna uma mensagem informativa (sempre sucesso por seguranca).
  Future<String> forgotPassword(String email);

  /// Realiza logout, removendo tokens armazenados.
  Future<void> logout();

  /// Verifica se o usuario esta autenticado (token valido ou renovavel).
  Future<bool> isAuthenticated();

  /// Recupera o usuario atual a partir do token armazenado.
  ///
  /// Retorna `null` se nao houver usuario autenticado.
  Future<User?> getCurrentUser();
}
