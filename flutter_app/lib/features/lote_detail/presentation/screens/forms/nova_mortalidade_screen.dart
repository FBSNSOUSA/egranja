import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/utils/whatsapp_utils.dart';
import 'package:egranja_flutter/core/widgets/form_field_widget.dart';
import 'package:egranja_flutter/core/widgets/date_picker_field.dart';
import 'package:egranja_flutter/core/widgets/dropdown_field.dart';
import 'package:egranja_flutter/features/config/presentation/providers/whatsapp_config_provider.dart';
import '../../providers/mortalidade_provider.dart';
import '../../providers/lote_detail_provider.dart';

/// Tela de registro de nova mortalidade.
class NovaMortalidadeScreen extends ConsumerStatefulWidget {
  const NovaMortalidadeScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<NovaMortalidadeScreen> createState() =>
      _NovaMortalidadeScreenState();
}

class _NovaMortalidadeScreenState
    extends ConsumerState<NovaMortalidadeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  final _observacaoController = TextEditingController();
  DateTime _data = DateTime.now();
  String? _causa;

  /// Causas de mortalidade comuns na avicultura de corte,
  /// ordenadas por frequencia tipica no campo.
  static const _causas = [
    DropdownOption(value: 'Natural', label: 'Natural'),
    DropdownOption(value: 'Descarte', label: 'Descarte'),
    DropdownOption(value: 'Morte Subita', label: 'Morte subita'),
    DropdownOption(value: 'Ascite', label: 'Ascite'),
    DropdownOption(value: 'Problemas locomotores', label: 'Problemas locomotores'),
    DropdownOption(value: 'Desidratacao', label: 'Desidratacao'),
    DropdownOption(value: 'Esmagamento', label: 'Esmagamento'),
    DropdownOption(value: 'Onfalite', label: 'Onfalite'),
    DropdownOption(value: 'Outros', label: 'Outros'),
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_causa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a causa da mortalidade.')),
      );
      return;
    }

    final dataFormatted =
        '${_data.year}-${_data.month.toString().padLeft(2, '0')}-${_data.day.toString().padLeft(2, '0')}';

    final success = await ref
        .read(mortalidadeProvider(widget.loteId).notifier)
        .criar(
          data: dataFormatted,
          quantidade: int.parse(_quantidadeController.text),
          causa: _causa!,
          observacao: _observacaoController.text.isNotEmpty
              ? _observacaoController.text
              : null,
        );

    if (success && mounted) {
      ref
          .read(loteDetailProvider(widget.loteId).notifier)
          .invalidateCache();

      final message =
          ref.read(mortalidadeProvider(widget.loteId)).successMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message ?? 'Mortalidade registrada com sucesso!'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // Oferecer compartilhamento via WhatsApp
      final whatsappPhone = ref.read(whatsappConfigProvider).phone;
      if (whatsappPhone.isNotEmpty && mounted) {
        final loteDetail = ref.read(loteDetailProvider(widget.loteId));
        final galpaoNome = loteDetail.lote?.galpaoNome ?? 'Galpao';
        final dia = _data.day.toString().padLeft(2, '0');
        final mes = _data.month.toString().padLeft(2, '0');
        final ano = _data.year;
        final dataDisplay = '$dia/$mes/$ano';
        final quantidade = int.tryParse(_quantidadeController.text) ?? 0;

        final shouldShare = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Compartilhar via WhatsApp?'),
            content: const Text(
              'Deseja enviar o registro de mortalidade para o integrador via WhatsApp?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Nao'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(ctx, true),
                icon: const Icon(Icons.chat, size: 18),
                label: const Text('Compartilhar'),
              ),
            ],
          ),
        );

        if (shouldShare == true && mounted) {
          final whatsappMessage = WhatsAppUtils.formatarMortalidade(
            galpaoNome: galpaoNome,
            data: dataDisplay,
            quantidade: quantidade,
            causa: _causa!,
            observacao: _observacaoController.text.isNotEmpty
                ? _observacaoController.text
                : null,
          );

          final sent = await WhatsAppUtils.compartilhar(
            phone: whatsappPhone,
            message: whatsappMessage,
          );

          if (!sent && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nao foi possivel abrir o WhatsApp.'),
                backgroundColor: AppColors.warning,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }

      if (mounted) context.pop();
    } else if (mounted) {
      final error =
          ref.read(mortalidadeProvider(widget.loteId)).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(error ?? 'Erro ao salvar mortalidade.'),
              ),
            ],
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Tentar novamente',
            textColor: AppColors.white,
            onPressed: _submit,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mortalidadeProvider(widget.loteId));

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DatePickerField(
            label: 'Data',
            value: _data,
            required: true,
            maximumDate: DateTime.now(),
            onChange: (date) => setState(() => _data = date),
          ),
          const SizedBox(height: 16),

          FormFieldWidget(
            label: 'Quantidade',
            placeholder: 'Numero de aves mortas',
            keyboardType: TextInputType.number,
            controller: _quantidadeController,
            required: true,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Informe a quantidade';
              }
              if (int.tryParse(v) == null || int.parse(v) <= 0) {
                return 'Quantidade invalida';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          DropdownField(
            label: 'Causa',
            value: _causa,
            options: _causas,
            required: true,
            placeholder: 'Selecione a causa',
            onSelect: (option) =>
                setState(() => _causa = option.value),
          ),
          const SizedBox(height: 16),

          FormFieldWidget(
            label: 'Observacao',
            placeholder: 'Observacoes adicionais (opcional)',
            controller: _observacaoController,
            multiline: true,
            numberOfLines: 3,
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: state.isSaving ? null : _submit,
              icon: state.isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                state.isSaving ? 'Salvando...' : 'Salvar Mortalidade',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
