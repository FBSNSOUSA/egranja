/// Indicadores consolidados de um lote.
///
/// Agrega metricas de desempenho zootecnico, mortalidade,
/// consumo de racao, agua e projecoes calculadas pelo backend.
///
/// Campos mapeados do DTO LoteIndicadoresResponse do backend Go.
/// Campos opcionais podem nao ser retornados dependendo do estado do lote.
class Indicadores {
  /// ID do lote.
  final String? loteId;

  /// Idade do lote em dias.
  final int diasDeVida;

  /// Quantidade de aves vivas no momento.
  final int avesVivas;

  /// Quantidade original de aves alojadas (campo `aves_alojadas`).
  final int avesAlojadas;

  /// Total de mortes acumuladas no lote (campo `mortalidade_total`).
  final int mortalidadeTotal;

  /// Percentual de mortalidade acumulada (campo `mortalidade_pct`).
  final double mortalidadePct;

  /// Viabilidade do lote (percentual).
  final double viabilidade;

  // ── Peso ─────────────────────────────────────────────────────────

  /// Ultimo peso medio registrado em gramas (campo `ultimo_peso_medio`).
  final double? ultimoPesoMedio;

  /// Peso padrao da linhagem para a idade, em gramas (campo `peso_padrao_g`).
  final double? pesoPadraoG;

  /// Desvio percentual do peso real em relacao ao padrao (campo `desvio_peso_pct`).
  final double? desvioPesoPct;

  // ── Indices zootecnicos ──────────────────────────────────────────

  /// Ganho de peso diario em g/dia.
  final double? gpd;

  /// Indice de conversao alimentar.
  final double? ica;

  /// Indice de eficiencia alimentar.
  final double? iea;

  /// Indice de eficiencia produtiva.
  final double? iep;

  /// Classificacao do IEP: 'Ruim', 'Regular', 'Bom', 'Excelente'.
  /// Campo `classificacao_iep` no backend.
  final String? classificacaoIep;

  // ── Racao ─────────────────────────────────────────────────────────

  /// Total de racao consumida em kg (campo `consumo_total_racao_kg`).
  final double? consumoTotalRacaoKg;

  /// Total de racao recebida em kg (campo `recebido_total_racao_kg`).
  final double? recebidoTotalRacaoKg;

  /// Saldo de racao em kg (campo `saldo_racao_kg`).
  final double? saldoRacaoKg;

  /// Dias de estoque de racao (campo `dias_estoque_racao`).
  final double? diasEstoqueRacao;

  /// Consumo de racao por ave em kg (campo `consumo_racao_por_ave`).
  final double? consumoRacaoPorAve;

  // ── Agua ─────────────────────────────────────────────────────────

  /// Consumo de agua do dia em litros (campo `consumo_agua_dia_l`).
  final double? consumoAguaDiaL;

  /// Relacao agua/racao.
  final double? relacaoAguaRacao;

  // ── Projecao ─────────────────────────────────────────────────────

  /// Projecao de peso (campo `projecao_peso`).
  final ProjecaoPeso? projecaoPeso;

  const Indicadores({
    this.loteId,
    required this.diasDeVida,
    required this.avesVivas,
    required this.avesAlojadas,
    required this.mortalidadeTotal,
    required this.mortalidadePct,
    required this.viabilidade,
    this.ultimoPesoMedio,
    this.pesoPadraoG,
    this.desvioPesoPct,
    this.gpd,
    this.ica,
    this.iea,
    this.iep,
    this.classificacaoIep,
    this.consumoTotalRacaoKg,
    this.recebidoTotalRacaoKg,
    this.saldoRacaoKg,
    this.diasEstoqueRacao,
    this.consumoRacaoPorAve,
    this.consumoAguaDiaL,
    this.relacaoAguaRacao,
    this.projecaoPeso,
  });

