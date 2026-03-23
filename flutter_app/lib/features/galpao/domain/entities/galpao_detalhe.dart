/// Historico de lote associado a um galpao.
class LoteHistorico {
  final String id;
  final String dataAlojamento;
  final String? dataFinalizacao;
  final int quantidade;
  final int? avesEntregues;
  final String status;
  final double? mortalidadePct;
  final double? pesoMedioFinal;

  const LoteHistorico({
    required this.id,
    required this.dataAlojamento,
    this.dataFinalizacao,
    required this.quantidade,
    this.avesEntregues,
    this.status = 'ativo',
    this.mortalidadePct,
    this.pesoMedioFinal,
  });

  factory LoteHistorico.fromJson(Map<String, dynamic> json) {
    return LoteHistorico(
      id: json['id'] as String,
      dataAlojamento: json['data_alojamento'] as String? ?? '',
      dataFinalizacao: json['data_finalizacao'] as String?,
      quantidade: (json['quantidade'] as num?)?.toInt() ?? 0,
      avesEntregues: (json['aves_entregues'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'ativo',
      mortalidadePct: (json['mortalidade_pct'] as num?)?.toDouble(),
      pesoMedioFinal: (json['peso_medio_final'] as num?)?.toDouble(),
    );
  }
}

/// Informacoes climaticas do galpao.
class ClimaGalpao {
  final double ventoVelocidade;
  final int ventoDirecao;
  final double temperaturaExterna;

  const ClimaGalpao({
    this.ventoVelocidade = 0,
    this.ventoDirecao = 0,
    this.temperaturaExterna = 0,
  });

  factory ClimaGalpao.fromJson(Map<String, dynamic> json) {
    return ClimaGalpao(
      ventoVelocidade: (json['vento_velocidade'] as num?)?.toDouble() ?? 0,
      ventoDirecao: (json['vento_direcao'] as num?)?.toInt() ?? 0,
      temperaturaExterna:
          (json['temperatura_externa'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Entidade detalhada de um galpao com historico de lotes e clima.
///
/// Backend DTO: GalpaoResponse
///   { "id", "usuario_id", "granja_id", "nome", "capacidade",
///     "latitude", "longitude", "orientacao_graus", "comprimento_m",
///     "largura_m", "area_m2", "tipo_ventilacao", "lado_cortinas",
///     "created_at", "updated_at" }
///
/// O backend nao envia `orientacao_texto`, `cortinas_abertas`, `lotes` ou `clima`.
class GalpaoDetalhe {
  final String id;
  final String nome;
  final double larguraM;
  final double comprimentoM;
  final double orientacaoGraus;
  final String orientacaoTexto;
  final String ventilacao;
  final String cortinas;
  final bool cortinasAbertas;
  final double latitude;
  final double longitude;
  final int capacidade;
  final List<LoteHistorico> lotes;
  final ClimaGalpao? clima;

  const GalpaoDetalhe({
    required this.id,
    required this.nome,
    this.larguraM = 0,
    this.comprimentoM = 0,
    this.orientacaoGraus = 0,
    this.orientacaoTexto = '',
    this.ventilacao = '',
    this.cortinas = '',
    this.cortinasAbertas = false,
    this.latitude = 0,
    this.longitude = 0,
    this.capacidade = 0,
    this.lotes = const [],
    this.clima,
  });

  /// Cria a partir do JSON do backend (GalpaoResponse).
  ///
  /// Backend envia `tipo_ventilacao` (nao `ventilacao`),
  /// `lado_cortinas` (nao `cortinas`), `orientacao_graus` como int,
  /// `capacidade` como nullable int.
  /// Campos `orientacao_texto`, `cortinas_abertas`, `lotes`, `clima`
  /// nao sao enviados pelo backend.
  factory GalpaoDetalhe.fromJson(Map<String, dynamic> json) {
    final orientGraus = (json['orientacao_graus'] as num?)?.toDouble() ?? 0;

    return GalpaoDetalhe(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] as String? ?? '',
      larguraM: (json['largura_m'] as num?)?.toDouble() ?? 0,
      comprimentoM: (json['comprimento_m'] as num?)?.toDouble() ?? 0,
      orientacaoGraus: orientGraus,
      orientacaoTexto: json['orientacao_texto'] as String? ??
          _orientacaoTexto(orientGraus),
      ventilacao: json['tipo_ventilacao'] as String? ??
          json['ventilacao'] as String? ??
          '',
      cortinas: json['lado_cortinas'] as String? ??
          json['cortinas'] as String? ??
          '',
      cortinasAbertas: json['cortinas_abertas'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      capacidade: (json['capacidade'] as num?)?.toInt() ?? 0,
      lotes: json['lotes'] != null
          ? (json['lotes'] as List<dynamic>)
              .map((e) => LoteHistorico.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      clima: json['clima'] != null
          ? ClimaGalpao.fromJson(json['clima'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Deriva o texto de orientacao a partir dos graus.
  static String _orientacaoTexto(double graus) {
    if (graus < 0) return '';
    const direcoes = [
      'Norte',
      'Nordeste',
      'Leste',
      'Sudeste',
      'Sul',
      'Sudoeste',
      'Oeste',
      'Noroeste',
    ];
    final idx = ((graus + 22.5) % 360 / 45).floor();
    return direcoes[idx % direcoes.length];
  }

  /// Retorna o lote ativo (status == 'ativo'), se existir.
  LoteHistorico? get loteAtivo {
    try {
      return lotes.firstWhere((l) => l.status == 'ativo');
    } catch (_) {
      return null;
    }
  }

  /// Retorna lotes finalizados.
  List<LoteHistorico> get lotesFinalizados {
    return lotes.where((l) => l.status == 'finalizado').toList();
  }
}
