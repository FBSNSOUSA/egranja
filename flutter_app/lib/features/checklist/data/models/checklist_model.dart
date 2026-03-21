import 'package:egranja_flutter/features/checklist/data/models/checklist_item_model.dart';
import 'package:egranja_flutter/features/checklist/domain/entities/checklist.dart';
import 'package:egranja_flutter/features/checklist/domain/entities/checklist_item.dart';

/// Modelo de dados para serializacao/deserializacao de [Checklist].
class ChecklistModel extends Checklist {
  const ChecklistModel({
    required super.id,
    required super.loteId,
    required super.data,
    required super.itens,
    required super.totalItens,
    required super.itensConcluidos,
    required super.percentualConcluido,
  });

  /// Cria uma instancia a partir de JSON da API.
  factory ChecklistModel.fromJson(Map<String, dynamic> json) {
    final itensList = (json['itens'] as List<dynamic>?)
            ?.map((e) =>
                ChecklistItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <ChecklistItem>[];

    final total = json['total_itens'] as int? ?? itensList.length;
    final concluidos = json['itens_concluidos'] as int? ??
        itensList.where((item) => item.concluido).length;
    final percentual = json['percentual_concluido'] as num? ??
        (total > 0 ? (concluidos / total) * 100 : 0);

    return ChecklistModel(
      id: json['id'] as String? ?? '',
      loteId: json['lote_id'] as String? ?? '',
      data: json['data'] as String? ?? '',
      itens: itensList,
      totalItens: total,
      itensConcluidos: concluidos,
      percentualConcluido: percentual.toDouble(),
    );
  }

  /// Converte para JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'data': data,
      'itens': itens
          .map((e) => e is ChecklistItemModel
              ? e.toJson()
              : {
                  'id': e.id,
                  'descricao': e.descricao,
                  'categoria': e.categoria,
                  'concluido': e.concluido,
                })
          .toList(),
      'total_itens': totalItens,
      'itens_concluidos': itensConcluidos,
      'percentual_concluido': percentualConcluido,
    };
  }
}
