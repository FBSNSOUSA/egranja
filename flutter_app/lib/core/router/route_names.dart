/// Nomes de rotas usados pelo GoRouter.
///
/// Definidos como constantes para evitar strings soltas e facilitar
/// refatoracoes. Cada constante corresponde a um `name:` no GoRoute.
class RouteNames {
  RouteNames._();

  // ── Auth ──────────────────────────────────────────────────────────────
  static const String login = 'login';

  // ── Home ──────────────────────────────────────────────────────────────
  static const String home = 'home';

  // ── Lote ──────────────────────────────────────────────────────────────
  static const String novoLote = 'novo-lote';
  static const String loteDetail = 'lote-detail';
  static const String novaPesagem = 'nova-pesagem';
  static const String novaMortalidade = 'nova-mortalidade';
  static const String novoRecebimento = 'novo-recebimento';
  static const String novoConsumo = 'novo-consumo';
  static const String novoConsumoAgua = 'novo-consumo-agua';
  static const String finalizarLote = 'finalizar-lote';

  // ── Chat ──────────────────────────────────────────────────────────────
  static const String chatList = 'chat-list';
  static const String chat = 'chat';

  // ── Checklist ─────────────────────────────────────────────────────────
  static const String checklist = 'checklist';

  // ── Sanidade ──────────────────────────────────────────────────────────
  static const String vacinacoes = 'vacinacoes';
  static const String novaVacinacao = 'nova-vacinacao';
  static const String medicamentos = 'medicamentos';
  static const String novoMedicamento = 'novo-medicamento';
  static const String visitantes = 'visitantes';
  static const String novoVisitante = 'novo-visitante';

  // ── Financeiro ────────────────────────────────────────────────────────
  static const String financeiroResumo = 'financeiro-resumo';
  static const String custos = 'custos';
  static const String novoCusto = 'novo-custo';
  static const String remuneracao = 'remuneracao';

  // ── Relatorios ────────────────────────────────────────────────────────
  static const String relatorios = 'relatorios';
  static const String comparativoLotes = 'comparativo-lotes';

  // ── IA ────────────────────────────────────────────────────────────────
  static const String iaAssistente = 'ia-assistente';
  static const String iaAnalise = 'ia-analise';

  // ── IoT ───────────────────────────────────────────────────────────────
  static const String iotDashboard = 'iot-dashboard';
  static const String iotHistorico = 'iot-historico';

  // ── Clima ─────────────────────────────────────────────────────────────
  static const String clima = 'clima';

  // ── Galpao ────────────────────────────────────────────────────────────
  static const String mapaGalpoes = 'mapa-galpoes';
  static const String galpaoDetalhe = 'galpao-detalhe';

  // ── Configuracoes ─────────────────────────────────────────────────────
  static const String configuracoes = 'configuracoes';
}
