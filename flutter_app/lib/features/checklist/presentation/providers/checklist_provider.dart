import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/checklist/data/repositories/checklist_repository_impl.dart';
import 'package:egranja_flutter/features/checklist/domain/entities/checklist.dart';
import 'package:egranja_flutter/features/checklist/domain/repositories/checklist_repository.dart';

// ── Repositorio ─────────────────────────────────────────────────────────

/// Provider do [ChecklistRepository].
final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChecklistRepositoryImpl(apiClient: apiClient);
});

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado imutavel da tela de Checklist.
class ChecklistState {
  final Checklist? checklist;
  final DateTime selectedDate;
  final bool isLoading;
  final bool isTogglingItem;
  final String? error;
  final String? successMessage;

  const ChecklistState({
    this.checklist,
    required this.selectedDate,
    this.isLoading = false,
    this.isTogglingItem = false,
    this.error,
    this.successMessage,
  });

  ChecklistState copyWith({
    Checklist? checklist,
    DateTime? selectedDate,
    bool? isLoading,
    bool? isTogglingItem,
    String? error,
    String? successMessage,
    bool clearChecklist = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ChecklistState(
      checklist: clearChecklist ? null : (checklist ?? this.checklist),
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      isTogglingItem: isTogglingItem ?? this.isTogglingItem,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  /// Percentual de conclusao como valor entre 0.0 e 1.0.
  double get progressFraction {
    if (checklist == null || checklist!.totalItens == 0) return 0.0;
    return checklist!.itensCompletados / checklist!.totalItens;
  }

  /// Texto de progresso no formato "X/Y".
  String get progressText {
    if (checklist == null) return '0/0';
    return '${checklist!.itensCompletados}/${checklist!.totalItens}';
  }

  /// Verifica se a data selecionada e hoje.
  bool get isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistState &&
          runtimeType == other.runtimeType &&
          checklist == other.checklist &&
          selectedDate == other.selectedDate &&
          isLoading == other.isLoading &&
          isTogglingItem == other.isTogglingItem &&
          error == other.error &&
          successMessage == other.successMessage;

  @override
  int get hashCode => Object.hash(
        checklist,
        selectedDate,
        isLoading,
        isTogglingItem,
        error,
        successMessage,
      );
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Formatador de data para envio a API (YYYY-MM-DD).
final _apiDateFormat = DateFormat('yyyy-MM-dd');

/// Gerenciador de estado do Checklist.
///
/// Carrega o checklist do dia selecionado, permite navegacao entre datas
/// e toggle de itens individuais.
class ChecklistNotifier extends StateNotifier<ChecklistState> {
  final ChecklistRepository _repository;
  final String _loteId;

  ChecklistNotifier({
    required ChecklistRepository repository,
    required String loteId,
  })  : _repository = repository,
        _loteId = loteId,
        super(ChecklistState(selectedDate: DateTime.now()));

  /// Carrega o checklist para a data selecionada.
  Future<void> fetchChecklist() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final dataStr = _apiDateFormat.format(state.selectedDate);
      final checklist = await _repository.fetchChecklist(_loteId, dataStr);
      if (!mounted) return;
      state = state.copyWith(
        checklist: checklist,
        isLoading: false,
        clearChecklist: checklist == null,
      );
    } catch (e) {
      debugPrint('[ChecklistNotifier] Erro ao buscar checklist: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Alterna o estado de conclusao de um item por indice.
  ///
  /// Constroi a lista completa de itens com o item no [itemIndex]
  /// alternado e envia ao backend via PATCH /lotes/{loteId}/checklists/{data}.
  Future<void> toggleItem(int itemIndex, bool concluido) async {
    final checklist = state.checklist;
    if (checklist == null || checklist.id.isEmpty) return;
    if (itemIndex < 0 || itemIndex >= checklist.itens.length) return;

    state = state.copyWith(isTogglingItem: true, clearError: true);

    try {
      // Construir lista de itens com o item alterado
      final updatedItens = checklist.itens.asMap().entries.map((entry) {
        if (entry.key == itemIndex) {
          return entry.value.copyWith(completado: concluido);
        }
        return entry.value;
      }).toList();

      // Extrair a data no formato YYYY-MM-DD do checklist
      final dataStr = checklist.data.substring(0, 10);

      final updated = await _repository.atualizarItens(
        _loteId,
        dataStr,
        updatedItens,
      );
      if (!mounted) return;
      state = state.copyWith(
        checklist: updated,
        isTogglingItem: false,
      );
    } catch (e) {
      debugPrint('[ChecklistNotifier] Erro ao marcar item: $e');
      if (!mounted) return;
      state = state.copyWith(
        isTogglingItem: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Atualiza observacao e/ou foto de um item.
  Future<void> updateItemDetails(
    int itemIndex, {
    String? observacao,
    String? fotoUrl,
    bool clearFoto = false,
  }) async {
    final checklist = state.checklist;
    if (checklist == null || checklist.id.isEmpty) return;
    if (itemIndex < 0 || itemIndex >= checklist.itens.length) return;

    state = state.copyWith(isTogglingItem: true, clearError: true);

    try {
      final updatedItens = checklist.itens.asMap().entries.map((entry) {
        if (entry.key == itemIndex) {
          return entry.value.copyWith(
            observacao: observacao ?? entry.value.observacao,
            fotoUrl: fotoUrl,
            clearFotoUrl: clearFoto,
          );
        }
        return entry.value;
      }).toList();

      final dataStr = checklist.data.substring(0, 10);

      final updated = await _repository.atualizarItens(
        _loteId,
        dataStr,
        updatedItens,
      );
      if (!mounted) return;
      state = state.copyWith(
        checklist: updated,
        isTogglingItem: false,
        successMessage: 'Detalhes atualizados.',
      );
    } catch (e) {
      debugPrint('[ChecklistNotifier] Erro ao atualizar detalhes: $e');
      if (!mounted) return;
      state = state.copyWith(
        isTogglingItem: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Navega para o dia anterior.
  void previousDay() {
    state = state.copyWith(
      selectedDate: state.selectedDate.subtract(const Duration(days: 1)),
      clearChecklist: true,
    );
    fetchChecklist();
  }

  /// Navega para o dia seguinte (nao ultrapassa hoje).
  void nextDay() {
    final tomorrow = state.selectedDate.add(const Duration(days: 1));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrowDate =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    if (tomorrowDate.isAfter(today)) return;

    state = state.copyWith(
      selectedDate: tomorrow,
      clearChecklist: true,
    );
    fetchChecklist();
  }

  /// Seleciona uma data especifica.
  void selectDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      clearChecklist: true,
    );
    fetchChecklist();
  }

  /// Limpa a mensagem de erro.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Limpa a mensagem de sucesso.
  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  String _extractErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }
}

// ── Provider principal ──────────────────────────────────────────────────

/// Provider family do [ChecklistNotifier], parametrizado por loteId.
///
/// Cada lote possui seu proprio estado de checklist independente.
final checklistProvider = StateNotifierProvider.family<ChecklistNotifier,
    ChecklistState, String>(
  (ref, loteId) {
    final repository = ref.watch(checklistRepositoryProvider);
    return ChecklistNotifier(repository: repository, loteId: loteId);
  },
);
