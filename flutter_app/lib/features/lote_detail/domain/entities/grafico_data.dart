/// Ponto individual de um grafico (label + valor numerico).
class PontoGrafico {
  final String label;
  final double valor;

  const PontoGrafico({
    required this.label,
    required this.valor,
  });

  factory PontoGrafico.fromJson(Map<String, dynamic> json) {
    return PontoGrafico(
      label: json['label'] as String,
      valor: (json['valor'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'valor': valor,
    };
  }
}

/// Dados para o grafico de evolucao de peso.
///
/// Contem as series de peso real e peso benchmark para comparacao.
class DadosGraficoPeso {
  final List<PontoGrafico> pesoReal;
  final List<PontoGrafico> pesoBenchmark;

  const DadosGraficoPeso({
    required this.pesoReal,
    required this.pesoBenchmark,
  });

  factory DadosGraficoPeso.fromJson(Map<String, dynamic> json) {
    return DadosGraficoPeso(
      pesoReal: (json['peso_real'] as List<dynamic>)
          .map((e) => PontoGrafico.fromJson(e as Map<String, dynamic>))
          .toList(),
      pesoBenchmark: (json['peso_benchmark'] as List<dynamic>)
          .map((e) => PontoGrafico.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'peso_real': pesoReal.map((e) => e.toJson()).toList(),
      'peso_benchmark': pesoBenchmark.map((e) => e.toJson()).toList(),
    };
  }
}

/// Dados para o grafico de mortalidade.
///
/// Contem as series de mortalidade diaria e acumulada.
class DadosGraficoMortalidade {
  final List<PontoGrafico> mortalidadeDiaria;
  final List<PontoGrafico> mortalidadeAcumulada;

  const DadosGraficoMortalidade({
    required this.mortalidadeDiaria,
    required this.mortalidadeAcumulada,
  });

  factory DadosGraficoMortalidade.fromJson(Map<String, dynamic> json) {
    return DadosGraficoMortalidade(
      mortalidadeDiaria: (json['mortalidade_diaria'] as List<dynamic>)
          .map((e) => PontoGrafico.fromJson(e as Map<String, dynamic>))
          .toList(),
      mortalidadeAcumulada: (json['mortalidade_acumulada'] as List<dynamic>)
          .map((e) => PontoGrafico.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mortalidade_diaria':
          mortalidadeDiaria.map((e) => e.toJson()).toList(),
      'mortalidade_acumulada':
          mortalidadeAcumulada.map((e) => e.toJson()).toList(),
    };
  }
}
