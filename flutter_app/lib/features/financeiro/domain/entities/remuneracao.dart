/// Registro de remuneracao de um lote.
///
/// Representa o pagamento recebido pela integradora, incluindo
/// valor, tipo de remuneracao, data de pagamento e observacao.
class Remuneracao {
  final String id;
  final String loteId;
  final double valor;
  final String? tipo;
  final String? dataPagamento;
  final String? observacao;
  final String createdAt;

  const Remuneracao({
    required this.id,
    required this.loteId,
    required this.valor,
    this.tipo,
    this.dataPagamento,
    this.observacao,
    required this.createdAt,
  });

  factory Remuneracao.fromJson(Map<String, dynamic> json) {
    return Remuneracao(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      tipo: json['tipo'] as String?,
      dataPagamento: json['data_pagamento'] as String?,
      observacao: json['observacao'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'valor': valor,
      if (tipo != null) 'tipo': tipo,
      if (dataPagamento != null) 'data_pagamento': dataPagamento,
      if (observacao != null) 'observacao': observacao,
      'created_at': createdAt,
    };
  }

  /// Label legivel para o tipo de remuneracao.
  static String tipoLabel(String? tipo) {
    if (tipo == null) return 'Nao informado';
    const labels = {
      'por_kg': 'Por kg',
      'por_ave': 'Por ave',
      'por_iep': 'Por IEP',
      'outro': 'Outro',
    };
    return labels[tipo] ?? tipo;
  }
}
