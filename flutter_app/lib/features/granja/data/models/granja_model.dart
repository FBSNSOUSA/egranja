import 'package:egranja_flutter/features/granja/domain/entities/granja.dart';

/// Modelo de dados para serializacao/deserializacao de [Granja].
///
/// Mapeia os campos JSON retornados pelo endpoint GET /granjas.
class GranjaModel extends Granja {
  const GranjaModel({
    required super.id,
    required super.usuarioId,
    required super.nome,
    super.endereco,
    super.cidade,
    super.estado,
    super.latitude,
    super.longitude,
    super.totalGalpaos,
    super.totalLotesAtivos,
    super.permissao,
    super.createdAt,
    super.updatedAt,
  });

  /// Cria uma instancia de [GranjaModel] a partir de JSON da API.
  factory GranjaModel.fromJson(Map<String, dynamic> json) {
    return GranjaModel(
      id: json['id']?.toString() ?? '',
      usuarioId: json['usuario_id']?.toString() ?? '',
      nome: json['nome'] as String? ?? '',
      endereco: json['endereco'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      totalGalpaos: (json['total_galpaos'] as num?)?.toInt() ?? 0,
      totalLotesAtivos: (json['total_lotes_ativos'] as num?)?.toInt() ?? 0,
      permissao: json['permissao'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Converte para JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nome': nome,
      if (endereco != null) 'endereco': endereco,
      if (cidade != null) 'cidade': cidade,
      if (estado != null) 'estado': estado,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'total_galpaos': totalGalpaos,
      'total_lotes_ativos': totalLotesAtivos,
      if (permissao != null) 'permissao': permissao,
    };
  }
}
