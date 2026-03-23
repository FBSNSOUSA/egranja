import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/features/granja/domain/entities/granja_form.dart';
import 'package:egranja_flutter/features/granja/presentation/providers/granja_provider.dart';

/// Tela de criacao/edicao de granja.
///
/// Campos: nome, endereco, cidade, estado, latitude, longitude.
/// Suporta captura de foto via image_picker e upload via /upload.
class GranjaFormScreen extends ConsumerStatefulWidget {
  const GranjaFormScreen({super.key, this.granjaId});

  /// Se nulo, cria nova granja. Se preenchido, edita granja existente.
  final String? granjaId;

  @override
  ConsumerState<GranjaFormScreen> createState() => _GranjaFormScreenState();
}

class _GranjaFormScreenState extends ConsumerState<GranjaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController(text: 'MG');
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _telefoneController = TextEditingController();

  bool _isSubmitting = false;
  String? _fotoPath;

  bool get _isEditing => widget.granjaId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadGranjaData();
    }
  }

  Future<void> _loadGranjaData() async {
    try {
      final repository = ref.read(granjaRepositoryProvider);
      final granja = await repository.fetchGranjaById(widget.granjaId!);
      if (!mounted) return;
      setState(() {
        _nomeController.text = granja.nome;
        _enderecoController.text = granja.endereco ?? '';
        _cidadeController.text = granja.cidade ?? '';
        _estadoController.text = granja.estado ?? 'MG';
        if (granja.latitude != null) {
          _latitudeController.text = granja.latitude!.toString();
        }
        if (granja.longitude != null) {
          _longitudeController.text = granja.longitude!.toString();
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _enderecoController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      setState(() {
        _fotoPath = image.path;
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      setState(() {
        _fotoPath = image.path;
      });
    }
  }

  Future<String?> _uploadFoto() async {
    if (_fotoPath == null) return null;
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.apiUpload(
        _fotoPath!,
        'image/jpeg',
        'granja_foto.jpg',
      );
      return response.data['url'] as String?;
    } catch (e) {
      debugPrint('[GranjaForm] Erro ao fazer upload: $e');
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      // Upload foto se selecionada
      if (_fotoPath != null) {
        await _uploadFoto();
      }

      final payload = GranjaFormPayload(
        nome: _nomeController.text.trim(),
        endereco: _enderecoController.text.trim().isEmpty
            ? null
            : _enderecoController.text.trim(),
        cidade: _cidadeController.text.trim().isEmpty
            ? null
            : _cidadeController.text.trim(),
        estado: _estadoController.text.trim().isEmpty
            ? null
            : _estadoController.text.trim().toUpperCase(),
        latitude: _latitudeController.text.trim().isNotEmpty
            ? double.tryParse(_latitudeController.text.trim())
            : null,
        longitude: _longitudeController.text.trim().isNotEmpty
            ? double.tryParse(_longitudeController.text.trim())
            : null,
      );

      if (_isEditing) {
        final repository = ref.read(granjaRepositoryProvider);
        await repository.atualizarGranja(widget.granjaId!, payload);
      } else {
        await ref.read(granjaListProvider.notifier).criarGranja(payload);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Granja atualizada com sucesso!'
                : 'Granja criada com sucesso!',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              // ── Foto da granja ─────────────────────────────────────
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Foto da Granja',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('Galeria'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _takePhoto,
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: const Text('Camera'),
                            ),
                          ),
                        ],
                      ),
                      if (_fotoPath != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Foto selecionada',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Dados basicos ──────────────────────────────────────
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dados da Granja',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nome
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da granja *',
                          hintText: 'Ex: Granja Sao Jose',
                          prefixIcon: Icon(Icons.agriculture_outlined),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nome obrigatorio';
                          }
                          if (v.trim().length > 200) {
                            return 'Maximo 200 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Endereco
                      TextFormField(
                        controller: _enderecoController,
                        decoration: const InputDecoration(
                          labelText: 'Endereco',
                          hintText: 'Ex: Rod. MG-050, Km 12',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),

                      // Cidade + Estado
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _cidadeController,
                              decoration: const InputDecoration(
                                labelText: 'Cidade',
                                hintText: 'Divinopolis',
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (v) {
                                if (v != null && v.length > 100) {
                                  return 'Maximo 100 caracteres';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _estadoController,
                              decoration: const InputDecoration(
                                labelText: 'UF',
                                hintText: 'MG',
                              ),
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(2),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z]')),
                              ],
                              validator: (v) {
                                if (v != null &&
                                    v.isNotEmpty &&
                                    v.length != 2) {
                                  return 'UF 2 letras';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Telefone/Contato
                      TextFormField(
                        controller: _telefoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone/Contato',
                          hintText: '(37) 99999-1234',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Localizacao ────────────────────────────────────────
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Localizacao',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Latitude + Longitude
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latitudeController,
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                                hintText: '-20.1389',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              validator: (v) {
                                if (v != null && v.isNotEmpty) {
                                  final val = double.tryParse(v);
                                  if (val == null) {
                                    return 'Valor invalido';
                                  }
                                  if (val < -90 || val > 90) {
                                    return '-90 a 90';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _longitudeController,
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                                hintText: '-44.8841',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              validator: (v) {
                                if (v != null && v.isNotEmpty) {
                                  final val = double.tryParse(v);
                                  if (val == null) {
                                    return 'Valor invalido';
                                  }
                                  if (val < -180 || val > 180) {
                                    return '-180 a 180';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Dica de localizacao
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Informe as coordenadas para exibir a granja '
                                'no mapa. Voce pode obter pelo GPS do celular.',
                                style:
                                    Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.info,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Botao Salvar ───────────────────────────────────────
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Salvar Alteracoes' : 'Criar Granja',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
    );
  }
}

