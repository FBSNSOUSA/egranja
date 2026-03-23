/// Registro de pesagem de um lote.
///
/// Cada pesagem contem um ou mais [PesagemItem], representando
/// amostras individuais de peso coletadas no campo.
///
/// Campos mapeados a partir do endpoint GET /lotes/{id}/pesagens
/// e do DTO PesagemResponse do backend Go.
class Pesagem {
  final String id;
  final String loteId;
  final String data;
  final int quantidadeTotal;

  /// Peso total em gramas.
  final double pesoTotal;

  /// Peso medio em gramas.
  final double pesoMedio;

  /// Itens individuais da pesagem (campo `items` do backend).
  final List<PesagemItem> items;

  final String createdAt;

  const Pesagem({
    required this.id,
    required this.loteId,
    required this.data,
    required this.quantidadeTotal,
    required this.pesoTotal,
    required this.pesoMedio,
    required this.items,
    required this.createdAt,
  });

  factory Pesagem.fromJson(Map<String, dynamic> json) {
    return Pesagem(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      data: json['data'] as String,
      quantidadeTotal: (json['quantidade_total'] as num).toInt(),
      pesoTotal: (json['peso_total'] as num).toDouble(),
      pesoMedio: (json['peso_medio'] as num).toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map(
                (e) => PesagemItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'data': data,
      'quantidade_total': quantidadeTotal,
      'peso_total': pesoTotal,
      'peso_medio': pesoMedio,
      'items': items.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
    };
  }
}

/// Item individual de uma pesagem.
///
/// Representa uma amostra: quantidade de aves pesadas e o peso
/// registrado em gramas.
class PesagemItem {
  final String id;

  /// Quantidade de aves nesta amostra.
  final int quantidade;

  /// Peso total desta amostra em gramas.
  final double peso;

  /// Peso medio desta amostra em gramas.
  final double pesoMedio;

  const PesagemItem({
    required this.id,
    required this.quantidade,
    required this.peso,
    required this.pesoMedio,
  });

  factory PesagemItem.fromJson(Map<String, dynamic> json) {
    return PesagemItem(
      id: json['id'] as String,
      quantidade: (json['quantidade'] as num).toInt(),
      peso: (json['peso'] as num).toDouble(),
      pesoMedio: (json['peso_medio'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantidade': quantidade,
      'peso': peso,
      'peso_medio': pesoMedio,
    };
  }
}
