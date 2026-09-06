import 'package:flutter_test/flutter_test.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution_lifecycle.dart';
import 'package:coreaxis/features/customer_solution/domain/services/customer_solution_configuration_resolver.dart';
import 'package:coreaxis/features/customer_solution/domain/models/effective_runtime_configuration_snapshot.dart';
import 'package:coreaxis/features/solution_blueprint/domain/models/marketplace_module_reference.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_module_configuration.dart';

void main() {
  group('CustomerSolutionConfigurationResolver', () {
    late CustomerSolutionConfigurationResolver resolver;

    setUp(() {
      resolver = CustomerSolutionConfigurationResolver();
    });

    test('should deeply merge blueprint defaults with current configuration', () {
      final moduleConfig = SolutionModuleConfiguration(
        reference: const MarketplaceModuleReference(
          marketplaceModuleId: 'm1',
          moduleCode: 'TEST_MODULE',
          exactPublishedVersion: '1.0.0',
          blueprintConfiguration: {
            'theme': 'light',
            'features': {
              'advanced': false,
              'beta': true,
            },
            'list': [1, 2],
          },
        ),
        configuration: {
          'features': {
            'advanced': true, // overrides
            // beta is missing, should inherit
            'new_feature': true, // newly added
          },
          'list': [3, 4], // overrides completely since it's a list (primitive type in JSON context)
        },
      );

      final solution = CustomerSolution(
        id: 's1',
        tenantId: 't1',
        sourceSolutionDefinitionId: 'sd1',
        exactSolutionDefinitionVersion: '1.0.0',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        moduleConfigurations: [moduleConfig],
      );

      final snapshot = resolver.resolve(solution);

      expect(snapshot.sourceSolutionDefinitionVersion, '1.0.0');
      expect(snapshot.resolvedConfiguration.containsKey('TEST_MODULE'), isTrue);

      final resolved = snapshot.resolvedConfiguration['TEST_MODULE']!;
      expect(resolved['theme'], 'light'); // Inherited
      expect(resolved['features']['advanced'], true); // Overridden
      expect(resolved['features']['beta'], true); // Inherited
      expect(resolved['features']['new_feature'], true); // Added
      expect(resolved['list'], [3, 4]); // Overridden
    });

    test('explicit null in override removes key from blueprint defaults', () {
      final moduleConfig = SolutionModuleConfiguration(
        reference: const MarketplaceModuleReference(
          marketplaceModuleId: 'm2',
          moduleCode: 'MODULE_NULL',
          exactPublishedVersion: '1.0.0',
          blueprintConfiguration: {
            'settingA': 'valueA',
            'settingB': 'valueB',
            'nested': {
              'sub1': 'val1',
              'sub2': 'val2',
            }
          },
        ),
        configuration: {
          'settingA': null, // Should remove
          'nested': {
            'sub1': null, // Should remove
          }
        },
      );

      final solution = CustomerSolution(
        id: 's2',
        tenantId: 't2',
        sourceSolutionDefinitionId: 'sd2',
        exactSolutionDefinitionVersion: '1.1.0',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        moduleConfigurations: [moduleConfig],
      );

      final snapshot = resolver.resolve(solution);
      final resolved = snapshot.resolvedConfiguration['MODULE_NULL']!;

      expect(resolved.containsKey('settingA'), isFalse);
      expect(resolved['settingB'], 'valueB');
      expect(resolved['nested'].containsKey('sub1'), isFalse);
      expect(resolved['nested']['sub2'], 'val2');
    });

    test('original objects are not mutated (deep copy enforcement)', () {
      final blueprintMap = <String, dynamic>{
        'nested': {'val': 1}
      };
      
      final currentMap = <String, dynamic>{
        'nested': {'new_val': 2}
      };

      final moduleConfig = SolutionModuleConfiguration(
        reference: MarketplaceModuleReference(
          marketplaceModuleId: 'm3',
          moduleCode: 'MODULE_MUT',
          exactPublishedVersion: '1.0.0',
          blueprintConfiguration: blueprintMap,
        ),
        configuration: currentMap,
      );

      final solution = CustomerSolution(
        id: 's3',
        tenantId: 't3',
        sourceSolutionDefinitionId: 'sd3',
        exactSolutionDefinitionVersion: '1.0.0',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        moduleConfigurations: [moduleConfig],
      );

      final snapshot = resolver.resolve(solution);
      final resolved = snapshot.resolvedConfiguration['MODULE_MUT']!;

      // Verify resolved data
      expect(resolved['nested']['val'], 1);
      expect(resolved['nested']['new_val'], 2);

      // Verify original objects were not mutated (isolated)
      expect(blueprintMap['nested'].containsKey('new_val'), isFalse);
      expect(currentMap['nested'].containsKey('val'), isFalse);
    });

    group('Deep Immutability', () {
      late EffectiveRuntimeConfigurationSnapshot snapshot;
      late Map<String, dynamic> sourceConfig;

      setUp(() {
        sourceConfig = {
          'settings': {
            'nested': {
              'value': 'original',
            },
            'items': [
              {'name': 'A'}
            ]
          }
        };

        final moduleConfig = SolutionModuleConfiguration(
          reference: const MarketplaceModuleReference(
            marketplaceModuleId: 'm4',
            moduleCode: 'MODULE_IMMUTABLE',
            exactPublishedVersion: '1.0.0',
            blueprintConfiguration: {},
          ),
          configuration: sourceConfig,
        );

        final solution = CustomerSolution(
          id: 's4',
          tenantId: 't4',
          sourceSolutionDefinitionId: 'sd4',
          exactSolutionDefinitionVersion: '1.0.0',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          moduleConfigurations: [moduleConfig],
        );

        snapshot = resolver.resolve(solution);
      });

      test('Test A - Nested map mutation fails', () {
        final resolved = snapshot.resolvedConfiguration['MODULE_IMMUTABLE']!;
        expect(
          () => resolved['settings']['nested']['value'] = 'mutated',
          throwsUnsupportedError,
        );
      });

      test('Test B - Nested list mutation fails', () {
        final resolved = snapshot.resolvedConfiguration['MODULE_IMMUTABLE']!;
        expect(
          () => (resolved['settings']['items'] as List).add({'name': 'B'}),
          throwsUnsupportedError,
        );
      });

      test('Test C - Deep nested mutation (Map -> List -> Map) fails', () {
        final resolved = snapshot.resolvedConfiguration['MODULE_IMMUTABLE']!;
        expect(
          () => resolved['settings']['items'][0]['name'] = 'B',
          throwsUnsupportedError,
        );
      });

      test('Test D - Source isolation ensures original mutation does not affect snapshot', () {
        // Mutate original source
        sourceConfig['settings']['nested']['value'] = 'mutated';
        (sourceConfig['settings']['items'] as List).add({'name': 'B'});

        // Verify snapshot remains unchanged
        final resolved = snapshot.resolvedConfiguration['MODULE_IMMUTABLE']!;
        expect(resolved['settings']['nested']['value'], 'original');
        expect((resolved['settings']['items'] as List).length, 1);
      });
    });
  });
}
