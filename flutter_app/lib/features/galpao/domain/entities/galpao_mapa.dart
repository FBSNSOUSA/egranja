/// Informacoes de IoT do galpao para exibicao no mapa.
class IoTInfo {
  final double? temperatura;
  final double? umidade;
  final String status;

  const IoTInfo({
    this.temperatura,
    this.umidade,
    this.status = 'offline',
  });

  factory IoTInfo.fromJson(Map<String, dynamic> json) {
    return IoTInfo(
      temperatura: (json['temperatura'] as num?)?.toDouble(),
      umidade: (json['umidade'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'offline',
    );
  }
}

/// Informacoes do lote ativo do galpao para exibicao no mapa.
class LoteAtivoInfo {
  final String id;
  final int avesVivas;
  final int diasDeVida;

  const LoteAtivoInfo({
    required this.id,
    required this.avesVivas,
    required this.diasDeVida,
  });

  factory LoteAtivoInfo.fromJson(Map<String, dynamic> json) {
    return LoteAtivoInfo(
      id: json['id'] as String,
      avesVivas: (json['aves_vivas'] as num?)?.toInt() ?? 0,
      diasDeVida: (json['dias_de_vida'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Entidade que representa um galpao no mapa, com coordenadas e informacoes
/// resumidas de IoT e lote ativo.
///
/// Backend DTO: GalpaoResponse
///   { "id", "usuario_id", "granja_id", "nome", "capacidade",
///     "latitude", "longitude", "orientacao_graus", "comprimento_m",
///     "largura_m", "area_m2", "tipo_ventilacao", "lado_cortinas",
///     "created_at", "updated_at" }
class GalpaoMapa {
  final String id;
  final String nome;
  final double latitude;
  final double longitude;
  final double orientacaoGraus;
  final double larguraM;
  final double comprimentoM;
  final String ventilacao;
  final String cortinas;
  final LoteAtivoInfo? loteAtivo;
  final IoTInfo? iot;

  const GalpaoMapa({
    required this.id,
    required this.nome,
    required this.latitude,
    required this.longitude,
    this.orientacaoGraus = 0,
    this.larguraM = 0,
    this.comprimentoM = 0,
    this.ventilacao = '',
    this.cortinas = '',
    this.loteAtivo,
    this.iot,
  });

  /// Cria a partir do JSON do backend (GalpaoResponse).
  ///
  /// Backend envia `tipo_ventilacao` (nao `ventilacao`) e
  /// `lado_cortinas` (nao `cortinas`). `orientacao_graus` e *int no backend.
  /// `lote_ativo` e `iot` nao sao enviados pelo backend neste endpoint.
  factory GalpaoMapa.fromJson(Map<String, dynamic> json) {
    return GalpaoMapa(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      orientacaoGraus: (json['orientacao_graus'] as num?)?.toDouble() ?? 0,
      larguraM: (json['largura_m'] as num?)?.toDouble() ?? 0,
      comprimentoM: (json['comprimento_m'] as num?)?.toDouble() ?? 0,
      ventilacao: json['tipo_ventilacao'] as String? ??
          json['ventilacao'] as String? ??
          '',
      cortinas: json['lado_cortinas'] as String? ??
          json['cortinas'] as String? ??
          '',
      loteAtivo: json['lote_ativo'] != null
          ? LoteAtivoInfo.fromJson(json['lote_ativo'] as Map<String, dynamic>)
          : null,
      iot: json['iot'] != null
          ? IoTInfo.fromJson(json['iot'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Informacoes da granja com lista de galpoes para o mapa.
class GranjaInfo {
  final String nome;
  final double latitude;
  final double longitude;
  final List<GalpaoMapa> galpoes;

  const GranjaInfo({
    required this.nome,
    required this.latitude,
    required this.longitude,
    this.galpoes = const [],
  });

  factory GranjaInfo.fromJson(Map<String, dynamic> json) {
    return GranjaInfo(
      nome: json['nome'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      galpoes: json['galpoes'] != null
          ? (json['galpoes'] as List<dynamic>)
              .map((e) => GalpaoMapa.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }
}
