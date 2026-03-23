/// Ponto de dados do historico de um sensor IoT.
///
/// Backend DTO: IoTAgregadoItem
///   { "periodo", "sensor_tipo", "media", "minimo", "maximo", "contagem" }
///
/// O campo `timestamp` mapeia para `periodo` do backend.
/// O campo `valor` mapeia para `media` do backend.
class HistoricoDataPoint {
  /// Momento da leitura (backend: `periodo`).
  final DateTime timestamp;

  /// Valor registrado (backend: `media`).
  final double valor;

  /// Tipo do sensor (backend: `sensor_tipo`).
  final String sensorTipo;

  /// Valor minimo do periodo (backend: `minimo`).
  final double minimo;

  /// Valor maximo do periodo (backend: `maximo`).
  final double maximo;

  /// Numero de leituras no periodo (backend: `contagem`).
  final int contagem;

  const HistoricoDataPoint({
    required this.timestamp,
    required this.valor,
    this.sensorTipo = '',
    this.minimo = 0,
    this.maximo = 0,
    this.contagem = 0,
  });

  factory HistoricoDataPoint.fromJson(Map<String, dynamic> json) {
    return HistoricoDataPoint(
      timestamp: json['periodo'] != null
          ? DateTime.parse(json['periodo'] as String)
          : (json['timestamp'] != null
              ? DateTime.parse(json['timestamp'] as String)
              : DateTime.now()),
      valor: (json['media'] as num?)?.toDouble() ??
          (json['valor'] as num?)?.toDouble() ??
          0,
      sensorTipo: json['sensor_tipo'] as String? ?? '',
      minimo: (json['minimo'] as num?)?.toDouble() ?? 0,
      maximo: (json['maximo'] as num?)?.toDouble() ?? 0,
      contagem: (json['contagem'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Resposta da API para historico IoT agregado.
///
/// Backend DTO: IoTHistoricoResponse
///   { "galpao_id", "intervalo", "dados": [IoTAgregadoItem] }
///
/// O Flutter UI usa `sensor` e `periodo` selecionados pelo usuario,
/// mas o backend retorna `intervalo` (hora/dia) e dados com `sensor_tipo`.
class HistoricoResponse {
  /// Tipo do sensor consultado (filtrado localmente dos dados retornados).
  final String sensor;

  /// Periodo selecionado no UI (24h, 7d, 30d).
  /// O backend usa `intervalo` (hora/dia) -- mapeado pelo provider.
  final String periodo;

  /// Lista de pontos de dados do historico.
  final List<HistoricoDataPoint> dados;

  /// Estatisticas calculadas a partir dos dados retornados.
  final EstatisticasSensor estatisticas;

  /// Faixa ideal de valores para o sensor (calculada localmente).
  final RangeIdeal rangeIdeal;

  const HistoricoResponse({
    required this.sensor,
    required this.periodo,
    required this.dados,
    required this.estatisticas,
    required this.rangeIdeal,
  });

  /// Constroi a partir do JSON do backend (IoTHistoricoResponse).
  ///
  /// Filtra os dados pelo `sensorTipo` desejado e calcula estatisticas
  /// localmente a partir dos dados.
  factory HistoricoResponse.fromBackendJson(
    Map<String, dynamic> json, {
    required String sensorTipo,
    required String periodo,
  }) {
    final todosDados = (json['dados'] as List<dynamic>?)
            ?.map(
                (e) => HistoricoDataPoint.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Filtrar pelo tipo de sensor desejado
    final dados = sensorTipo.isNotEmpty
        ? todosDados.where((d) => d.sensorTipo == sensorTipo).toList()
        : todosDados;

    // Calcular estatisticas localmente
    EstatisticasSensor estatisticas;
    if (dados.isNotEmpty) {
      double minimo = dados.first.minimo;
      double maximo = dados.first.maximo;
      double soma = 0;
      for (final d in dados) {
        if (d.minimo < minimo) minimo = d.minimo;
        if (d.maximo > maximo) maximo = d.maximo;
        soma += d.valor;
      }
      estatisticas = EstatisticasSensor(
        minimo: minimo,
        maximo: maximo,
        media: soma / dados.length,
      );
    } else {
      estatisticas = const EstatisticasSensor(minimo: 0, maximo: 0, media: 0);
    }

    // Faixa ideal padrao por tipo de sensor
    final rangeIdeal = _defaultRange(sensorTipo);

    return HistoricoResponse(
      sensor: sensorTipo,
      periodo: periodo,
      dados: dados,
      estatisticas: estatisticas,
      rangeIdeal: rangeIdeal,
    );
  }

  /// Retorna a faixa ideal padrao para cada tipo de sensor.
  static RangeIdeal _defaultRange(String sensorTipo) {
    switch (sensorTipo) {
      case 'temperatura':
        return const RangeIdeal(min: 20, max: 32);
      case 'umidade':
        return const RangeIdeal(min: 50, max: 70);
      case 'co2':
        return const RangeIdeal(min: 0, max: 3000);
      case 'amonia':
        return const RangeIdeal(min: 0, max: 20);
      case 'luminosidade':
        return const RangeIdeal(min: 5, max: 60);
      case 'pressao':
        return const RangeIdeal(min: 10, max: 25);
      default:
        return const RangeIdeal(min: 0, max: 100);
    }
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
