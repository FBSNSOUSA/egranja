import 'package:egranja_flutter/features/home/domain/entities/galpao.dart';

/// Modelo de dados para serializacao/deserializacao de [Galpao].
class GalpaoModel extends Galpao {
  const GalpaoModel({
    required super.id,
    required super.nome,
    super.capacidade,
  });

  /// Cria uma instancia de [GalpaoModel] a partir de JSON da API.
  factory GalpaoModel.fromJson(Map<String, dynamic> json) {
    return GalpaoModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      capacidade: json['capacidade'] as int?,
    );
  }

  /// Converte para JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      if (capacidade != null) 'capacidade': capacidade,
    };
  }
}
