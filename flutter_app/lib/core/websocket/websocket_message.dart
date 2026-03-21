// Tipos de mensagem WebSocket do eGranja.
//
// Classes simples sem Freezed -- serao migradas posteriormente.

/// Tipos de mensagem WebSocket.
enum WSMessageType {
  text,
  photo,
  audio,
  solicitacao,
  system,
  typing,
  read,
  heartbeat;

  /// Converte string para enum.
  static WSMessageType fromString(String value) {
    return WSMessageType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WSMessageType.text,
    );
  }
}

/// Status de solicitacao formal.
enum SolicitacaoStatus {
  pendente,
  respondida,
  expirada;

  static SolicitacaoStatus fromString(String value) {
    return SolicitacaoStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SolicitacaoStatus.pendente,
    );
  }
}

/// Dados de solicitacao formal embutida na mensagem.
class WSSolicitacao {
  final String id;
  final String titulo;
  final String descricao;
  final String prazo;
  final SolicitacaoStatus status;
  final String? resposta;
  final String? respostaMediaUrl;

  const WSSolicitacao({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.prazo,
    required this.status,
    this.resposta,
    this.respostaMediaUrl,
  });

  factory WSSolicitacao.fromJson(Map<String, dynamic> json) {
    return WSSolicitacao(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      prazo: json['prazo'] as String,
      status: SolicitacaoStatus.fromString(json['status'] as String),
      resposta: json['resposta'] as String?,
      respostaMediaUrl: json['resposta_media_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'prazo': prazo,
      'status': status.name,
      if (resposta != null) 'resposta': resposta,
      if (respostaMediaUrl != null) 'resposta_media_url': respostaMediaUrl,
    };
  }
}

/// Dados de solicitacao para envio (sem id/status, definidos pelo servidor).
class WSSolicitacaoPayload {
  final String titulo;
  final String descricao;
  final String prazo;

  const WSSolicitacaoPayload({
    required this.titulo,
    required this.descricao,
    required this.prazo,
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'prazo': prazo,
    };
  }
}

/// Payload de mensagem recebida via WebSocket.
class WSMessage {
  final String? id;
  final WSMessageType type;
  final String loteId;
  final String senderId;
  final String? senderNome;
  final String? senderTipo;
  final String? content;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final WSSolicitacao? solicitacao;
  final String? createdAt;

  const WSMessage({
    this.id,
    required this.type,
    required this.loteId,
    required this.senderId,
    this.senderNome,
    this.senderTipo,
    this.content,
    this.mediaUrl,
    this.thumbnailUrl,
    this.solicitacao,
    this.createdAt,
  });

  factory WSMessage.fromJson(Map<String, dynamic> json) {
    return WSMessage(
      id: json['id'] as String?,
      type: WSMessageType.fromString(json['type'] as String),
      loteId: json['lote_id'] as String,
      senderId: json['sender_id'] as String,
      senderNome: json['sender_nome'] as String?,
      senderTipo: json['sender_tipo'] as String?,
      content: json['content'] as String?,
      mediaUrl: json['media_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      solicitacao: json['solicitacao'] != null
          ? WSSolicitacao.fromJson(
              json['solicitacao'] as Map<String, dynamic>,
            )
          : null,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type.name,
      'lote_id': loteId,
      'sender_id': senderId,
      if (senderNome != null) 'sender_nome': senderNome,
      if (senderTipo != null) 'sender_tipo': senderTipo,
      if (content != null) 'content': content,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (solicitacao != null) 'solicitacao': solicitacao!.toJson(),
      if (createdAt != null) 'created_at': createdAt,
    };
  }
}

/// Payload enviado para o servidor via WebSocket.
class WSSendPayload {
  final WSMessageType type;
  final String loteId;
  final String? content;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final WSSolicitacaoPayload? solicitacao;

  const WSSendPayload({
    required this.type,
    required this.loteId,
    this.content,
    this.mediaUrl,
    this.thumbnailUrl,
    this.solicitacao,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'lote_id': loteId,
      if (content != null) 'content': content,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (solicitacao != null) 'solicitacao': solicitacao!.toJson(),
    };
  }
}
