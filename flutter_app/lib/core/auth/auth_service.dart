import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import 'secure_storage.dart';

/// Dados do usuario retornados pelo login.
///
/// Classe simples que sera substituida por Freezed posteriormente.
class User {
  final String id;
  final String login;
  final String nome;
  final String tipo; // 'produtor' ou 'tecnico'
  final bool ativo;

  const User({
    required this.id,
    required this.login,
    required this.nome,
    required this.tipo,
    required this.ativo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      login: json['login'] as String,
      nome: json['nome'] as String,
      tipo: json['tipo'] as String,
      ativo: json['ativo'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'nome': nome,
      'tipo': tipo,
      'ativo': ativo,
    };
  }

  @override
  String toString() => 'User(id: $id, login: $login, nome: $nome, tipo: $tipo)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Payload decodificado do JWT (campos relevantes).
class _JWTPayload {
  final String sub;
  final int exp;
  final int iat;
  final String tipo;

  const _JWTPayload({
    required this.sub,
    required this.exp,
    required this.iat,
    required this.tipo,
  });

  factory _JWTPayload.fromJson(Map<String, dynamic> json) {
    return _JWTPayload(
      sub: json['sub'] as String,
      exp: json['exp'] as int,
      iat: json['iat'] as int,
      tipo: json['tipo'] as String,
    );
  }
}

/// Servico de autenticacao do eGranja.
///
/// Gerencia login, logout, refresh de tokens e armazenamento seguro.
///
/// Fluxo JWT:
/// - Access token: valido por 24h, enviado em toda request
/// - Refresh token: valido por 30 dias, usado para renovar access token
/// - Tokens armazenados de forma segura no dispositivo
class AuthService {
  final SecureStorage _storage;

  /// Dio dedicado para chamadas de auth (login/refresh).
  /// Nao usa o AuthInterceptor para evitar loop circular.
  final Dio _dio;

  AuthService({
    required SecureStorage storage,
    Dio? dio,
  })  : _storage = storage,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  // ==========================================
  // FUNCOES PUBLICAS
  // ==========================================

  /// Realiza login do usuario.
  ///
  /// Envia credenciais para a API, recebe tokens JWT e dados do usuario.
  /// Salva tokens de forma segura no dispositivo.
  ///
  /// Lanca [AuthException] se as credenciais forem invalidas,
  /// [NetworkException] se nao houver conexao, ou
  /// [ServerException] para erros do servidor.
  Future<User> login(String username, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'login': username,
          'senha': password,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final body = response.data;
      if (body == null || body['success'] != true || body['data'] == null) {
        throw const AuthException(
          code: 'INVALID_CREDENTIALS',
          message: 'Usuario ou senha incorretos.',
        );
      }

      final data = body['data'] as Map<String, dynamic>;
      final accessToken = data['access_token'] as String;
      final refreshTokenValue = data['refresh_token'] as String;
      final userJson = data['user'] as Map<String, dynamic>;

      // Salvar tokens de forma segura
      await Future.wait([
        _storage.saveAccessToken(accessToken),
        _storage.saveRefreshToken(refreshTokenValue),
      ]);

      return User.fromJson(userJson);
    } on DioException catch (e) {
      // Erro de rede (sem conexao)
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.response == null) {
        throw const NetworkException(
          code: 'NETWORK_ERROR',
          message:
              'Sem conexao com a internet. Verifique sua conexao e tente novamente.',
        );
      }

      final status = e.response?.statusCode;

      // Erro de credenciais (401)
      if (status == 401) {
        throw const AuthException(
          code: 'INVALID_CREDENTIALS',
          message: 'Usuario ou senha incorretos.',
        );
      }

      // Rate limiting (429)
      if (status == 429) {
        throw const AuthException(
          code: 'RATE_LIMITED',
          message:
              'Muitas tentativas de login. Aguarde um momento e tente novamente.',
        );
      }

      // Erro do servidor (5xx)
      if (status != null && status >= 500) {
        throw const ServerException(
          code: 'SERVER_ERROR',
          message: 'Servidor indisponivel. Tente novamente mais tarde.',
        );
      }

      throw const ServerException(
        code: 'UNKNOWN_ERROR',
        message: 'Ocorreu um erro inesperado. Tente novamente.',
      );
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw const ServerException(
        code: 'UNKNOWN_ERROR',
        message: 'Ocorreu um erro inesperado. Tente novamente.',
      );
    }
  }

