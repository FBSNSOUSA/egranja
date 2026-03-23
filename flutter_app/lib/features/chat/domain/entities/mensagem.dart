/// Tipos de mensagem no chat.
enum MensagemTipo {
  texto,
  foto,
  audio,
  solicitacao,
  visita;

  /// Converte string da API para enum.
  static MensagemTipo fromString(String value) {
    switch (value) {
      case 'texto':
        return MensagemTipo.texto;
      case 'foto':
        return MensagemTipo.foto;
      case 'audio':
        return MensagemTipo.audio;
      case 'solicitacao':
        return MensagemTipo.solicitacao;
      case 'visita':
        return MensagemTipo.visita;
      default:
        return MensagemTipo.texto;
    }
  }

  /// Converte enum para string da API.
  String toApiString() {
    switch (this) {
      case MensagemTipo.texto:
        return 'texto';
      case MensagemTipo.foto:
        return 'foto';
      case MensagemTipo.audio:
        return 'audio';
      case MensagemTipo.solicitacao:
        return 'solicitacao';
      case MensagemTipo.visita:
        return 'visita';
    }
  }
}

/// Entidade de dominio que representa uma mensagem no chat.
class Mensagem {
  final String id;
  final String loteId;
  final MensagemTipo tipo;
  final String conteudo;
  final String remetenteId;
  final String remetenteNome;
  final String remetenteTipo; // 'produtor' ou 'tecnico'
  final bool lida;
  final DateTime createdAt;

  /// URL de midia para mensagens de foto ou audio.
  final String? midiaUrl;

  /// URL do thumbnail para mensagens de foto.
  final String? midiaThumbnailUrl;

  /// Status da solicitacao (pendente, respondida, expirada).
  final String? solicitacaoStatus;

  /// Prazo da solicitacao.
  final DateTime? solicitacaoPrazo;

  const Mensagem({
    required this.id,
    required this.loteId,
    required this.tipo,
    required this.conteudo,
    required this.remetenteId,
    required this.remetenteNome,
    required this.remetenteTipo,
    required this.lida,
    required this.createdAt,
    this.midiaUrl,
    this.midiaThumbnailUrl,
    this.solicitacaoStatus,
    this.solicitacaoPrazo,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mensagem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Mensagem(id: $id, tipo: $tipo, remetente: $remetenteNome)';
}
