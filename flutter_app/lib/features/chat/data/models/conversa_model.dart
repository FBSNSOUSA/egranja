import 'package:egranja_flutter/features/chat/domain/entities/conversa.dart';

/// Modelo de dados para serializacao/deserializacao de [Conversa].
///
/// A lista de conversas e construida a partir do endpoint GET /lotes,
/// que retorna objetos de lote (nao conversas dedicadas). Os campos
/// sao mapeados conforme:
/// - id -> loteId
/// - galpao_nome + linhagem -> loteNome
/// - galpao_nome -> galpaoNome
/// - updated_at -> updatedAt
/// Campos de chat (ultima_mensagem, nao_lidas, etc) nao existem no
/// endpoint de lotes, entao recebem valores padrao.
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
  ///
  /// O JSON vem do endpoint GET /lotes, cujos campos relevantes sao:
  /// id, galpao_nome, linhagem, status, updated_at.
  factory ConversaModel.fromJson(Map<String, dynamic> json) {
    // Construir nome amigavel para exibir na lista de conversas
    final galpaoNome = json['galpao_nome'] as String? ?? '';
    final linhagem = json['linhagem'] as String? ?? '';
    final loteNome = galpaoNome.isNotEmpty
        ? (linhagem.isNotEmpty ? '$galpaoNome - $linhagem' : galpaoNome)
        : 'Lote';

    return ConversaModel(
      loteId: json['id'] as String,
      loteNome: loteNome,
      galpaoNome: galpaoNome.isNotEmpty ? galpaoNome : null,
      // Campos de chat nao disponibilizados pelo endpoint de lotes
      ultimaMensagem: null,
      ultimaMensagemTipo: null,
      naoLidas: 0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      temPendencia: false,
      participanteNome: null,
    );
  }
}