  /// Realiza logout do usuario.
  ///
  /// Remove todos os tokens do armazenamento seguro.
  /// Nao chama API (o token simplesmente expira no servidor).
  Future<void> logout() async {
    try {
      await _storage.clearTokens();
    } catch (e) {
      debugPrint('[Auth] Erro ao realizar logout: $e');
      // Mesmo com erro, tenta limpar o que puder
      await _storage.clearTokens();
    }
  }

  /// Renova o access token usando o refresh token.
  ///
  /// Chamado automaticamente pelo [AuthInterceptor] quando recebe 401.
  /// Se o refresh token tambem estiver expirado, retorna `null`
  /// (usuario deve fazer login novamente).
  Future<String?> refreshToken() async {
    try {
      final currentRefreshToken = await _storage.getRefreshToken();
      if (currentRefreshToken == null) {
        debugPrint('[Auth] Nenhum refresh token disponivel.');
        return null;
      }

      // Verificar se refresh token esta expirado antes de chamar API
      if (_isTokenExpired(currentRefreshToken)) {
        debugPrint('[Auth] Refresh token expirado.');
        await _storage.clearTokens();
        return null;
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {
          'refresh_token': currentRefreshToken,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final body = response.data;
      if (body == null || body['success'] != true || body['data'] == null) {
        await _storage.clearTokens();
        return null;
      }

      final data = body['data'] as Map<String, dynamic>;
      final accessToken = data['access_token'] as String;

      // Salvar novo access token (mantem o refresh token atual)
      await _storage.saveAccessToken(accessToken);

      return accessToken;
    } catch (e) {
      debugPrint('[Auth] Erro ao renovar token: $e');
      await _storage.clearTokens();
      return null;
    }
  }

  /// Recupera o access token armazenado no dispositivo.
  /// Retorna `null` se nao houver token salvo.
  Future<String?> getToken() async {
    return _storage.getAccessToken();
  }

  /// Verifica se o usuario esta autenticado.
  ///
  /// Retorna `true` se:
  /// - Ha um access token salvo E nao esta expirado, OU
  /// - Ha um refresh token salvo E nao esta expirado (pode renovar)
  Future<bool> isAuthenticated() async {
    try {
      // Verificar access token
      final accessToken = await _storage.getAccessToken();
      if (accessToken != null && !_isTokenExpired(accessToken)) {
        return true;
      }

      // Access token expirado/ausente: verificar refresh token
      final refreshTokenValue = await _storage.getRefreshToken();
      if (refreshTokenValue != null && !_isTokenExpired(refreshTokenValue)) {
        // Tentar renovar o access token
        final newToken = await refreshToken();
        return newToken != null;
      }

      return false;
    } catch (e) {
      debugPrint('[Auth] Erro ao verificar autenticacao: $e');
      return false;
    }
  }

  /// Extrai dados do usuario a partir do access token salvo.
  /// Util para recuperar info do usuario sem chamar API.
  ///
  /// Retorna dados parciais do usuario ou `null` se nao autenticado.
  Future<User?> getUserFromToken() async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null) return null;

      final payload = _decodeJWT(token);
      if (payload == null) return null;

      return User(
        id: payload.sub,
        login: '',
        nome: '',
        tipo: payload.tipo,
        ativo: true,
      );
    } catch (e) {
      debugPrint('[Auth] Erro ao extrair dados do token: $e');
      return null;
    }
  }

  // ==========================================
  // FUNCOES PRIVADAS
  // ==========================================

  /// Decodifica o payload de um JWT sem verificar assinatura.
  /// Usado apenas para leitura local (expiracao, tipo, etc).
  /// A validacao real acontece no servidor.
  _JWTPayload? _decodeJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      // Normalizar base64url para base64 padrao
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      return _JWTPayload.fromJson(json);
    } catch (e) {
      debugPrint('[Auth] Erro ao decodificar JWT: $e');
      return null;
    }
  }

  /// Verifica se o token esta expirado.
  /// Considera expirado se faltam menos de 60 segundos para expirar.
  bool _isTokenExpired(String token) {
    final payload = _decodeJWT(token);
    if (payload == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const marginSeconds = 60;
    return payload.exp <= now + marginSeconds;
  }
}
