import 'package:egranja_flutter/features/chat/domain/entities/mensagem.dart';

/// Modelo de dados para serializacao/deserializacao de [Mensagem].
class MensagemModel extends Mensagem {
  const MensagemModel({
    required super.id,
    required super.loteId,
    required super.tipo,
    required super.conteudo,
    required super.remetenteId,
    required super.remetenteNome,
    required super.remetenteTipo,
    required super.lida,
    required super.createdAt,
    super.midiaUrl,
    super.midiaThumbnailUrl,
    super.solicitacaoStatus,
    super.solicitacaoPrazo,
  });

  /// Cria uma instancia de [MensagemModel] a partir de JSON da API.
  factory MensagemModel.fromJson(Map<String, dynamic> json) {
    return MensagemModel(
      id: json['id'] as String,
      loteId: json['lote_id'] as String? ?? '',
      tipo: MensagemTipo.fromString(json['tipo'] as String? ?? 'texto'),
      conteudo: json['conteudo'] as String? ?? '',
      remetenteId: json['remetente_id'] as String,
      remetenteNome: json['remetente_nome'] as String? ?? '',
      remetenteTipo: json['remetente_tipo'] as String? ?? 'produtor',
      lida: json['lida'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      midiaUrl: json['midia_url'] as String?,
      midiaThumbnailUrl: json['midia_thumbnail_url'] as String?,
      solicitacaoStatus: json['solicitacao_status'] as String?,
      solicitacaoPrazo: json['solicitacao_prazo'] != null
          ? DateTime.parse(json['solicitacao_prazo'] as String)
          : null,
    );
  }

  /// Converte para JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'tipo': tipo.toApiString(),
      'conteudo': conteudo,
      'remetente_id': remetenteId,
      'remetente_nome': remetenteNome,
      'remetente_tipo': remetenteTipo,
      'lida': lida,
      'created_at': createdAt.toIso8601String(),
      if (midiaUrl != null) 'midia_url': midiaUrl,
      if (midiaThumbnailUrl != null) 'midia_thumbnail_url': midiaThumbnailUrl,
      if (solicitacaoStatus != null) 'solicitacao_status': solicitacaoStatus,
      if (solicitacaoPrazo != null)
        'solicitacao_prazo': solicitacaoPrazo!.toIso8601String(),
    };
  }
}
