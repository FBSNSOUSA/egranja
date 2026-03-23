/// Registro de consumo diario de agua de um lote.
///
/// Campos mapeados a partir do endpoint GET /lotes/{id}/water_consumptions.
/// Backend retorna: id, lote_id, data, quantidade_litros, created_at.
class ConsumoAgua {
  final String id;
  final String loteId;
  final String data;

  /// Quantidade consumida em litros.
  final double quantidadeLitros;

  final String createdAt;

  const ConsumoAgua({
    required this.id,
    required this.loteId,
    required this.data,
    required this.quantidadeLitros,
    required this.createdAt,
  });

  factory ConsumoAgua.fromJson(Map<String, dynamic> json) {
    return ConsumoAgua(
      id: json['id'] as String,
      loteId: json['lote_id'] as String,
      data: json['data'] as String,
      quantidadeLitros: (json['quantidade_litros'] as num).toDouble(),
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lote_id': loteId,
      'data': data,
      'quantidade_litros': quantidadeLitros,
      'created_at': createdAt,
    };
  }
}
