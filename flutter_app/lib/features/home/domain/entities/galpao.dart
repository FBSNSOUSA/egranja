/// Entidade de dominio que representa um galpao de aves.
class Galpao {
  final String id;
  final String nome;
  final int? capacidade;

  const Galpao({
    required this.id,
    required this.nome,
    this.capacidade,
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
