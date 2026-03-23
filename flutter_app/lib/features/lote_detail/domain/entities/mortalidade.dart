/// Registro de mortalidade diaria de um lote.
///
/// Campos mapeados a partir do endpoint GET /lotes/{id}/mortalidades.
/// Backend retorna: id, lote_id, data, quantidade, causa, observacao?, created_at.
class Mortalidade {
  final String id;
  final String loteId;
  final String data;

  /// Quantidade de aves mortas.
  final int quantidade;

  /// Causa da mortalidade.
  final String causa;

  /// Observacao adicional (opcional).
  final String? observacao;

  final String createdAt;

  const Mortalidade({
    required this.id,
    required this.loteId,
    required this.data,
    required this.quantidade,
    required this.causa,
    this.observacao,
    required this.createdAt,
  });

  factory Mortalidade.fromJson(Map<String, dynamic> json) {
    return Mortalidade(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      data: json['data'] as String,
      quantidade: (json['quantidade'] as num).toInt(),
      causa: json['causa'] as String? ?? 'Indefinida',
      observacao: json['observacao'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'data': data,
      'quantidade': quantidade,
      'causa': causa,
      if (observacao != null) 'observacao': observacao,
      'created_at': createdAt,
    };
  }
}
