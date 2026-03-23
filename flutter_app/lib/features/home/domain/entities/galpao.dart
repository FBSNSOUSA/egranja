/// Entidade de dominio que representa um galpao de aves.
///
/// Campos mapeados a partir do endpoint GET /galpaos do backend Go.
/// Backend retorna: id, usuario_id, granja_id, nome, capacidade,
/// tipo_ventilacao, created_at, updated_at.
class Galpao {
  final String id;
  final String nome;
  final int? capacidade;
  final String? tipoVentilacao;

  const Galpao({
    required this.id,
    required this.nome,
    this.capacidade,
    this.tipoVentilacao,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Galpao && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Galpao(id: $id, nome: $nome, capacidade: $capacidade)';
}
