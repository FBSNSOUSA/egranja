/// Registro de remuneracao de um lote.
///
/// Representa o pagamento recebido pela integradora, incluindo
/// valor base, bonificacoes, descontos, valor liquido, periodo
/// e status do pagamento.
class Remuneracao {
  final String id;
  final String loteId;
  final double valorBase;
  final double bonificacoes;
  final double descontos;
  final double valorLiquido;
  final String periodoInicio;
  final String periodoFim;
  final String status;
  final String createdAt;

  const Remuneracao({
    required this.id,
    required this.loteId,
    required this.valorBase,
    required this.bonificacoes,
    required this.descontos,
    required this.valorLiquido,
    required this.periodoInicio,
    required this.periodoFim,
    required this.status,
    required this.createdAt,
  });

  factory Remuneracao.fromJson(Map<String, dynamic> json) {
    return Remuneracao(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      valorBase: (json['valor_base'] as num).toDouble(),
      bonificacoes: (json['bonificacoes'] as num).toDouble(),
      descontos: (json['descontos'] as num).toDouble(),
      valorLiquido: (json['valor_liquido'] as num).toDouble(),
      periodoInicio: json['periodo_inicio'] as String,
      periodoFim: json['periodo_fim'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'valor_base': valorBase,
      'bonificacoes': bonificacoes,
      'descontos': descontos,
      'valor_liquido': valorLiquido,
      'periodo_inicio': periodoInicio,
      'periodo_fim': periodoFim,
      'status': status,
      'created_at': createdAt,
    };
  }

  /// Label legivel para o status da remuneracao.
  static String statusLabel(String status) {
    const labels = {
      'pendente': 'Pendente',
      'pago': 'Pago',
      'atrasado': 'Atrasado',
      'cancelado': 'Cancelado',
    };
    return labels[status] ?? status;
  }
}
