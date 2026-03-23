import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/notifications/presentation/providers/alertas_provider.dart';
import '../router/route_names.dart';
import '../sync/sync_state.dart';
import '../theme/app_colors.dart';

/// Shell principal do app: Scaffold com AppBar + Drawer.
///
/// Usado como wrapper do [ShellRoute] do GoRouter para manter o Drawer
/// persistente em todas as telas autenticadas.
class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.child,
    this.routeName = '',
  });

  final Widget child;
  final String routeName;

  /// Retorna o titulo da AppBar baseado na rota atual.
  static String _titleForRoute(String routeName) {
    switch (routeName) {
      case RouteNames.home:
        return 'eGranja';
      case RouteNames.checklist:
        return 'Checklist Diario';
      case RouteNames.chatList:
        return 'Mensagens';
      case RouteNames.vacinacoes:
        return 'Vacinacoes';
      case RouteNames.medicamentos:
        return 'Medicamentos';
      case RouteNames.visitantes:
        return 'Visitantes';
      case RouteNames.financeiroResumo:
        return 'Financeiro';
      case RouteNames.custos:
        return 'Custos';
      case RouteNames.remuneracao:
        return 'Remuneracao';
      case RouteNames.relatorios:
        return 'Relatorios';
      case RouteNames.comparativoLotes:
        return 'Comparativo de Lotes';
      case RouteNames.relatorioPesagens:
        return 'Relatorio de Pesagens';
      case RouteNames.relatorioMortalidade:
        return 'Relatorio de Mortalidade';
      case RouteNames.relatorioConversao:
        return 'Conversao Alimentar';
      case RouteNames.relatorioConsumo:
        return 'Relatorio de Consumo';
      case RouteNames.iaAssistente:
        return 'Assistente IA';
      case RouteNames.iaAnalise:
        return 'Analise IA';
      case RouteNames.iotDashboard:
        return 'Sensores IoT';
      case RouteNames.iotHistorico:
        return 'Historico Sensores';
      case RouteNames.iotConfig:
        return 'Configuracao IoT';
      case RouteNames.clima:
        return 'Previsao do Tempo';
      case RouteNames.mapaGalpoes:
        return 'Mapa de Galpoes';
      case RouteNames.granjaList:
        return 'Granjas';
      case RouteNames.configuracoes:
        return 'Configuracoes';
      case RouteNames.editarPerfil:
        return 'Editar Perfil';
      case RouteNames.notificacoes:
        return 'Alertas';
      case RouteNames.produtores:
        return 'Produtores';
      case RouteNames.novoLote:
        return 'Novo Lote';
      case RouteNames.loteDetail:
        return 'Detalhe do Lote';
      case RouteNames.novaPesagem:
        return 'Nova Pesagem';
      case RouteNames.novaMortalidade:
        return 'Nova Mortalidade';
      case RouteNames.novoRecebimento:
        return 'Novo Recebimento';
      case RouteNames.novoConsumo:
        return 'Consumo de Racao';
      case RouteNames.novoConsumoAgua:
        return 'Consumo de Agua';
      case RouteNames.finalizarLote:
        return 'Finalizar Lote';
      case RouteNames.chat:
        return 'Chat';
      case RouteNames.novaVacinacao:
        return 'Nova Vacinacao';
      case RouteNames.novoMedicamento:
        return 'Novo Medicamento';
      case RouteNames.novoVisitante:
        return 'Registrar Visitante';
      case RouteNames.novoCusto:
        return 'Novo Custo';
      case RouteNames.galpaoDetalhe:
        return 'Detalhe do Galpao';
      case RouteNames.granjaDetail:
        return 'Detalhe da Granja';
      case RouteNames.granjaForm:
        return 'Nova Granja';
      case RouteNames.granjaFormEdit:
        return 'Editar Granja';
      default:
        return 'eGranja';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Titulo dinamico — recebido diretamente do ShellRoute builder.
    final title = routeName.isNotEmpty ? _titleForRoute(routeName) : 'eGranja';

    // Badge de alertas
    int alertCount = 0;
    try {
      alertCount = ref.watch(alertasCountProvider);
    } catch (_) {
      // Provider chain nao pronta.
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          _NotificationBell(alertCount: alertCount),
        ],
      ),
      drawer: const _AppDrawer(),
      body: child,
    );
  }
}

