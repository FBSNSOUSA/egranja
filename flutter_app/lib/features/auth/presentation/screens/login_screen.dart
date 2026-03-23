import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/features/auth/presentation/providers/auth_provider.dart';

/// Tela de login do eGranja.
///
/// Portada do design React Native original com:
/// - Logo circular com fundo primary e texto "eGranja"
/// - Subtitulo "Gestao completa de aviarios"
/// - Campos de login e senha com icones
/// - Botao "Entrar" com estado de loading
/// - Auto-login na inicializacao se houver token valido
/// - Todos os textos em portugues brasileiro
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _hasCheckedAuth = false;
  bool _isManualLogin = false;

  @override
  void initState() {
    super.initState();
    // Verificar auto-login apos o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoLogin();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Verifica se ha sessao valida para auto-login.
  /// Usa timeout de 5 segundos para evitar travar na web.
  Future<void> _checkAutoLogin() async {
    if (_hasCheckedAuth) return;
    _hasCheckedAuth = true;

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .checkAuth()
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      // Timeout ou erro: prosseguir sem auto-login
      debugPrint('[LoginScreen] Auto-login falhou ou timeout: $e');
      if (mounted) {
        ref.read(authNotifierProvider.notifier).clearError();
      }
    }
  }

  /// Submete o formulario de login.
  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Esconder teclado
    FocusScope.of(context).unfocus();

    setState(() => _isManualLogin = true);

    await ref.read(authNotifierProvider.notifier).login(
          _usernameController.text.trim(),
          _passwordController.text,
        );

    if (mounted) {
      setState(() => _isManualLogin = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    // Campos desabilitados APENAS durante login manual, nao durante auto-login
    final isLoading = _isManualLogin && authState.status == AuthStatus.loading;
    final isInitialOrLoading = authState.status == AuthStatus.initial ||
        (authState.status == AuthStatus.loading && !_hasCheckedAuth);

    // Exibir SnackBar para erros
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                textColor: AppColors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
      }
    });

    // Tela de loading enquanto verifica auto-login
    if (isInitialOrLoading && !_hasCheckedAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Logo ──────────────────────────────────────────
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'eGranja',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Subtitulo ─────────────────────────────────────
                    Text(
                      'Gestao completa de aviarios',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                    ),
                    const SizedBox(height: 48),

                    // ── Campo Login ───────────────────────────────────
                    TextFormField(
                      controller: _usernameController,
                      focusNode: _usernameFocusNode,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        hintText: 'Digite seu usuario',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe seu usuario';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        _passwordFocusNode.requestFocus();
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Campo Senha ───────────────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      enabled: !isLoading,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: 'Digite sua senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe sua senha';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: 4),

                    // ── Esqueceu a senha? ─────────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.go('/forgot-password'),
                        child: Text(
                          'Esqueceu a senha?',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // ── Mensagem de erro ──────────────────────────────
                    if (authState.status == AuthStatus.error &&
                        authState.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          authState.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // ── Botao Entrar ──────────────────────────────────
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text('Entrar'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Criar Conta ──────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nao tem conta? ',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.go('/register'),
                          child: const Text('Criar Conta'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── Footer ────────────────────────────────────────
                    Text(
                      'eGranja v1.0.0',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.gray500,
                                fontSize: 14,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
