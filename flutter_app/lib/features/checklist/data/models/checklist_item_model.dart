import 'package:egranja_flutter/features/checklist/domain/entities/checklist_item.dart';

/// Modelo de dados para serializacao/deserializacao de [ChecklistItem].
class ChecklistItemModel extends ChecklistItem {
  const ChecklistItemModel({
    required super.id,
    required super.loteId,
    required super.descricao,
    required super.categoria,
    required super.concluido,
    super.observacao,
    super.concluidoPor,
    super.concluidoEm,
    required super.createdAt,
  });

  /// Cria uma instancia a partir de JSON da API.
  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      id: json['id'] as String,
      loteId: json['lote_id'] as String? ?? '',
      descricao: json['descricao'] as String? ?? json['label'] as String? ?? '',
      categoria: json['categoria'] as String? ?? 'geral',
      concluido: json['concluido'] as bool? ?? json['checked'] as bool? ?? false,
      observacao: json['observacao'] as String?,
      concluidoPor: json['concluido_por'] as String?,
      concluidoEm: json['concluido_em'] as String? ?? json['checked_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  /// Converte para JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'descricao': descricao,
      'categoria': categoria,
      'concluido': concluido,
      if (observacao != null) 'observacao': observacao,
      if (concluidoPor != null) 'concluido_por': concluidoPor,
      if (concluidoEm != null) 'concluido_em': concluidoEm,
      'created_at': createdAt,
    };
  }
}
