import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coreaxis/features/marketplace/domain/models/marketplace_module.dart';
import 'package:coreaxis/features/marketplace/domain/models/marketplace_module_draft.dart';
import 'package:coreaxis/features/marketplace/domain/models/marketplace_module_release.dart';
import 'package:coreaxis/features/marketplace/domain/models/marketplace_module_visibility.dart';
import 'package:coreaxis/features/marketplace/domain/models/marketplace_module_lifecycle_state.dart';
import 'package:coreaxis/features/marketplace/mock/mock_marketplace_repository.dart';
import 'package:coreaxis/features/marketplace/application/marketplace_providers.dart';
import 'package:coreaxis/features/marketplace/application/marketplace_publishing_providers.dart';

void main() {
  group('CA-MKT-003 Marketplace Publishing & Package Lifecycle Tests', () {
    late MockMarketplaceRepository repo;
    late ProviderContainer container;

    setUp(() {
      repo = MockMarketplaceRepository();
      container = ProviderContainer(
        overrides: [
          marketplaceRepositoryProvider.overrideWithValue(repo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('1-2. Create draft and Save draft', () async {
      final draft = MarketplaceModuleDraft(
        name: 'Test Module',
        version: '1.0.0',
        shortDescription: 'Short',
        description: 'Long description',
        icon: 'box',
        state: MarketplaceDraftState.drafting,
      );

      await container.read(marketplacePublishingControllerProvider.notifier).createModule(draft);

      final modules = await repo.getManagementModules();
      final created = modules.firstWhere((m) => m.draft?.name == 'Test Module');

      expect(created, isNotNull);
      expect(created.visibility, MarketplaceModuleVisibility.unpublished);
      expect(created.releases, isEmpty);
      expect(created.draft?.name, 'Test Module');
      expect(created.draft?.version, '1.0.0');
    });

    test('3-5. Validate valid draft, invalid draft, and warnings', () async {
      final draft = MarketplaceModuleDraft(
        name: 'Test Valid Module',
        version: '1.0.0',
        shortDescription: '', // Empty to trigger warning
        description: 'Long desc',
        icon: '', // Empty to trigger warning
        state: MarketplaceDraftState.drafting,
      );

      await container.read(marketplacePublishingControllerProvider.notifier).createModule(draft);
      final modules = await repo.getManagementModules();
      final moduleId = modules.firstWhere((m) => m.draft?.name == 'Test Valid Module').id;

      // Validate
      await container.read(marketplacePublishingControllerProvider.notifier).validateDraft(moduleId);
      
      final state = container.read(marketplacePublishingControllerProvider);
      expect(state.validationResult, isNotNull);
      print('IS_VALID: ${state.validationResult!.isValid}, ERRORS: ${state.validationResult!.errors}');
      expect(state.validationResult!.isValid, true);
      // Warning for missing screenshots and release notes
      expect(state.validationResult!.warnings.isNotEmpty, true);

      // Now create an invalid draft (invalid version)
      final invalidDraft = MarketplaceModuleDraft(
        name: 'Test Invalid Module',
        version: 'invalid',
        shortDescription: '',
        description: '',
        icon: 'box',
        state: MarketplaceDraftState.drafting,
      );
      
      await container.read(marketplacePublishingControllerProvider.notifier).createModule(invalidDraft);
      final modules2 = await repo.getManagementModules();
      final invalidModuleId = modules2.firstWhere((m) => m.draft?.name == 'Test Invalid Module').id;

      await container.read(marketplacePublishingControllerProvider.notifier).validateDraft(invalidModuleId);
      final state2 = container.read(marketplacePublishingControllerProvider);
      expect(state2.validationResult!.isValid, false);
      expect(state2.validationResult!.errors.any((e) => e.contains('Invalid semantic version')), true);
    });

    test('6-8. Publish valid draft, Published release creation, and immutability', () async {
      final draft = MarketplaceModuleDraft(
        name: 'Test Publish Module',
        version: '1.0.0',
        shortDescription: 'Short',
        description: 'Long desc',
        icon: 'box',
        state: MarketplaceDraftState.drafting,
      );

      await container.read(marketplacePublishingControllerProvider.notifier).createModule(draft);
      var modules = await repo.getManagementModules();
      final moduleId = modules.firstWhere((m) => m.draft?.name == 'Test Publish Module').id;

      await container.read(marketplacePublishingControllerProvider.notifier).validateDraft(moduleId);
      await container.read(marketplacePublishingControllerProvider.notifier).publishDraft(moduleId);

      modules = await repo.getManagementModules();
      final publishedModule = modules.firstWhere((m) => m.id == moduleId);

      expect(publishedModule.visibility, MarketplaceModuleVisibility.published);
      expect(publishedModule.draft, isNull);
      expect(publishedModule.releases.length, 1);
      expect(publishedModule.releases.first.version, '1.0.0');

      // Test Immutability
      expect(() => publishedModule.releases.add(MarketplaceModuleRelease(
        version: '2.0.0',
        publishedAt: DateTime.now(),
        releaseNotes: '',
        name: '',
        shortDescription: '',
        description: '',
        icon: ''
      )), throwsUnsupportedError);
    });

    test('9-11. Create new version draft, Version must exceed latest, Preserve history', () async {
      final draft = MarketplaceModuleDraft(
        name: 'Version Test Module',
        version: '1.0.0',
        shortDescription: 'Short',
        description: 'Long',
        icon: 'box',
        state: MarketplaceDraftState.drafting,
      );

      await container.read(marketplacePublishingControllerProvider.notifier).createModule(draft);
      var modules = await repo.getManagementModules();
      final moduleId = modules.firstWhere((m) => m.draft?.name == 'Version Test Module').id;

      await container.read(marketplacePublishingControllerProvider.notifier).validateDraft(moduleId);
      await container.read(marketplacePublishingControllerProvider.notifier).publishDraft(moduleId);

      // Create new version draft
      await container.read(marketplacePublishingControllerProvider.notifier).createNewVersionDraft(moduleId);
      modules = await repo.getManagementModules();
      var moduleWithDraft = modules.firstWhere((m) => m.id == moduleId);
      
      expect(moduleWithDraft.draft, isNotNull);
      expect(moduleWithDraft.draft!.version, '1.0.1'); // Assuming utility increments patch
      expect(moduleWithDraft.releases.length, 1); // History preserved

      // Try updating to an older version and validate
      await container.read(marketplacePublishingControllerProvider.notifier).updateDraft(
        moduleId,
        moduleWithDraft.draft!.copyWith(version: '0.9.0'),
      );
      
      await container.read(marketplacePublishingControllerProvider.notifier).validateDraft(moduleId);
      final state = container.read(marketplacePublishingControllerProvider);
      
      expect(state.validationResult!.isValid, false);
      expect(state.validationResult!.errors.any((e) => e.contains('must be strictly greater')), true);
    });

    test('12-15. Deprecate, Retire, and Installation semantics', () async {
      // Find an existing mock module that is published
      var modules = await repo.getManagementModules();
      final moduleId = modules.firstWhere((m) => m.visibility == MarketplaceModuleVisibility.published).id;

      // Deprecate
      await container.read(marketplacePublishingControllerProvider.notifier).deprecateModule(moduleId);
      modules = await repo.getManagementModules();
      expect(modules.firstWhere((m) => m.id == moduleId).visibility, MarketplaceModuleVisibility.deprecated);
      
      // Retire
      await container.read(marketplacePublishingControllerProvider.notifier).retireModule(moduleId);
      modules = await repo.getManagementModules();
      final retiredModule = modules.firstWhere((m) => m.id == moduleId);
      expect(retiredModule.visibility, MarketplaceModuleVisibility.retired);
      
      // Ensure existing installation remains intact (lifecycleState is not nullified)
      expect(retiredModule.lifecycleState, isNotNull);

      // Cannot install retired modules
      expect(() => repo.installModule(moduleId), throwsException);
    });

    test('17. Repository persistence across provider rebuild', () async {
       final draft = MarketplaceModuleDraft(
        name: 'Persistence Test',
        version: '1.0.0',
        shortDescription: 'Short',
        description: 'Long',
        icon: 'box',
        state: MarketplaceDraftState.drafting,
      );

      await container.read(marketplacePublishingControllerProvider.notifier).createModule(draft);
      
      // Invalidate provider
      container.invalidate(marketplacePublishingControllerProvider);
      
      // Draft should still exist
      final modules = await repo.getManagementModules();
      expect(modules.any((m) => m.draft?.name == 'Persistence Test'), true);
    });

    test('18-19. Explorer hides draft and retired modules', () async {
      final draft = MarketplaceModuleDraft(
        name: 'Explorer Draft',
        version: '1.0.0',
        shortDescription: 'Short',
        description: 'Long',
        icon: 'box',
        state: MarketplaceDraftState.drafting,
      );

      await container.read(marketplacePublishingControllerProvider.notifier).createModule(draft);
      
      // Get marketplace modules (explorer view)
      final explorerModules = await repo.filterModules();
      
      // Should not contain the drafted module
      expect(explorerModules.any((m) => m.draft?.name == 'Explorer Draft'), false);
      
      // Should not contain retired modules
      expect(explorerModules.any((m) => m.visibility == MarketplaceModuleVisibility.retired), false);
    });
  });
}
