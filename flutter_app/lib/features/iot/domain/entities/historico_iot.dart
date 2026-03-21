/// Ponto de dados do historico de um sensor IoT.
class HistoricoDataPoint {
  /// Momento da leitura.
  final DateTime timestamp;

  /// Valor registrado.
  final double valor;

  const HistoricoDataPoint({
    required this.timestamp,
    required this.valor,
  });

  factory HistoricoDataPoint.fromJson(Map<String, dynamic> json) {
    return HistoricoDataPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      valor: (json['valor'] as num).toDouble(),
    );
  }
}

/// Resposta da API para historico de um sensor IoT.
class HistoricoResponse {
  /// Tipo do sensor consultado.
  final String sensor;

  /// Periodo selecionado (24h, 7d, 30d).
  final String periodo;

  /// Lista de pontos de dados do historico.
  final List<HistoricoDataPoint> dados;

  /// Estatisticas calculadas para o periodo.
  final EstatisticasSensor estatisticas;

  /// Faixa ideal de valores para o sensor.
  final RangeIdeal rangeIdeal;

  const HistoricoResponse({
    required this.sensor,
    required this.periodo,
    required this.dados,
    required this.estatisticas,
    required this.rangeIdeal,
  });

  factory HistoricoResponse.fromJson(Map<String, dynamic> json) {
    return HistoricoResponse(
      sensor: json['sensor'] as String? ?? '',
      periodo: json['periodo'] as String? ?? '24h',
      dados: (json['dados'] as List<dynamic>?)
              ?.map(
                  (e) => HistoricoDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      estatisticas: json['estatisticas'] != null
          ? EstatisticasSensor.fromJson(
              json['estatisticas'] as Map<String, dynamic>)
          : const EstatisticasSensor(minimo: 0, maximo: 0, media: 0),
      rangeIdeal: json['range_ideal'] != null
          ? RangeIdeal.fromJson(json['range_ideal'] as Map<String, dynamic>)
          : const RangeIdeal(min: 0, max: 0),
    );
  }
}

/// Estatisticas de um sensor para um determinado periodo.
class EstatisticasSensor {
  /// Valor minimo registrado.
  final double minimo;

  /// Valor maximo registrado.
  final double maximo;

  /// Valor medio do periodo.
  final double media;

  const EstatisticasSensor({
    required this.minimo,
    required this.maximo,
    required this.media,
  });

  factory EstatisticasSensor.fromJson(Map<String, dynamic> json) {
    return EstatisticasSensor(
      minimo: (json['minimo'] as num?)?.toDouble() ?? 0,
      maximo: (json['maximo'] as num?)?.toDouble() ?? 0,
      media: (json['media'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Faixa de valores ideais para um sensor.
class RangeIdeal {
  /// Limite inferior da faixa ideal.
  final double min;

  /// Limite superior da faixa ideal.
  final double max;

  const RangeIdeal({
    required this.min,
    required this.max,
  });

  factory RangeIdeal.fromJson(Map<String, dynamic> json) {
    return RangeIdeal(
      min: (json['min'] as num?)?.toDouble() ?? 0,
      max: (json['max'] as num?)?.toDouble() ?? 0,
    );
  }
}
