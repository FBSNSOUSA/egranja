import 'package:flutter/foundation.dart' show kIsWeb;

/// Constantes de configuracao da API eGranja.
///
/// URLs e timeouts sao configuraveis via --dart-define em tempo de compilacao.
/// Na web, usa localhost:8080. No mobile, usa 10.0.2.2:8080 (emulador Android).
class ApiConstants {
  ApiConstants._();

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _envWsUrl = String.fromEnvironment('WS_URL');

  /// URL base da API REST.
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    return kIsWeb
        ? 'http://localhost:8080/api/v1'
        : 'http://10.0.2.2:8080/api/v1';
  }

  /// URL base do WebSocket.
  static String get wsUrl {
    if (_envWsUrl.isNotEmpty) return _envWsUrl;
    return kIsWeb
        ? 'ws://localhost:8080/ws'
        : 'ws://10.0.2.2:8080/ws';
  }

  /// Timeout para estabelecer conexao HTTP.
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Timeout para receber resposta HTTP.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Timeout para upload de arquivos.
  static const Duration uploadTimeout = Duration(seconds: 60);
}
