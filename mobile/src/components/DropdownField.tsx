/**
 * Campo dropdown estilizado para o eGranja.
 *
 * Exibe um campo de selecao com lista de opcoes em modal.
 * Suporta busca dentro das opcoes para listas grandes.
 * Botoes e textos com tamanho minimo para uso no campo.
 */

import React, { useState, useCallback, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Modal,
  FlatList,
  SafeAreaView,
} from 'react-native';
import { TextInput, Searchbar, HelperText, Divider } from 'react-native-paper';
import {
  colors,
  typography,
  spacing,
  borders,
  components,
  shadows,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

export interface DropdownOption {
  /** Valor da opcao (enviado a API) */
  value: string;
  /** Label de exibicao */
  label: string;
  /** Subtitulo opcional */
  subtitle?: string;
}

interface DropdownFieldProps {
  /** Label do campo */
  label: string;
  /** Valor selecionado */
  value: string;
  /** Opcoes disponiveis */
  options: DropdownOption[];
  /** Callback ao selecionar */
  onSelect: (value: string) => void;
  /** Placeholder quando nenhum selecionado */
  placeholder?: string;
  /** Mensagem de erro */
  error?: string;
  /** Texto de ajuda */
  helperText?: string;
  /** Campo obrigatorio */
  required?: boolean;
  /** Campo desabilitado */
  disabled?: boolean;
  /** Habilitar busca (para listas com > 5 itens) */
  searchable?: boolean;
  /** testID */
  testID?: string;
}

// ==========================================
// COMPONENTE
// ==========================================

export const DropdownField: React.FC<DropdownFieldProps> = ({
  label,
  value,
  options,
  onSelect,
  placeholder = 'Selecione...',
  error,
  helperText,
  required = false,
  disabled = false,
  searchable = false,
  testID,
}) => {
  const [modalVisible, setModalVisible] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const hasError = !!error;

  // Label do valor selecionado
  const selectedLabel = useMemo(() => {
    const selected = options.find((opt) => opt.value === value);
    return selected?.label || '';
  }, [options, value]);

  // Opcoes filtradas pela busca
  const filteredOptions = useMemo(() => {
    if (!searchQuery.trim()) return options;
    const query = searchQuery.toLowerCase().trim();
    return options.filter(
      (opt) =>
        opt.label.toLowerCase().includes(query) ||
        (opt.subtitle && opt.subtitle.toLowerCase().includes(query)),
    );
  }, [options, searchQuery]);

  const handleOpen = useCallback(() => {
    if (!disabled) {
      setSearchQuery('');
      setModalVisible(true);
    }
  }, [disabled]);

  const handleSelect = useCallback(
    (optionValue: string) => {
      onSelect(optionValue);
      setModalVisible(false);
    },
    [onSelect],
  );

  const renderOption = useCallback(
    ({ item }: { item: DropdownOption }) => (
      <TouchableOpacity
        style={[
          styles.optionItem,
          item.value === value && styles.optionItemSelected,
        ]}
        onPress={() => handleSelect(item.value)}
        activeOpacity={0.7}
      >
        <Text
          style={[
            styles.optionLabel,
            item.value === value && styles.optionLabelSelected,
          ]}
        >
          {item.label}
        </Text>
        {item.subtitle && (
          <Text style={styles.optionSubtitle}>{item.subtitle}</Text>
        )}
      </TouchableOpacity>
    ),
    [value, handleSelect],
  );

  return (
    <View style={styles.container}>
      <TouchableOpacity
        onPress={handleOpen}
        disabled={disabled}
        activeOpacity={0.7}
        testID={testID}
      >
        <TextInput
          label={required ? `${label} *` : label}
          value={selectedLabel}
          editable={false}
          mode="outlined"
          outlineColor={hasError ? colors.danger : colors.gray400}
          activeOutlineColor={colors.primary}
          style={styles.input}
          contentStyle={styles.inputContent}
          right={<TextInput.Icon icon="chevron-down" />}
          error={hasError}
          disabled={disabled}
          placeholder={placeholder}
        />
      </TouchableOpacity>

      {hasError && (
        <HelperText type="error" visible={hasError} style={styles.errorText}>
          {error}
        </HelperText>
      )}

      {helperText && !hasError && (
        <HelperText type="info" visible style={styles.helperText}>
          {helperText}
        </HelperText>
      )}

      {/* Modal de selecao */}
      <Modal
        visible={modalVisible}
        animationType="slide"
        transparent
        onRequestClose={() => setModalVisible(false)}
      >
        <SafeAreaView style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            {/* Cabecalho do modal */}
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>{label}</Text>
              <TouchableOpacity
                onPress={() => setModalVisible(false)}
                style={styles.modalCloseButton}
                hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
              >
                <Text style={styles.modalCloseText}>Fechar</Text>
              </TouchableOpacity>
            </View>

            <Divider />

            {/* Busca */}
            {searchable && (
              <Searchbar
                placeholder="Buscar..."
                onChangeText={setSearchQuery}
                value={searchQuery}
                style={styles.searchBar}
                inputStyle={styles.searchInput}
              />
            )}

            {/* Lista de opcoes */}
            <FlatList
              data={filteredOptions}
              keyExtractor={(item) => item.value}
              renderItem={renderOption}
              ItemSeparatorComponent={() => <Divider />}
              contentContainerStyle={styles.optionsList}
              ListEmptyComponent={
                <View style={styles.emptyContainer}>
                  <Text style={styles.emptyText}>
                    Nenhuma opcao encontrada.
                  </Text>
                </View>
              }
            />
          </View>
        </SafeAreaView>
      </Modal>
    </View>
  );
};

// ==========================================
// ESTILOS
// ==========================================

const styles = StyleSheet.create({
  container: {
    marginBottom: spacing.md,
  },
  input: {
    backgroundColor: colors.white,
    fontSize: typography.fontSizeM,
  },
  inputContent: {
    fontSize: typography.fontSizeM,
    minHeight: components.input.minHeight,
  },
  errorText: {
    fontSize: typography.fontSizeXS,
    color: colors.danger,
  },
  helperText: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
  },

  // Modal
  modalOverlay: {
    flex: 1,
    backgroundColor: colors.overlay,
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: colors.surface,
    borderTopLeftRadius: borders.radiusXL,
    borderTopRightRadius: borders.radiusXL,
    maxHeight: '70%',
    ...shadows.large,
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: spacing.lg,
  },
  modalTitle: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  modalCloseButton: {
    padding: spacing.sm,
  },
  modalCloseText: {
    fontSize: typography.fontSizeS,
    color: colors.primary,
    fontWeight: typography.fontWeightMedium,
  },

  // Busca
  searchBar: {
    margin: spacing.md,
    backgroundColor: colors.gray100,
    elevation: 0,
  },
  searchInput: {
    fontSize: typography.fontSizeS,
  },

  // Opcoes
  optionsList: {
    paddingBottom: spacing.xxl,
  },
  optionItem: {
    paddingVertical: spacing.lg,
    paddingHorizontal: spacing.xl,
    minHeight: 52,
    justifyContent: 'center',
  },
  optionItemSelected: {
    backgroundColor: colors.primaryLight + '15',
  },
  optionLabel: {
    fontSize: typography.fontSizeM,
    color: colors.text,
    fontWeight: typography.fontWeightRegular,
  },
  optionLabelSelected: {
    color: colors.primary,
    fontWeight: typography.fontWeightBold,
  },
  optionSubtitle: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginTop: 2,
  },

  // Vazio
  emptyContainer: {
    padding: spacing.xxl,
    alignItems: 'center',
  },
  emptyText: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
  },
});

export default DropdownField;