  factory Indicadores.fromJson(Map<String, dynamic> json) {
    return Indicadores(
      loteId: json['lote_id'] as String?,
      diasDeVida: (json['dias_de_vida'] as num?)?.toInt() ?? 0,
      avesVivas: (json['aves_vivas'] as num?)?.toInt() ?? 0,
      avesAlojadas: (json['aves_alojadas'] as num?)?.toInt() ?? 0,
      mortalidadeTotal: (json['mortalidade_total'] as num?)?.toInt() ?? 0,
      mortalidadePct: (json['mortalidade_pct'] as num?)?.toDouble() ?? 0.0,
      viabilidade: (json['viabilidade'] as num?)?.toDouble() ?? 0.0,
      ultimoPesoMedio: (json['ultimo_peso_medio'] as num?)?.toDouble(),
      pesoPadraoG: (json['peso_padrao_g'] as num?)?.toDouble(),
      desvioPesoPct: (json['desvio_peso_pct'] as num?)?.toDouble(),
      gpd: (json['gpd'] as num?)?.toDouble(),
      ica: (json['ica'] as num?)?.toDouble(),
      iea: (json['iea'] as num?)?.toDouble(),
      iep: (json['iep'] as num?)?.toDouble(),
      classificacaoIep: json['classificacao_iep'] as String?,
      consumoTotalRacaoKg:
          (json['consumo_total_racao_kg'] as num?)?.toDouble(),
      recebidoTotalRacaoKg:
          (json['recebido_total_racao_kg'] as num?)?.toDouble(),
      saldoRacaoKg: (json['saldo_racao_kg'] as num?)?.toDouble(),
      diasEstoqueRacao:
          (json['dias_estoque_racao'] as num?)?.toDouble(),
      consumoRacaoPorAve:
          (json['consumo_racao_por_ave'] as num?)?.toDouble(),
      consumoAguaDiaL:
          (json['consumo_agua_dia_l'] as num?)?.toDouble(),
      relacaoAguaRacao:
          (json['relacao_agua_racao'] as num?)?.toDouble(),
      projecaoPeso: json['projecao_peso'] != null
          ? ProjecaoPeso.fromJson(
              json['projecao_peso'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (loteId != null) 'lote_id': loteId,
      'dias_de_vida': diasDeVida,
      'aves_vivas': avesVivas,
      'aves_alojadas': avesAlojadas,
      'mortalidade_total': mortalidadeTotal,
      'mortalidade_pct': mortalidadePct,
      'viabilidade': viabilidade,
      if (ultimoPesoMedio != null) 'ultimo_peso_medio': ultimoPesoMedio,
      if (pesoPadraoG != null) 'peso_padrao_g': pesoPadraoG,
      if (desvioPesoPct != null) 'desvio_peso_pct': desvioPesoPct,
      if (gpd != null) 'gpd': gpd,
      if (ica != null) 'ica': ica,
      if (iea != null) 'iea': iea,
      if (iep != null) 'iep': iep,
      if (classificacaoIep != null) 'classificacao_iep': classificacaoIep,
      if (consumoTotalRacaoKg != null)
        'consumo_total_racao_kg': consumoTotalRacaoKg,
      if (recebidoTotalRacaoKg != null)
        'recebido_total_racao_kg': recebidoTotalRacaoKg,
      if (saldoRacaoKg != null) 'saldo_racao_kg': saldoRacaoKg,
      if (diasEstoqueRacao != null) 'dias_estoque_racao': diasEstoqueRacao,
      if (consumoRacaoPorAve != null)
        'consumo_racao_por_ave': consumoRacaoPorAve,
      if (consumoAguaDiaL != null) 'consumo_agua_dia_l': consumoAguaDiaL,
      if (relacaoAguaRacao != null) 'relacao_agua_racao': relacaoAguaRacao,
      if (projecaoPeso != null) 'projecao_peso': projecaoPeso!.toJson(),
    };
  }
}

/// Projecao de peso do lote.
///
/// Campos mapeados do DTO ProjecaoPesoDTO do backend Go.
class ProjecaoPeso {
  final double pesoEstimadoG;
  final String dataEstimada;
  final double gpdG;
  final String mensagem;

  const ProjecaoPeso({
    required this.pesoEstimadoG,
    required this.dataEstimada,
    required this.gpdG,
    required this.mensagem,
  });

  factory ProjecaoPeso.fromJson(Map<String, dynamic> json) {
    return ProjecaoPeso(
      pesoEstimadoG: (json['peso_estimado_g'] as num?)?.toDouble() ?? 0.0,
      dataEstimada: json['data_estimada'] as String? ?? '',
      gpdG: (json['gpd_g'] as num?)?.toDouble() ?? 0.0,
      mensagem: json['mensagem'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'peso_estimado_g': pesoEstimadoG,
      'data_estimada': dataEstimada,
      'gpd_g': gpdG,
      'mensagem': mensagem,
    };
  }
}
