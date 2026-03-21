/// Entidade Lote para o feature lote_detail.
///
/// Representa um lote de aves com seus dados basicos.
/// Definido localmente para evitar dependencia circular com o feature home.
class Lote {
  final String id;
  final String granjaId;
  final String galpaoId;
  final String? galpaoNome;
  final String linhagem;
  final int quantidadeInicial;
  final String dataAlojamento;
  final String? dataFinalizacao;
  final String status; // 'ativo', 'finalizado'
  final int? idadeDias;
  final String? granjaNome;
  final String createdAt;
  final String updatedAt;

  const Lote({
    required this.id,
    required this.granjaId,
    required this.galpaoId,
    this.galpaoNome,
    required this.linhagem,
    required this.quantidadeInicial,
    required this.dataAlojamento,
    this.dataFinalizacao,
    required this.status,
    this.idadeDias,
    this.granjaNome,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lote.fromJson(Map<String, dynamic> json) {
    return Lote(
      id: json['id'] as String,
      granjaId: json['granja_id'] as String,
      galpaoId: json['galpao_id'] as String,
      galpaoNome: json['galpao_nome'] as String?,
      linhagem: json['linhagem'] as String,
      quantidadeInicial: json['quantidade_inicial'] as int,
      dataAlojamento: json['data_alojamento'] as String,
      dataFinalizacao: json['data_finalizacao'] as String?,
      status: json['status'] as String,
      idadeDias: json['idade_dias'] as int?,
      granjaNome: json['granja_nome'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'granja_id': granjaId,
      'galpao_id': galpaoId,
      'galpao_nome': galpaoNome,
      'linhagem': linhagem,
      'quantidade_inicial': quantidadeInicial,
      'data_alojamento': dataAlojamento,
      'data_finalizacao': dataFinalizacao,
      'status': status,
      'idade_dias': idadeDias,
      'granja_nome': granjaNome,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
