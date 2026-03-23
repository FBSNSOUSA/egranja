/// Condicao climatica atual de um galpao/regiao.
///
/// O backend nao retorna um bloco `atual` separado; esta classe e
/// construida a partir da primeira entrada de `horaria` (PrevisaoHorariaDTO).
class CondicaoAtual {
  final double temperatura;
  final double sensacaoTermica;
  final double umidade;
  final double ventoVelocidade;
  final int ventoDirecao;
  final String ventoDirecaoTexto;
  final double precipitacao;
  final String descricao;
  final String icone;

  const CondicaoAtual({
    required this.temperatura,
    required this.sensacaoTermica,
    required this.umidade,
    required this.ventoVelocidade,
    required this.ventoDirecao,
    required this.ventoDirecaoTexto,
    required this.precipitacao,
    required this.descricao,
    required this.icone,
  });

  factory CondicaoAtual.fromJson(Map<String, dynamic> json) {
    return CondicaoAtual(
      temperatura: (json['temperatura'] as num?)?.toDouble() ?? 0,
      sensacaoTermica: (json['sensacao_termica'] as num?)?.toDouble() ?? 0,
      umidade: (json['umidade'] as num?)?.toDouble() ?? 0,
      ventoVelocidade: (json['vento_velocidade'] as num?)?.toDouble() ??
          (json['vento_kmh'] as num?)?.toDouble() ??
          0,
      ventoDirecao: (json['vento_direcao'] as num?)?.toInt() ?? 0,
      ventoDirecaoTexto: json['vento_direcao_texto'] as String? ??
          _direcaoTexto((json['vento_direcao'] as num?)?.toInt() ?? 0),
      precipitacao: (json['precipitacao'] as num?)?.toDouble() ??
          (json['precipitacao_mm'] as num?)?.toDouble() ??
          0,
      descricao: json['descricao'] as String? ?? '',
      icone: json['icone'] as String? ?? 'sol',
    );
  }

  /// Constroi CondicaoAtual a partir de um PrevisaoHorariaDTO do backend.
  factory CondicaoAtual.fromHorariaJson(Map<String, dynamic> json) {
    final temp = (json['temperatura'] as num?)?.toDouble() ?? 0;
    final umidade = (json['umidade'] as num?)?.toDouble() ?? 0;
    final ventoKmh = (json['vento_kmh'] as num?)?.toDouble() ?? 0;
    final ventoDirecao = (json['vento_direcao'] as num?)?.toInt() ?? 0;
    final precipMm = (json['precipitacao_mm'] as num?)?.toDouble() ?? 0;
    final probPrecip =
        (json['probabilidade_precipitacao'] as num?)?.toInt() ?? 0;

    return CondicaoAtual(
      temperatura: temp,
      sensacaoTermica: temp, // backend nao tem sensacao termica separada
      umidade: umidade,
      ventoVelocidade: ventoKmh,
      ventoDirecao: ventoDirecao,
      ventoDirecaoTexto: _direcaoTexto(ventoDirecao),
      precipitacao: precipMm,
      descricao: _descricaoFromPrecip(probPrecip, precipMm),
      icone: _iconeFromPrecip(probPrecip, precipMm),
    );
  }

  static String _direcaoTexto(int graus) {
    if (graus < 0) return '';
    const direcoes = ['N', 'NE', 'L', 'SE', 'S', 'SO', 'O', 'NO'];
    final idx = ((graus + 22.5) % 360 / 45).floor();
    return direcoes[idx % direcoes.length];
  }

  static String _descricaoFromPrecip(int probPrecip, double precipMm) {
    if (precipMm > 5) return 'Chuva';
    if (probPrecip > 60) return 'Chuva provavel';
    if (probPrecip > 30) return 'Parcialmente nublado';
    return 'Tempo bom';
  }

  static String _iconeFromPrecip(int probPrecip, double precipMm) {
    if (precipMm > 10) return 'tempestade';
    if (precipMm > 2) return 'chuva';
    if (probPrecip > 60) return 'nublado';
    if (probPrecip > 30) return 'parcial';
    return 'sol';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CondicaoAtual &&
          runtimeType == other.runtimeType &&
          temperatura == other.temperatura &&
          umidade == other.umidade;

  @override
  int get hashCode => Object.hash(temperatura, umidade);

  @override
  String toString() =>
      'CondicaoAtual(temp: $temperatura, descricao: $descricao)';
}

/// Previsao para um dia especifico.
///
/// Backend DTO: PrevisaoDiariaDTO
///   { "data", "temperatura_max", "temperatura_min", "precipitacao_mm", "vento_max_kmh" }
///
/// Campos `dia_semana`, `umidade`, `probabilidade_chuva`, `icone`, `descricao`
/// nao sao enviados pelo backend e sao derivados localmente.
class PrevisaoDia {
  final String data;
  final String diaSemana;
  final double tempMax;
  final double tempMin;
  final double umidade;
  final int probabilidadeChuva;
  final String icone;
  final String descricao;

