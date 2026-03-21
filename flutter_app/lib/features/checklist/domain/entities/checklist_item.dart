/// Entidade de dominio que representa um item do checklist diario.
///
/// Cada item corresponde a uma tarefa de manejo que deve ser verificada
/// pelo produtor ou tecnico durante a vistoria do galpao.
class ChecklistItem {
  final String id;
  final String loteId;
  final String descricao;
  final String categoria;
  final bool concluido;
  final String? observacao;
  final String? concluidoPor;
  final String? concluidoEm;
  final String createdAt;

  const ChecklistItem({
    required this.id,
    required this.loteId,
    required this.descricao,
    required this.categoria,
    required this.concluido,
    this.observacao,
    this.concluidoPor,
    this.concluidoEm,
    required this.createdAt,
  });

  /// Cria uma copia com campos alterados.
  ChecklistItem copyWith({
    String? id,
    String? loteId,
    String? descricao,
    String? categoria,
    bool? concluido,
    String? observacao,
    String? concluidoPor,
    String? concluidoEm,
    String? createdAt,
    bool clearObservacao = false,
    bool clearConcluidoPor = false,
    bool clearConcluidoEm = false,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      loteId: loteId ?? this.loteId,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      concluido: concluido ?? this.concluido,
      observacao: clearObservacao ? null : (observacao ?? this.observacao),
      concluidoPor:
          clearConcluidoPor ? null : (concluidoPor ?? this.concluidoPor),
      concluidoEm:
          clearConcluidoEm ? null : (concluidoEm ?? this.concluidoEm),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ChecklistItem(id: $id, descricao: $descricao, concluido: $concluido)';
}
