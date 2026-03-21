/// Resumo financeiro consolidado de um lote.
///
/// Agrupa custos por categoria, receita estimada, margem e custo por kg vivo.
class ResumoFinanceiro {
  final double custoTotal;
  final double custoRacao;
  final double custoMedicamentos;
  final double custoPintos;
  final double custoMaoObra;
  final double custoOutros;
  final double receitaEstimada;
  final double margemEstimada;
  final double custoKgVivo;

  const ResumoFinanceiro({
    required this.custoTotal,
    required this.custoRacao,
    required this.custoMedicamentos,
    required this.custoPintos,
    required this.custoMaoObra,
    required this.custoOutros,
    required this.receitaEstimada,
    required this.margemEstimada,
    required this.custoKgVivo,
  });

  factory ResumoFinanceiro.fromJson(Map<String, dynamic> json) {
    return ResumoFinanceiro(
      custoTotal: (json['custo_total'] as num).toDouble(),
      custoRacao: (json['custo_racao'] as num).toDouble(),
      custoMedicamentos: (json['custo_medicamentos'] as num).toDouble(),
      custoPintos: (json['custo_pintos'] as num).toDouble(),
      custoMaoObra: (json['custo_mao_obra'] as num).toDouble(),
      custoOutros: (json['custo_outros'] as num).toDouble(),
      receitaEstimada: (json['receita_estimada'] as num).toDouble(),
      margemEstimada: (json['margem_estimada'] as num).toDouble(),
      custoKgVivo: (json['custo_kg_vivo'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'custo_total': custoTotal,
      'custo_racao': custoRacao,
      'custo_medicamentos': custoMedicamentos,
      'custo_pintos': custoPintos,
      'custo_mao_obra': custoMaoObra,
      'custo_outros': custoOutros,
      'receita_estimada': receitaEstimada,
      'margem_estimada': margemEstimada,
      'custo_kg_vivo': custoKgVivo,
    };
  }
}
