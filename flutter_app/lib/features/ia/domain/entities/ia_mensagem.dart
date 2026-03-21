/// Entidade de dominio que representa uma mensagem no chat com IA.
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

  /// Cria uma [IAMensagem] a partir do JSON da API.
  ///
  /// Converte `role` ('user' -> 'usuario', 'assistant' -> 'ia'),
  /// `content` -> `texto` e `created_at` -> `timestamp`.
  factory IAMensagem.fromJson(Map<String, dynamic> json) {
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
