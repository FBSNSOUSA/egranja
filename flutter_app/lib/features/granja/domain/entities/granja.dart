/// Entidade de dominio que representa uma granja (propriedade avicola).
///
/// Campos mapeados a partir do endpoint GET /granjas do backend Go.
/// Backend retorna: id, usuario_id, nome, endereco, cidade, estado,
/// latitude, longitude, total_galpaos, total_lotes_ativos, permissao,
/// created_at, updated_at.
class Granja {
  final String id;
  final String usuarioId;
  final String nome;
  final String? endereco;
  final String? cidade;
  final String? estado;
  final double? latitude;
  final double? longitude;
  final int totalGalpaos;
  final int totalLotesAtivos;
  final String? permissao;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Granja({
    required this.id,
    required this.usuarioId,
    required this.nome,
    this.endereco,
    this.cidade,
    this.estado,
    this.latitude,
    this.longitude,
    this.totalGalpaos = 0,
    this.totalLotesAtivos = 0,
    this.permissao,
    this.createdAt,
    this.updatedAt,
  });

  /// Retorna o endereco formatado para exibicao.
  String get enderecoFormatado {
    final parts = <String>[];
    if (endereco != null && endereco!.isNotEmpty) parts.add(endereco!);
    if (cidade != null && cidade!.isNotEmpty) {
      if (estado != null && estado!.isNotEmpty) {
        parts.add('$cidade/$estado');
      } else {
        parts.add(cidade!);
      }
    } else if (estado != null && estado!.isNotEmpty) {
      parts.add(estado!);
    }
    return parts.join(', ');
  }

  /// Retorna true se a granja possui coordenadas validas.
  bool get temLocalizacao => latitude != null && longitude != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Granja && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Granja(id: $id, nome: $nome, galpaos: $totalGalpaos, lotes: $totalLotesAtivos)';
}
