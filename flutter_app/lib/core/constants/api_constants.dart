/// Constantes de configuracao da API eGranja.
///
/// URLs e timeouts sao configuraveis via --dart-define em tempo de compilacao.
/// Valores padrao apontam para o emulador Android (10.0.2.2).
class ApiConstants {
  ApiConstants._();

  /// URL base da API REST.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );

  /// URL base do WebSocket.
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://10.0.2.2:8080/ws',
  );

  /// Timeout para estabelecer conexao HTTP.
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Timeout para receber resposta HTTP.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Timeout para upload de arquivos.
  static const Duration uploadTimeout = Duration(seconds: 60);
}
