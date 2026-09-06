import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coreaxis/features/marketplace/application/marketplace_providers.dart';
import 'package:coreaxis/features/marketplace/domain/models/marketplace_module.dart';
import 'package:coreaxis/features/marketplace/domain/models/marketplace_module_release.dart';
import 'package:coreaxis/features/solution_blueprint/application/blueprint_providers.dart';
import 'package:coreaxis/features/solution_blueprint/domain/models/marketplace_module_reference.dart';
import 'package:coreaxis/features/solution_blueprint/domain/models/solution_blueprint.dart';
import 'package:coreaxis/features/marketplace/mock/mock_marketplace_repository.dart';
import 'package:coreaxis/features/marketplace/domain/models/marketplace_module_dependency.dart';

void main() {
  group('CA-MKT-004 Blueprint Integration Tests', () {
    test('1. Module Selection and Exact Version Pinning', () async {
      final container = ProviderContainer();
      final marketplaceRepo = container.read(marketplaceRepositoryProvider);
      
      // Inject test modules into marketplace
      await marketplaceRepo.addTestModule(MarketplaceModule(
        id: 'customer-v1',
        moduleKey: 'CRM-CUST',
        moduleCode: 'customer',
        publisherName: 'CoreAxis',
        releases: [
          MarketplaceModuleRelease(
            version: '1.0.0',
            publishedAt: DateTime.now(),
            releaseNotes: 'Initial',
            name: 'Customer',
            shortDescription: 'Desc',
            description: 'Desc',
            icon: 'icon',
            categoryIds: ['crm'],
            tags: [],
            capabilities: [],
            features: [],
            screens: [],
            screenshots: [],
            minCoreAxisVersion: '1.0.0',
            dependencies: [],
          ),
          MarketplaceModuleRelease(
            version: '1.1.0',
            publishedAt: DateTime.now(),
            releaseNotes: 'Update',
            name: 'Customer 1.1',
            shortDescription: 'Desc',
            description: 'Desc',
            icon: 'icon',
            categoryIds: ['crm'],
            tags: [],
            capabilities: [],
            features: [],
            screens: [],
            screenshots: [],
            minCoreAxisVersion: '1.0.0',
            dependencies: [],
          )
        ],
        draft: null,
      ));

      final blueprintRepo = container.read(mockBlueprintRepositoryProvider);
      final blueprint = await blueprintRepo.createBlueprint('Test BP', 'Test', 'Desc');

      await container.read(blueprintEditorControllerProvider.notifier).loadBlueprint(blueprint.id);
      
      // Add module at v1.0.0 (pinning)
      await container.read(blueprintEditorControllerProvider.notifier).addModuleReference('customer-v1', 'customer', '1.0.0');
      
      final state = container.read(blueprintEditorControllerProvider);
      expect(state.blueprint!.moduleReferences.length, 1);
      
      final ref = state.blueprint!.moduleReferences.first;
      expect(ref.marketplaceModuleId, 'customer-v1');
      expect(ref.exactPublishedVersion, '1.0.0'); // Verified exact version pinning
      expect(ref.hasUpdateAvailable, true); // Verified update detection

      container.dispose();
    });

    test('2. Dependency Validation', () async {
      final container = ProviderContainer();
      final marketplaceRepo = container.read(marketplaceRepositoryProvider);
      
      await marketplaceRepo.addTestModule(MarketplaceModule(
        id: 'customer-v1',
        moduleKey: 'CRM-CUST',
        moduleCode: 'customer',
        publisherName: 'CoreAxis',
        releases: [
          MarketplaceModuleRelease(
            version: '1.0.0',
            publishedAt: DateTime.now(),
            releaseNotes: 'Initial',
            name: 'Customer',
            shortDescription: 'Desc',
            description: 'Desc',
            icon: 'icon',
            categoryIds: ['crm'],
            tags: [],
            capabilities: [],
            features: [],
            screens: [],
            screenshots: [],
            minCoreAxisVersion: '1.0.0',
            dependencies: [],
          )
        ],
        draft: null,
      ));

      await marketplaceRepo.addTestModule(MarketplaceModule(
        id: 'sales-order-v1',
        moduleKey: 'SALES-ORD',
        moduleCode: 'sales_order',
        publisherName: 'CoreAxis',
        releases: [
          MarketplaceModuleRelease(
            version: '1.0.0',
            publishedAt: DateTime.now(),
            releaseNotes: 'Initial',
            name: 'Sales Order',
            shortDescription: 'Desc',
            description: 'Desc',
            icon: 'icon',
            categoryIds: ['sales'],
            tags: [],
            capabilities: [],
            features: [],
            screens: [],
            screenshots: [],
            minCoreAxisVersion: '1.0.0',
            dependencies: [
              MarketplaceModuleDependency(
                moduleId: 'customer-v1', 
                moduleCode: 'customer',
                requiredVersion: '^1.0.0',
                isRequired: true,
              )
            ],
          )
        ],
        draft: null,
      ));

      final blueprintRepo = container.read(mockBlueprintRepositoryProvider);
      final blueprint = await blueprintRepo.createBlueprint('Test BP 2', 'Test', 'Desc');

      await container.read(blueprintEditorControllerProvider.notifier).loadBlueprint(blueprint.id);
      
      // Add sales order which REQUIRES customer,      // Add sales-order (requires customer)
      await container.read(blueprintEditorControllerProvider.notifier).addModuleReference('sales-order-v1', 'sales_order', '1.0.0');
      final state = container.read(blueprintEditorControllerProvider);
      
      // Should fail validation because customer-v1 is missing
      expect(state.blueprint!.validationResult!.isValid, false);
      expect(state.blueprint!.validationResult!.errors.any((e) => e.contains('missing from the Blueprint')), true);
      
      // Now add customer
      await container.read(blueprintEditorControllerProvider.notifier).addModuleReference('customer-v1', 'customer', '1.0.0');
      final state2 = container.read(blueprintEditorControllerProvider);
      
      // Should pass validation
      print('Validation errors: ${state2.blueprint!.validationResult!.errors}');
      expect(state2.blueprint!.validationResult!.isValid, true);
    });
  });
}
