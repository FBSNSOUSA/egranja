/// Registro de pesagem de um lote.
///
/// Cada pesagem contem um ou mais [PesagemItem], representando
/// amostras individuais de peso coletadas no campo.
class Pesagem {
  final String id;
  final String loteId;
  final String data;
  final int quantidadeTotal;

  /// Peso total em gramas.
  final double pesoTotal;

  /// Peso medio em gramas.
  final double pesoMedio;

  /// Peso benchmark da linhagem para a idade, em gramas.
  final double? pesoBenchmark;

  /// Desvio percentual em relacao ao benchmark.
  final double? desvioPct;

  /// Coeficiente de variacao (uniformidade).
  final double? uniformidadeCV;

  /// Idade do lote no dia da pesagem.
  final int? idade;

  /// Itens individuais da pesagem.
  final List<PesagemItem> itens;

  final String createdAt;

  const Pesagem({
    required this.id,
    required this.loteId,
    required this.data,
    required this.quantidadeTotal,
    required this.pesoTotal,
    required this.pesoMedio,
    this.pesoBenchmark,
    this.desvioPct,
    this.uniformidadeCV,
    this.idade,
    required this.itens,
    required this.createdAt,
  });

  factory Pesagem.fromJson(Map<String, dynamic> json) {
    return Pesagem(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      data: json['data'] as String,
      quantidadeTotal: json['quantidade_total'] as int,
      pesoTotal: (json['peso_total'] as num).toDouble(),
      pesoMedio: (json['peso_medio'] as num).toDouble(),
      pesoBenchmark: (json['peso_benchmark'] as num?)?.toDouble(),
      desvioPct: (json['desvio_pct'] as num?)?.toDouble(),
      uniformidadeCV: (json['uniformidade_cv'] as num?)?.toDouble(),
      idade: json['idade'] as int?,
      itens: (json['itens'] as List<dynamic>?)
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
      'peso_benchmark': pesoBenchmark,
      'desvio_pct': desvioPct,
      'uniformidade_cv': uniformidadeCV,
      'idade': idade,
      'itens': itens.map((e) => e.toJson()).toList(),
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
  final String pesagemId;

  /// Quantidade de aves nesta amostra.
  final int quantidade;

  /// Peso total desta amostra em gramas.
  final double peso;

  /// Peso medio desta amostra em gramas.
  final double pesoMedio;

  const PesagemItem({
    required this.id,
    required this.pesagemId,
    required this.quantidade,
    required this.peso,
    required this.pesoMedio,
  });

  factory PesagemItem.fromJson(Map<String, dynamic> json) {
    return PesagemItem(
      id: json['id'] as String,
      pesagemId: json['pesagem_id'] as String,
      quantidade: json['quantidade'] as int,
      peso: (json['peso'] as num).toDouble(),
      pesoMedio: (json['peso_medio'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pesagem_id': pesagemId,
      'quantidade': quantidade,
      'peso': peso,
      'peso_medio': pesoMedio,
    };
  }
}
