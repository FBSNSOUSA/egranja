import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/features/auth/presentation/providers/auth_provider.dart';

/// Tela de edicao de perfil do eGranja.
///
/// Permite ao usuario (produtor ou tecnico) editar:
/// - Foto (avatar circular com tap para trocar via image_picker)
/// - Nome
/// - Email
/// - Telefone
///
/// Usa o endpoint PATCH /auth/profile e POST /upload para foto.
class EditarPerfilScreen extends ConsumerStatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  ConsumerState<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends ConsumerState<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  bool _isSubmitting = false;
  bool _isUploadingPhoto = false;
  bool _isLoadingProfile = true;
  String? _fotoUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  /// Carrega os dados atuais do perfil do backend.
  Future<void> _loadProfile() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.apiGet<Map<String, dynamic>>(
        '/auth/profile',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (mounted) {
        final data = response.data;
        setState(() {
          _nomeController.text = (data['nome'] as String?) ?? '';
          _emailController.text = (data['email'] as String?) ?? '';
          _telefoneController.text = (data['telefone'] as String?) ?? '';
          _fotoUrl = (data['foto_url'] as String?) ?? '';
          _isLoadingProfile = false;
        });
      }
    } on NetworkException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoadingProfile = false;
        });
        // Fallback: usar dados do auth state
        _loadFromAuthState();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
        // Fallback: usar dados do auth state
        _loadFromAuthState();
      }
    }
  }

  /// Fallback: carrega dados do auth state local quando API esta indisponivel.
  void _loadFromAuthState() {
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      setState(() {
        _nomeController.text =
            _nomeController.text.isEmpty ? user.nome : _nomeController.text;
        _emailController.text = _emailController.text.isEmpty
            ? (user.email.isNotEmpty ? user.email : user.login)
            : _emailController.text;
        _telefoneController.text = _telefoneController.text.isEmpty
            ? user.telefone
            : _telefoneController.text;
        _fotoUrl = _fotoUrl?.isEmpty == true ? user.fotoUrl : _fotoUrl;
      });
    }
  }

  /// Abre a galeria para selecionar uma foto de perfil.
  Future<void> _handlePickPhoto() async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingPhoto = true);

      // Upload da foto
      final apiClient = ref.read(apiClientProvider);
      final result = await apiClient.apiUpload(
        pickedFile.path,
        'image/jpeg',
        'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      if (mounted) {
        final uploadData = result.data;
        final url = (uploadData['url'] as String?) ?? '';
        setState(() {
          _fotoUrl = url;
          _isUploadingPhoto = false;
        });
      }
    } on NetworkException catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Erro ao fazer upload da foto. Tente novamente.'),
            ),
          );
      }
    }
  }

  /// Salva as alteracoes do perfil no backend.
  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Esconder teclado
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final data = <String, dynamic>{};

      if (_nomeController.text.trim().isNotEmpty) {
        data['nome'] = _nomeController.text.trim();
      }
      if (_emailController.text.trim().isNotEmpty) {
        data['email'] = _emailController.text.trim();
      }
      if (_telefoneController.text.trim().isNotEmpty) {
        data['telefone'] = _telefoneController.text.trim();
      }
      if (_fotoUrl != null && _fotoUrl!.isNotEmpty) {
        data['foto_url'] = _fotoUrl;
      }

      await apiClient.apiPatch<Map<String, dynamic>>(
        '/auth/profile',
        data: data,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
        // Voltar para a tela anterior
        context.pop();
      }
    } on ServerException catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      }
    } on NetworkException catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Erro ao salvar perfil. Tente novamente.'),
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final tipoConta = user?.tipo == 'tecnico' ? 'Tecnico' : 'Produtor';

    if (_isLoadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Mensagem de erro ao carregar ─────────────────
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    color: AppColors.warningLight,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber,
                              color: AppColors.warning, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dados carregados localmente. $_errorMessage',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Avatar ────────────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _isUploadingPhoto ? null : _handlePickPhoto,
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: AppColors.primary,
                        backgroundImage:
                            _fotoUrl != null && _fotoUrl!.isNotEmpty
                                ? NetworkImage(_fotoUrl!)
                                : null,
                        child: _isUploadingPhoto
                            ? const CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2.5,
                              )
                            : (_fotoUrl == null || _fotoUrl!.isEmpty)
                                ? Text(
                                    _nomeController.text.isNotEmpty
                                        ? _nomeController.text[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  )
                                : null,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _isUploadingPhoto ? null : _handlePickPhoto,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Toque para alterar a foto',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Chip(
                  label: Text(
                    tipoConta,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(height: 32),

              // ── Nome ──────────────────────────────────────────
              TextFormField(
                controller: _nomeController,
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  hintText: 'Digite seu nome',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe seu nome';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome deve ter no minimo 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Email ─────────────────────────────────────────
              TextFormField(
                controller: _emailController,
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Digite seu email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe seu email';
                  }
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Informe um email valido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Telefone ──────────────────────────────────────
              TextFormField(
                controller: _telefoneController,
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: '(11) 99999-9999',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.trim().length < 8) {
                      return 'Telefone deve ter no minimo 8 digitos';
                    }
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _handleSave(),
              ),
              const SizedBox(height: 32),

              // ── Botao Salvar ──────────────────────────────────
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleSave,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSubmitting ? 'Salvando...' : 'Salvar'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
    );
  }
}
