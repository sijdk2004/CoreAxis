import 'package:coreaxis/features/platform/domain/contracts/provisioning_boundaries.dart';
import 'package:coreaxis/features/marketplace/mock/mock_marketplace_repository.dart';

class MarketplaceDependencyAdapter implements IMarketplaceDependencyValidatorAdapter {
  final MockMarketplaceRepository _repository;

  MarketplaceDependencyAdapter(this._repository);

  @override
  Future<bool> validateDependencies(List<String> moduleIds) async {
    for (final id in moduleIds) {
      final module = await _repository.getModuleById(id);
      if (module == null) {
        throw Exception('Marketplace module $id not found.');
      }
      
      // Strict dependency validation delegated to M2
      if (!_repository.validateCompatibility(module)) {
        throw Exception('Module ${module.name} is incompatible with current environment.');
      }
      
      final missingRequired = _repository.getMissingDependencies(module, onlyRequired: true);
      if (missingRequired.isNotEmpty) {
        final missingNames = missingRequired.map((d) => d.moduleCode).join(', ');
        throw Exception('Module ${module.name} is missing required dependencies: $missingNames.');
      }
    }
    
    return true; // All dependencies met
  }
}
