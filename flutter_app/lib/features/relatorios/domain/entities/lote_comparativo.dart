/// Dados comparativos de desempenho de um lote.
///
/// Usado na tela de comparativo para exibir indicadores
/// lado a lado entre lotes do mesmo galpao.
class LoteComparativo {
  final String loteId;
  final String dataAlojamento;
  final int diasDeVida;
  final int quantidade;
  final int mortalidade;
  final double mortalidadePct;
  final double? pesoMedio;
  final double? ica;
  final double? iep;
  final double? gpd;

  const LoteComparativo({
    required this.loteId,
    required this.dataAlojamento,
    required this.diasDeVida,
    required this.quantidade,
    required this.mortalidade,
    required this.mortalidadePct,
    this.pesoMedio,
    this.ica,
    this.iep,
    this.gpd,
  });

  /// Label curto para identificar o lote na UI (primeiros 8 chars do ID).
  String get loteLabel {
    if (loteId.length >= 8) return loteId.substring(0, 8);
    return loteId;
  }

  /// Viabilidade percentual derivada: 100 - mortalidade %.
  double get viabilidadePct => 100.0 - mortalidadePct;

  factory LoteComparativo.fromJson(Map<String, dynamic> json) {
    return LoteComparativo(
      loteId: json['lote_id'] as String,
      dataAlojamento: json['data_alojamento'] as String? ?? '',
      diasDeVida: (json['dias_de_vida'] as num?)?.toInt() ?? 0,
      quantidade: (json['quantidade'] as num?)?.toInt() ?? 0,
      mortalidade: (json['mortalidade'] as num?)?.toInt() ?? 0,
      mortalidadePct: (json['mortalidade_pct'] as num?)?.toDouble() ?? 0.0,
      pesoMedio: (json['peso_medio'] as num?)?.toDouble(),
      ica: (json['ica'] as num?)?.toDouble(),
      iep: (json['iep'] as num?)?.toDouble(),
      gpd: (json['gpd'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lote_id': loteId,
      'data_alojamento': dataAlojamento,
      'dias_de_vida': diasDeVida,
      'quantidade': quantidade,
      'mortalidade': mortalidade,
      'mortalidade_pct': mortalidadePct,
      if (pesoMedio != null) 'peso_medio': pesoMedio,
      if (ica != null) 'ica': ica,
      if (iep != null) 'iep': iep,
      if (gpd != null) 'gpd': gpd,
    };
  }
}
