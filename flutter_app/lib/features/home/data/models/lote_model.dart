import 'package:egranja_flutter/features/home/domain/entities/lote.dart';

/// Modelo de dados para serializacao/deserializacao de [Lote].
///
/// Mapeia os campos JSON retornados pelo backend Go para a entidade [Lote].
/// Campos opcionais sao tratados com null-safety para evitar crashes
/// quando o backend nao retorna determinado campo.
class LoteModel extends Lote {
  const LoteModel({
    required super.id,
    super.usuarioId,
    required super.galpaoId,
    required super.galpaoNome,
    required super.dataAlojamento,
    super.dataPrevistaAbate,
    required super.quantidade,
    required super.tipo,
    super.linhagem,
    required super.pesoInicialG,
    required super.status,
    super.mortalidadeTotal,
    super.diasDeVida,
    super.avesVivas,
    super.ultimoPesoMedio,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Cria uma instancia de [LoteModel] a partir de JSON da API.
  ///
  /// Backend retorna campos como:
  /// - `mortalidade_total` (int) - total de mortes acumuladas
  /// - `dias_de_vida` (int) - idade do lote em dias
  /// - `aves_vivas` (int) - aves vivas atualmente
  /// - `peso_inicial_g` (num) - peso inicial em gramas
  factory LoteModel.fromJson(Map<String, dynamic> json) {
    return LoteModel(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String?,
      galpaoId: json['galpao_id'] as String,
      galpaoNome: json['galpao_nome'] as String? ?? '',
      dataAlojamento: json['data_alojamento'] as String,
      dataPrevistaAbate: json['data_prevista_abate'] as String?,
      quantidade: (json['quantidade'] as num).toInt(),
      tipo: json['tipo'] as String,
      linhagem: json['linhagem'] as String?,
      pesoInicialG: (json['peso_inicial_g'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      mortalidadeTotal: (json['mortalidade_total'] as num?)?.toInt(),
      diasDeVida: (json['dias_de_vida'] as num?)?.toInt(),
      avesVivas: (json['aves_vivas'] as num?)?.toInt(),
      ultimoPesoMedio: (json['ultimo_peso_medio'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  /// Converte para JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (usuarioId != null) 'usuario_id': usuarioId,
      'galpao_id': galpaoId,
      'galpao_nome': galpaoNome,
      'data_alojamento': dataAlojamento,
      if (dataPrevistaAbate != null) 'data_prevista_abate': dataPrevistaAbate,
      'quantidade': quantidade,
      'tipo': tipo,
      if (linhagem != null) 'linhagem': linhagem,
      'peso_inicial_g': pesoInicialG,
      'status': status,
      if (mortalidadeTotal != null) 'mortalidade_total': mortalidadeTotal,
      if (diasDeVida != null) 'dias_de_vida': diasDeVida,
      if (avesVivas != null) 'aves_vivas': avesVivas,
      if (ultimoPesoMedio != null) 'ultimo_peso_medio': ultimoPesoMedio,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
