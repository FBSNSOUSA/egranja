/// Payload para criacao/edicao de granja.
///
/// Espelha o [CreateGranjaRequest] do backend Go.
class GranjaFormPayload {
  final String nome;
  final String? endereco;
  final String? cidade;
  final String? estado;
  final double? latitude;
  final double? longitude;

  const GranjaFormPayload({
    required this.nome,
    this.endereco,
    this.cidade,
    this.estado,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      if (endereco != null && endereco!.isNotEmpty) 'endereco': endereco,
      if (cidade != null && cidade!.isNotEmpty) 'cidade': cidade,
      if (estado != null && estado!.isNotEmpty) 'estado': estado,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}
