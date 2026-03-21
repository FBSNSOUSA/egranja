/// Tipos de mensagem no chat.
enum MensagemTipo {
  texto,
  foto,
  audio,
  solicitacao,
  sistema;

  /// Converte string da API para enum.
  static MensagemTipo fromString(String value) {
    switch (value) {
      case 'text':
        return MensagemTipo.texto;
      case 'photo':
        return MensagemTipo.foto;
      case 'audio':
        return MensagemTipo.audio;
      case 'solicitacao':
        return MensagemTipo.solicitacao;
      case 'system':
        return MensagemTipo.sistema;
      default:
        return MensagemTipo.texto;
    }
  }

  /// Converte enum para string da API.
  String toApiString() {
    switch (this) {
      case MensagemTipo.texto:
        return 'text';
      case MensagemTipo.foto:
        return 'photo';
      case MensagemTipo.audio:
        return 'audio';
      case MensagemTipo.solicitacao:
        return 'solicitacao';
      case MensagemTipo.sistema:
        return 'system';
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
  final String? mediaUrl;

  /// URL do thumbnail para mensagens de foto.
  final String? thumbnailUrl;

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
    this.mediaUrl,
    this.thumbnailUrl,
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
