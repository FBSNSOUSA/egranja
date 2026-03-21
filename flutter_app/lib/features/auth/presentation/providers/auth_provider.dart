import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/auth/auth_service.dart';
import 'package:egranja_flutter/core/auth/secure_storage.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:egranja_flutter/features/auth/domain/repositories/auth_repository.dart';

// ── Estado de autenticacao ──────────────────────────────────────────────

/// Status possivel do fluxo de autenticacao.
enum AuthStatus {
  /// Estado inicial antes de qualquer verificacao.
  initial,

  /// Verificacao ou login em andamento.
  loading,

  /// Usuario autenticado com sucesso.
  authenticated,

  /// Usuario nao autenticado (token ausente, expirado ou logout).
  unauthenticated,

  /// Ocorreu um erro durante login ou verificacao.
  error,
}

/// Estado imutavel de autenticacao.
///
/// Contem o [status] atual, o [user] autenticado (se houver) e a
/// [errorMessage] em caso de erro.
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() =>
      'AuthState(status: $status, user: $user, error: $errorMessage)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          user == other.user &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(status, user, errorMessage);
}

// ── Providers de infraestrutura ─────────────────────────────────────────

/// Provider do [SecureStorage].
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// Provider do [AuthService].
final authServiceProvider = Provider<AuthService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthService(storage: storage);
});

/// Provider do [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepositoryImpl(authService: authService);
});

// ── AuthNotifier ────────────────────────────────────────────────────────

/// Gerenciador de estado de autenticacao.
///
/// Expoe metodos para login, logout, verificacao de sessao e limpeza
/// de erros. Utiliza [AuthRepository] para operacoes de dados.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier({required AuthRepository repository})
      : _repository = repository,
        super(const AuthState());

  /// Verifica se ha uma sessao valida armazenada.
  ///
  /// Chamado na inicializacao do app para auto-login.
  /// Se o token for valido, transiciona para [AuthStatus.authenticated].
  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final isAuth = await _repository.isAuthenticated();

      if (isAuth) {
        final user = await _repository.getCurrentUser();
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      debugPrint('[AuthNotifier] Erro ao verificar autenticacao: $e');
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Realiza login com usuario e senha.
  ///
  /// Transiciona para [AuthStatus.loading] durante a requisicao,
  /// [AuthStatus.authenticated] em caso de sucesso ou
  /// [AuthStatus.error] com a mensagem de erro.
  Future<void> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final user = await _repository.login(username, password);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } on AuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } on NetworkException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } on ServerException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Ocorreu um erro inesperado. Tente novamente.',
      );
    }
  }

  /// Realiza logout e limpa o estado.
  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (e) {
      debugPrint('[AuthNotifier] Erro ao realizar logout: $e');
    }
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Limpa a mensagem de erro, retornando ao estado anterior.
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }
}

// ── Provider principal ──────────────────────────────────────────────────

/// Provider do [AuthNotifier] e seu [AuthState].
///
/// Usado pela UI (LoginScreen, AppShell) e pelo GoRouter para
/// verificar o estado de autenticacao.
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository: repository);
});
