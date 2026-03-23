/// Prioridade do alerta retornado pela API.
enum AlertaPrioridade {
  critica,
  alta,
  media;

  /// Converte string do backend para enum.
  static AlertaPrioridade fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CRITICA':
        return AlertaPrioridade.critica;
      case 'ALTA':
        return AlertaPrioridade.alta;
      case 'MEDIA':
        return AlertaPrioridade.media;
      default:
        return AlertaPrioridade.media;
    }
  }
}

/// Entidade de dominio que representa um alerta gerado pelo sistema.
///
/// Espelha a struct `Alerta` do backend Go.
class Alerta {
  final String tipo;
  final String condicao;
  final AlertaPrioridade prioridade;
  final String mensagem;
  final String loteId;
  final String? galpaoNome;
  final double? valor;
  final double? limite;
  final int diasDeVida;

  const Alerta({
    required this.tipo,
    required this.condicao,
    required this.prioridade,
    required this.mensagem,
    required this.loteId,
    this.galpaoNome,
    this.valor,
    this.limite,
    required this.diasDeVida,
  });

  factory Alerta.fromJson(Map<String, dynamic> json) {
    return Alerta(
      tipo: json['tipo'] as String,
      condicao: json['condicao'] as String,
      prioridade: AlertaPrioridade.fromString(json['prioridade'] as String),
      mensagem: json['mensagem'] as String,
      loteId: json['lote_id'] as String,
      galpaoNome: json['galpao_nome'] as String?,
      valor: (json['valor'] as num?)?.toDouble(),
      limite: (json['limite'] as num?)?.toDouble(),
      diasDeVida: (json['dias_de_vida'] as num).toInt(),
    );
  }

  @override
  String toString() =>
      'Alerta(tipo: $tipo, prioridade: $prioridade, galpao: $galpaoNome)';
}
