/// Registro de medicamento aplicado em um lote.
class Medicamento {
  final String id;
  final String loteId;
  final String nome;
  final String? principioAtivo;
  final String? dosagem;
  final String? viaAdministracao;
  final int? duracaoTratamentoDias;
  final int? periodoCarenciaDias;
  final String? dataInicio;
  final String? dataFim;
  final String? responsavel;
  final String? observacao;
  final String? status;
  final String createdAt;

  const Medicamento({
    required this.id,
    required this.loteId,
    required this.nome,
    this.principioAtivo,
    this.dosagem,
    this.viaAdministracao,
    this.duracaoTratamentoDias,
    this.periodoCarenciaDias,
    this.dataInicio,
    this.dataFim,
    this.responsavel,
    this.observacao,
    this.status,
    required this.createdAt,
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      nome: json['nome'] as String,
      principioAtivo: json['principio_ativo'] as String?,
      dosagem: json['dosagem'] as String?,
      viaAdministracao: json['via_administracao'] as String?,
      duracaoTratamentoDias: json['duracao_tratamento_dias'] as int?,
      periodoCarenciaDias: json['periodo_carencia_dias'] as int?,
      dataInicio: json['data_inicio'] as String?,
      dataFim: json['data_fim'] as String?,
      responsavel: json['responsavel'] as String?,
      observacao: json['observacao'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'nome': nome,
      'principio_ativo': principioAtivo,
      'dosagem': dosagem,
      'via_administracao': viaAdministracao,
      'duracao_tratamento_dias': duracaoTratamentoDias,
      'periodo_carencia_dias': periodoCarenciaDias,
      'data_inicio': dataInicio,
      'data_fim': dataFim,
      'responsavel': responsavel,
      'observacao': observacao,
      'status': status,
      'created_at': createdAt,
    };
  }
}
