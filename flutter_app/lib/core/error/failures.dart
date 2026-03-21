// Classes de falha do eGranja.
//
// Representam erros na camada de dominio. Diferente de [Exception],
// falhas sao valores (nao interrompem o fluxo) e sao usadas com
// Either/Result para tratamento funcional de erros.

/// Classe base de falha.
abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => '$runtimeType($message)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Falha causada por erro no servidor.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erro interno do servidor.']);
}

/// Falha causada por erro de cache/armazenamento local.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erro ao acessar dados locais.']);
}

/// Falha causada por ausencia de conexao de rede.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexao com a internet.']);
}

/// Falha causada por erro de autenticacao.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Erro de autenticacao.']);
}
