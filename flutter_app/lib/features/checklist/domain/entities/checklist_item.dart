/// Entidade de dominio que representa um item do checklist diario.
///
/// Cada item corresponde a uma tarefa de manejo que deve ser verificada
/// pelo produtor ou tecnico durante a vistoria do galpao.
///
/// No backend, checklist items sao objetos JSON simples armazenados
/// dentro do campo `itens` (JSONB) do checklist principal.
class ChecklistItem {
  final String descricao;
  final bool completado;
  final String? observacao;
  final String? fotoUrl;

  const ChecklistItem({
    required this.descricao,
    required this.completado,
    this.observacao,
    this.fotoUrl,
  });

  /// Cria uma copia com campos alterados.
  ChecklistItem copyWith({
    String? descricao,
    bool? completado,
    String? observacao,
    String? fotoUrl,
    bool clearObservacao = false,
    bool clearFotoUrl = false,
  }) {
    return ChecklistItem(
      descricao: descricao ?? this.descricao,
      completado: completado ?? this.completado,
      observacao: clearObservacao ? null : (observacao ?? this.observacao),
      fotoUrl: clearFotoUrl ? null : (fotoUrl ?? this.fotoUrl),
    );
  }

  /// Cria a partir de JSON do backend.
  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      descricao: json['descricao'] as String? ?? '',
      completado: json['completado'] as bool? ?? false,
      observacao: json['observacao'] as String?,
      fotoUrl: json['foto_url'] as String?,
    );
  }

  /// Converte para JSON do backend.
  Map<String, dynamic> toJson() {
    return {
      'descricao': descricao,
      'completado': completado,
      if (observacao != null && observacao!.isNotEmpty)
        'observacao': observacao,
      if (fotoUrl != null && fotoUrl!.isNotEmpty) 'foto_url': fotoUrl,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistItem &&
          runtimeType == other.runtimeType &&
          descricao == other.descricao &&
          completado == other.completado &&
          observacao == other.observacao &&
          fotoUrl == other.fotoUrl;

  @override
  int get hashCode => Object.hash(descricao, completado, observacao, fotoUrl);

  @override
  String toString() =>
      'ChecklistItem(descricao: $descricao, completado: $completado, '
      'observacao: $observacao, fotoUrl: $fotoUrl)';
}
