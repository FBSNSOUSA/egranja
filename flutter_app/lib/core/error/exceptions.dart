// Excecoes customizadas do eGranja.
//
// Cada excecao carrega um [code] maquina-legivel e uma [message] amigavel
// para o usuario. Sao lancadas na camada de dados e convertidas em
// [Failure] na camada de dominio.

/// Excecao para erros do servidor (HTTP 5xx ou respostas inesperadas).
class ServerException implements Exception {
  final String code;
  final String message;

  const ServerException({
    this.code = 'SERVER_ERROR',
    this.message = 'Erro interno do servidor. Tente novamente mais tarde.',
  });

  @override
  String toString() => 'ServerException($code: $message)';
}

/// Excecao para erros de cache/armazenamento local.
class CacheException implements Exception {
  final String code;
  final String message;

  const CacheException({
    this.code = 'CACHE_ERROR',
    this.message = 'Erro ao acessar dados locais.',
  });

  @override
  String toString() => 'CacheException($code: $message)';
}

/// Excecao para erros de rede (sem conexao, timeout).
class NetworkException implements Exception {
  final String code;
  final String message;

  const NetworkException({
    this.code = 'NETWORK_ERROR',
    this.message =
        'Sem conexao com a internet. Verifique sua conexao e tente novamente.',
  });

  @override
  String toString() => 'NetworkException($code: $message)';
}

/// Excecao para erros de autenticacao (401, sessao expirada).
class AuthException implements Exception {
  final String code;
  final String message;

  const AuthException({
    this.code = 'AUTH_ERROR',
    this.message = 'Erro de autenticacao.',
  });

  @override
  String toString() => 'AuthException($code: $message)';
}
