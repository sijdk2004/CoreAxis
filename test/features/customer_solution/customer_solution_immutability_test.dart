import 'package:flutter_test/flutter_test.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution_lifecycle.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_definition.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_module_configuration.dart';
import 'package:coreaxis/features/solution_blueprint/domain/models/marketplace_module_reference.dart';

void main() {
  group('CA-MKT-007 Customer Solution Immutability Tests', () {
    test('CustomerSolution deep copies module configurations from SolutionDefinition', () {
      // 1. Setup source Solution Definition
      final originalRef = MarketplaceModuleReference(
        marketplaceModuleId: 'm1',
        moduleCode: 'SALES_CORE',
        exactPublishedVersion: '1.0.0',
        blueprintConfiguration: {'timeout': 30, 'nested': {'flag': true}},
      );
      
      final originalModConfig = SolutionModuleConfiguration(
        reference: originalRef,
        configuration: {'tenantSetting': 'enabled', 'list': [1, 2, 3]},
      );
      
      final sourceDefinition = SolutionDefinition(
        id: 'sd-1',
        name: 'Test SD',
        sourceBlueprintId: 'bp-1',
        state: SolutionDefinitionState.published,
        moduleConfigurations: [originalModConfig],
      );
      
      // 2. Provision Customer Solution
      final customerSolution = CustomerSolution(
        id: 'cs-1',
        tenantId: 't-1',
        sourceSolutionDefinitionId: sourceDefinition.id,
        exactSolutionDefinitionVersion: '1.0.0',
        moduleConfigurations: CustomerSolution.deepCopyModules(sourceDefinition.moduleConfigurations),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // 3. Verify identical initial state
      expect(customerSolution.moduleConfigurations.length, 1);
      final provisionedConfig = customerSolution.moduleConfigurations[0];
      
      expect(provisionedConfig.configuration['tenantSetting'], 'enabled');
      expect(provisionedConfig.reference.blueprintConfiguration['timeout'], 30);
      
      // 4. Mutate the provisioned configuration
      provisionedConfig.configuration['tenantSetting'] = 'disabled';
      (provisionedConfig.configuration['list'] as List).add(4);
      (provisionedConfig.reference.blueprintConfiguration['nested'] as Map)['flag'] = false;
      
      // 5. Verify mutation applied to CustomerSolution
      expect(customerSolution.moduleConfigurations[0].configuration['tenantSetting'], 'disabled');
      expect((customerSolution.moduleConfigurations[0].configuration['list'] as List).length, 4);
      expect((customerSolution.moduleConfigurations[0].reference.blueprintConfiguration['nested'] as Map)['flag'], false);
      
      // 6. Verify source SolutionDefinition is untouched (Deep Immutability Check)
      final sourceConfig = sourceDefinition.moduleConfigurations[0];
      expect(sourceConfig.configuration['tenantSetting'], 'enabled');
      expect((sourceConfig.configuration['list'] as List).length, 3);
      expect((sourceConfig.reference.blueprintConfiguration['nested'] as Map)['flag'], true);
    });
  });
}
