/// Entidade simplificada de Granja para uso no seletor de visitantes.
///
/// Contem apenas id e nome, mapeados do endpoint GET /granjas.
class Granja {
  final String id;
  final String nome;

  const Granja({
    required this.id,
    required this.nome,
  });

  factory Granja.fromJson(Map<String, dynamic> json) {
    return Granja(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Granja && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Granja(id: $id, nome: $nome)';
}
