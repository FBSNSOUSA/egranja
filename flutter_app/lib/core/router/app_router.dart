import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'page_transitions.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/home_tecnico_screen.dart';
import '../../features/home/presentation/screens/novo_lote_screen.dart';
import '../../features/lote_detail/presentation/screens/lote_detail_screen.dart';
import '../../features/lote_detail/presentation/screens/forms/nova_pesagem_screen.dart';
import '../../features/lote_detail/presentation/screens/forms/nova_mortalidade_screen.dart';
import '../../features/lote_detail/presentation/screens/forms/novo_recebimento_screen.dart';
import '../../features/lote_detail/presentation/screens/forms/novo_consumo_screen.dart';
import '../../features/lote_detail/presentation/screens/forms/novo_consumo_agua_screen.dart';
import '../../features/checklist/presentation/screens/checklist_screen.dart';
import '../../features/sanidade/presentation/screens/vacinacoes_screen.dart';
import '../../features/sanidade/presentation/screens/nova_vacinacao_screen.dart';
import '../../features/sanidade/presentation/screens/medicamentos_screen.dart';
import '../../features/sanidade/presentation/screens/novo_medicamento_screen.dart';
import '../../features/sanidade/presentation/screens/visitantes_screen.dart';
import '../../features/sanidade/presentation/screens/novo_visitante_screen.dart';
import '../../features/financeiro/presentation/screens/financeiro_resumo_screen.dart';
import '../../features/financeiro/presentation/screens/custos_screen.dart';
import '../../features/financeiro/presentation/screens/novo_custo_screen.dart';
import '../../features/financeiro/presentation/screens/remuneracao_screen.dart';
import '../../features/lote_detail/presentation/screens/forms/finalizar_lote_screen.dart';
import '../../features/relatorios/presentation/screens/relatorios_screen.dart';
import '../../features/relatorios/presentation/screens/comparativo_lotes_screen.dart';
import '../../features/ia/presentation/screens/ia_assistente_screen.dart';
import '../../features/ia/presentation/screens/ia_analise_screen.dart';
import '../../features/clima/presentation/screens/clima_screen.dart';
import '../../features/iot/presentation/screens/iot_dashboard_screen.dart';
import '../../features/iot/presentation/screens/iot_historico_screen.dart';
import '../../features/galpao/presentation/screens/mapa_galpoes_screen.dart';
import '../../features/galpao/presentation/screens/galpao_detalhe_screen.dart';
import '../../features/config/presentation/screens/configuracoes_screen.dart';
import '../widgets/app_shell.dart';
import 'route_names.dart';

