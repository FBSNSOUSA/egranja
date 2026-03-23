/// Entidade de dominio que representa uma analise gerada pela IA.
///
/// Backend DTO: IAAnaliseResponse
///   { "resposta": "...", "tokens": ... }
///
/// O backend retorna um texto livre em `resposta` (nao campos estruturados).
/// Os campos `pontosPositivos`, `pontosAtencao` e `acoesRecomendadas` sao
/// extraidos do texto quando possivel, ou o texto completo vai em `resumo`.
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
  ///
  /// Backend envia `{ "resposta": "...", "tokens": ... }`.
  /// Se o JSON tiver campo `resposta` (IAAnaliseResponse), usa-o como resumo.
  /// Se tiver campos estruturados (pontos_positivos etc.), usa-os diretamente.
  factory AnaliseIA.fromJson(Map<String, dynamic> json) {
    // Verificar se e o formato IAAnaliseResponse (campo `resposta`)
    if (json.containsKey('resposta') && !json.containsKey('resumo')) {
      final resposta = json['resposta'] as String? ?? '';
      final parsed = _parseRespostaTexto(resposta);

      return AnaliseIA(
        id: json['id']?.toString() ??
            'analise_${DateTime.now().millisecondsSinceEpoch}',
        geradaEm: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        pontosPositivos: parsed['positivos'] ?? [],
        pontosAtencao: parsed['atencao'] ?? [],
        acoesRecomendadas: parsed['acoes'] ?? [],
        resumo: json['resumo'] as String? ?? resposta,
      );
    }

    // Formato estruturado (campos individuais)
    return AnaliseIA(
      id: json['id']?.toString() ?? '',
      geradaEm: json['gerada_em'] != null
          ? DateTime.parse(json['gerada_em'] as String)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now()),
      pontosPositivos: _parseStringList(json['pontos_positivos']),
      pontosAtencao: _parseStringList(json['pontos_atencao']),
      acoesRecomendadas: _parseStringList(json['acoes_recomendadas']),
      resumo: json['resumo'] as String? ?? json['resposta'] as String? ?? '',
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Tenta extrair pontos positivos, de atencao e acoes recomendadas
  /// do texto livre da resposta da IA.
  ///
  /// Procura por padroes como "Pontos Positivos:", "Pontos de Atencao:",
  /// "Acoes Recomendadas:" seguidos de listas com "-" ou "*".
  static Map<String, List<String>> _parseRespostaTexto(String texto) {
    final result = <String, List<String>>{
      'positivos': <String>[],
      'atencao': <String>[],
      'acoes': <String>[],
    };

    if (texto.isEmpty) return result;

    // Padroes de secao (case-insensitive)
    final sections = <String, String>{
      'positivos': r'(?:pontos?\s+positivos?|aspectos?\s+positivos?)',
      'atencao': r'(?:pontos?\s+de\s+aten[cç][aã]o|pontos?\s+negativos?|aspectos?\s+negativos?)',
      'acoes': r'(?:a[cç][oõ]es?\s+recomendad[ao]s?|recomenda[cç][oõ]es?|sugest[oõ]es?)',
    };

    for (final entry in sections.entries) {
      final regex = RegExp(
        '${entry.value}[:\\s]*\\n((?:[-*]\\s+[^\\n]+\\n?)+)',
        caseSensitive: false,
      );
      final match = regex.firstMatch(texto);
      if (match != null) {
        final block = match.group(1) ?? '';
        final items = block
            .split('\n')
            .map((l) => l.replaceFirst(RegExp(r'^[-*]\s+'), '').trim())
            .where((l) => l.isNotEmpty)
            .toList();
        result[entry.key] = items;
      }
    }

    return result;
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
