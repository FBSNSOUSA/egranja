/// Entidade de dominio que representa uma mensagem no chat com IA.
///
/// O backend retorna interacoes no formato IAInteracaoResponse:
///   { "id", "pergunta", "resposta", "tipo", "modelo", "tokens", "created_at" }
///
/// Cada IAInteracaoResponse e convertida em DUAS IAMensagens:
/// uma do usuario (pergunta) e uma da IA (resposta).
class IAMensagem {
  final String id;
  final String remetente; // 'usuario' ou 'ia'
  final String texto;
  final DateTime timestamp;

  const IAMensagem({
    required this.id,
    required this.remetente,
    required this.texto,
    required this.timestamp,
  });

  /// Converte uma IAInteracaoResponse do backend em uma lista de IAMensagens.
  ///
  /// Backend DTO: IAInteracaoResponse
  ///   { "id", "pergunta", "resposta", "tipo", "modelo", "tokens", "created_at" }
  ///
  /// Cada interacao gera duas mensagens: pergunta (usuario) e resposta (ia).
  static List<IAMensagem> fromInteracaoJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final timestamp = json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now();
    final pergunta = json['pergunta'] as String? ?? '';
    final resposta = json['resposta'] as String? ?? '';

    final mensagens = <IAMensagem>[];

    if (pergunta.isNotEmpty) {
      mensagens.add(IAMensagem(
        id: '${id}_pergunta',
        remetente: 'usuario',
        texto: pergunta,
        timestamp: timestamp,
      ));
    }

    if (resposta.isNotEmpty) {
      mensagens.add(IAMensagem(
        id: '${id}_resposta',
        remetente: 'ia',
        texto: resposta,
        timestamp: timestamp,
      ));
    }

    return mensagens;
  }

  /// Cria uma [IAMensagem] a partir do JSON da API.
  ///
  /// Suporta ambos os formatos:
  /// - role/content (antigo): `role` -> remetente, `content` -> texto
  /// - pergunta/resposta (backend atual): `pergunta`/`resposta` -> texto
  factory IAMensagem.fromJson(Map<String, dynamic> json) {
    // Formato com role/content
    if (json.containsKey('role')) {
      final role = json['role'] as String? ?? '';
      final remetente = role == 'user' ? 'usuario' : 'ia';
      return IAMensagem(
        id: json['id']?.toString() ?? '',
        remetente: remetente,
        texto: json['content'] as String? ?? '',
        timestamp: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );
    }

    // Formato pergunta/resposta (IAInteracaoResponse)
    // Usado como fallback, retorna a resposta da IA
    return IAMensagem(
      id: json['id']?.toString() ?? '',
      remetente: 'ia',
      texto: json['resposta'] as String? ?? json['pergunta'] as String? ?? '',
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IAMensagem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'IAMensagem(id: $id, remetente: $remetente, texto: ${texto.length > 30 ? '${texto.substring(0, 30)}...' : texto})';
}
