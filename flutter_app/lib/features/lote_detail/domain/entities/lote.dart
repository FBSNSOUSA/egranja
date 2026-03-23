/// Entidade Lote para o feature lote_detail.
///
/// Representa um lote de aves com seus dados basicos, mapeando
/// exatamente os campos retornados pelo backend Go (LoteResponse DTO).
class Lote {
  final String id;
  final String? usuarioId;
  final String galpaoId;
  final String? galpaoNome;
  final String dataAlojamento;
  final String? dataPrevistaAbate;
  final int quantidade;
  final String tipo; // 'Femea', 'Macho', 'Misto'
  final String? linhagem;
  final double pesoInicialG;
  final String status; // 'ativo', 'finalizado'
  final int? diasDeVida;
  final int? avesVivas;
  final double? ultimoPesoMedio;
  final int? mortalidadeTotal;
  final String? dataFinalizacao;
  final String createdAt;
  final String updatedAt;

  const Lote({
    required this.id,
    this.usuarioId,
    required this.galpaoId,
    this.galpaoNome,
    required this.dataAlojamento,
    this.dataPrevistaAbate,
    required this.quantidade,
    required this.tipo,
    this.linhagem,
    required this.pesoInicialG,
    required this.status,
    this.diasDeVida,
    this.avesVivas,
    this.ultimoPesoMedio,
    this.mortalidadeTotal,
    this.dataFinalizacao,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lote.fromJson(Map<String, dynamic> json) {
    return Lote(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String?,
      galpaoId: json['galpao_id'] as String,
      galpaoNome: json['galpao_nome'] as String?,
      dataAlojamento: json['data_alojamento'] as String,
      dataPrevistaAbate: json['data_prevista_abate'] as String?,
      quantidade: (json['quantidade'] as num).toInt(),
      tipo: json['tipo'] as String? ?? 'Misto',
      linhagem: json['linhagem'] as String?,
      pesoInicialG: (json['peso_inicial_g'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      diasDeVida: (json['dias_de_vida'] as num?)?.toInt(),
      avesVivas: (json['aves_vivas'] as num?)?.toInt(),
      ultimoPesoMedio: (json['ultimo_peso_medio'] as num?)?.toDouble(),
      mortalidadeTotal: (json['mortalidade_total'] as num?)?.toInt(),
      dataFinalizacao: json['data_finalizacao'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (usuarioId != null) 'usuario_id': usuarioId,
      'galpao_id': galpaoId,
      if (galpaoNome != null) 'galpao_nome': galpaoNome,
      'data_alojamento': dataAlojamento,
      if (dataPrevistaAbate != null) 'data_prevista_abate': dataPrevistaAbate,
      'quantidade': quantidade,
      'tipo': tipo,
      if (linhagem != null) 'linhagem': linhagem,
      'peso_inicial_g': pesoInicialG,
      'status': status,
      if (diasDeVida != null) 'dias_de_vida': diasDeVida,
      if (avesVivas != null) 'aves_vivas': avesVivas,
      if (ultimoPesoMedio != null) 'ultimo_peso_medio': ultimoPesoMedio,
      if (mortalidadeTotal != null) 'mortalidade_total': mortalidadeTotal,
      if (dataFinalizacao != null) 'data_finalizacao': dataFinalizacao,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
