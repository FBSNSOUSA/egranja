/// Registro de recebimento de racao para um lote.
class RecebimentoRacao {
  final String id;
  final String loteId;
  final String dataRecebimento;

  /// Quantidade recebida em kg.
  final double quantidadeKg;

  final String? tipoRacaoId;
  final String? tipoRacaoNome;
  final String? fornecedor;
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
      origem: json['origem'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'data_recebimento': dataRecebimento,
      'quantidade_kg': quantidadeKg,
      'tipo_racao_id': tipoRacaoId,
      'tipo_racao_nome': tipoRacaoNome,
      'fornecedor': fornecedor,
      'lote_racao': loteRacao,
      'origem': origem,
      'created_at': createdAt,
    };
  }
}

/// Registro de consumo diario de racao de um lote.
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
