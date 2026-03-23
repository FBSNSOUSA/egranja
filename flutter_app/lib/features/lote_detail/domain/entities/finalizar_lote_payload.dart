/// Payload para finalizar um lote.
///
/// Enviado via PATCH /lotes/{id}/finalizar com os dados
/// de encerramento do lote.
///
/// Campos mapeados do DTO FinalizarLoteRequest do backend Go.
class FinalizarLotePayload {
  /// Data de finalizacao no formato YYYY-MM-DD.
  final String dataFinalizacao;

  /// Quantidade de aves entregues ao abate.
  final int avesEntregues;

  /// Peso total entregue em kg.
  final double pesoTotalEntregue;

  /// Sobra de racao em kg, se houver (campo `sobra_racao_kg`).
  final double? sobraRacaoKg;

  const FinalizarLotePayload({
    required this.dataFinalizacao,
    required this.avesEntregues,
    required this.pesoTotalEntregue,
    this.sobraRacaoKg,
  });

  Map<String, dynamic> toJson() {
    return {
      'data_finalizacao': dataFinalizacao,
      'aves_entregues': avesEntregues,
      'peso_total_entregue': pesoTotalEntregue,
      if (sobraRacaoKg != null) 'sobra_racao_kg': sobraRacaoKg,
    };
  }
}
