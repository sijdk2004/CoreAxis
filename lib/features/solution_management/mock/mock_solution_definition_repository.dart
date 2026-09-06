import 'package:coreaxis/features/solution_management/domain/models/solution_definition.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_module_configuration.dart';
import 'package:coreaxis/features/solution_blueprint/domain/models/marketplace_module_reference.dart';

class MockSolutionDefinitionRepository {
  final List<SolutionDefinition> _definitions = [];

  MockSolutionDefinitionRepository() {
    _seedData();
  }

  void _seedData() {
    _definitions.addAll([
      const SolutionDefinition(
        id: 'sd-1',
        name: 'FurniFlow North America',
        sourceBlueprintId: 'bp-1',
        description: 'Deployed configuration for NA region.',
        state: SolutionDefinitionState.published,
        moduleConfigurations: [
          SolutionModuleConfiguration(
            reference: MarketplaceModuleReference(
              marketplaceModuleId: 'm-sales-1',
              moduleCode: 'SALES',
              exactPublishedVersion: '1.2.0',
            ),
          )
        ],
        solutionConfiguration: {
          'currency': 'USD',
          'language': 'en_US',
        },
      ),
      const SolutionDefinition(
        id: 'sd-2',
        name: 'FurniFlow Europe (Draft)',
        sourceBlueprintId: 'bp-1',
        description: 'Draft configuration for EU region.',
        state: SolutionDefinitionState.draft,
        moduleConfigurations: [
          SolutionModuleConfiguration(
            reference: MarketplaceModuleReference(
              marketplaceModuleId: 'm-sales-1',
              moduleCode: 'SALES',
              exactPublishedVersion: '1.2.0',
            ),
          )
        ],
        solutionConfiguration: {
          'currency': 'EUR',
          'language': 'en_UK',
        },
      ),
      const SolutionDefinition(
        id: 'sd-3',
        name: 'Die Casting Global',
        sourceBlueprintId: 'bp-2',
        description: 'Global template for die casting.',
        state: SolutionDefinitionState.validation,
        moduleConfigurations: [
          SolutionModuleConfiguration(
            reference: MarketplaceModuleReference(
              marketplaceModuleId: 'm-mfg-1',
              moduleCode: 'MFG',
              exactPublishedVersion: '2.0.1',
            ),
          )
        ],
        solutionConfiguration: {
          'currency': 'USD',
          'language': 'en_US',
        },
      )
    ]);
  }

  Future<List<SolutionDefinition>> getDefinitions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_definitions);
  }

  Future<SolutionDefinition?> getDefinitionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _definitions.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<SolutionDefinition> createDefinition(SolutionDefinition definition) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _definitions.add(definition);
    return definition;
  }

  Future<void> updateDefinition(SolutionDefinition definition) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _definitions.indexWhere((d) => d.id == definition.id);
    if (index != -1) {
      final existing = _definitions[index];
      if (existing.state == SolutionDefinitionState.published && definition.state != SolutionDefinitionState.maintenance && definition.state != SolutionDefinitionState.archived) {
        throw Exception('Cannot mutate a published Solution Definition. Please create a new version.');
      }
      _definitions[index] = definition;
    } else {
      throw Exception('Solution Definition not found');
    }
  }
}

