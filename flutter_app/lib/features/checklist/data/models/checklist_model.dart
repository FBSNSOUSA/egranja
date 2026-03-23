import 'package:egranja_flutter/features/checklist/domain/entities/checklist.dart';
import 'package:egranja_flutter/features/checklist/domain/entities/checklist_item.dart';

/// Modelo de dados para serializacao/deserializacao de [Checklist].
class ChecklistModel extends Checklist {
  const ChecklistModel({
    required super.id,
    required super.loteId,
    required super.data,
    required super.itens,
    required super.completado,
    required super.porcentagemConclusao,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Cria uma instancia a partir de JSON da API.
  factory ChecklistModel.fromJson(Map<String, dynamic> json) {
    final itensList = (json['itens'] as List<dynamic>?)
            ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <ChecklistItem>[];

    return ChecklistModel(
      id: json['id'] as String? ?? '',
      loteId: json['lote_id'] as String? ?? '',
      data: json['data'] as String? ?? '',
      itens: itensList,
      completado: json['completado'] as bool? ?? false,
      porcentagemConclusao:
          (json['porcentagem_conclusao'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  /// Converte para JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'data': data,
      'itens': itens.map((e) => e.toJson()).toList(),
      'completado': completado,
      'porcentagem_conclusao': porcentagemConclusao,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
