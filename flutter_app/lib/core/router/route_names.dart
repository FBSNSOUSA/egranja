/// Nomes de rotas usados pelo GoRouter.
///
/// Definidos como constantes para evitar strings soltas e facilitar
/// refatoracoes. Cada constante corresponde a um `name:` no GoRoute.
class RouteNames {
  RouteNames._();

  // ── Auth ──────────────────────────────────────────────────────────────
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';

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
  static const String relatorioPesagens = 'relatorio-pesagens';
  static const String relatorioMortalidade = 'relatorio-mortalidade';
  static const String relatorioConversao = 'relatorio-conversao';
  static const String relatorioConsumo = 'relatorio-consumo';

  // ── IA ────────────────────────────────────────────────────────────────
  static const String iaAssistente = 'ia-assistente';
  static const String iaAnalise = 'ia-analise';

  // ── IoT ───────────────────────────────────────────────────────────────
  static const String iotDashboard = 'iot-dashboard';
  static const String iotHistorico = 'iot-historico';
  static const String iotConfig = 'iot-config';

  // ── Clima ─────────────────────────────────────────────────────────────
  static const String clima = 'clima';

  // ── Galpao ────────────────────────────────────────────────────────────
  static const String mapaGalpoes = 'mapa-galpoes';
  static const String galpaoDetalhe = 'galpao-detalhe';

  // ── Granja ──────────────────────────────────────────────────────────
  static const String granjaList = 'granja-list';
  static const String granjaDetail = 'granja-detail';
  static const String granjaForm = 'granja-form';
  static const String granjaFormEdit = 'granja-form-edit';

  // ── Configuracoes ─────────────────────────────────────────────────────
  static const String configuracoes = 'configuracoes';
  static const String editarPerfil = 'editar-perfil';

  // ── Notificacoes ────────────────────────────────────────────────────
  static const String notificacoes = 'notificacoes';

  // ── Produtores (visao tecnico) ──────────────────────────────────────
  static const String produtores = 'produtores';
}
