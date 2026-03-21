/// Registro de consumo diario de agua de um lote.
class ConsumoAgua {
  final String id;
  final String loteId;
  final String data;

  /// Quantidade consumida em litros.
  final double quantidadeLitros;

  /// Consumo por ave em mL.
  final double? consumoPorAve;

  /// Relacao agua/racao.
  final double? relacaoAguaRacao;

  final String createdAt;

  const ConsumoAgua({
    required this.id,
    required this.loteId,
    required this.data,
    required this.quantidadeLitros,
    this.consumoPorAve,
    this.relacaoAguaRacao,
    required this.createdAt,
  });

  factory ConsumoAgua.fromJson(Map<String, dynamic> json) {
    return ConsumoAgua(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      data: json['data'] as String,
      quantidadeLitros: (json['quantidade_litros'] as num).toDouble(),
      consumoPorAve: (json['consumo_por_ave'] as num?)?.toDouble(),
      relacaoAguaRacao: (json['relacao_agua_racao'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'data': data,
      'quantidade_litros': quantidadeLitros,
      'consumo_por_ave': consumoPorAve,
      'relacao_agua_racao': relacaoAguaRacao,
      'created_at': createdAt,
    };
  }
}
