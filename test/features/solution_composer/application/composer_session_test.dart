import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coreaxis/features/solution_blueprint/application/blueprint_providers.dart';
import 'package:coreaxis/features/solution_blueprint/domain/models/marketplace_module_reference.dart';

import 'package:coreaxis/features/solution_composer/application/composer_providers.dart';
import 'package:coreaxis/features/solution_management/application/solution_management_providers.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_definition.dart';

void main() {
  test('Composer Session creates Definition from Blueprint', () async {
    final container = ProviderContainer();
    final repo = container.read(mockBlueprintRepositoryProvider);
    
    final blueprint = await repo.createBlueprint('Test Blueprint', 'Tech', 'Desc');
    
    final controller = container.read(composerSessionControllerProvider.notifier);
    await controller.initializeFromBlueprint(blueprint.id);
    
    final state = container.read(composerSessionControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    expect(state.definition, isNotNull);
    expect(state.definition!.sourceBlueprintId, blueprint.id);
    expect(state.definition!.name, '${blueprint.name} Instance');
  });

  test('Repository persistence survives invalidation', () async {
    final container = ProviderContainer();
    final repo = container.read(mockBlueprintRepositoryProvider);
    final blueprint = await repo.createBlueprint('Test BP', 'Tech', 'Desc');
    
    final controller = container.read(composerSessionControllerProvider.notifier);
    await controller.initializeFromBlueprint(blueprint.id);
    await controller.saveDefinition();
    
    final state = container.read(composerSessionControllerProvider);
    expect(state.definition, isNotNull);
    final savedId = state.definition!.id;

    // Read through solutionDefinitionListProvider
    var definitions = await container.read(solutionDefinitionListProvider.future);
    expect(definitions.any((d) => d.id == savedId), isTrue);

    // Invalidate solutionDefinitionListProvider
    container.invalidate(solutionDefinitionListProvider);

    // Read again
    definitions = await container.read(solutionDefinitionListProvider.future);
    expect(definitions.any((d) => d.id == savedId), isTrue);
    expect(definitions.firstWhere((d) => d.id == savedId).state, SolutionDefinitionState.draft);
  });

  test('Blueprint immutability', () async {
    final container = ProviderContainer();
    final repo = container.read(mockBlueprintRepositoryProvider);
    var blueprint = await repo.createBlueprint('Test BP', 'Tech', 'Desc');
    
    // Setup Blueprint with a reference and config
    final newRef = const MarketplaceModuleReference(marketplaceModuleId: 'm1', moduleCode: 'M-01', exactPublishedVersion: '1.4.2');
    blueprint = blueprint.copyWith(
      moduleReferences: [newRef],
      configurationDefaults: {'currency': 'USD'},
    );
    await repo.updateBlueprint(blueprint);
    
    final originalBlueprintConfig = Map.from(blueprint.configurationDefaults);
    final originalBlueprintModules = List.from(blueprint.moduleReferences);
    
    final controller = container.read(composerSessionControllerProvider.notifier);
    await controller.initializeFromBlueprint(blueprint.id);
    
    // Modify Solution configuration
    controller.updateConfiguration('currency', 'EUR');
    
    // Verify Blueprint is unchanged
    final currentBlueprint = await repo.getBlueprintById(blueprint.id);
    expect(currentBlueprint!.configurationDefaults, equals(originalBlueprintConfig));
    expect(currentBlueprint.moduleReferences, equals(originalBlueprintModules));
  });

  test('Exact version inheritance', () async {
    final container = ProviderContainer();
    final repo = container.read(mockBlueprintRepositoryProvider);
    var blueprint = await repo.createBlueprint('Test BP', 'Tech', 'Desc');
    
    // Blueprint containing exact version
    final newRef = const MarketplaceModuleReference(marketplaceModuleId: 'm2', moduleCode: 'X', exactPublishedVersion: '1.4.2');
    blueprint = blueprint.copyWith(moduleReferences: [newRef]);
    await repo.updateBlueprint(blueprint);
    
    final controller = container.read(composerSessionControllerProvider.notifier);
    await controller.initializeFromBlueprint(blueprint.id);
    
    final state = container.read(composerSessionControllerProvider);
    final solutionModule = state.definition!.moduleConfigurations.first;
    
    expect(solutionModule.reference.moduleCode, 'X');
    expect(solutionModule.reference.exactPublishedVersion, '1.4.2');
  });

  test('Configuration isolation', () async {
    final container = ProviderContainer();
    final repo = container.read(mockBlueprintRepositoryProvider);
    var blueprint = await repo.createBlueprint('Test BP', 'Tech', 'Desc');
    
    blueprint = blueprint.copyWith(configurationDefaults: {'theme': 'light'});
    await repo.updateBlueprint(blueprint);
    
    final controller = container.read(composerSessionControllerProvider.notifier);
    await controller.initializeFromBlueprint(blueprint.id);
    
    // Check initial inheritance
    var state = container.read(composerSessionControllerProvider);
    expect(state.definition!.solutionConfiguration['theme'], 'light');
    
    // Modify the Solution configuration
    controller.updateConfiguration('theme', 'dark');
    
    state = container.read(composerSessionControllerProvider);
    expect(state.definition!.solutionConfiguration['theme'], 'dark');
    
    // Verify Blueprint remains unchanged
    final currentBlueprint = await repo.getBlueprintById(blueprint.id);
    expect(currentBlueprint!.configurationDefaults['theme'], 'light');
  });
}
