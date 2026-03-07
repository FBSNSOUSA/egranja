/**
 * Campo de formulario padronizado do eGranja.
 *
 * Wrapper do TextInput do react-native-paper com:
 * - Label obrigatorio
 * - Mensagem de erro
 * - Helper text
 * - Suporte a teclado numerico
 * - Estilo consistente com design system (minimo 48dp, 16sp)
 */

import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  KeyboardTypeOptions,
} from 'react-native';
import { TextInput, HelperText } from 'react-native-paper';
import {
  colors,
  typography,
  spacing,
  components,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface FormFieldProps {
  /** Label do campo */
  label: string;
  /** Valor atual */
  value: string;
  /** Callback de alteracao */
  onChangeText: (text: string) => void;
  /** Placeholder */
  placeholder?: string;
  /** Mensagem de erro */
  error?: string;
  /** Texto de ajuda */
  helperText?: string;
  /** Tipo de teclado */
  keyboardType?: KeyboardTypeOptions;
  /** Campo obrigatorio (exibe asterisco) */
  required?: boolean;
  /** Campo desabilitado */
  disabled?: boolean;
  /** Multilinhas */
  multiline?: boolean;
  /** Numero de linhas para multiline */
  numberOfLines?: number;
  /** Icone a esquerda (MaterialCommunityIcons) */
  leftIcon?: string;
  /** Icone a direita */
  rightIcon?: string;
  /** Callback do icone a direita */
  onRightIconPress?: () => void;
  /** Auto capitalize */
  autoCapitalize?: 'none' | 'sentences' | 'words' | 'characters';
  /** Tipo de return key */
  returnKeyType?: 'done' | 'next' | 'go' | 'search';
  /** Callback ao submeter */
  onSubmitEditing?: () => void;
  /** Ref do input */
  inputRef?: React.RefObject<any>;
  /** Mascara para editable=false com valor formatado */
  editable?: boolean;
  /** Sufixo (ex: "g", "kg", "L") */
  suffix?: string;
  /** testID para testes */
  testID?: string;
}

// ==========================================
// COMPONENTE
// ==========================================

export const FormField: React.FC<FormFieldProps> = ({
  label,
  value,
  onChangeText,
  placeholder,
  error,
  helperText,
  keyboardType = 'default',
  required = false,
  disabled = false,
  multiline = false,
  numberOfLines = 1,
  leftIcon,
  rightIcon,
  onRightIconPress,
  autoCapitalize = 'sentences',
  returnKeyType,
  onSubmitEditing,
  inputRef,
  editable = true,
  suffix,
  testID,
}) => {
  const hasError = !!error;

  return (
    <View style={styles.container}>
      <TextInput
        ref={inputRef}
        label={required ? `${label} *` : label}
        value={suffix && value ? `${value} ${suffix}` : value}
        onChangeText={(text) => {
          // Remove suffix se presente antes de enviar
          if (suffix) {
            const cleaned = text.replace(` ${suffix}`, '').replace(suffix, '');
            onChangeText(cleaned);
          } else {
            onChangeText(text);
          }
        }}
        placeholder={placeholder}
        keyboardType={keyboardType}
        autoCapitalize={autoCapitalize}
        autoCorrect={false}
        disabled={disabled}
        editable={editable}
        multiline={multiline}
        numberOfLines={numberOfLines}
        returnKeyType={returnKeyType}
        onSubmitEditing={onSubmitEditing}
        error={hasError}
        mode="outlined"
        outlineColor={colors.gray400}
        activeOutlineColor={hasError ? colors.danger : colors.primary}
        style={[styles.input, multiline && { minHeight: 48 * numberOfLines }]}
        contentStyle={styles.inputContent}
        left={leftIcon ? <TextInput.Icon icon={leftIcon} /> : undefined}
        right={rightIcon ? (
          <TextInput.Icon icon={rightIcon} onPress={onRightIconPress} />
        ) : undefined}
        testID={testID}
      />

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

export default FormField;
