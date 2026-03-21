/// Indicadores consolidados de um lote.
///
/// Agrega metricas de desempenho zootecnico, mortalidade,
/// consumo de racao, agua e projecoes calculadas pelo backend.
class Indicadores {
  /// Idade do lote em dias.
  final int diasDeVida;

  /// Quantidade de aves vivas no momento.
  final int avesVivas;

  /// Quantidade original de aves alojadas.
  final int quantidadeOriginal;

  /// Total de mortes acumuladas no lote.
  final int mortalidadeAcumulada;

  /// Percentual de mortalidade acumulada.
  final double mortalidadeAcumuladaPct;

  /// Mortalidade do dia corrente.
  final int mortalidadeDia;

  /// Percentual de mortalidade do dia.
  final double mortalidadeDiaPct;

  /// Ultimo peso medio registrado em gramas.
  final double ultimoPesoMedio;

  /// Peso benchmark da linhagem para a idade, em gramas.
  final double pesoBenchmark;

  /// Desvio percentual do peso real em relacao ao benchmark.
  final double pesoDesvioPct;

  /// Ganho de peso diario em g/dia.
  final double gpd;

  /// Indice de conversao alimentar.
  final double ica;

  /// Indice de eficiencia alimentar.
  final double iea;

  /// Indice de eficiencia produtiva.
  final double iep;

  /// Classificacao do IEP: 'Ruim', 'Regular', 'Bom', 'Excelente'.
  final String iepClassificacao;

  /// Viabilidade do lote (percentual).
  final double viabilidade;

  /// Total de racao recebida em kg.
  final double racaoRecebida;

  /// Total de racao consumida em kg.
  final double racaoConsumida;

  /// Saldo de racao em kg.
  final double saldoRacao;

  /// Dias restantes de racao com base no consumo medio.
  final int diasRestantesRacao;

  /// Consumo medio diario de racao em kg.
  final double consumoMedioDiarioRacao;

  /// Consumo de agua do dia em litros.
  final double consumoAguaDia;

  /// Consumo de agua por ave em mL.
  final double consumoAguaPorAve;

  /// Relacao agua/racao.
  final double relacaoAguaRacao;

  /// Texto descritivo da projecao de desempenho.
  final String projecaoTexto;

  /// Peso projetado no abate em gramas.
  final double pesoProjetadoAbate;

  /// Dias restantes para atingir o peso alvo.
  final int diasParaPesoAlvo;

  const Indicadores({
    required this.diasDeVida,
    required this.avesVivas,
    required this.quantidadeOriginal,
    required this.mortalidadeAcumulada,
    required this.mortalidadeAcumuladaPct,
    required this.mortalidadeDia,
    required this.mortalidadeDiaPct,
    required this.ultimoPesoMedio,
    required this.pesoBenchmark,
    required this.pesoDesvioPct,
    required this.gpd,
    required this.ica,
    required this.iea,
    required this.iep,
    required this.iepClassificacao,
    required this.viabilidade,
    required this.racaoRecebida,
    required this.racaoConsumida,
    required this.saldoRacao,
    required this.diasRestantesRacao,
    required this.consumoMedioDiarioRacao,
    required this.consumoAguaDia,
    required this.consumoAguaPorAve,
    required this.relacaoAguaRacao,
    required this.projecaoTexto,
    required this.pesoProjetadoAbate,
    required this.diasParaPesoAlvo,
  });

  factory Indicadores.fromJson(Map<String, dynamic> json) {
    return Indicadores(
      diasDeVida: json['dias_de_vida'] as int,
      avesVivas: json['aves_vivas'] as int,
      quantidadeOriginal: json['quantidade_original'] as int,
      mortalidadeAcumulada: json['mortalidade_acumulada'] as int,
      mortalidadeAcumuladaPct:
          (json['mortalidade_acumulada_pct'] as num).toDouble(),
      mortalidadeDia: json['mortalidade_dia'] as int,
      mortalidadeDiaPct: (json['mortalidade_dia_pct'] as num).toDouble(),
      ultimoPesoMedio: (json['ultimo_peso_medio'] as num).toDouble(),
      pesoBenchmark: (json['peso_benchmark'] as num).toDouble(),
      pesoDesvioPct: (json['peso_desvio_pct'] as num).toDouble(),
      gpd: (json['gpd'] as num).toDouble(),
      ica: (json['ica'] as num).toDouble(),
      iea: (json['iea'] as num).toDouble(),
      iep: (json['iep'] as num).toDouble(),
      iepClassificacao: json['iep_classificacao'] as String,
      viabilidade: (json['viabilidade'] as num).toDouble(),
      racaoRecebida: (json['racao_recebida'] as num).toDouble(),
      racaoConsumida: (json['racao_consumida'] as num).toDouble(),
      saldoRacao: (json['saldo_racao'] as num).toDouble(),
      diasRestantesRacao: json['dias_restantes_racao'] as int,
      consumoMedioDiarioRacao:
          (json['consumo_medio_diario_racao'] as num).toDouble(),
      consumoAguaDia: (json['consumo_agua_dia'] as num).toDouble(),
      consumoAguaPorAve: (json['consumo_agua_por_ave'] as num).toDouble(),
      relacaoAguaRacao: (json['relacao_agua_racao'] as num).toDouble(),
      projecaoTexto: json['projecao_texto'] as String,
      pesoProjetadoAbate: (json['peso_projetado_abate'] as num).toDouble(),
      diasParaPesoAlvo: json['dias_para_peso_alvo'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dias_de_vida': diasDeVida,
      'aves_vivas': avesVivas,
      'quantidade_original': quantidadeOriginal,
      'mortalidade_acumulada': mortalidadeAcumulada,
      'mortalidade_acumulada_pct': mortalidadeAcumuladaPct,
      'mortalidade_dia': mortalidadeDia,
      'mortalidade_dia_pct': mortalidadeDiaPct,
      'ultimo_peso_medio': ultimoPesoMedio,
      'peso_benchmark': pesoBenchmark,
      'peso_desvio_pct': pesoDesvioPct,
      'gpd': gpd,
      'ica': ica,
      'iea': iea,
      'iep': iep,
      'iep_classificacao': iepClassificacao,
      'viabilidade': viabilidade,
      'racao_recebida': racaoRecebida,
      'racao_consumida': racaoConsumida,
      'saldo_racao': saldoRacao,
      'dias_restantes_racao': diasRestantesRacao,
      'consumo_medio_diario_racao': consumoMedioDiarioRacao,
      'consumo_agua_dia': consumoAguaDia,
      'consumo_agua_por_ave': consumoAguaPorAve,
      'relacao_agua_racao': relacaoAguaRacao,
      'projecao_texto': projecaoTexto,
      'peso_projetado_abate': pesoProjetadoAbate,
      'dias_para_peso_alvo': diasParaPesoAlvo,
    };
  }
}
