/// Entidade de dominio que representa uma analise gerada pela IA.
class AnaliseIA {
  final String id;
  final DateTime geradaEm;
  final List<String> pontosPositivos;
  final List<String> pontosAtencao;
  final List<String> acoesRecomendadas;
  final String resumo;

  const AnaliseIA({
    required this.id,
    required this.geradaEm,
    required this.pontosPositivos,
    required this.pontosAtencao,
    required this.acoesRecomendadas,
    required this.resumo,
  });

  /// Cria uma [AnaliseIA] a partir do JSON da API.
  factory AnaliseIA.fromJson(Map<String, dynamic> json) {
    return AnaliseIA(
      id: json['id']?.toString() ?? '',
      geradaEm: json['gerada_em'] != null
          ? DateTime.parse(json['gerada_em'] as String)
          : DateTime.now(),
      pontosPositivos: _parseStringList(json['pontos_positivos']),
      pontosAtencao: _parseStringList(json['pontos_atencao']),
      acoesRecomendadas: _parseStringList(json['acoes_recomendadas']),
      resumo: json['resumo'] as String? ?? '',
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnaliseIA &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AnaliseIA(id: $id, geradaEm: $geradaEm, resumo: ${resumo.length > 30 ? '${resumo.substring(0, 30)}...' : resumo})';
}
