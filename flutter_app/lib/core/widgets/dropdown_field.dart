import 'package:flutter/material.dart';

/// Opcao para o [DropdownField].
class DropdownOption {
  const DropdownOption({
    required this.value,
    required this.label,
    this.subtitle,
  });

  /// Valor interno da opcao.
  final String value;

  /// Texto visivel da opcao.
  final String label;

  /// Texto secundario opcional.
  final String? subtitle;
}

/// Campo de selecao estilo dropdown com modal bottom sheet.
///
/// Abre um bottom sheet com lista de opcoes ao ser tocado.
/// Suporta busca via campo de texto quando [searchable] e `true`.
///
/// Portado do componente React Native `DropdownField.tsx`.
class DropdownField extends StatelessWidget {
  const DropdownField({
    super.key,
    required this.label,
    this.value,
    required this.options,
    this.onSelect,
    this.placeholder,
    this.error,
    this.helperText,
    this.required = false,
    this.disabled = false,
    this.searchable = false,
  });

  /// Rotulo do campo.
  final String label;

  /// Valor selecionado atualmente.
  final String? value;

  /// Lista de opcoes disponiveis.
  final List<DropdownOption> options;

  /// Callback quando o usuario seleciona uma opcao.
  final ValueChanged<DropdownOption>? onSelect;

  /// Texto placeholder quando nenhum valor selecionado.
  final String? placeholder;

  /// Mensagem de erro exibida abaixo do campo.
  final String? error;

  /// Texto auxiliar exibido abaixo do campo.
  final String? helperText;

  /// Se `true`, exibe asterisco no label.
  final bool required;

  /// Se `true`, desabilita interacao.
  final bool disabled;

  /// Se `true`, exibe campo de busca no bottom sheet.
  final bool searchable;

  String _getDisplayText() {
    if (value == null) return '';
    final selected = options.where((o) => o.value == value);
    if (selected.isEmpty) return '';
    return selected.first.label;
  }

  Future<void> _openSheet(BuildContext context) async {
    if (disabled) return;

    final result = await showModalBottomSheet<DropdownOption>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _DropdownBottomSheet(
        label: label,
        options: options,
        selectedValue: value,
        searchable: searchable,
      ),
    );

    if (result != null) {
      onSelect?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayLabel = required ? '$label *' : label;

    return Semantics(
      label: '$label, campo de selecao',
      child: GestureDetector(
        onTap: disabled ? null : () => _openSheet(context),
        child: AbsorbPointer(
          child: TextFormField(
            controller: TextEditingController(text: _getDisplayText()),
            readOnly: true,
            enabled: !disabled,
            decoration: InputDecoration(
              labelText: displayLabel,
              hintText: placeholder ?? 'Selecione...',
              errorText: error,
              helperText: helperText,
              suffixIcon: const Icon(Icons.keyboard_arrow_down),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownBottomSheet extends StatefulWidget {
  const _DropdownBottomSheet({
    required this.label,
    required this.options,
    this.selectedValue,
    this.searchable = false,
  });

  final String label;
  final List<DropdownOption> options;
  final String? selectedValue;
  final bool searchable;

  @override
  State<_DropdownBottomSheet> createState() => _DropdownBottomSheetState();
}

class _DropdownBottomSheetState extends State<_DropdownBottomSheet> {
  String _searchQuery = '';

  List<DropdownOption> get _filteredOptions {
    if (_searchQuery.isEmpty) return widget.options;
    final query = _searchQuery.toLowerCase();
    return widget.options
        .where((o) =>
            o.label.toLowerCase().contains(query) ||
            (o.subtitle?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.6;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.label,
              style: theme.textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: 8),

          // Search
          if (widget.searchable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),

          const SizedBox(height: 8),

          // Options list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredOptions.length,
              padding: const EdgeInsets.only(bottom: 16),
              itemBuilder: (ctx, index) {
                final option = _filteredOptions[index];
                final isSelected = option.value == widget.selectedValue;

                return ListTile(
                  title: Text(option.label),
                  subtitle:
                      option.subtitle != null ? Text(option.subtitle!) : null,
                  selected: isSelected,
                  selectedColor: theme.colorScheme.primary,
                  trailing: isSelected
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () => Navigator.of(ctx).pop(option),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