/// Sino de notificacao com badge.
/// Separado como StatelessWidget para evitar estado no AppShell.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.alertCount});

  final int alertCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Notificacoes',
          onPressed: () => context.goNamed(RouteNames.notificacoes),
        ),
        if (alertCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                alertCount > 99 ? '99+' : '$alertCount',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// Drawer principal do app.
///
/// Usa [ConsumerWidget] para ter seu proprio [WidgetRef] e funcionar
/// corretamente quando renderizado no overlay do Scaffold.
class _AppDrawer extends ConsumerWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Proteger leitura do auth state
    String userName = 'Usuario';
    String userEmail = '';
    String userInitial = 'U';
    String userTipo = 'produtor';

    try {
      final authState = ref.watch(authNotifierProvider);
      final user = authState.user;
      if (user != null) {
        userName = user.nome.isNotEmpty ? user.nome : 'Usuario';
        userEmail = user.login;
        userTipo = user.tipo;
        if (user.nome.isNotEmpty) {
          userInitial = user.nome[0].toUpperCase();
        }
      }
    } catch (_) {
      // Auth state indisponivel.
    }

    final isTecnico = userTipo == 'tecnico';
    final tipoLabel = isTecnico ? 'Tecnico' : 'Produtor';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.white.withAlpha(51),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.white,
                    child: Text(
                      userInitial,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        userName,
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tipoLabel,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                      ),
                    ),
                  ],
                ),
                if (userEmail.isNotEmpty)
                  Text(
                    userEmail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withAlpha(217),
                        ),
                  ),
              ],
            ),
          ),

          // ── Tarefas Diarias ──────────────────────────────────────────
          _DrawerSectionHeader(
            label: isTecnico ? 'Painel Tecnico' : 'Tarefas Diarias',
          ),
          _DrawerItem(
            icon: Icons.home_outlined,
            label: 'Inicio',
            onTap: () => _navigate(context, RouteNames.home),
          ),

          if (isTecnico)
            _DrawerItem(
              icon: Icons.people_outlined,
              label: 'Produtores',
              onTap: () => _navigate(context, RouteNames.produtores),
            ),

          _DrawerItem(
            icon: Icons.agriculture_outlined,
            label: 'Granjas',
            onTap: () => _navigate(context, RouteNames.granjaList),
          ),
          _DrawerItem(
            icon: Icons.checklist_outlined,
            label: 'Checklist Diario',
            onTap: () => _navigate(context, RouteNames.checklist),
          ),

          if (!isTecnico)
            _DrawerItem(
              icon: Icons.inventory_2_outlined,
              label: 'Novo Lote',
              onTap: () => _navigate(context, RouteNames.novoLote),
            ),

          _DrawerItem(
            icon: Icons.notifications_outlined,
            label: 'Alertas',
            onTap: () => _navigate(context, RouteNames.notificacoes),
          ),

          const Divider(),

          // ── Monitoramento ───────────────────────────────────────────
          _DrawerSectionHeader(label: 'Monitoramento'),
          _DrawerItem(
            icon: Icons.sensors_outlined,
            label: 'IoT Sensores',
            onTap: () => _navigate(context, RouteNames.iotDashboard),
          ),
          _DrawerItem(
            icon: Icons.settings_input_antenna_outlined,
            label: 'IoT Configuracao',
            onTap: () => _navigate(context, RouteNames.iotConfig),
          ),
          _DrawerItem(
            icon: Icons.cloud_outlined,
            label: 'Clima',
            onTap: () => _navigate(context, RouteNames.clima),
          ),
          _DrawerItem(
            icon: Icons.map_outlined,
            label: 'Mapa Galpoes',
            onTap: () => _navigate(context, RouteNames.mapaGalpoes),
          ),

          const Divider(),

          // ── Sanidade ────────────────────────────────────────────────
          _DrawerSectionHeader(label: 'Sanidade'),
          _DrawerItem(
            icon: Icons.vaccines_outlined,
            label: 'Vacinacoes',
            onTap: () => _navigate(context, RouteNames.vacinacoes),
          ),
          _DrawerItem(
            icon: Icons.medication_outlined,
            label: 'Medicamentos',
            onTap: () => _navigate(context, RouteNames.medicamentos),
          ),
          _DrawerItem(
            icon: Icons.badge_outlined,
            label: 'Visitantes',
            onTap: () => _navigate(context, RouteNames.visitantes),
          ),

          const Divider(),

          // ── Analise & Relatorios ────────────────────────────────────
          _DrawerSectionHeader(label: 'Analise'),
          _DrawerItem(
            icon: Icons.bar_chart_outlined,
            label: 'Relatorios',
            onTap: () => _navigate(context, RouteNames.relatorios),
          ),
          _DrawerItem(
            icon: Icons.smart_toy_outlined,
            label: 'IA Assistente',
            onTap: () => _navigate(context, RouteNames.iaAssistente),
          ),
          _DrawerItem(
            icon: Icons.attach_money_outlined,
            label: 'Financeiro',
            onTap: () => _navigate(context, RouteNames.financeiroResumo),
          ),

          const Divider(),

          // ── Comunicacao ─────────────────────────────────────────────
          _DrawerItem(
            icon: Icons.chat_outlined,
            label: 'Mensagens',
            onTap: () => _navigate(context, RouteNames.chatList),
          ),

          const Divider(),

          // ── Configuracoes & Sair ────────────────────────────────────
          _DrawerItem(
            icon: Icons.settings_outlined,
            label: 'Configuracoes',
            onTap: () => _navigate(context, RouteNames.configuracoes),
          ),
          _DrawerItem(
            icon: Icons.logout,
            label: 'Sair',
            iconColor: AppColors.danger,
            onTap: () => _handleLogout(context, ref),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String routeName) {
    Navigator.of(context).pop(); // fecha drawer
    context.goNamed(routeName);
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pop(); // fecha drawer

    int pendingCount = 0;
    try {
      final syncState = ref.read(syncProvider);
      pendingCount = syncState.pendingCount;
    } catch (_) {}

    if (pendingCount > 0) {
      showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Operacoes pendentes'),
          content: Text(
            'Voce tem $pendingCount '
            '${pendingCount == 1 ? 'operacao pendente' : 'operacoes pendentes'}. '
            'Deseja sair mesmo assim?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
                ref.read(authNotifierProvider.notifier).logout();
              },
              child: const Text('Sair'),
            ),
          ],
        ),
      );
    } else {
      ref.read(authNotifierProvider.notifier).logout();
    }
  }
}

/// Cabecalho de secao no drawer.
class _DrawerSectionHeader extends StatelessWidget {
  const _DrawerSectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.gray500,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              fontSize: 11,
            ),
      ),
    );
  }
}

/// Item individual do drawer.
class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.gray700),
      title: Text(label),
      onTap: onTap,
      dense: true,
    );
  }
}
