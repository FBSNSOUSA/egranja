/// Dados de um sensor IoT.
///
/// Representa uma leitura individual de sensor com valor atual,
/// status de classificacao e historico das ultimas 24 horas.
class SensorData {
  /// Tipo do sensor: temperatura, umidade, co2, amonia, luminosidade, pressao.
  final String tipo;

  /// Valor atual da leitura.
  final double valor;

  /// Unidade de medida (°C, %, ppm, lux, Pa).
  final String unidade;

  /// Status da leitura: 'normal', 'atencao', 'critico'.
  final String status;

  /// Valores das ultimas 24 horas para sparkline.
  final List<double> historico24h;

  /// Momento da leitura.
  final DateTime timestamp;

  const SensorData({
    required this.tipo,
    required this.valor,
    required this.unidade,
    required this.status,
    required this.historico24h,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      tipo: json['tipo'] as String,
      valor: (json['valor'] as num).toDouble(),
      unidade: json['unidade'] as String,
      status: json['status'] as String? ?? 'normal',
      historico24h: (json['historico_24h'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}

/// Resposta da API para leitura mais recente dos sensores IoT de um galpao.
class IoTLatestResponse {
  /// ID do galpao.
  final String galpaoId;

  /// Nome do galpao.
  final String galpaoNome;

  /// Lista de leituras dos sensores.
  final List<SensorData> sensores;

  /// Momento da ultima leitura geral.
  final DateTime ultimaLeitura;

  const IoTLatestResponse({
    required this.galpaoId,
    required this.galpaoNome,
    required this.sensores,
    required this.ultimaLeitura,
  });

  factory IoTLatestResponse.fromJson(Map<String, dynamic> json) {
    return IoTLatestResponse(
      galpaoId: json['galpao_id'] as String? ?? '',
      galpaoNome: json['galpao_nome'] as String? ?? '',
      sensores: (json['sensores'] as List<dynamic>?)
              ?.map((e) => SensorData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ultimaLeitura: json['ultima_leitura'] != null
          ? DateTime.parse(json['ultima_leitura'] as String)
          : DateTime.now(),
    );
  }
}
