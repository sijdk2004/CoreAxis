import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:coreaxis/features/customer_solution/domain/models/customer_solution.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution_lifecycle.dart';
import 'package:coreaxis/features/customer_solution/data/mock_customer_solution_repository.dart';
import 'package:coreaxis/features/customer_solution/application/customer_solution_providers.dart';

import 'package:coreaxis/features/solution_management/domain/models/solution_definition.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_module_configuration.dart';
import 'package:coreaxis/features/solution_management/application/solution_management_providers.dart';

import 'package:coreaxis/features/solution_blueprint/domain/models/solution_blueprint.dart';
import 'package:coreaxis/features/solution_blueprint/domain/models/marketplace_module_reference.dart';

void main() {
  group('CA-MKT-007 Comprehensive Tests', () {
    
    test('Customer Solution creates independent deep copy of configurations (SolutionDefinition & Blueprint Immutability)', () {
      final originalRef = MarketplaceModuleReference(
        marketplaceModuleId: 'm1',
        moduleCode: 'SALES_CORE',
        exactPublishedVersion: '1.0.0',
        blueprintConfiguration: {'timeout': 30, 'nested': {'flag': true}},
      );
      
      final blueprint = SolutionBlueprint(
        id: 'bp-1',
        name: 'Test BP',
        moduleReferences: [originalRef],
      );

      final originalModConfig = SolutionModuleConfiguration(
        reference: blueprint.moduleReferences[0],
        configuration: {'tenantSetting': 'enabled', 'list': [1, 2, 3]},
      );
      
      final sourceDefinition = SolutionDefinition(
        id: 'sd-1',
        name: 'Test SD',
        sourceBlueprintId: blueprint.id,
        state: SolutionDefinitionState.published,
        moduleConfigurations: [originalModConfig],
      );
      
      final customerSolution = CustomerSolution(
        id: 'cs-1',
        tenantId: 't-1',
        sourceSolutionDefinitionId: sourceDefinition.id,
        exactSolutionDefinitionVersion: '1.0.0',
        moduleConfigurations: CustomerSolution.deepCopyModules(sourceDefinition.moduleConfigurations),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Mutate
      final provisionedConfig = customerSolution.moduleConfigurations[0];
      provisionedConfig.configuration['tenantSetting'] = 'disabled';
      (provisionedConfig.configuration['list'] as List).add(4);
      (provisionedConfig.reference.blueprintConfiguration['nested'] as Map)['flag'] = false;
      
      // Verify isolation of SolutionDefinition
      final sourceConfig = sourceDefinition.moduleConfigurations[0];
      expect(sourceConfig.configuration['tenantSetting'], 'enabled');
      expect((sourceConfig.configuration['list'] as List).length, 3);
      expect((sourceConfig.reference.blueprintConfiguration['nested'] as Map)['flag'], true);
      
      // Verify isolation of Blueprint
      final bpConfig = blueprint.moduleReferences[0];
      expect((bpConfig.blueprintConfiguration['nested'] as Map)['flag'], true);
    });

    test('Exact Version Locking and Module Version Traceability', () {
      final customerSolution = CustomerSolution(
        id: 'cs-2',
        tenantId: 't-1',
        sourceSolutionDefinitionId: 'sd-1',
        exactSolutionDefinitionVersion: '1.0.0',
        moduleConfigurations: [
          SolutionModuleConfiguration(
            reference: MarketplaceModuleReference(
              marketplaceModuleId: 'm1',
              moduleCode: 'SALES',
              exactPublishedVersion: '3.0.0',
            ),
          )
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Verify it retains 1.0.0 and 3.0.0
      expect(customerSolution.exactSolutionDefinitionVersion, '1.0.0');
      expect(customerSolution.moduleConfigurations[0].reference.exactPublishedVersion, '3.0.0');
    });

    test('CustomerSolutionLifecycle transitions', () async {
      final repo = MockCustomerSolutionRepository();
      
      final cs = CustomerSolution(
        id: 'cs-3',
        tenantId: 't-1',
        sourceSolutionDefinitionId: 'sd-1',
        exactSolutionDefinitionVersion: '1.0.0',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await repo.createSolution(cs);
      
      // Invalid transition: provisioning -> suspended
      expect(
        () => repo.updateLifecycle('cs-3', CustomerSolutionLifecycle.suspended),
        throwsException,
      );

      // Valid: provisioning -> active
      await repo.updateLifecycle('cs-3', CustomerSolutionLifecycle.active);
      final activeCs = await repo.getSolutionById('cs-3');
      expect(activeCs!.lifecycleState, CustomerSolutionLifecycle.active);

      // Valid: active -> suspended
      await repo.updateLifecycle('cs-3', CustomerSolutionLifecycle.suspended);
      final suspendedCs = await repo.getSolutionById('cs-3');
      expect(suspendedCs!.lifecycleState, CustomerSolutionLifecycle.suspended);

      // Valid: suspended -> active
      await repo.updateLifecycle('cs-3', CustomerSolutionLifecycle.active);
      final reactivatedCs = await repo.getSolutionById('cs-3');
      expect(reactivatedCs!.lifecycleState, CustomerSolutionLifecycle.active);
    });

    test('Multiple Tenants and Tenant Isolation', () async {
      final repo = MockCustomerSolutionRepository();
      
      final csA = CustomerSolution(id: 'cs-A', tenantId: 'tenant-A', sourceSolutionDefinitionId: 'sd-1', exactSolutionDefinitionVersion: '1.0.0', createdAt: DateTime.now(), updatedAt: DateTime.now());
      final csB = CustomerSolution(id: 'cs-B', tenantId: 'tenant-B', sourceSolutionDefinitionId: 'sd-1', exactSolutionDefinitionVersion: '1.0.0', createdAt: DateTime.now(), updatedAt: DateTime.now());
      
      await repo.createSolution(csA);
      await repo.createSolution(csB);
      
      final tenantASolutions = await repo.getSolutionsForTenant('tenant-A');
      expect(tenantASolutions.length, 1);
      expect(tenantASolutions[0].id, 'cs-A');

      final tenantBSolutions = await repo.getSolutionsForTenant('tenant-B');
      expect(tenantBSolutions.length, 1);
      expect(tenantBSolutions[0].id, 'cs-B');
    });

    test('Repository Persistence across provider invalidation', () async {
      final container = ProviderContainer();
      final repo = container.read(mockCustomerSolutionRepositoryProvider);
      
      final cs = CustomerSolution(id: 'cs-repo', tenantId: 't-repo', sourceSolutionDefinitionId: 'sd-1', exactSolutionDefinitionVersion: '1.0.0', createdAt: DateTime.now(), updatedAt: DateTime.now());
      await repo.createSolution(cs);
      
      // Invalidate a derived provider
      container.invalidate(customerSolutionListProvider);
      
      final solutions = await repo.getSolutionsForTenant('t-repo');
      expect(solutions.length, 1);
      expect(solutions[0].id, 'cs-repo');
    });

    test('Published Source Validation (Provisioning fails for non-published Definition)', () async {
      final container = ProviderContainer();
      final defRepo = container.read(mockSolutionDefinitionRepositoryProvider);
      
      // Create a draft definition
      final draftDef = SolutionDefinition(
        id: 'sd-draft',
        name: 'Draft SD',
        sourceBlueprintId: 'bp-1',
        state: SolutionDefinitionState.draft,
      );
      await defRepo.createDefinition(draftDef);

      final controller = container.read(customerSolutionListProvider.notifier);
      
      final cs = CustomerSolution(
        id: 'cs-draft-prov',
        tenantId: 't-1',
        sourceSolutionDefinitionId: 'sd-draft',
        exactSolutionDefinitionVersion: '1.0.0',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await expectLater(
        controller.provisionCustomerSolution(cs),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Only published SolutionDefinitions can be provisioned'))),
      );

      // Now create a published one and provision it
      final pubDef = draftDef.copyWith(id: 'sd-pub', state: SolutionDefinitionState.published);
      await defRepo.createDefinition(pubDef);

      final csValid = cs.copyWith(sourceSolutionDefinitionId: 'sd-pub');
      final provisioned = await controller.provisionCustomerSolution(csValid);
      expect(provisioned.id, csValid.id);
    });

  });
}
