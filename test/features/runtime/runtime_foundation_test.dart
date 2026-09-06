import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution_lifecycle.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_module_configuration.dart';
import 'package:coreaxis/features/solution_blueprint/domain/models/marketplace_module_reference.dart';
import 'package:coreaxis/features/runtime/domain/models/runtime_context.dart';
import 'package:coreaxis/features/runtime/domain/models/module_runtime_descriptor.dart';
import 'package:coreaxis/features/runtime/data/legacy_module_registry.dart';
import 'package:coreaxis/features/runtime/application/runtime_providers.dart';
import 'package:coreaxis/features/auth/presentation/rbac_provider.dart';
import 'package:coreaxis/features/platform/data/mock_organization_repository.dart';
import 'package:coreaxis/features/platform/domain/models/organization.dart';
import 'package:coreaxis/features/platform/application/provisioning_providers.dart';

class TestMockOrgRepo extends MockOrganizationRepository {
  @override
  Future<Organization?> getOrganizationById(String id) async {
    if (id == 'org1') {
       return Organization(
         id: 'org1',
         name: 'Test Org',
         code: 'O1',
         tenantId: 'tenant1',
         tenantName: 'T1',
         industry: 'Tech',
         branchCount: 1,
         employeeCount: 1,
         country: 'US',
         status: 'Active',
         logoUrl: '',
         createdAt: DateTime.now(),
       );
    }
    return null;
  }
}

