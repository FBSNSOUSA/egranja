/// Entidade de dominio que representa um resumo de conversa (agrupada por lote).
class Conversa {
  final String loteId;
  final String loteNome;
  final String? galpaoNome;
  final String? ultimaMensagem;
  final String? ultimaMensagemTipo;
  final int naoLidas;
  final DateTime updatedAt;

  /// Se o lote tem pendencia (solicitacao pendente).
  final bool temPendencia;

  /// Nome do ultimo participante que enviou mensagem.
  final String? participanteNome;

  const Conversa({
    required this.loteId,
    required this.loteNome,
    this.galpaoNome,
    this.ultimaMensagem,
    this.ultimaMensagemTipo,
    required this.naoLidas,
    required this.updatedAt,
    this.temPendencia = false,
    this.participanteNome,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Conversa &&
          runtimeType == other.runtimeType &&
          loteId == other.loteId;

  @override
  int get hashCode => loteId.hashCode;

  @override
  String toString() =>
      'Conversa(loteId: $loteId, loteNome: $loteNome, naoLidas: $naoLidas)';
}
