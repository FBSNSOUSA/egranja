/// Registro de custo de um lote.
///
/// Cada custo possui um [tipo] que indica a categoria
/// (racao, medicamento, pinto, mao_obra, outros),
/// alem de valor, data, nota fiscal e fornecedor opcionais.
class Custo {
  final String id;
  final String loteId;
  final String tipo;
  final String descricao;
  final double valor;
  final String data;
  final String? notaFiscal;
  final String? fornecedor;
  final String createdAt;

  const Custo({
    required this.id,
    required this.loteId,
    required this.tipo,
    required this.descricao,
    required this.valor,
    required this.data,
    this.notaFiscal,
    this.fornecedor,
    required this.createdAt,
  });

  factory Custo.fromJson(Map<String, dynamic> json) {
    return Custo(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      tipo: json['tipo'] as String,
      descricao: json['descricao'] as String,
      valor: (json['valor'] as num).toDouble(),
      data: json['data'] as String,
      notaFiscal: json['nota_fiscal'] as String?,
      fornecedor: json['fornecedor'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'tipo': tipo,
      'descricao': descricao,
      'valor': valor,
      'data': data,
      'nota_fiscal': notaFiscal,
      'fornecedor': fornecedor,
      'created_at': createdAt,
    };
  }

  /// Label legivel para o tipo de custo.
  static String tipoLabel(String tipo) {
    const labels = {
      'racao': 'Racao',
      'medicamento': 'Medicamento',
      'pinto': 'Pinto',
      'mao_obra': 'Mao de obra',
      'outros': 'Outros',
    };
    return labels[tipo] ?? tipo;
  }
}
