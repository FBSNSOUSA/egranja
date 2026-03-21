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
    super.mediaUrl,
    super.thumbnailUrl,
  });

  /// Cria uma instancia de [MensagemModel] a partir de JSON da API.
  factory MensagemModel.fromJson(Map<String, dynamic> json) {
    return MensagemModel(
      id: json['id'] as String,
      loteId: json['lote_id'] as String? ?? '',
      tipo: MensagemTipo.fromString(json['type'] as String? ?? 'text'),
      conteudo: json['content'] as String? ?? '',
      remetenteId: json['sender_id'] as String,
      remetenteNome: json['sender_nome'] as String? ?? '',
      remetenteTipo: json['sender_tipo'] as String? ?? 'produtor',
      lida: json['lida'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      mediaUrl: json['media_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  /// Converte para JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'type': tipo.toApiString(),
      'content': conteudo,
      'sender_id': remetenteId,
      'sender_nome': remetenteNome,
      'sender_tipo': remetenteTipo,
      'lida': lida,
      'created_at': createdAt.toIso8601String(),
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
    };
  }
}
