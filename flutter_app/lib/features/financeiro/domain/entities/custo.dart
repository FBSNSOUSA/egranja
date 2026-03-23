/// Registro de custo de um lote.
///
/// Cada custo possui uma [categoria] que indica o tipo de custo
/// (mao_de_obra, energia, aquecimento, cama, manutencao, depreciacao, agua, outros),
/// alem de valor, descricao e data opcionais.
class Custo {
  final String id;
  final String loteId;
  final String categoria;
  final String? descricao;
  final double valor;
  final String? data;
  final String createdAt;

  const Custo({
    required this.id,
    required this.loteId,
    required this.categoria,
    this.descricao,
    required this.valor,
    this.data,
    required this.createdAt,
  });

  factory Custo.fromJson(Map<String, dynamic> json) {
    return Custo(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      categoria: json['categoria'] as String? ?? '',
      descricao: json['descricao'] as String?,
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      data: json['data'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'categoria': categoria,
      if (descricao != null) 'descricao': descricao,
      'valor': valor,
      if (data != null) 'data': data,
      'created_at': createdAt,
    };
  }

  /// Label legivel para a categoria de custo.
  ///
  /// Categorias padrao da avicultura de corte:
  /// - pintinhos: custo dos pintos de um dia (DOC)
  /// - racao: maior custo (~70% do total)
  /// - energia: eletricidade e gas
  /// - aquecimento: gas GLP, lenha para aquecedores
  /// - mao_de_obra: funcionarios do galpao
  /// - sanidade: vacinas, medicamentos, desinfetantes
  /// - cama: maravalha, casca de arroz, etc.
  /// - manutencao: reparos e pecas de equipamentos
  /// - depreciacao: depreciacao de galpao e equipamentos
  /// - agua: consumo de agua
  /// - outros: custos nao classificados
  static String categoriaLabel(String categoria) {
    const labels = {
      'pintinhos': 'Pintinhos (DOC)',
      'racao': 'Racao',
      'mao_de_obra': 'Mao de obra',
      'energia': 'Energia',
      'aquecimento': 'Aquecimento (gas/lenha)',
      'sanidade': 'Sanidade (vacinas/medicamentos)',
      'cama': 'Cama (maravalha)',
      'manutencao': 'Manutencao',
      'depreciacao': 'Depreciacao',
      'agua': 'Agua',
      'outros': 'Outros',
    };
    return labels[categoria] ?? categoria;
  }
}
