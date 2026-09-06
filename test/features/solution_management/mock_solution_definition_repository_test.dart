import 'package:flutter_test/flutter_test.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_definition.dart';
import 'package:coreaxis/features/solution_management/mock/mock_solution_definition_repository.dart';

void main() {
  group('MockSolutionDefinitionRepository', () {
    late MockSolutionDefinitionRepository repo;

    setUp(() {
      repo = MockSolutionDefinitionRepository();
    });

    test('getDefinitions returns seeded data', () async {
      final definitions = await repo.getDefinitions();
      expect(definitions.isNotEmpty, true);
    });

    test('createDefinition adds a definition and persists it', () async {
      final newDef = const SolutionDefinition(
        id: 'test-sd-1',
        name: 'Test Def',
        sourceBlueprintId: 'test-bp',
        state: SolutionDefinitionState.draft,
      );

      await repo.createDefinition(newDef);

      final fetched = await repo.getDefinitionById('test-sd-1');
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Test Def');
    });

    test('updateDefinition updates an existing definition', () async {
      final newDef = const SolutionDefinition(
        id: 'test-sd-2',
        name: 'Test Def 2',
        sourceBlueprintId: 'test-bp',
        state: SolutionDefinitionState.draft,
      );

      await repo.createDefinition(newDef);

      final updatedDef = newDef.copyWith(name: 'Updated Name');
      await repo.updateDefinition(updatedDef);

      final fetched = await repo.getDefinitionById('test-sd-2');
      expect(fetched!.name, 'Updated Name');
    });

    test('updateDefinition rejects mutation of published definitions', () async {
      // Create a published definition
      final newDef = const SolutionDefinition(
        id: 'test-sd-pub',
        name: 'Published Def',
        sourceBlueprintId: 'test-bp',
        state: SolutionDefinitionState.published,
      );

      await repo.createDefinition(newDef);

      // Attempt to mutate it
      final mutatedDef = newDef.copyWith(name: 'Hacked Name');
      
      expect(
        () => repo.updateDefinition(mutatedDef),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Cannot mutate a published Solution Definition'))),
      );

      // Verify it was not mutated
      final fetched = await repo.getDefinitionById('test-sd-pub');
      expect(fetched!.name, 'Published Def');
    });
  });
}
