/// Registro de mortalidade diaria de um lote.
class Mortalidade {
  final String id;
  final String loteId;
  final String data;

  /// Quantidade de aves mortas.
  final int quantidade;

  /// Causa da mortalidade.
  final String causa;

  /// Observacao adicional.
  final String? observacao;

  /// URL da foto de evidencia.
  final String? fotoUrl;

  /// Percentual de mortalidade do dia.
  final double? percentualDia;

  final String createdAt;

  const Mortalidade({
    required this.id,
    required this.loteId,
    required this.data,
    required this.quantidade,
    required this.causa,
    this.observacao,
    this.fotoUrl,
    this.percentualDia,
    required this.createdAt,
  });

  factory Mortalidade.fromJson(Map<String, dynamic> json) {
    return Mortalidade(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      data: json['data'] as String,
      quantidade: json['quantidade'] as int,
      causa: json['causa'] as String,
      observacao: json['observacao'] as String?,
      fotoUrl: json['foto_url'] as String?,
      percentualDia: (json['percentual_dia'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'data': data,
      'quantidade': quantidade,
      'causa': causa,
      'observacao': observacao,
      'foto_url': fotoUrl,
      'percentual_dia': percentualDia,
      'created_at': createdAt,
    };
  }
}
