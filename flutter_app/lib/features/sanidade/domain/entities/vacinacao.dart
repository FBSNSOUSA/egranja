/// Registro de vacinacao aplicada em um lote.
///
/// Matches backend DTO VacinacaoResponse:
/// - vacina (not nome)
/// - data (not data_aplicacao)
/// - lote_produto (not lote)
/// - via_administracao
class Vacinacao {
  final String id;
  final String loteId;
  final String data;
  final String vacina;
  final String? loteProduto;
  final String? viaAdministracao;
  final String? responsavel;
  final String? observacao;
  final String createdAt;

  const Vacinacao({
    required this.id,
    required this.loteId,
    required this.data,
    required this.vacina,
    this.loteProduto,
    this.viaAdministracao,
    this.responsavel,
    this.observacao,
    required this.createdAt,
  });

  factory Vacinacao.fromJson(Map<String, dynamic> json) {
    return Vacinacao(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      data: json['data'] as String,
      vacina: json['vacina'] as String,
      loteProduto: json['lote_produto'] as String?,
      viaAdministracao: json['via_administracao'] as String?,
      responsavel: json['responsavel'] as String?,
      observacao: json['observacao'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'data': data,
      'vacina': vacina,
      if (loteProduto != null) 'lote_produto': loteProduto,
      if (viaAdministracao != null) 'via_administracao': viaAdministracao,
      if (responsavel != null) 'responsavel': responsavel,
      if (observacao != null) 'observacao': observacao,
      'created_at': createdAt,
    };
  }
}
