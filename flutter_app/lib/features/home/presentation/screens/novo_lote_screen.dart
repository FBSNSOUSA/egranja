import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/date_picker_field.dart';
import 'package:egranja_flutter/core/widgets/dropdown_field.dart';
import 'package:egranja_flutter/core/widgets/form_field_widget.dart';
import 'package:egranja_flutter/features/home/data/models/novo_lote_payload.dart';
import 'package:egranja_flutter/features/home/presentation/providers/home_provider.dart';

/// Tela de criacao de novo lote.
///
/// Formulario com validacao, selecao de galpao, datas, tipo
/// de ave e peso inicial. Suporta feedback de sucesso/erro
/// via SnackBar.
class NovoLoteScreen extends ConsumerStatefulWidget {
  const NovoLoteScreen({super.key});

  @override
  ConsumerState<NovoLoteScreen> createState() => _NovoLoteScreenState();
}

class _NovoLoteScreenState extends ConsumerState<NovoLoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  final _pesoController = TextEditingController(text: '42');

  String? _selectedGalpaoId;
  DateTime _dataAlojamento = DateTime.now();
  DateTime _dataPrevistaAbate =
      DateTime.now().add(const Duration(days: 42));
  String _tipo = 'Misto';
  String? _linhagem;
  bool _isSaving = false;

  static const _linhagens = [
    'Cobb 500',
    'Ross 308',
    'Hubbard',
    'Outra',
  ];

  @override
  void dispose() {
    _quantidadeController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGalpaoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um galpao.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final payload = NovoLotePayload(
        galpaoId: _selectedGalpaoId!,
        dataAlojamento:
            DateFormat('yyyy-MM-dd').format(_dataAlojamento),
        dataPrevistaAbate:
            DateFormat('yyyy-MM-dd').format(_dataPrevistaAbate),
        quantidade: int.parse(_quantidadeController.text.trim()),
        tipo: _tipo,
        linhagem: _linhagem,
        pesoInicialG:
            double.parse(_pesoController.text.trim().replaceAll(',', '.')),
      );

      final repository = ref.read(homeRepositoryProvider);
      await repository.criarLote(payload);

      // Recarregar lotes na home
      ref.read(homeProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lote criado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao criar lote: ${_extractErrorMessage(e)}',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _extractErrorMessage(Object error) {
    final msg = error.toString();
    // Remove prefixos comuns de excecao
    if (msg.contains(': ')) {
      return msg.substring(msg.indexOf(': ') + 2);
    }
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    final galpaosAsync = ref.watch(galpaosProvider);
    final connectivityAsync = ref.watch(connectivityProvider);
    final theme = Theme.of(context);

    final isOnline = connectivityAsync.when(
      data: (online) => online,
      loading: () => true,
      error: (e, s) => true,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Lote'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Offline warning banner
            if (!isOnline)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.wifi_off_outlined,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Voce esta offline. O lote sera criado quando a conexao for restaurada.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.gray800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Galpao dropdown
            galpaosAsync.when(
              data: (galpoes) => DropdownField(
                label: 'Galpao',
                value: _selectedGalpaoId,
                required: true,
                options: galpoes
                    .map(
                      (g) => DropdownOption(
                        value: g.id,
                        label: g.nome,
                        subtitle: g.capacidade != null
                            ? 'Capacidade: ${g.capacidade} aves'
                            : null,
                      ),
                    )
                    .toList(),
                onSelect: (option) {
                  setState(() => _selectedGalpaoId = option.value);
                },
                placeholder: 'Selecione o galpao',
              ),
              loading: () => const DropdownField(
                label: 'Galpao',
                options: [],
                required: true,
                disabled: true,
                placeholder: 'Carregando galpoes...',
              ),
              error: (e, s) => DropdownField(
                label: 'Galpao',
                options: const [],
                required: true,
                disabled: true,
                error: 'Erro ao carregar galpoes',
              ),
            ),
            const SizedBox(height: 16),

            // Data alojamento
            DatePickerField(
              label: 'Data de Alojamento',
              value: _dataAlojamento,
              required: true,
              maximumDate: DateTime.now(),
              onChange: (date) {
                setState(() {
                  _dataAlojamento = date;
                  // Auto-calcular abate (+42 dias)
                  _dataPrevistaAbate =
                      date.add(const Duration(days: 42));
                });
              },
            ),
            const SizedBox(height: 16),

            // Data prevista abate
            DatePickerField(
              label: 'Data Prevista de Abate',
              value: _dataPrevistaAbate,
              required: true,
              minimumDate: _dataAlojamento.add(const Duration(days: 1)),
              onChange: (date) {
                setState(() => _dataPrevistaAbate = date);
              },
              helperText: 'Auto-calculada: alojamento + 42 dias',
            ),
            const SizedBox(height: 16),

            // Quantidade
            FormFieldWidget(
              label: 'Quantidade de Aves',
              controller: _quantidadeController,
              required: true,
              keyboardType: TextInputType.number,
              leftIcon: Icons.pets_outlined,
              placeholder: 'Ex: 25000',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a quantidade de aves';
                }
                final qty = int.tryParse(value.trim());
                if (qty == null || qty <= 0) {
                  return 'A quantidade deve ser maior que zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Tipo (segmented button)
            Text(
              'Tipo *',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Femea',
                  label: Text('Femea'),
                  icon: Icon(Icons.female),
                ),
                ButtonSegment(
                  value: 'Macho',
                  label: Text('Macho'),
                  icon: Icon(Icons.male),
                ),
                ButtonSegment(
                  value: 'Misto',
                  label: Text('Misto'),
                  icon: Icon(Icons.people_outline),
                ),
              ],
              selected: {_tipo},
              onSelectionChanged: (selected) {
                setState(() => _tipo = selected.first);
              },
            ),
            const SizedBox(height: 16),

            // Linhagem
            DropdownField(
              label: 'Linhagem',
              value: _linhagem,
              options: _linhagens
                  .map((l) => DropdownOption(value: l, label: l))
                  .toList(),
              onSelect: (option) {
                setState(() => _linhagem = option.value);
              },
              placeholder: 'Selecione a linhagem',
            ),
            const SizedBox(height: 16),

            // Peso inicial
            FormFieldWidget(
              label: 'Peso Inicial',
              controller: _pesoController,
              required: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              suffix: 'g',
              leftIcon: Icons.monitor_weight_outlined,
              helperText: 'Peso medio dos pintainhos ao alojar',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o peso inicial';
                }
                final peso =
                    double.tryParse(value.trim().replaceAll(',', '.'));
                if (peso == null || peso <= 0) {
                  return 'O peso deve ser maior que zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Save button
            FilledButton.icon(
              onPressed: _isSaving ? null : _salvar,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isSaving ? 'Salvando...' : 'Criar Lote'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
