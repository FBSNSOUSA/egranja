/// Entidade de dominio que representa um lote de aves.
///
/// Contem dados basicos do lote e indicadores calculados pela API.
/// Campos opcionais correspondem a valores que o backend pode ou nao retornar.
class Lote {
  final String id;
  final String? usuarioId;
  final String galpaoId;
  final String galpaoNome;
  final String dataAlojamento;
  final String? dataPrevistaAbate;
  final int quantidade;
  final String tipo; // 'Femea', 'Macho', 'Misto'
  final String? linhagem;
  final double pesoInicialG;
  final String status; // 'ativo', 'finalizado'

  // Indicadores retornados inline pelo backend
  final int? mortalidadeTotal;
  final int? diasDeVida;
  final int? avesVivas;
  final double? ultimoPesoMedio;

  // Timestamps
  final String createdAt;
  final String updatedAt;

  const Lote({
    required this.id,
    this.usuarioId,
    required this.galpaoId,
    required this.galpaoNome,
    required this.dataAlojamento,
    this.dataPrevistaAbate,
    required this.quantidade,
    required this.tipo,
    this.linhagem,
    required this.pesoInicialG,
    required this.status,
    this.mortalidadeTotal,
    this.diasDeVida,
    this.avesVivas,
    this.ultimoPesoMedio,
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
