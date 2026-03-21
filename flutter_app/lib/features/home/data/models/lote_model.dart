import 'package:egranja_flutter/features/home/domain/entities/lote.dart';

/// Modelo de dados para serializacao/deserializacao de [Lote].
class LoteModel extends Lote {
  const LoteModel({
    required super.id,
    required super.galpaoId,
    required super.galpaoNome,
    required super.dataAlojamento,
    required super.dataPrevistaAbate,
    required super.quantidade,
    required super.tipo,
    super.linhagem,
    required super.pesoInicialG,
    required super.status,
    super.mortalidadeAcumulada,
    super.ultimoPesoMedio,
    super.pesoBenchmark,
    super.mortesRecentes,
    super.dataMortesRecentes,
    super.mortalidadeRecentePct,
    super.temAlerta,
    super.quantidadeAlertas,
    super.diasDeVida,
    super.avesVivas,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Cria uma instancia de [LoteModel] a partir de JSON da API.
  factory LoteModel.fromJson(Map<String, dynamic> json) {
    return LoteModel(
      id: json['id'] as String,
      galpaoId: json['galpao_id'] as String,
      galpaoNome: json['galpao_nome'] as String? ?? '',
      dataAlojamento: json['data_alojamento'] as String,
      dataPrevistaAbate: json['data_prevista_abate'] as String,
      quantidade: json['quantidade'] as int,
      tipo: json['tipo'] as String,
      linhagem: json['linhagem'] as String?,
      pesoInicialG: (json['peso_inicial_g'] as num).toDouble(),
      status: json['status'] as String,
      mortalidadeAcumulada: json['mortalidade_acumulada'] as int?,
      ultimoPesoMedio: (json['ultimo_peso_medio'] as num?)?.toDouble(),
      pesoBenchmark: (json['peso_benchmark'] as num?)?.toDouble(),
      mortesRecentes: json['mortes_recentes'] as int?,
      dataMortesRecentes: json['data_mortes_recentes'] as String?,
      mortalidadeRecentePct:
          (json['mortalidade_recente_pct'] as num?)?.toDouble(),
      temAlerta: json['tem_alerta'] as bool?,
      quantidadeAlertas: json['quantidade_alertas'] as int?,
      diasDeVida: json['dias_de_vida'] as int?,
      avesVivas: json['aves_vivas'] as int?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  /// Converte para JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'galpao_id': galpaoId,
      'galpao_nome': galpaoNome,
      'data_alojamento': dataAlojamento,
      'data_prevista_abate': dataPrevistaAbate,
      'quantidade': quantidade,
      'tipo': tipo,
      'linhagem': linhagem,
      'peso_inicial_g': pesoInicialG,
      'status': status,
      'mortalidade_acumulada': mortalidadeAcumulada,
      'ultimo_peso_medio': ultimoPesoMedio,
      'peso_benchmark': pesoBenchmark,
      'mortes_recentes': mortesRecentes,
      'data_mortes_recentes': dataMortesRecentes,
      'mortalidade_recente_pct': mortalidadeRecentePct,
      'tem_alerta': temAlerta,
      'quantidade_alertas': quantidadeAlertas,
      'dias_de_vida': diasDeVida,
      'aves_vivas': avesVivas,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
