/// Registro de vacinacao aplicada em um lote.
class Vacinacao {
  final String id;
  final String loteId;
  final String nome;
  final String? fabricante;
  final String? lote;
  final String dataAplicacao;
  final double? doseMl;
  final String? viaAplicacao;
  final String? responsavel;
  final String? observacao;
  final String createdAt;

  const Vacinacao({
    required this.id,
    required this.loteId,
    required this.nome,
    this.fabricante,
    this.lote,
    required this.dataAplicacao,
    this.doseMl,
    this.viaAplicacao,
    this.responsavel,
    this.observacao,
    required this.createdAt,
  });

  factory Vacinacao.fromJson(Map<String, dynamic> json) {
    return Vacinacao(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      nome: json['nome'] as String,
      fabricante: json['fabricante'] as String?,
      lote: json['lote'] as String?,
      dataAplicacao: json['data_aplicacao'] as String,
      doseMl: (json['dose_ml'] as num?)?.toDouble(),
      viaAplicacao: json['via_aplicacao'] as String?,
      responsavel: json['responsavel'] as String?,
      observacao: json['observacao'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'nome': nome,
      'fabricante': fabricante,
      'lote': lote,
      'data_aplicacao': dataAplicacao,
      'dose_ml': doseMl,
      'via_aplicacao': viaAplicacao,
      'responsavel': responsavel,
      'observacao': observacao,
      'created_at': createdAt,
    };
  }
}
