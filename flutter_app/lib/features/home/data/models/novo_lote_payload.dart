/// Payload para criacao de um novo lote.
class NovoLotePayload {
  final String galpaoId;
  final String dataAlojamento;
  final String dataPrevistaAbate;
  final int quantidade;
  final String tipo;
  final String? linhagem;
  final double pesoInicialG;

  const NovoLotePayload({
    required this.galpaoId,
    required this.dataAlojamento,
    required this.dataPrevistaAbate,
    required this.quantidade,
    required this.tipo,
    this.linhagem,
    required this.pesoInicialG,
  });

  /// Converte para JSON para envio a API.
  Map<String, dynamic> toJson() {
    return {
      'galpao_id': galpaoId,
      'data_alojamento': dataAlojamento,
      'data_prevista_abate': dataPrevistaAbate,
      'quantidade': quantidade,
      'tipo': tipo,
      if (linhagem != null) 'linhagem': linhagem,
      'peso_inicial_g': pesoInicialG,
    };
  }
}
