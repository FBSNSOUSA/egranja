/// Payload para finalizar um lote.
///
/// Enviado via PATCH /lotes/{id}/finalizar com os dados
/// de encerramento do lote.
class FinalizarLotePayload {
  /// Data de finalizacao no formato ISO 8601 (yyyy-MM-dd).
  final String dataFinalizacao;

  /// Quantidade de aves entregues ao abate.
  final int avesEntregues;

  /// Peso total entregue em kg.
  final double pesoTotalEntregue;

  /// Sobra de racao em kg, se houver.
  final double? sobraRacao;

  /// Se a sobra de racao deve ser transferida para o proximo lote.
  final bool? transferirSobraProximoLote;

  const FinalizarLotePayload({
    required this.dataFinalizacao,
    required this.avesEntregues,
    required this.pesoTotalEntregue,
    this.sobraRacao,
    this.transferirSobraProximoLote,
  });

  Map<String, dynamic> toJson() {
    return {
      'data_finalizacao': dataFinalizacao,
      'aves_entregues': avesEntregues,
      'peso_total_entregue': pesoTotalEntregue,
      if (sobraRacao != null) 'sobra_racao': sobraRacao,
      if (transferirSobraProximoLote != null)
        'transferir_sobra_proximo_lote': transferirSobraProximoLote,
    };
  }
}
