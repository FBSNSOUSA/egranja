/// Custo agrupado por categoria.
class CustoCategoria {
  final String categoria;
  final double total;

  const CustoCategoria({
    required this.categoria,
    required this.total,
  });

  factory CustoCategoria.fromJson(Map<String, dynamic> json) {
    return CustoCategoria(
      categoria: json['categoria'] as String? ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoria': categoria,
      'total': total,
    };
  }
}

/// Resumo financeiro consolidado de um lote.
///
/// Retorna custo total, receita total, resultado liquido,
/// custo por kg e por ave, margens e custos agrupados por categoria.
class ResumoFinanceiro {
  final String? loteId;
  final double custoTotal;
  final double receitaTotal;
  final double resultadoLiquido;
  final double? custoPorKg;
  final double? custoPorAve;
  final double? margemPorKg;
  final double? margemPorAve;
  final List<CustoCategoria> custosPorCategoria;

  const ResumoFinanceiro({
    this.loteId,
    required this.custoTotal,
    required this.receitaTotal,
    required this.resultadoLiquido,
    this.custoPorKg,
    this.custoPorAve,
    this.margemPorKg,
    this.margemPorAve,
    this.custosPorCategoria = const [],
  });

  factory ResumoFinanceiro.fromJson(Map<String, dynamic> json) {
    final custosCatJson = json['custos_por_categoria'] as List<dynamic>?;

    return ResumoFinanceiro(
      loteId: json['lote_id'] as String?,
      custoTotal: (json['custo_total'] as num?)?.toDouble() ?? 0.0,
      receitaTotal: (json['receita_total'] as num?)?.toDouble() ?? 0.0,
      resultadoLiquido: (json['resultado_liquido'] as num?)?.toDouble() ?? 0.0,
      custoPorKg: (json['custo_por_kg'] as num?)?.toDouble(),
      custoPorAve: (json['custo_por_ave'] as num?)?.toDouble(),
      margemPorKg: (json['margem_por_kg'] as num?)?.toDouble(),
      margemPorAve: (json['margem_por_ave'] as num?)?.toDouble(),
      custosPorCategoria: custosCatJson
              ?.map((e) =>
                  CustoCategoria.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (loteId != null) 'lote_id': loteId,
      'custo_total': custoTotal,
      'receita_total': receitaTotal,
      'resultado_liquido': resultadoLiquido,
      if (custoPorKg != null) 'custo_por_kg': custoPorKg,
      if (custoPorAve != null) 'custo_por_ave': custoPorAve,
      if (margemPorKg != null) 'margem_por_kg': margemPorKg,
      if (margemPorAve != null) 'margem_por_ave': margemPorAve,
      'custos_por_categoria':
          custosPorCategoria.map((e) => e.toJson()).toList(),
    };
  }
}
