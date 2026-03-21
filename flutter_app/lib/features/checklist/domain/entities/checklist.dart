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
  final int totalItens;
  final int itensConcluidos;
  final double percentualConcluido;

  const Checklist({
    required this.id,
    required this.loteId,
    required this.data,
    required this.itens,
    required this.totalItens,
    required this.itensConcluidos,
    required this.percentualConcluido,
  });

  /// Cria uma copia com campos alterados.
  Checklist copyWith({
    String? id,
    String? loteId,
    String? data,
    List<ChecklistItem>? itens,
    int? totalItens,
    int? itensConcluidos,
    double? percentualConcluido,
  }) {
    return Checklist(
      id: id ?? this.id,
      loteId: loteId ?? this.loteId,
      data: data ?? this.data,
      itens: itens ?? this.itens,
      totalItens: totalItens ?? this.totalItens,
      itensConcluidos: itensConcluidos ?? this.itensConcluidos,
      percentualConcluido: percentualConcluido ?? this.percentualConcluido,
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
      'progresso: $itensConcluidos/$totalItens)';
}
