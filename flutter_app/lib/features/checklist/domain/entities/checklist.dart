import 'checklist_item.dart';

/// Entidade de dominio que representa o checklist diario de um lote.
///
/// Agrupa todos os itens de verificacao de um dia especifico,
/// com indicadores de progresso calculados.
class Checklist {
  final String id;
  final String loteId;
  final String data;
  final List<ChecklistItem> itens;
  final bool completado;
  final double porcentagemConclusao;
  final String createdAt;
  final String updatedAt;

  const Checklist({
    required this.id,
    required this.loteId,
    required this.data,
    required this.itens,
    required this.completado,
    required this.porcentagemConclusao,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total de itens no checklist.
  int get totalItens => itens.length;

  /// Quantidade de itens completados.
  int get itensCompletados => itens.where((i) => i.completado).length;

  /// Cria uma copia com campos alterados.
  Checklist copyWith({
    String? id,
    String? loteId,
    String? data,
    List<ChecklistItem>? itens,
    bool? completado,
    double? porcentagemConclusao,
    String? createdAt,
    String? updatedAt,
  }) {
    return Checklist(
      id: id ?? this.id,
      loteId: loteId ?? this.loteId,
      data: data ?? this.data,
      itens: itens ?? this.itens,
      completado: completado ?? this.completado,
      porcentagemConclusao: porcentagemConclusao ?? this.porcentagemConclusao,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Checklist &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          data == other.data;

  @override
  int get hashCode => Object.hash(id, data);

  @override
  String toString() =>
      'Checklist(id: $id, loteId: $loteId, data: $data, '
      'progresso: $itensCompletados/$totalItens)';
}