  const PrevisaoDia({
    required this.data,
    required this.diaSemana,
    required this.tempMax,
    required this.tempMin,
    required this.umidade,
    required this.probabilidadeChuva,
    required this.icone,
    required this.descricao,
  });

  /// Cria a partir do JSON do backend (PrevisaoDiariaDTO).
  ///
  /// Backend envia `temperatura_max`/`temperatura_min` (nao `temp_max`/`temp_min`)
  /// e `precipitacao_mm`/`vento_max_kmh` em vez de campos separados de chuva.
  factory PrevisaoDia.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as String? ?? '';
    final precipMm = (json['precipitacao_mm'] as num?)?.toDouble() ?? 0;
    final probChuva = precipMm > 5
        ? 80
        : precipMm > 1
            ? 50
            : precipMm > 0
                ? 20
                : 0;

    return PrevisaoDia(
      data: data,
      diaSemana: json['dia_semana'] as String? ?? _diaDaSemana(data),
      tempMax: (json['temperatura_max'] as num?)?.toDouble() ??
          (json['temp_max'] as num?)?.toDouble() ??
          0,
      tempMin: (json['temperatura_min'] as num?)?.toDouble() ??
          (json['temp_min'] as num?)?.toDouble() ??
          0,
      umidade: (json['umidade'] as num?)?.toDouble() ?? 0,
      probabilidadeChuva: (json['probabilidade_chuva'] as num?)?.toInt() ?? probChuva,
      icone: json['icone'] as String? ?? _iconeFromPrecip(precipMm),
      descricao: json['descricao'] as String? ?? _descricaoFromPrecip(precipMm),
    );
  }

