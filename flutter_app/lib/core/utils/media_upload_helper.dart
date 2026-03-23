import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import 'package:egranja_flutter/core/network/api_client.dart';

/// Resultado de um upload de midia.
class MediaUploadResult {
  final String url;
  final String? thumbnailUrl;
  final String fileName;
  final String contentType;

  const MediaUploadResult({
    required this.url,
    this.thumbnailUrl,
    required this.fileName,
    required this.contentType,
  });
}

/// Helper para upload de midias (fotos e audios) para o backend.
///
/// Encapsula a selecao de midia, validacao e upload via [ApiClient.apiUpload].
class MediaUploadHelper {
  final ApiClient _apiClient;
  final ImagePicker _picker;

  MediaUploadHelper({
    required ApiClient apiClient,
    ImagePicker? picker,
  })  : _apiClient = apiClient,
        _picker = picker ?? ImagePicker();

  /// Seleciona uma foto da camera e faz upload.
  ///
  /// Retorna [MediaUploadResult] com a URL do arquivo no servidor,
  /// ou `null` se o usuario cancelar a selecao.
  Future<MediaUploadResult?> uploadFotoCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image == null) return null;
    return _uploadFile(image.path, _getImageContentType(image.path));
  }

  /// Seleciona uma foto da galeria e faz upload.
  ///
  /// Retorna [MediaUploadResult] com a URL do arquivo no servidor,
  /// ou `null` se o usuario cancelar a selecao.
  Future<MediaUploadResult?> uploadFotoGaleria() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image == null) return null;
    return _uploadFile(image.path, _getImageContentType(image.path));
  }

  /// Faz upload de um arquivo de audio ja gravado.
  ///
  /// [filePath] caminho local do arquivo de audio.
  /// Retorna [MediaUploadResult] com a URL do arquivo no servidor.
  Future<MediaUploadResult> uploadAudio(String filePath) async {
    final contentType = _getAudioContentType(filePath);
    return _uploadFile(filePath, contentType);
  }

  /// Faz upload de um arquivo qualquer.
  Future<MediaUploadResult> _uploadFile(
    String filePath,
    String contentType,
  ) async {
    final fileName = p.basename(filePath);

    debugPrint('[MediaUploadHelper] Uploading: $fileName ($contentType)');

    final response = await _apiClient.apiUpload(
      filePath,
      contentType,
      fileName,
    );

    final data = response.data;
    return MediaUploadResult(
      url: data['url'] as String,
      thumbnailUrl: data['thumbnail_url'] as String?,
      fileName: data['file_name'] as String,
      contentType: data['content_type'] as String,
    );
  }

  /// Determina o content type de uma imagem com base na extensao.
  String _getImageContentType(String path) {
    final ext = p.extension(path).toLowerCase();
    switch (ext) {
      case '.png':
        return 'image/png';
      case '.jpg':
      case '.jpeg':
      default:
        return 'image/jpeg';
    }
  }

  /// Determina o content type de um audio com base na extensao.
  String _getAudioContentType(String path) {
    final ext = p.extension(path).toLowerCase();
    switch (ext) {
      case '.ogg':
        return 'audio/ogg';
      case '.opus':
        return 'audio/opus';
      case '.m4a':
        return 'audio/mp4';
      case '.mp4':
        return 'audio/mp4';
      case '.mp3':
      default:
        return 'audio/mpeg';
    }
  }
}
