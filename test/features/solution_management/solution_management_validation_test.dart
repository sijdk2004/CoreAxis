import 'package:flutter_test/flutter_test.dart';
import 'package:coreaxis/features/solution_blueprint/domain/models/solution_blueprint.dart';
import 'package:coreaxis/features/solution_blueprint/domain/models/marketplace_module_reference.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_definition.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_module_configuration.dart';
import 'package:coreaxis/features/solution_management/application/solution_management_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coreaxis/features/solution_composer/application/composer_providers.dart';
import 'package:coreaxis/features/solution_management/mock/mock_solution_definition_repository.dart';
import 'package:coreaxis/features/solution_blueprint/application/blueprint_providers.dart';
import 'package:coreaxis/features/solution_blueprint/mock/mock_blueprint_repository.dart';

void main() {
  group('CA-MKT-006 Architecture Validation', () {
    late ProviderContainer container;
    late MockSolutionDefinitionRepository repo;
    late MockBlueprintRepository blueprintRepo;

    setUp(() {
      repo = MockSolutionDefinitionRepository();
      blueprintRepo = MockBlueprintRepository();
      container = ProviderContainer(
        overrides: [
          mockSolutionDefinitionRepositoryProvider.overrideWithValue(repo),
          mockBlueprintRepositoryProvider.overrideWithValue(blueprintRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Blueprint Immutability, Exact Version Inheritance, and Configuration Isolation', () async {
      // 1. Prepare a Blueprint test fixture without modifying the production mock seed
      final initialBlueprint = await blueprintRepo.getBlueprintById('bp-1');
      final testFixture = initialBlueprint!.copyWith(
        moduleReferences: [
          const MarketplaceModuleReference(
            marketplaceModuleId: 'm-sales-1',
            moduleCode: 'SALES',
            exactPublishedVersion: '1.2.0',
          )
        ],
        configurationDefaults: {'currency': 'USD'},
      );
      await blueprintRepo.updateBlueprint(testFixture);

      final blueprint = await blueprintRepo.getBlueprintById('bp-1');
      expect(blueprint, isNotNull);
      
      final originalModuleCount = blueprint!.moduleReferences.length;
      final originalVersion = blueprint.moduleReferences.first.exactPublishedVersion;
      final originalCurrency = blueprint.configurationDefaults['currency'];

      // 2. Load into Composer (simulating Create Solution Definition)
      final composerNotifier = container.read(composerSessionControllerProvider.notifier);
      await composerNotifier.initializeFromBlueprint('bp-1');
      
      final composerState = container.read(composerSessionControllerProvider);
      final definition = composerState.definition!;

      // Verify exact version inheritance
      expect(definition.moduleConfigurations.first.reference.exactPublishedVersion, originalVersion);

      // 3. Modify Solution-specific configuration
      composerNotifier.updateConfiguration('currency', 'EUR');
      
      // Verify isolation
      final modifiedState = container.read(composerSessionControllerProvider);
      expect(modifiedState.definition!.solutionConfiguration['currency'], 'EUR');
      
      // Verify originating Blueprint is unchanged
      final reloadedBlueprint = await blueprintRepo.getBlueprintById('bp-1');
      expect(reloadedBlueprint!.moduleReferences.length, originalModuleCount);
      expect(reloadedBlueprint.moduleReferences.first.exactPublishedVersion, originalVersion);
      expect(reloadedBlueprint.configurationDefaults['currency'], originalCurrency);
      
      // Verify Composer saves as Draft and does not publish
      await composerNotifier.saveDefinition();
      
      final savedDef = await repo.getDefinitionById(modifiedState.definition!.id);
      expect(savedDef, isNotNull);
      expect(savedDef!.state, SolutionDefinitionState.draft); // Composer only saves as draft
    });

    test('Invalid Lifecycle Transitions are Rejected', () async {
      final def = const SolutionDefinition(
        id: 'test-invalid-trans',
        name: 'Test',
        sourceBlueprintId: 'bp-1',
        state: SolutionDefinitionState.draft,
      );
      
      await repo.createDefinition(def);
      final controller = container.read(solutionManagementControllerProvider.notifier);
      
      // draft -> validation
      expect(
        () => controller.transitionToValidation(def),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Can only transition to validation from configuration'))),
      );
      
      // draft -> published
      expect(
        () => controller.publish(def),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Can only publish from preview or validation'))),
      );
      
      // mutate published
      final pubDef = def.copyWith(state: SolutionDefinitionState.published);
      await repo.createDefinition(pubDef.copyWith(id: 'pub-1'));
      
      expect(
        () => controller.transitionToDesign(pubDef.copyWith(id: 'pub-1')),
        throwsA(isA<Exception>()),
      );
    });

    test('Repository Persistence Survives Provider Invalidation', () async {
      final newDef = const SolutionDefinition(
        id: 'test-persist',
        name: 'Persist Test',
        sourceBlueprintId: 'bp-1',
      );
      
      await repo.createDefinition(newDef);
      
      // Read through list provider
      final list1 = await container.read(solutionDefinitionListProvider.future);
      expect(list1.any((d) => d.id == 'test-persist'), true);
      
      // Invalidate list provider
      container.invalidate(solutionDefinitionListProvider);
      
      // Read again
      final list2 = await container.read(solutionDefinitionListProvider.future);
      expect(list2.any((d) => d.id == 'test-persist'), true);
    });
    
    test('Composer Blocked from Editing Published Definitions', () async {
      final pubDef = const SolutionDefinition(
        id: 'pub-composer',
        name: 'Published',
        sourceBlueprintId: 'bp-1',
        state: SolutionDefinitionState.published,
      );
      await repo.createDefinition(pubDef);
      
      final composerNotifier = container.read(composerSessionControllerProvider.notifier);
      await composerNotifier.loadExistingDefinition('pub-composer');
      
      final state = container.read(composerSessionControllerProvider);
      expect(state.error, contains('Cannot edit a published definition in Composer'));
      expect(state.definition, isNull);
    });
  });
}