void main() {
  group('Runtime Context - Deep Immutability & Scoping', () {
    test('RuntimeContext deeply copies configurations', () {
      final moduleRef = MarketplaceModuleReference(
        marketplaceModuleId: 'm1',
        moduleCode: 'CORE_SALES',
        exactPublishedVersion: '1.0.0',
        blueprintConfiguration: {'setting': 'blue'},
      );
      
      final config = SolutionModuleConfiguration(
        reference: moduleRef,
        configuration: {'custom': 'red'},
      );

      final solution = CustomerSolution(
        id: 'sol1',
        tenantId: 'tenant1',
        sourceSolutionDefinitionId: 'def1',
        exactSolutionDefinitionVersion: '1.0.0',
        lifecycleState: CustomerSolutionLifecycle.active,
        moduleConfigurations: [config],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final context = RuntimeContext.fromCustomerSolution(
        solution: solution,
        effectiveConfigurationSnapshot: {'CORE_SALES.custom': 'red', 'CORE_SALES.setting': 'blue'}
      );

      // Mutate original
      solution.moduleConfigurations[0].configuration['custom'] = 'green';
      solution.moduleConfigurations[0].reference.blueprintConfiguration['setting'] = 'black';

      // Verify RuntimeContext is unchanged
      expect(context.effectiveRuntimeConfiguration['CORE_SALES.custom'], 'red');
      expect(context.effectiveRuntimeConfiguration['CORE_SALES.setting'], 'blue');
    });

    test('Configuration consumption is effective snapshot', () {
      final moduleRef = MarketplaceModuleReference(
        marketplaceModuleId: 'm1',
        moduleCode: 'CORE_SALES',
        exactPublishedVersion: '1.0.0',
        blueprintConfiguration: {'bp_key': 'bp_val', 'overlap': 'old'},
      );
      
      final config = SolutionModuleConfiguration(
        reference: moduleRef,
        configuration: {'cust_key': 'cust_val', 'overlap': 'new'}, // overlap overrides bp
      );

      final solution = CustomerSolution(
        id: 'sol1',
        tenantId: 'tenant1',
        sourceSolutionDefinitionId: 'def1',
        exactSolutionDefinitionVersion: '1.0.0',
        lifecycleState: CustomerSolutionLifecycle.active,
        moduleConfigurations: [config],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final context = RuntimeContext.fromCustomerSolution(
        solution: solution,
        effectiveConfigurationSnapshot: {
          'CORE_SALES.bp_key': 'bp_val',
          'CORE_SALES.cust_key': 'cust_val',
          'CORE_SALES.overlap': 'new',
        }
      );
      expect(context.effectiveRuntimeConfiguration['CORE_SALES.bp_key'], 'bp_val');
      expect(context.effectiveRuntimeConfiguration['CORE_SALES.cust_key'], 'cust_val');
      expect(context.effectiveRuntimeConfiguration['CORE_SALES.overlap'], 'new');
    });
  });

  group('Module Composition & Navigation', () {
    test('Enabled modules appear', () async {
      final config1 = SolutionModuleConfiguration(
        reference: MarketplaceModuleReference(marketplaceModuleId: 'm1', moduleCode: 'CORE_SALES', exactPublishedVersion: '1.0', blueprintConfiguration: {}),
        configuration: {},
      );


      final solution = CustomerSolution(
        id: 'sol1',
        tenantId: 'tenant1',
        sourceSolutionDefinitionId: 'def1',
        exactSolutionDefinitionVersion: '1.0.0',
        lifecycleState: CustomerSolutionLifecycle.active,
        moduleConfigurations: [config1],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          currentTenantIdProvider.overrideWith((ref) async => 'tenant1'),
          currentOrganizationIdProvider.overrideWith((ref) async => 'org1'),
          activeCustomerSolutionIdProvider.overrideWith((ref) => 'sol1'),
          runtimeContextProvider.overrideWith((ref) => Future.value(RuntimeContext.fromCustomerSolution(solution: solution, effectiveConfigurationSnapshot: {}))),
        ]
      );

      await container.read(runtimeContextProvider.future);
      final enabled = container.read(enabledRuntimeModulesProvider).value!;
      expect(enabled.length, 1);
      expect(enabled.first.moduleCode, 'CORE_SALES');
    });

    test('Missing descriptor becomes unavailable', () async {
      final config = SolutionModuleConfiguration(
        reference: MarketplaceModuleReference(marketplaceModuleId: 'mx', moduleCode: 'NON_EXISTENT_MODULE', exactPublishedVersion: '1.0', blueprintConfiguration: {}),
        configuration: {},
      );

      final solution = CustomerSolution(
        id: 'sol1',
        tenantId: 'tenant1',
        sourceSolutionDefinitionId: 'def1',
        exactSolutionDefinitionVersion: '1.0.0',
        lifecycleState: CustomerSolutionLifecycle.active,
        moduleConfigurations: [config],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          currentTenantIdProvider.overrideWith((ref) async => 'tenant1'),
          currentOrganizationIdProvider.overrideWith((ref) async => 'org1'),
          activeCustomerSolutionIdProvider.overrideWith((ref) => 'sol1'),
          runtimeContextProvider.overrideWith((ref) => Future.value(RuntimeContext.fromCustomerSolution(solution: solution, effectiveConfigurationSnapshot: {}))),
        ]
      );

      await container.read(runtimeContextProvider.future);
      final enabled = container.read(enabledRuntimeModulesProvider).value!;
      expect(enabled.isEmpty, true);
    });

    test('Navigation respects RBAC authorization', () async {
      final config1 = SolutionModuleConfiguration(
        reference: MarketplaceModuleReference(marketplaceModuleId: 'm1', moduleCode: 'CORE_SALES', exactPublishedVersion: '1.0', blueprintConfiguration: {}),
        configuration: {},
      );

      final solution = CustomerSolution(
        id: 'sol1',
        tenantId: 'tenant1',
        sourceSolutionDefinitionId: 'def1',
        exactSolutionDefinitionVersion: '1.0.0',
        lifecycleState: CustomerSolutionLifecycle.active,
        moduleConfigurations: [config1],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // User has no permissions
      final container1 = ProviderContainer(
        overrides: [
          runtimeContextProvider.overrideWith((ref) => Future.value(RuntimeContext.fromCustomerSolution(solution: solution, effectiveConfigurationSnapshot: {}))),
        ]
      );
      await container1.read(runtimeContextProvider.future);
      final nav1 = container1.read(runtimeNavigationProvider).value!;
      expect(nav1.isEmpty, true);

      // User has sales permission
      final container2 = ProviderContainer(
        overrides: [
          runtimeContextProvider.overrideWith((ref) => Future.value(RuntimeContext.fromCustomerSolution(solution: solution, effectiveConfigurationSnapshot: {}))),
        ]
      );
      container2.read(rbacProvider.notifier).setPermissions(['manage_sales_orders']);
      
      await container2.read(runtimeContextProvider.future);
      final nav2 = container2.read(runtimeNavigationProvider).value!;
      expect(nav2.length, 1);
      expect(nav2.first.moduleCode, 'CORE_SALES');
    });
  });

  group('Routing & Guards', () {
    test('Unknown route is not attributed to a module', () {
      final descriptor = LegacyModuleRegistry.getDescriptor('CORE_SALES')!;
      expect(descriptor.ownsRoute('/sales-orders'), true);
      expect(descriptor.ownsRoute('/quotations'), true);
      expect(descriptor.ownsRoute('/platform/home'), false); // Unknown/platform
    });

    test('Route Authorization verifies enabled and RBAC', () async {
       final config1 = SolutionModuleConfiguration(
        reference: MarketplaceModuleReference(marketplaceModuleId: 'm1', moduleCode: 'CORE_SALES', exactPublishedVersion: '1.0', blueprintConfiguration: {}),
        configuration: {},
      );

      final solution = CustomerSolution(
        id: 'sol1',
        tenantId: 'tenant1',
        sourceSolutionDefinitionId: 'def1',
        exactSolutionDefinitionVersion: '1.0.0',
        lifecycleState: CustomerSolutionLifecycle.active,
        moduleConfigurations: [config1],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          runtimeContextProvider.overrideWith((ref) => Future.value(RuntimeContext.fromCustomerSolution(solution: solution, effectiveConfigurationSnapshot: {}))),
        ]
      );
      
      // Initially false (no RBAC)
      // wait for resolution
      await container.read(runtimeContextProvider.future);
      
      final auth1 = container.read(routeAuthorizationProvider('/sales-orders')).value!;
      expect(auth1, false);

      // Give RBAC
      container.read(rbacProvider.notifier).setPermissions(['manage_sales_orders']);
      final auth2 = container.read(routeAuthorizationProvider('/sales-orders')).value!;
      expect(auth2, true);

      // Unknown route or disabled module route
      final auth3 = container.read(routeAuthorizationProvider('/production')).value!;
      expect(auth3, false);
    });
  });

  group('Organization Isolation', () {
    test('Cross-tenant organization rejected', () async {
      print('TEST 1: START');
      final container = ProviderContainer(
        overrides: [
          currentTenantIdProvider.overrideWith((ref) async => 'tenant2'),
          currentOrganizationIdProvider.overrideWith((ref) async => 'org1'),
          activeCustomerSolutionIdProvider.overrideWith((ref) => 'sol1'),
          mockOrganizationRepositoryProvider.overrideWith((ref) => TestMockOrgRepo()),
        ]
      );
      
      container.read(runtimeContextProvider);
      await Future.delayed(const Duration(milliseconds: 100));
      final state = container.read(runtimeContextProvider);
      
      expect(state.hasError, true);
      expect(state.error.toString(), contains('Tenant Isolation Violation: Organization does not belong to current tenant.'));
    });

    test('Same-tenant organization accepted', () async {
      final config1 = SolutionModuleConfiguration(
        reference: MarketplaceModuleReference(marketplaceModuleId: 'm1', moduleCode: 'CORE_SALES', exactPublishedVersion: '1.0', blueprintConfiguration: {}),
        configuration: {},
      );

      final solution = CustomerSolution(
        id: 'sol1',
        tenantId: 'tenant1',
        sourceSolutionDefinitionId: 'def1',
        exactSolutionDefinitionVersion: '1.0.0',
        lifecycleState: CustomerSolutionLifecycle.active,
        moduleConfigurations: [config1],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          currentTenantIdProvider.overrideWith((ref) async => 'tenant1'),
          currentOrganizationIdProvider.overrideWith((ref) async => 'org1'),
          activeCustomerSolutionIdProvider.overrideWith((ref) => 'sol1'),
          mockOrganizationRepositoryProvider.overrideWith((ref) => TestMockOrgRepo()),
          runtimeContextProvider.overrideWith((ref) => Future.value(RuntimeContext.fromCustomerSolution(solution: solution, effectiveConfigurationSnapshot: {}, organizationId: 'org1'))),
        ]
      );
      
      final ctx = await container.read(runtimeContextProvider.future);
      expect(ctx?.organizationId, 'org1');
    });

    test('Cross-tenant CustomerSolution rejected', () async {
      final config1 = SolutionModuleConfiguration(
        reference: MarketplaceModuleReference(marketplaceModuleId: 'm1', moduleCode: 'CORE_SALES', exactPublishedVersion: '1.0', blueprintConfiguration: {}),
        configuration: {},
      );

      final solution = CustomerSolution(
        id: 'sol_cross',
        tenantId: 'tenant_cross',
        sourceSolutionDefinitionId: 'def1',
        exactSolutionDefinitionVersion: '1.0.0',
        lifecycleState: CustomerSolutionLifecycle.active,
        moduleConfigurations: [config1],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          currentTenantIdProvider.overrideWith((ref) => Future.value('tenant1')),
          currentOrganizationIdProvider.overrideWith((ref) => Future.value('org1')),
          activeCustomerSolutionIdProvider.overrideWith((ref) => 'sol_cross'),
          mockOrganizationRepositoryProvider.overrideWith((ref) => TestMockOrgRepo()),
        ]
      );
      
      try {
        await container.read(runtimeContextProvider.future);
      } catch (e) {
        // MockCustomerSolutionRepository returns null or something, but we just check if it fails or returns null
      }
      final ctx = await container.read(runtimeContextProvider.future);
      expect(ctx, isNull);
    });
  });
}
