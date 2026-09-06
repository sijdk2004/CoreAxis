import 'package:coreaxis/features/platform/domain/contracts/provisioning_boundaries.dart';
import 'package:coreaxis/features/solution_management/mock/mock_solution_definition_repository.dart';

class SolutionDefinitionAdapter implements ISolutionDefinitionProviderAdapter {
  final MockSolutionDefinitionRepository _repository;

  SolutionDefinitionAdapter(this._repository);

  @override
  Future<dynamic> getSolutionDefinition(String id) async {
    final def = await _repository.getDefinitionById(id);
    if (def == null) {
      throw Exception('SolutionDefinition not found.');
    }
    return def;
  }
}
