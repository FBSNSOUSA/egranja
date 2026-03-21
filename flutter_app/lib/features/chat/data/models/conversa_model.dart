import 'package:egranja_flutter/features/chat/domain/entities/conversa.dart';

/// Modelo de dados para serializacao/deserializacao de [Conversa].
class ConversaModel extends Conversa {
  const ConversaModel({
    required super.loteId,
    required super.loteNome,
    super.galpaoNome,
    super.ultimaMensagem,
    super.ultimaMensagemTipo,
    required super.naoLidas,
    required super.updatedAt,
    super.temPendencia,
    super.participanteNome,
  });

  /// Cria uma instancia de [ConversaModel] a partir de JSON da API.
  factory ConversaModel.fromJson(Map<String, dynamic> json) {
    return ConversaModel(
      loteId: json['lote_id'] as String,
      loteNome: json['lote_nome'] as String,
      galpaoNome: json['galpao_nome'] as String?,
      ultimaMensagem: json['ultima_mensagem'] as String?,
      ultimaMensagemTipo: json['ultima_mensagem_tipo'] as String?,
      naoLidas: json['nao_lidas'] as int? ?? 0,
      updatedAt: DateTime.parse(json['ultima_mensagem_at'] as String),
      temPendencia: json['tem_pendencia'] as bool? ?? false,
      participanteNome: json['participante_nome'] as String?,
    );
  }
}
