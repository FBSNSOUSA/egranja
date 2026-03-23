import 'package:egranja_flutter/features/home/domain/entities/galpao.dart';

/// Modelo de dados para serializacao/deserializacao de [Galpao].
///
/// Mapeia os campos JSON retornados pelo endpoint GET /galpaos.
class GalpaoModel extends Galpao {
  const GalpaoModel({
    required super.id,
    required super.nome,
    super.capacidade,
    super.tipoVentilacao,
  });

  /// Cria uma instancia de [GalpaoModel] a partir de JSON da API.
  ///
  /// Backend retorna: id, usuario_id, granja_id, nome, capacidade,
  /// tipo_ventilacao, created_at, updated_at.
  factory GalpaoModel.fromJson(Map<String, dynamic> json) {
    return GalpaoModel(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] as String? ?? '',
      capacidade: (json['capacidade'] as num?)?.toInt(),
      tipoVentilacao: json['tipo_ventilacao'] as String?,
    );
  }

  /// Converte para JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      if (capacidade != null) 'capacidade': capacidade,
      if (tipoVentilacao != null) 'tipo_ventilacao': tipoVentilacao,
    };
  }
}
