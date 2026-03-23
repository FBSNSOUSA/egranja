import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/features/chat/domain/entities/conversa.dart';
import 'package:egranja_flutter/features/chat/presentation/providers/chat_list_provider.dart';

/// Tela de lista de conversas do eGranja.
///
/// Exibe conversas agrupadas por lote com avatar (iniciais),
/// nome do lote, preview da ultima mensagem, badge de nao lidas
/// e timestamp. Suporta filtro (todas / com pendencias) e
/// pull-to-refresh.
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  bool _filtrarPendencias = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(conversaListProvider.notifier).fetchConversas();
    });
  }

  List<Conversa> _getConversasFiltradas(List<Conversa> conversas) {
    if (_filtrarPendencias) {
      return conversas.where((c) => c.temPendencia).toList();
    }
    return conversas;
  }

  String _getMessagePreview(Conversa conversa) {
    switch (conversa.ultimaMensagemTipo) {
      case 'foto':
        return 'Foto enviada';
      case 'audio':
        return 'Audio enviado';
      case 'solicitacao':
        return 'Solicitacao formal';
      case 'visita':
        return 'Visita tecnica';
      default:
        return conversa.ultimaMensagem ?? '';
    }
  }

  String _getTimeLabel(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    if (diff.inDays == 1) {
      return 'Ontem';
    }
    if (diff.inDays < 7) {
      const diasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
      return diasSemana[date.weekday - 1];
    }
    final dia = date.day.toString().padLeft(2, '0');
    final mes = date.month.toString().padLeft(2, '0');
    final ano = (date.year % 100).toString().padLeft(2, '0');
    return '$dia/$mes/$ano';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversaListProvider);
    final theme = Theme.of(context);
    final conversasFiltradas = _getConversasFiltradas(state.conversas);

    return Column(
      children: [
        // Filtros
        _buildFiltros(theme),

        // Lista de conversas
        Expanded(
          child: _buildContent(state, conversasFiltradas, theme),
        ),
      ],
    );
  }

  Widget _buildFiltros(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Todas'),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Com pendencias'),
                ),
              ],
              selected: {_filtrarPendencias},
              onSelectionChanged: (selected) {
                setState(() {
                  _filtrarPendencias = selected.first;
                });
              },
              style: SegmentedButton.styleFrom(
                backgroundColor: AppColors.gray100,
                selectedBackgroundColor:
                    theme.colorScheme.primary.withAlpha(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    ConversaListState state,
    List<Conversa> conversas,
    ThemeData theme,
  ) {
    // Loading
    if (state.isLoading && state.conversas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (state.error != null && state.conversas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.error!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref.read(conversaListProvider.notifier).fetchConversas();
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    // Empty
    if (conversas.isEmpty) {
      return EmptyState(
        icon: Icons.chat_outlined,
        titulo: 'Nenhuma conversa',
        descricao: _filtrarPendencias
            ? 'Nenhuma conversa com pendencias no momento.'
            : 'Suas conversas com o tecnico aparecerao aqui.',
      );
    }

    // Data
    return RefreshIndicator(
      onRefresh: () => ref.read(conversaListProvider.notifier).refresh(),
      child: ListView.separated(
        itemCount: conversas.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 76, // avatar width (52) + padding (24)
          color: AppColors.divider,
        ),
        itemBuilder: (context, index) {
          return _buildConversaItem(conversas[index], theme);
        },
      ),
    );
  }

  Widget _buildConversaItem(Conversa conversa, ThemeData theme) {
    final hasUnread = conversa.naoLidas > 0;
    final initial = conversa.loteNome.isNotEmpty
        ? conversa.loteNome[0].toUpperCase()
        : '?';
    final preview = _getMessagePreview(conversa);
    final timeLabel = _getTimeLabel(conversa.updatedAt);
    final participante = conversa.participanteNome;

    return InkWell(
      onTap: () {
        // Marcar como lida localmente
        ref.read(conversaListProvider.notifier).marcarComoLida(conversa.loteId);

        context.pushNamed(
          RouteNames.chat,
          pathParameters: {'chatId': conversa.loteId},
          extra: conversa.loteNome,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initial,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (conversa.temPendencia)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Conteudo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: nome + timestamp
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversa.loteNome,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight:
                                hasUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: hasUnread
                              ? theme.colorScheme.primary
                              : AppColors.textSecondary,
                          fontWeight:
                              hasUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Footer: preview + badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          participante != null ? '$participante: $preview' : preview,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: hasUnread
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Text(
                            conversa.naoLidas > 99
                                ? '99+'
                                : conversa.naoLidas.toString(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
