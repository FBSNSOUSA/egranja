/// Registro de recebimento de racao para um lote.
///
/// Campos mapeados a partir do endpoint GET /lotes/{id}/feed_receipts
/// e do DTO FeedReceiptResponse do backend Go.
class RecebimentoRacao {
  final String id;
  final String loteId;
  final String dataRecebimento;

  /// Quantidade recebida em kg.
  final double quantidadeKg;

  /// ID do tipo de racao (opcional).
  final String? tipoRacaoId;

  /// Nome do tipo de racao (opcional, retornado pelo backend via join).
  final String? tipoRacaoNome;

  /// Fornecedor da racao (opcional).
  final String? fornecedor;

  /// Numero do lote da racao (opcional).
  final String? loteRacao;

  /// Origem do recebimento: 'compra', 'remanescente_anterior', 'sobra_final'.
  final String origem;

  final String createdAt;

  const RecebimentoRacao({
    required this.id,
    required this.loteId,
    required this.dataRecebimento,
    required this.quantidadeKg,
    this.tipoRacaoId,
    this.tipoRacaoNome,
    this.fornecedor,
    this.loteRacao,
    required this.origem,
    required this.createdAt,
  });

  factory RecebimentoRacao.fromJson(Map<String, dynamic> json) {
    return RecebimentoRacao(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      dataRecebimento: json['data_recebimento'] as String,
      quantidadeKg: (json['quantidade_kg'] as num).toDouble(),
      tipoRacaoId: json['tipo_racao_id'] as String?,
      tipoRacaoNome: json['tipo_racao_nome'] as String?,
      fornecedor: json['fornecedor'] as String?,
      loteRacao: json['lote_racao'] as String?,
      origem: json['origem'] as String? ?? 'compra',
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'data_recebimento': dataRecebimento,
      'quantidade_kg': quantidadeKg,
      if (tipoRacaoId != null) 'tipo_racao_id': tipoRacaoId,
      if (tipoRacaoNome != null) 'tipo_racao_nome': tipoRacaoNome,
      if (fornecedor != null) 'fornecedor': fornecedor,
      if (loteRacao != null) 'lote_racao': loteRacao,
      'origem': origem,
      'created_at': createdAt,
    };
  }
}

/// Registro de consumo diario de racao de um lote.
///
/// Campos mapeados a partir do endpoint GET /lotes/{id}/feed_consumptions
/// e do DTO FeedConsumptionResponse do backend Go.
class ConsumoRacao {
  final String id;
  final String loteId;
  final String data;

  /// Quantidade consumida em kg.
  final double quantidadeKg;

  final String createdAt;

  const ConsumoRacao({
    required this.id,
    required this.loteId,
    required this.data,
    required this.quantidadeKg,
    required this.createdAt,
  });

  factory ConsumoRacao.fromJson(Map<String, dynamic> json) {
    return ConsumoRacao(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      data: json['data'] as String,
      quantidadeKg: (json['quantidade_kg'] as num).toDouble(),
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'data': data,
      'quantidade_kg': quantidadeKg,
      'created_at': createdAt,
    };
  }
}
