/// Registro de visitante em um lote.
class Visitante {
  final String id;
  final String loteId;
  final String nome;
  final String? empresa;
  final String? motivo;
  final String dataVisita;
  final String? horaEntrada;
  final String? horaSaida;
  final bool usouEpi;
  final String? observacao;
  final String createdAt;

  const Visitante({
    required this.id,
    required this.loteId,
    required this.nome,
    this.empresa,
    this.motivo,
    required this.dataVisita,
    this.horaEntrada,
    this.horaSaida,
    this.usouEpi = false,
    this.observacao,
    required this.createdAt,
  });

  factory Visitante.fromJson(Map<String, dynamic> json) {
    return Visitante(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      nome: json['nome'] as String,
      empresa: json['empresa'] as String?,
      motivo: json['motivo'] as String?,
      dataVisita: json['data_visita'] as String,
      horaEntrada: json['hora_entrada'] as String?,
      horaSaida: json['hora_saida'] as String?,
      usouEpi: json['usou_epi'] as bool? ?? false,
      observacao: json['observacao'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'nome': nome,
      'empresa': empresa,
      'motivo': motivo,
      'data_visita': dataVisita,
      'hora_entrada': horaEntrada,
      'hora_saida': horaSaida,
      'usou_epi': usouEpi,
      'observacao': observacao,
      'created_at': createdAt,
    };
  }
}
