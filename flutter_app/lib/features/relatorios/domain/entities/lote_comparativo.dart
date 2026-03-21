/// Dados comparativos de desempenho de um lote.
///
/// Usado na tela de comparativo para exibir indicadores
/// lado a lado entre lotes finalizados.
class LoteComparativo {
  final String loteId;
  final String loteNome;
  final double pesoMedioG;
  final double mortalidadePct;
  final double conversaoAlimentar;
  final double iep;
  final double gpd;
  final double viabilidadePct;
  final int totalAvesAlojadas;
  final int totalAvesAbatidas;

  const LoteComparativo({
    required this.loteId,
    required this.loteNome,
    required this.pesoMedioG,
    required this.mortalidadePct,
    required this.conversaoAlimentar,
    required this.iep,
    required this.gpd,
    required this.viabilidadePct,
    required this.totalAvesAlojadas,
    required this.totalAvesAbatidas,
  });

  factory LoteComparativo.fromJson(Map<String, dynamic> json) {
    return LoteComparativo(
      loteId: json['lote_id'] as String,
      loteNome: json['lote_nome'] as String,
      pesoMedioG: (json['peso_medio_g'] as num).toDouble(),
      mortalidadePct: (json['mortalidade_pct'] as num).toDouble(),
      conversaoAlimentar: (json['conversao_alimentar'] as num).toDouble(),
      iep: (json['iep'] as num).toDouble(),
      gpd: (json['gpd'] as num).toDouble(),
      viabilidadePct: (json['viabilidade_pct'] as num).toDouble(),
      totalAvesAlojadas: json['total_aves_alojadas'] as int,
      totalAvesAbatidas: json['total_aves_abatidas'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lote_id': loteId,
      'lote_nome': loteNome,
      'peso_medio_g': pesoMedioG,
      'mortalidade_pct': mortalidadePct,
      'conversao_alimentar': conversaoAlimentar,
      'iep': iep,
      'gpd': gpd,
      'viabilidade_pct': viabilidadePct,
      'total_aves_alojadas': totalAvesAlojadas,
      'total_aves_abatidas': totalAvesAbatidas,
    };
  }
}