/// Provider do GoRouter com redirect baseado em autenticacao.
///
/// Observa o [authNotifierProvider] para reagir a mudancas de estado
/// e redirecionar automaticamente entre login e rotas protegidas.
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoginRoute = state.matchedLocation == '/login';
      final isAuthenticated = authState.status == AuthStatus.authenticated;

      // Ainda verificando autenticacao → nao redirecionar
      if (authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading) {
        return null;
      }

      // Nao autenticado tentando acessar rota protegida → login
      if (!isAuthenticated && !isLoginRoute) return '/login';

      // Autenticado tentando acessar login → home
      if (isAuthenticated && isLoginRoute) return '/';

      return null; // sem redirect
    },
    routes: [
      // ── Login (fora do shell) ────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // ── App Shell (Scaffold + Drawer) ────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Home - Produtor ou Tecnico baseado no tipo de usuario
          GoRoute(
            path: '/',
            name: RouteNames.home,
            pageBuilder: (context, state) {
              final user = authState.user;
              final child = (user != null && user.tipo == 'tecnico')
                  ? const HomeTecnicoScreen()
                  : const HomeScreen();
              return buildFadeSlideTransition(state: state, child: child);
            },
          ),

          // ── Lote ─────────────────────────────────────────────────────
          GoRoute(
            path: '/lotes/novo',
            name: RouteNames.novoLote,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: const NovoLoteScreen(),
            ),
          ),
          GoRoute(
            path: '/lotes/:loteId',
            name: RouteNames.loteDetail,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: LoteDetailScreen(
                loteId: state.pathParameters['loteId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/lotes/:loteId/pesagem',
            name: RouteNames.novaPesagem,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: NovaPesagemScreen(
                loteId: state.pathParameters['loteId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/lotes/:loteId/mortalidade',
            name: RouteNames.novaMortalidade,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: NovaMortalidadeScreen(
                loteId: state.pathParameters['loteId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/lotes/:loteId/recebimento',
            name: RouteNames.novoRecebimento,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: NovoRecebimentoScreen(
                loteId: state.pathParameters['loteId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/lotes/:loteId/consumo',
            name: RouteNames.novoConsumo,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: NovoConsumoScreen(
                loteId: state.pathParameters['loteId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/lotes/:loteId/agua',
            name: RouteNames.novoConsumoAgua,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: NovoConsumoAguaScreen(
                loteId: state.pathParameters['loteId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/lotes/:loteId/finalizar',
            name: RouteNames.finalizarLote,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: FinalizarLoteScreen(
                loteId: state.pathParameters['loteId']!,
              ),
            ),
          ),

          // ── Chat ─────────────────────────────────────────────────────
          GoRoute(
            path: '/chat',
            name: RouteNames.chatList,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: const ChatListScreen(),
            ),
          ),
          GoRoute(
            path: '/chat/:chatId',
            name: RouteNames.chat,
            pageBuilder: (context, state) {
              final chatId = state.pathParameters['chatId']!;
              final loteNome = state.extra as String?;
              return buildFadeSlideTransition(
                state: state,
                child: ChatScreen(
                  loteId: chatId,
                  loteNome: loteNome,
                ),
              );
            },
          ),

          // ── Checklist ────────────────────────────────────────────────
          GoRoute(
            path: '/checklist',
            name: RouteNames.checklist,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: const ChecklistScreen(),
            ),
          ),

          // ── Sanidade ─────────────────────────────────────────────────
          GoRoute(
            path: '/sanidade/vacinacoes',
            name: RouteNames.vacinacoes,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: VacinacoesScreen(
                loteId: state.uri.queryParameters['loteId'],
              ),
            ),
          ),
          GoRoute(
            path: '/sanidade/vacinacoes/nova',
            name: RouteNames.novaVacinacao,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: NovaVacinacaoScreen(
                loteId: state.uri.queryParameters['loteId'] ?? '',
              ),
            ),
          ),
          GoRoute(
            path: '/sanidade/medicamentos',
            name: RouteNames.medicamentos,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: MedicamentosScreen(
                loteId: state.uri.queryParameters['loteId'],
              ),
            ),
          ),
          GoRoute(
            path: '/sanidade/medicamentos/novo',
            name: RouteNames.novoMedicamento,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: NovoMedicamentoScreen(
                loteId: state.uri.queryParameters['loteId'] ?? '',
              ),
            ),
          ),
          GoRoute(
            path: '/sanidade/visitantes',
            name: RouteNames.visitantes,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: VisitantesScreen(
                loteId: state.uri.queryParameters['loteId'],
              ),
            ),
          ),
          GoRoute(
            path: '/sanidade/visitantes/novo',
            name: RouteNames.novoVisitante,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: NovoVisitanteScreen(
                loteId: state.uri.queryParameters['loteId'] ?? '',
              ),
            ),
          ),

          // ── Financeiro ───────────────────────────────────────────────
          GoRoute(
            path: '/financeiro',
            name: RouteNames.financeiroResumo,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: FinanceiroResumoScreen(
                loteId: state.uri.queryParameters['loteId'] ?? '',
              ),
            ),
          ),
          GoRoute(
            path: '/financeiro/custos',
            name: RouteNames.custos,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: CustosScreen(
                loteId: state.uri.queryParameters['loteId'] ?? '',
              ),
            ),
          ),
          GoRoute(
            path: '/financeiro/custos/novo',
            name: RouteNames.novoCusto,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: NovoCustoScreen(
                loteId: state.uri.queryParameters['loteId'] ?? '',
              ),
            ),
          ),
          GoRoute(
            path: '/financeiro/remuneracao',
            name: RouteNames.remuneracao,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: RemuneracaoScreen(
                loteId: state.uri.queryParameters['loteId'] ?? '',
              ),
            ),
          ),

          // ── Relatorios ───────────────────────────────────────────────
          GoRoute(
            path: '/relatorios',
            name: RouteNames.relatorios,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: const RelatoriosScreen(),
            ),
          ),
          GoRoute(
            path: '/relatorios/comparativo',
            name: RouteNames.comparativoLotes,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: const ComparativoLotesScreen(),
            ),
          ),

          // ── IA ───────────────────────────────────────────────────────
          GoRoute(
            path: '/ia/assistente',
            name: RouteNames.iaAssistente,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: IAAssistenteScreen(
                loteId: state.uri.queryParameters['loteId'] ?? '',
              ),
            ),
          ),
          GoRoute(
            path: '/ia/analise',
            name: RouteNames.iaAnalise,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: IAAnaliseScreen(
                loteId: state.uri.queryParameters['loteId'] ?? '',
              ),
            ),
          ),

          // ── IoT ──────────────────────────────────────────────────────
          GoRoute(
            path: '/iot',
            name: RouteNames.iotDashboard,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: IoTDashboardScreen(
                galpaoId: state.uri.queryParameters['galpaoId'],
              ),
            ),
          ),
          GoRoute(
            path: '/iot/historico',
            name: RouteNames.iotHistorico,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: IoTHistoricoScreen(
                galpaoId: state.uri.queryParameters['galpaoId'] ?? '',
              ),
            ),
          ),

          // ── Clima ────────────────────────────────────────────────────
          GoRoute(
            path: '/clima',
            name: RouteNames.clima,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: ClimaScreen(
                galpaoId: state.uri.queryParameters['galpaoId'] ?? '',
              ),
            ),
          ),

          // ── Galpao ───────────────────────────────────────────────────
          GoRoute(
            path: '/galpoes',
            name: RouteNames.mapaGalpoes,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: const MapaGalpoesScreen(),
            ),
          ),
          GoRoute(
            path: '/galpoes/:galpaoId',
            name: RouteNames.galpaoDetalhe,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: GalpaoDetalheScreen(
                galpaoId: state.pathParameters['galpaoId']!,
              ),
            ),
          ),

          // ── Configuracoes ────────────────────────────────────────────
          GoRoute(
            path: '/configuracoes',
            name: RouteNames.configuracoes,
            pageBuilder: (context, state) => buildFadeSlideTransition(
              state: state,
              child: const ConfiguracoesScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