  /// Calcula o dia da semana a partir de uma data YYYY-MM-DD.
  static String _diaDaSemana(String data) {
    try {
      final dt = DateTime.parse(data);
      const nomes = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
      return nomes[dt.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  static String _iconeFromPrecip(double precipMm) {
    if (precipMm > 10) return 'tempestade';
    if (precipMm > 2) return 'chuva';
    if (precipMm > 0) return 'parcial';
    return 'sol';
  }

  static String _descricaoFromPrecip(double precipMm) {
    if (precipMm > 10) return 'Chuva forte';
    if (precipMm > 2) return 'Chuva';
    if (precipMm > 0) return 'Parcialmente nublado';
    return 'Tempo bom';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrevisaoDia &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() =>
      'PrevisaoDia(data: $data, max: $tempMax, min: $tempMin)';
}

/// Previsao para uma hora especifica do dia.
///
/// Backend DTO: PrevisaoHorariaDTO
///   { "hora", "temperatura", "umidade", "probabilidade_precipitacao",
///     "precipitacao_mm", "vento_kmh", "vento_direcao" }
class PrevisaoHora {
  final String hora;
  final double temperatura;
  final double umidade;
  final double precipitacao;

  const PrevisaoHora({
    required this.hora,
    required this.temperatura,
    required this.umidade,
    required this.precipitacao,
  });

  /// Cria a partir do JSON do backend (PrevisaoHorariaDTO).
  ///
  /// Backend envia `precipitacao_mm` (nao `precipitacao`).
  /// Backend envia `hora` no formato "YYYY-MM-DDTHH:00" -- extraimos "HH:00"
  /// para exibicao nos graficos.
  factory PrevisaoHora.fromJson(Map<String, dynamic> json) {
    final horaRaw = json['hora'] as String? ?? '';
    // Extrair "HH:00" de "YYYY-MM-DDTHH:00" se necessario
    final hora = horaRaw.contains('T')
        ? horaRaw.split('T').last.substring(0, 5)
        : horaRaw;

    return PrevisaoHora(
      hora: hora,
      temperatura: (json['temperatura'] as num?)?.toDouble() ?? 0,
      umidade: (json['umidade'] as num?)?.toDouble() ?? 0,
      precipitacao: (json['precipitacao_mm'] as num?)?.toDouble() ??
          (json['precipitacao'] as num?)?.toDouble() ??
          0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrevisaoHora &&
          runtimeType == other.runtimeType &&
          hora == other.hora;

  @override
  int get hashCode => hora.hashCode;

  @override
  String toString() =>
      'PrevisaoHora(hora: $hora, temp: $temperatura)';
}

/// Alerta climatico para um galpao/regiao.
///
/// Backend DTO: AlertaClimaResponse
///   { "tipo", "severidade", "mensagem", "valor", "limite", "data" }
///
/// O Flutter UI usa `titulo` e `descricao`, mas o backend envia `mensagem`.
/// O campo `titulo` e derivado do `tipo` e `descricao` mapeia para `mensagem`.
class AlertaClimatico {
  final String tipo;
  final String severidade;
  final String titulo;
  final String descricao;

  const AlertaClimatico({
    required this.tipo,
    required this.severidade,
    required this.titulo,
    required this.descricao,
  });

  /// Cria a partir do JSON do backend (AlertaClimaResponse).
  ///
  /// Backend envia `mensagem` (nao `titulo`/`descricao`).
  /// `titulo` e derivado do `tipo`, `descricao` mapeia para `mensagem`.
  factory AlertaClimatico.fromJson(Map<String, dynamic> json) {
    final tipo = json['tipo'] as String? ?? '';
    return AlertaClimatico(
      tipo: tipo,
      severidade: json['severidade'] as String? ?? 'baixa',
      titulo: json['titulo'] as String? ?? _tituloFromTipo(tipo),
      descricao:
          json['descricao'] as String? ?? json['mensagem'] as String? ?? '',
    );
  }

  /// Deriva um titulo amigavel a partir do tipo do alerta.
  static String _tituloFromTipo(String tipo) {
    switch (tipo) {
      case 'temperatura_alta':
        return 'Temperatura Alta';
      case 'temperatura_baixa':
        return 'Temperatura Baixa';
      case 'vento_forte':
        return 'Vento Forte';
      case 'chuva_intensa':
        return 'Chuva Intensa';
      default:
        return 'Alerta Climatico';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertaClimatico &&
          runtimeType == other.runtimeType &&
          tipo == other.tipo &&
          titulo == other.titulo;

  @override
  int get hashCode => Object.hash(tipo, titulo);

  @override
  String toString() =>
      'AlertaClimatico(tipo: $tipo, severidade: $severidade, titulo: $titulo)';
}

/// Resposta completa da API de previsao do tempo.
///
/// Backend DTO: PrevisaoTempoResponse
///   { "galpao_id", "latitude", "longitude", "horaria": [], "diaria": [], "updated_at" }
///
/// O backend usa `horaria` (nao `previsao_horaria`) e `diaria` (nao `previsao_7dias`).
/// O backend nao envia um bloco `atual` -- e derivado da primeira entrada horaria.
class PrevisaoResponse {
  final CondicaoAtual atual;
  final List<PrevisaoDia> previsao7dias;
  final List<PrevisaoHora> previsaoHoraria;

  const PrevisaoResponse({
    required this.atual,
    required this.previsao7dias,
    required this.previsaoHoraria,
  });

  /// Cria a partir do JSON do backend (PrevisaoTempoResponse).
  ///
  /// Backend envia `horaria` (nao `previsao_horaria`),
  /// `diaria` (nao `previsao_7dias`), e nao envia `atual`.
  /// O campo `atual` e derivado da primeira entrada horaria.
  factory PrevisaoResponse.fromJson(Map<String, dynamic> json) {
    // Parse horaria (backend: `horaria`, fallback: `previsao_horaria`)
    final horariaList = (json['horaria'] as List<dynamic>?) ??
        (json['previsao_horaria'] as List<dynamic>?) ??
        [];
    final previsaoHoraria = horariaList
        .map((e) => PrevisaoHora.fromJson(e as Map<String, dynamic>))
        .toList();

    // Parse diaria (backend: `diaria`, fallback: `previsao_7dias`)
    final diariaList = (json['diaria'] as List<dynamic>?) ??
        (json['previsao_7dias'] as List<dynamic>?) ??
        [];
    final previsao7dias = diariaList
        .map((e) => PrevisaoDia.fromJson(e as Map<String, dynamic>))
        .toList();

    // Derivar `atual` da primeira entrada horaria, ou do campo `atual` se existir
    CondicaoAtual atual;
    if (json['atual'] != null) {
      atual = CondicaoAtual.fromJson(json['atual'] as Map<String, dynamic>);
    } else if (horariaList.isNotEmpty) {
      atual = CondicaoAtual.fromHorariaJson(
          horariaList.first as Map<String, dynamic>);
    } else {
      atual = const CondicaoAtual(
        temperatura: 0,
        sensacaoTermica: 0,
        umidade: 0,
        ventoVelocidade: 0,
        ventoDirecao: 0,
        ventoDirecaoTexto: '',
        precipitacao: 0,
        descricao: 'Sem dados',
        icone: 'sol',
      );
    }

    return PrevisaoResponse(
      atual: atual,
      previsao7dias: previsao7dias,
      previsaoHoraria: previsaoHoraria,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrevisaoResponse &&
          runtimeType == other.runtimeType &&
          atual == other.atual;

  @override
  int get hashCode => atual.hashCode;

  @override
  String toString() =>
      'PrevisaoResponse(atual: $atual, '
      'dias: ${previsao7dias.length}, horas: ${previsaoHoraria.length})';
}
