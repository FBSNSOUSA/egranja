/// Registro de medicamento aplicado em um lote.
///
/// Matches backend DTO MedicamentoResponse:
/// - medicamento (not nome)
/// - via (not via_administracao)
/// - data_inicio, data_fim
/// - periodo_carencia_dias
/// - em_carencia
class Medicamento {
  final String id;
  final String loteId;
  final String dataInicio;
  final String? dataFim;
  final String medicamento;
  final String? dosagem;
  final String? via;
  final int? periodoCarenciaDias;
  final String? responsavel;
  final String? observacao;
  final bool emCarencia;
  final String createdAt;

  const Medicamento({
    required this.id,
    required this.loteId,
    required this.dataInicio,
    this.dataFim,
    required this.medicamento,
    this.dosagem,
    this.via,
    this.periodoCarenciaDias,
    this.responsavel,
    this.observacao,
    this.emCarencia = false,
    required this.createdAt,
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      dataInicio: json['data_inicio'] as String,
      dataFim: json['data_fim'] as String?,
      medicamento: json['medicamento'] as String,
      dosagem: json['dosagem'] as String?,
      via: json['via'] as String?,
      periodoCarenciaDias: (json['periodo_carencia_dias'] as num?)?.toInt(),
      responsavel: json['responsavel'] as String?,
      observacao: json['observacao'] as String?,
      emCarencia: json['em_carencia'] as bool? ?? false,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'data_inicio': dataInicio,
      if (dataFim != null) 'data_fim': dataFim,
      'medicamento': medicamento,
      if (dosagem != null) 'dosagem': dosagem,
      if (via != null) 'via': via,
      if (periodoCarenciaDias != null)
        'periodo_carencia_dias': periodoCarenciaDias,
      if (responsavel != null) 'responsavel': responsavel,
      if (observacao != null) 'observacao': observacao,
      'em_carencia': emCarencia,
      'created_at': createdAt,
    };
  }
}
