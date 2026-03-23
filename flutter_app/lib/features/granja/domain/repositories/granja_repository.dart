import 'package:egranja_flutter/features/granja/domain/entities/granja.dart';
import 'package:egranja_flutter/features/granja/domain/entities/granja_form.dart';

/// Contrato do repositorio de dados de granjas.
///
/// Define operacoes CRUD para granjas, consumidas pela camada
/// de apresentacao via Riverpod providers.
abstract class GranjaRepository {
  /// Busca todas as granjas acessiveis pelo usuario autenticado.
  Future<List<Granja>> fetchGranjas();

  /// Busca os detalhes de uma granja pelo ID.
  Future<Granja> fetchGranjaById(String id);

  /// Cria uma nova granja.
  Future<Granja> criarGranja(GranjaFormPayload payload);

  /// Atualiza uma granja existente.
  Future<Granja> atualizarGranja(String id, GranjaFormPayload payload);

  /// Remove uma granja pelo ID.
  Future<void> deletarGranja(String id);
}
