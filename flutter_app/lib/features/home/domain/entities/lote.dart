/// Entidade de dominio que representa um lote de aves.
///
/// Contem dados basicos do lote e indicadores calculados pela API.
class Lote {
  final String id;
  final String galpaoId;
  final String galpaoNome;
  final String dataAlojamento;
  final String dataPrevistaAbate;
  final int quantidade;
  final String tipo; // 'Femea', 'Macho', 'Misto'
  final String? linhagem;
  final double pesoInicialG;
  final String status; // 'ativo', 'finalizado'

  // Indicadores calculados pela API
  final int? mortalidadeAcumulada;
  final double? ultimoPesoMedio;
  final double? pesoBenchmark;
  final int? mortesRecentes;
  final String? dataMortesRecentes;
  final double? mortalidadeRecentePct;
  final bool? temAlerta;
  final int? quantidadeAlertas;
  final int? diasDeVida;
  final int? avesVivas;

  // Timestamps
  final String createdAt;
  final String updatedAt;

  const Lote({
    required this.id,
    required this.galpaoId,
    required this.galpaoNome,
    required this.dataAlojamento,
    required this.dataPrevistaAbate,
    required this.quantidade,
    required this.tipo,
    this.linhagem,
    required this.pesoInicialG,
    required this.status,
    this.mortalidadeAcumulada,
    this.ultimoPesoMedio,
    this.pesoBenchmark,
    this.mortesRecentes,
    this.dataMortesRecentes,
    this.mortalidadeRecentePct,
    this.temAlerta,
    this.quantidadeAlertas,
    this.diasDeVida,
    this.avesVivas,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lote && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Lote(id: $id, galpao: $galpaoNome, status: $status, dias: $diasDeVida)';
}
