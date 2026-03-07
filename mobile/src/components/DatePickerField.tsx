/**
 * Campo de selecao de data estilizado para o eGranja.
 *
 * Exibe um campo de texto somente-leitura que ao ser pressionado
 * abre o DateTimePicker nativo do dispositivo.
 * Formato de exibicao: DD/MM/AAAA (padrao brasileiro).
 */

import React, { useState, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Platform,
} from 'react-native';
import { TextInput, HelperText } from 'react-native-paper';
import DateTimePicker, { DateTimePickerEvent } from '@react-native-community/datetimepicker';
import dayjs from 'dayjs';
import {
  colors,
  typography,
  spacing,
  components,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface DatePickerFieldProps {
  /** Label do campo */
  label: string;
  /** Data selecionada */
  value: Date;
  /** Callback ao selecionar data */
  onChange: (date: Date) => void;
  /** Mensagem de erro */
  error?: string;
  /** Texto de ajuda */
  helperText?: string;
  /** Campo obrigatorio */
  required?: boolean;
  /** Campo desabilitado */
  disabled?: boolean;
  /** Data minima */
  minimumDate?: Date;
  /** Data maxima */
  maximumDate?: Date;
  /** testID */
  testID?: string;
}

// ==========================================
// COMPONENTE
// ==========================================

export const DatePickerField: React.FC<DatePickerFieldProps> = ({
  label,
  value,
  onChange,
  error,
  helperText,
  required = false,
  disabled = false,
  minimumDate,
  maximumDate,
  testID,
}) => {
  const [showPicker, setShowPicker] = useState(false);
  const hasError = !!error;

  const formattedDate = dayjs(value).format('DD/MM/YYYY');

  const handlePress = useCallback(() => {
    if (!disabled) {
      setShowPicker(true);
    }
  }, [disabled]);

  const handleChange = useCallback(
    (event: DateTimePickerEvent, selectedDate?: Date) => {
      setShowPicker(Platform.OS === 'ios');
      if (selectedDate) {
        onChange(selectedDate);
      }
    },
    [onChange],
  );

  return (
    <View style={styles.container}>
      <TouchableOpacity
        onPress={handlePress}
        disabled={disabled}
        activeOpacity={0.7}
        testID={testID}
      >
        <TextInput
          label={required ? `${label} *` : label}
          value={formattedDate}
          editable={false}
          mode="outlined"
          outlineColor={hasError ? colors.danger : colors.gray400}
          activeOutlineColor={colors.primary}
          style={styles.input}
          contentStyle={styles.inputContent}
          right={<TextInput.Icon icon="calendar" />}
          error={hasError}
          disabled={disabled}
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

      {showPicker && (
        <DateTimePicker
          value={value}
          mode="date"
          display={Platform.OS === 'ios' ? 'spinner' : 'default'}
          onChange={handleChange}
          minimumDate={minimumDate}
          maximumDate={maximumDate}
          locale="pt-BR"
        />
      )}
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
});

export default DatePickerField;
