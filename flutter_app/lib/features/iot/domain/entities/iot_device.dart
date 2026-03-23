/// Entidade que representa um dispositivo/sensor IoT configurado.
///
/// Diferente de [SensorData] (que e uma leitura individual),
/// esta classe representa a configuracao persistente do sensor.
class IoTDevice {
  /// ID unico do dispositivo.
  final String id;

  /// Nome amigavel (ex: "Sensor Temp Galpao 1").
  final String nome;

  /// Tipo do sensor: temperatura, umidade, amonia, co2, luminosidade, pressao.
  final String tipo;

  /// ID do galpao associado.
  final String galpaoId;

  /// Nome do galpao (para exibicao).
  final String galpaoNome;

  /// Topico MQTT configurado.
  final String mqttTopic;

  /// Se o dispositivo esta ativo.
  final bool ativo;

  /// Status de conexao: online, offline.
  final String status;

  /// Ultima leitura recebida.
  final double? ultimaLeitura;

  /// Unidade de medida da ultima leitura.
  final String unidade;

  /// Timestamp da ultima leitura.
  final DateTime? ultimaLeituraTimestamp;

  /// Data de criacao.
  final DateTime createdAt;

  const IoTDevice({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.galpaoId,
    this.galpaoNome = '',
    this.mqttTopic = '',
    this.ativo = true,
    this.status = 'offline',
    this.ultimaLeitura,
    this.unidade = '',
    this.ultimaLeituraTimestamp,
    required this.createdAt,
  });

  factory IoTDevice.fromJson(Map<String, dynamic> json) {
    return IoTDevice(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] as String? ?? '',
      tipo: json['tipo'] as String? ?? json['sensor_tipo'] as String? ?? '',
      galpaoId: json['galpao_id']?.toString() ?? '',
      galpaoNome: json['galpao_nome'] as String? ?? '',
      mqttTopic: json['mqtt_topic'] as String? ?? '',
      ativo: json['ativo'] as bool? ?? true,
      status: json['status'] as String? ?? 'offline',
      ultimaLeitura: (json['ultima_leitura'] as num?)?.toDouble(),
      unidade: json['unidade'] as String? ?? _unidadePorTipo(json['tipo'] as String? ?? ''),
      ultimaLeituraTimestamp: json['ultima_leitura_timestamp'] != null
          ? DateTime.tryParse(json['ultima_leitura_timestamp'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'tipo': tipo,
      'galpao_id': galpaoId,
      'mqtt_topic': mqttTopic,
      'ativo': ativo,
    };
  }

  IoTDevice copyWith({
    String? nome,
    String? tipo,
    String? galpaoId,
    String? galpaoNome,
    String? mqttTopic,
    bool? ativo,
    String? status,
  }) {
    return IoTDevice(
      id: id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      galpaoId: galpaoId ?? this.galpaoId,
      galpaoNome: galpaoNome ?? this.galpaoNome,
      mqttTopic: mqttTopic ?? this.mqttTopic,
      ativo: ativo ?? this.ativo,
      status: status ?? this.status,
      ultimaLeitura: ultimaLeitura,
      unidade: unidade,
      ultimaLeituraTimestamp: ultimaLeituraTimestamp,
      createdAt: createdAt,
    );
  }

  /// Retorna true se a ultima leitura foi ha mais de 5 minutos.
  bool get isOffline {
    if (ultimaLeituraTimestamp == null) return true;
    return DateTime.now().difference(ultimaLeituraTimestamp!).inMinutes > 5;
  }

  /// Retorna a unidade padrao por tipo de sensor.
  static String _unidadePorTipo(String tipo) {
    switch (tipo) {
      case 'temperatura':
        return '\u00B0C';
      case 'umidade':
        return '%';
      case 'co2':
        return 'ppm';
      case 'amonia':
      case 'nh3':
        return 'ppm';
      case 'luminosidade':
        return 'lux';
      case 'pressao':
        return 'Pa';
      default:
        return '';
    }
  }
}
