import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../error/exceptions.dart';
import 'auth_service.dart';
import 'secure_storage.dart';

/// Interceptor Dio para autenticacao JWT.
///
/// Funcionalidades:
/// - **onRequest**: Adiciona `Authorization: Bearer <token>` em toda request.
/// - **onError (401)**: Tenta refresh automatico do token.
///   - Se ja esta refreshing, enfileira a request e aguarda.
///   - Se nao, chama [AuthService.refreshToken] e reenvia.
///   - Em caso de falha, rejeita todas as requests enfileiradas.
///
/// Usa um sistema baseado em [Completer] para evitar chamadas
/// simultaneas de refresh (race condition).
class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;
  final AuthService _authService;
  final Dio _dio;

  /// Flag para evitar loop infinito de refresh.
  bool _isRefreshing = false;

  /// Fila de requests que aguardam o refresh do token.
  /// Cada entrada e um Completer que sera completado com o novo token
  /// ou com um erro.
  final List<Completer<String>> _pendingRequests = [];

  AuthInterceptor({
    required SecureStorage storage,
    required AuthService authService,
    required Dio dio,
  })  : _storage = storage,
        _authService = authService,
        _dio = dio;

  /// Adiciona o JWT no header Authorization de toda requisicao.
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _storage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Se falhar ao recuperar token, continua sem ele.
      // O servidor retornara 401 e o onError tratara.
      debugPrint('[API] Falha ao recuperar token para request: $e');
    }
    handler.next(options);
  }

  /// Trata erro 401 com refresh automatico.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Apenas tratar 401
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Verificar se ja tentamos retry nesta request
    final options = err.requestOptions;
    if (options.extra['_retry'] == true) {
      return handler.next(err);
    }

    // Se ja esta fazendo refresh, enfileirar e aguardar
    if (_isRefreshing) {
      try {
        final newToken = await _enqueueAndWait();
        // Reenviar request com o novo token
        final response = await _retryRequest(options, newToken);
        return handler.resolve(response);
      } catch (e) {
        return handler.reject(
          DioException(
            requestOptions: options,
            error: const AuthException(
              code: 'SESSION_EXPIRED',
              message: 'Sua sessao expirou. Faca login novamente.',
            ),
            type: DioExceptionType.unknown,
          ),
        );
      }
    }

    // Iniciar processo de refresh
    _isRefreshing = true;
    options.extra['_retry'] = true;

    try {
      final newToken = await _authService.refreshToken();

      if (newToken != null) {
        // Refresh bem-sucedido: resolver fila e reenviar request original
        _resolveQueue(newToken);

        final response = await _retryRequest(options, newToken);
        return handler.resolve(response);
      } else {
        // Refresh falhou: rejeitar fila e sinalizar sessao expirada
        _rejectQueue(
          const AuthException(
            code: 'SESSION_EXPIRED',
            message: 'Sua sessao expirou. Faca login novamente.',
          ),
        );

        return handler.reject(
          DioException(
            requestOptions: options,
            error: const AuthException(
              code: 'SESSION_EXPIRED',
              message: 'Sua sessao expirou. Faca login novamente.',
            ),
            type: DioExceptionType.unknown,
          ),
        );
      }
    } catch (e) {
      // Erro inesperado durante refresh
      _rejectQueue(
        const AuthException(
          code: 'SESSION_EXPIRED',
          message: 'Sua sessao expirou. Faca login novamente.',
        ),
      );

      return handler.reject(
        DioException(
          requestOptions: options,
          error: const AuthException(
            code: 'SESSION_EXPIRED',
            message: 'Sua sessao expirou. Faca login novamente.',
          ),
          type: DioExceptionType.unknown,
        ),
      );
    } finally {
      _isRefreshing = false;
    }
  }

  // ==========================================
  // METODOS PRIVADOS
  // ==========================================

  /// Enfileira a request atual e retorna um Future que sera completado
  /// quando o refresh terminar.
  Future<String> _enqueueAndWait() {
    final completer = Completer<String>();
    _pendingRequests.add(completer);
    return completer.future;
  }

  /// Resolve todas as requests enfileiradas com o novo token.
  void _resolveQueue(String token) {
    for (final completer in _pendingRequests) {
      if (!completer.isCompleted) {
        completer.complete(token);
      }
    }
    _pendingRequests.clear();
  }

  /// Rejeita todas as requests enfileiradas com o erro fornecido.
  void _rejectQueue(AuthException error) {
    for (final completer in _pendingRequests) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }
    _pendingRequests.clear();
  }

  /// Reenvia a request original com o novo token.
  Future<Response<dynamic>> _retryRequest(
    RequestOptions options,
    String token,
  ) {
    options.headers['Authorization'] = 'Bearer $token';
    return _dio.fetch(options);
  }
}
