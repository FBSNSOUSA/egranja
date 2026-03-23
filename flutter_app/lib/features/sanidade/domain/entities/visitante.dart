/// Registro de visitante em uma granja (livro de registro digital).
///
/// Matches backend DTO VisitanteResponse:
/// - granja_id (not lote_id)
/// - data_entrada (not data_visita)
/// - documento, origem, ultimo_contato_aves, placa_veiculo
/// - data_saida
/// Endpoint: GET /granjas/:id/visitantes (not /lotes/:id/visitantes)
class Visitante {
  final String id;
  final String granjaId;
  final String nome;
  final String? documento;
  final String? origem;
  final String? motivo;
  final String? ultimoContatoAves;
  final String? placaVeiculo;
  final String dataEntrada;
  final String? dataSaida;
  final String? observacao;
  final String createdAt;

  const Visitante({
    required this.id,
    required this.granjaId,
    required this.nome,
    this.documento,
    this.origem,
    this.motivo,
    this.ultimoContatoAves,
    this.placaVeiculo,
    required this.dataEntrada,
    this.dataSaida,
    this.observacao,
    required this.createdAt,
  });

  factory Visitante.fromJson(Map<String, dynamic> json) {
    return Visitante(
      id: json['id'] as String,
      granjaId: json['granja_id'] as String,
      nome: json['nome'] as String,
      documento: json['documento'] as String?,
      origem: json['origem'] as String?,
      motivo: json['motivo'] as String?,
      ultimoContatoAves: json['ultimo_contato_aves'] as String?,
      placaVeiculo: json['placa_veiculo'] as String?,
      dataEntrada: json['data_entrada'] as String,
      dataSaida: json['data_saida'] as String?,
      observacao: json['observacao'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'granja_id': granjaId,
      'nome': nome,
      if (documento != null) 'documento': documento,
      if (origem != null) 'origem': origem,
      if (motivo != null) 'motivo': motivo,
      if (ultimoContatoAves != null) 'ultimo_contato_aves': ultimoContatoAves,
      if (placaVeiculo != null) 'placa_veiculo': placaVeiculo,
      'data_entrada': dataEntrada,
      if (dataSaida != null) 'data_saida': dataSaida,
      if (observacao != null) 'observacao': observacao,
      'created_at': createdAt,
    };
  }
}
