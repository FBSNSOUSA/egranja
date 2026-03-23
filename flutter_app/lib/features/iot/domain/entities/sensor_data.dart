/// Dados de um sensor IoT.
///
/// Representa uma leitura individual de sensor com valor atual,
/// status de classificacao e historico das ultimas 24 horas.
///
/// Backend DTO: IoTReadingResponse
///   { "id", "galpao_id", "sensor_tipo", "valor", "unidade", "timestamp" }
class SensorData {
  /// ID unico da leitura.
  final String id;

  /// Tipo do sensor: temperatura, umidade, co2, amonia, luminosidade, pressao.
  /// Backend field: `sensor_tipo`.
  final String tipo;

  /// Valor atual da leitura.
  final double valor;

  /// Unidade de medida (°C, %, ppm, lux, Pa).
  final String unidade;

  /// Status da leitura: 'normal', 'atencao', 'critico'.
  /// Calculado localmente -- backend nao envia este campo.
  final String status;

  /// Valores das ultimas 24 horas para sparkline.
  /// Calculado localmente -- backend nao envia este campo.
  final List<double> historico24h;

  /// Momento da leitura.
  final DateTime timestamp;

  const SensorData({
    this.id = '',
    required this.tipo,
    required this.valor,
    required this.unidade,
    required this.status,
    required this.historico24h,
    required this.timestamp,
  });

  /// Cria a partir do JSON da API (IoTReadingResponse).
  ///
  /// Backend envia `sensor_tipo` (nao `tipo`) e nao envia `status`
  /// nem `historico_24h`.
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id']?.toString() ?? '',
      tipo: json['sensor_tipo'] as String? ?? json['tipo'] as String? ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0,
      unidade: json['unidade'] as String? ?? '',
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
///
/// Backend DTO: IoTLatestResponse
///   { "galpao_id": UUID, "sensores": [IoTReadingResponse] }
class IoTLatestResponse {
  /// ID do galpao.
  final String galpaoId;

  /// Lista de leituras dos sensores.
  final List<SensorData> sensores;

  /// Momento da ultima leitura geral.
  /// Derivado do sensor com timestamp mais recente.
  final DateTime ultimaLeitura;

  const IoTLatestResponse({
    required this.galpaoId,
    required this.sensores,
    required this.ultimaLeitura,
  });

  factory IoTLatestResponse.fromJson(Map<String, dynamic> json) {
    final sensores = (json['sensores'] as List<dynamic>?)
            ?.map((e) => SensorData.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Derivar ultimaLeitura do sensor com timestamp mais recente
    DateTime ultimaLeitura = DateTime.now();
    if (sensores.isNotEmpty) {
      ultimaLeitura = sensores
          .map((s) => s.timestamp)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }

    return IoTLatestResponse(
      galpaoId: json['galpao_id']?.toString() ?? '',
      sensores: sensores,
      ultimaLeitura: ultimaLeitura,
    );
  }
}
