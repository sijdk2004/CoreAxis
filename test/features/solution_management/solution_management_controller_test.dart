import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_definition.dart';
import 'package:coreaxis/features/solution_management/application/solution_management_providers.dart';
import 'package:coreaxis/features/solution_management/mock/mock_solution_definition_repository.dart';

void main() {
  group('SolutionManagementController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          mockSolutionDefinitionRepositoryProvider.overrideWithValue(MockSolutionDefinitionRepository()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('valid transition from draft to design updates state', () async {
      final repo = container.read(mockSolutionDefinitionRepositoryProvider);
      
      final def = const SolutionDefinition(
        id: 'test-1',
        name: 'Test',
        sourceBlueprintId: 'bp-1',
        state: SolutionDefinitionState.draft,
      );
      
      await repo.createDefinition(def);
      
      final controller = container.read(solutionManagementControllerProvider.notifier);
      await controller.transitionToDesign(def);
      
      final updated = await repo.getDefinitionById('test-1');
      expect(updated!.state, SolutionDefinitionState.design);
    });

    test('invalid transition throws exception', () async {
      final repo = container.read(mockSolutionDefinitionRepositoryProvider);
      
      final def = const SolutionDefinition(
        id: 'test-2',
        name: 'Test',
        sourceBlueprintId: 'bp-1',
        state: SolutionDefinitionState.draft,
      );
      
      await repo.createDefinition(def);
      
      final controller = container.read(solutionManagementControllerProvider.notifier);
      
      // Try to jump from draft straight to preview (invalid)
      expect(
        () => controller.transitionToPreview(def),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Can only transition to preview from validation'))),
      );
    });

    test('publish transitions to published', () async {
      final repo = container.read(mockSolutionDefinitionRepositoryProvider);
      
      final def = const SolutionDefinition(
        id: 'test-3',
        name: 'Test',
        sourceBlueprintId: 'bp-1',
        state: SolutionDefinitionState.preview,
      );
      
      await repo.createDefinition(def);
      
      final controller = container.read(solutionManagementControllerProvider.notifier);
      await controller.publish(def);
      
      final updated = await repo.getDefinitionById('test-3');
      expect(updated!.state, SolutionDefinitionState.published);
    });
  });
}
