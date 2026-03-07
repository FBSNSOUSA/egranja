/**
 * Tela de Login do eGranja.
 *
 * Funcionalidades:
 * - Campos Login e Senha
 * - Validacao de campos vazios
 * - Mensagem "Usuario ou senha incorretos"
 * - Botao grande (minimo 48dp) para acessibilidade
 * - Auto-login se token valido (verificacao na inicializacao)
 * - Indicador de loading durante autenticacao
 * - Textos minimo 16sp, otimizado para uso no campo
 */

import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
} from 'react-native';
import {
  TextInput,
  Button,
  Text,
  Snackbar,
  ActivityIndicator,
} from 'react-native-paper';
import { useAuthStore } from '@stores/authStore';
import { colors, typography, spacing, components } from '@theme/index';

// ==========================================
// TIPOS DE NAVEGACAO
// ==========================================

interface LoginScreenProps {
  navigation: {
    replace: (screen: string) => void;
  };
}

// ==========================================
// COMPONENTE
// ==========================================

export const LoginScreen: React.FC<LoginScreenProps> = ({ navigation }) => {
  // Estado local dos campos
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [snackbarVisible, setSnackbarVisible] = useState(false);

  // Estado global de autenticacao
  const {
    isAuthenticated,
    isLoading,
    errorMessage,
    login,
    refreshUser,
    clearError,
  } = useAuthStore();

  // Auto-login: verificar se tem token valido salvo
  useEffect(() => {
    refreshUser();
  }, [refreshUser]);

  // Redirecionar quando autenticado
  useEffect(() => {
    if (isAuthenticated) {
      navigation.replace('Main');
    }
  }, [isAuthenticated, navigation]);

  // Exibir snackbar quando houver erro
  useEffect(() => {
    if (errorMessage) {
      setSnackbarVisible(true);
    }
  }, [errorMessage]);

  // Handler do botao de login
  const handleLogin = useCallback(async () => {
    clearError();
    await login(username.trim(), password);
  }, [username, password, login, clearError]);

  // Handler para fechar snackbar
  const handleDismissSnackbar = useCallback(() => {
    setSnackbarVisible(false);
    clearError();
  }, [clearError]);

  // Tela de loading enquanto verifica auto-login
  if (isLoading && !username && !password) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={colors.primary} />
        <Text style={styles.loadingText}>Verificando credenciais...</Text>
      </View>
    );
  }

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        keyboardShouldPersistTaps="handled"
      >
        {/* Logo e titulo */}
        <View style={styles.headerSection}>
          <View style={styles.logoPlaceholder}>
            <Text style={styles.logoText}>eGranja</Text>
          </View>
          <Text style={styles.subtitle}>
            Gestao completa de aviarios
          </Text>
        </View>

        {/* Formulario de login */}
        <View style={styles.formSection}>
          {/* Campo Login */}
          <TextInput
            label="Login"
            value={username}
            onChangeText={setUsername}
            autoCapitalize="none"
            autoCorrect={false}
            autoComplete="username"
            returnKeyType="next"
            disabled={isLoading}
            mode="outlined"
            outlineColor={colors.gray400}
            activeOutlineColor={colors.primary}
            style={styles.input}
            contentStyle={styles.inputContent}
            left={<TextInput.Icon icon="account" />}
            testID="login-input"
          />

          {/* Campo Senha */}
          <TextInput
            label="Senha"
            value={password}
            onChangeText={setPassword}
            secureTextEntry={!showPassword}
            autoCapitalize="none"
            autoCorrect={false}
            autoComplete="password"
            returnKeyType="done"
            disabled={isLoading}
            onSubmitEditing={handleLogin}
            mode="outlined"
            outlineColor={colors.gray400}
            activeOutlineColor={colors.primary}
            style={styles.input}
            contentStyle={styles.inputContent}
            left={<TextInput.Icon icon="lock" />}
            right={
              <TextInput.Icon
                icon={showPassword ? 'eye-off' : 'eye'}
                onPress={() => setShowPassword(!showPassword)}
              />
            }
            testID="password-input"
          />

          {/* Mensagem de erro inline */}
          {errorMessage && (
            <Text style={styles.errorText} testID="error-message">
              {errorMessage}
            </Text>
          )}

          {/* Botao de login */}
          <Button
            mode="contained"
            onPress={handleLogin}
            loading={isLoading}
            disabled={isLoading}
            style={styles.loginButton}
            contentStyle={styles.loginButtonContent}
            labelStyle={styles.loginButtonLabel}
            buttonColor={colors.primary}
            textColor={colors.textOnPrimary}
            testID="login-button"
          >
            {isLoading ? 'Entrando...' : 'Entrar'}
          </Button>
        </View>

        {/* Rodape */}
        <View style={styles.footerSection}>
          <Text style={styles.versionText}>
            eGranja v1.0.0
          </Text>
        </View>
      </ScrollView>

      {/* Snackbar para erros nao-bloqueantes */}
      <Snackbar
        visible={snackbarVisible}
        onDismiss={handleDismissSnackbar}
        duration={4000}
        style={styles.snackbar}
        action={{
          label: 'Fechar',
          onPress: handleDismissSnackbar,
          textColor: colors.white,
        }}
      >
        <Text style={styles.snackbarText}>
          {errorMessage || ''}
        </Text>
      </Snackbar>
    </KeyboardAvoidingView>
  );
};

// ==========================================
// ESTILOS
// ==========================================

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.white,
  },

  scrollContent: {
    flexGrow: 1,
    justifyContent: 'center',
    paddingHorizontal: spacing.xxl,
    paddingVertical: spacing.xxxl,
  },

  // Loading (auto-login)
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: colors.white,
  },
  loadingText: {
    marginTop: spacing.lg,
    fontSize: typography.fontSizeM,
    color: colors.textSecondary,
  },

  // Header com logo
  headerSection: {
    alignItems: 'center',
    marginBottom: spacing.huge,
  },
  logoPlaceholder: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: colors.primary,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: spacing.lg,
  },
  logoText: {
    fontSize: typography.fontSizeXXL,
    fontWeight: typography.fontWeightBold,
    color: colors.textOnPrimary,
  },
  subtitle: {
    fontSize: typography.fontSizeL,
    color: colors.textSecondary,
    textAlign: 'center',
  },

  // Formulario
  formSection: {
    width: '100%',
    maxWidth: 400,
    alignSelf: 'center',
  },
  input: {
    marginBottom: spacing.lg,
    backgroundColor: colors.white,
  },
  inputContent: {
    fontSize: typography.fontSizeM,
    minHeight: components.input.minHeight,
  },

  // Erro
  errorText: {
    fontSize: typography.fontSizeS,
    color: colors.danger,
    marginBottom: spacing.lg,
    textAlign: 'center',
    fontWeight: typography.fontWeightMedium,
  },

  // Botao de login
  loginButton: {
    marginTop: spacing.sm,
    borderRadius: components.button.borderRadius,
  },
  loginButtonContent: {
    minHeight: components.buttonLarge.minHeight,
    paddingVertical: spacing.sm,
  },
  loginButtonLabel: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
  },

  // Rodape
  footerSection: {
    marginTop: spacing.huge,
    alignItems: 'center',
  },
  versionText: {
    fontSize: typography.fontSizeXS,
    color: colors.gray500,
  },

  // Snackbar
  snackbar: {
    backgroundColor: colors.danger,
  },
  snackbarText: {
    color: colors.white,
    fontSize: typography.fontSizeS,
  },
});

export default LoginScreen;
