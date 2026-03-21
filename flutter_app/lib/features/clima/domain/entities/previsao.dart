/// Condicao climatica atual de um galpao/regiao.
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
      temperatura: (json['temperatura'] as num).toDouble(),
      sensacaoTermica: (json['sensacao_termica'] as num).toDouble(),
      umidade: (json['umidade'] as num).toDouble(),
      ventoVelocidade: (json['vento_velocidade'] as num).toDouble(),
      ventoDirecao: json['vento_direcao'] as int,
      ventoDirecaoTexto: json['vento_direcao_texto'] as String,
      precipitacao: (json['precipitacao'] as num).toDouble(),
      descricao: json['descricao'] as String,
      icone: json['icone'] as String,
    );
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

  factory PrevisaoDia.fromJson(Map<String, dynamic> json) {
    return PrevisaoDia(
      data: json['data'] as String,
      diaSemana: json['dia_semana'] as String,
      tempMax: (json['temp_max'] as num).toDouble(),
      tempMin: (json['temp_min'] as num).toDouble(),
      umidade: (json['umidade'] as num).toDouble(),
      probabilidadeChuva: json['probabilidade_chuva'] as int,
      icone: json['icone'] as String,
      descricao: json['descricao'] as String,
    );
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

  factory PrevisaoHora.fromJson(Map<String, dynamic> json) {
    return PrevisaoHora(
      hora: json['hora'] as String,
      temperatura: (json['temperatura'] as num).toDouble(),
      umidade: (json['umidade'] as num).toDouble(),
      precipitacao: (json['precipitacao'] as num).toDouble(),
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

  factory AlertaClimatico.fromJson(Map<String, dynamic> json) {
    return AlertaClimatico(
      tipo: json['tipo'] as String,
      severidade: json['severidade'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
    );
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
class PrevisaoResponse {
  final CondicaoAtual atual;
  final List<PrevisaoDia> previsao7dias;
  final List<PrevisaoHora> previsaoHoraria;

  const PrevisaoResponse({
    required this.atual,
    required this.previsao7dias,
    required this.previsaoHoraria,
  });

  factory PrevisaoResponse.fromJson(Map<String, dynamic> json) {
    return PrevisaoResponse(
      atual: CondicaoAtual.fromJson(json['atual'] as Map<String, dynamic>),
      previsao7dias: (json['previsao_7dias'] as List<dynamic>)
          .map((e) => PrevisaoDia.fromJson(e as Map<String, dynamic>))
          .toList(),
      previsaoHoraria: (json['previsao_horaria'] as List<dynamic>)
          .map((e) => PrevisaoHora.fromJson(e as Map<String, dynamic>))
          .toList(),
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
