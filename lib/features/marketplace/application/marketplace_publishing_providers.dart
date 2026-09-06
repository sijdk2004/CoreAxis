import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/marketplace_module.dart';
import '../domain/models/marketplace_module_draft.dart';
import '../domain/models/marketplace_validation_result.dart';
import 'marketplace_providers.dart';

// --- Management Modules Provider ---
final marketplaceManagementModulesProvider = FutureProvider<List<MarketplaceModule>>((ref) {
  final repo = ref.watch(marketplaceRepositoryProvider);
  return repo.getManagementModules();
});

// --- Publishing Operation State ---
enum MarketplacePublishingOperationState {
  idle,
  saving,
  validating,
  publishing,
  deprecating,
  retiring,
  success,
  failure,
}

class MarketplacePublishingOperation {
  final MarketplacePublishingOperationState state;
  final String? error;
  final MarketplaceValidationResult? validationResult;
  final MarketplaceModule? module;

  const MarketplacePublishingOperation({
    this.state = MarketplacePublishingOperationState.idle,
    this.error,
    this.validationResult,
    this.module,
  });
}

class MarketplacePublishingController extends Notifier<MarketplacePublishingOperation> {
  @override
  MarketplacePublishingOperation build() => const MarketplacePublishingOperation();

  Future<void> createModule(MarketplaceModuleDraft initialDraft) async {
    state = const MarketplacePublishingOperation(state: MarketplacePublishingOperationState.saving);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final newModule = await repo.createModule(initialDraft);
      state = MarketplacePublishingOperation(state: MarketplacePublishingOperationState.success, module: newModule);
      _invalidateAllProviders();
    } catch (e) {
      state = MarketplacePublishingOperation(state: MarketplacePublishingOperationState.failure, error: e.toString());
    }
  }

  Future<void> createNewVersionDraft(String moduleId) async {
    state = const MarketplacePublishingOperation(state: MarketplacePublishingOperationState.saving);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      await repo.createNewVersionDraft(moduleId);
      state = const MarketplacePublishingOperation(state: MarketplacePublishingOperationState.success);
      _invalidateAllProviders();
    } catch (e) {
      state = MarketplacePublishingOperation(state: MarketplacePublishingOperationState.failure, error: e.toString());
    }
  }

  Future<void> updateDraft(String moduleId, MarketplaceModuleDraft draft) async {
    state = const MarketplacePublishingOperation(state: MarketplacePublishingOperationState.saving);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      await repo.updateDraft(moduleId, draft);
      state = const MarketplacePublishingOperation(state: MarketplacePublishingOperationState.success);
      _invalidateAllProviders();
    } catch (e) {
      state = MarketplacePublishingOperation(state: MarketplacePublishingOperationState.failure, error: e.toString());
    }
  }

  Future<void> validateDraft(String moduleId) async {
    state = const MarketplacePublishingOperation(state: MarketplacePublishingOperationState.validating);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final result = await repo.validateDraft(moduleId);
      state = MarketplacePublishingOperation(
        state: MarketplacePublishingOperationState.success, 
        validationResult: result,
      );
      _invalidateAllProviders();
    } catch (e) {
      state = MarketplacePublishingOperation(state: MarketplacePublishingOperationState.failure, error: e.toString());
    }
  }

  Future<void> publishDraft(String moduleId) async {
    state = const MarketplacePublishingOperation(state: MarketplacePublishingOperationState.publishing);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      await repo.publishDraft(moduleId);
      state = const MarketplacePublishingOperation(state: MarketplacePublishingOperationState.success);
      _invalidateAllProviders();
    } catch (e) {
      state = MarketplacePublishingOperation(state: MarketplacePublishingOperationState.failure, error: e.toString());
    }
  }

  Future<void> deprecateModule(String moduleId) async {
    state = const MarketplacePublishingOperation(state: MarketplacePublishingOperationState.deprecating);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      await repo.deprecateModule(moduleId);
      state = const MarketplacePublishingOperation(state: MarketplacePublishingOperationState.success);
      _invalidateAllProviders();
    } catch (e) {
      state = MarketplacePublishingOperation(state: MarketplacePublishingOperationState.failure, error: e.toString());
    }
  }

  Future<void> retireModule(String moduleId) async {
    state = const MarketplacePublishingOperation(state: MarketplacePublishingOperationState.retiring);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      await repo.retireModule(moduleId);
      state = const MarketplacePublishingOperation(state: MarketplacePublishingOperationState.success);
      _invalidateAllProviders();
    } catch (e) {
      state = MarketplacePublishingOperation(state: MarketplacePublishingOperationState.failure, error: e.toString());
    }
  }

  void reset() {
    state = const MarketplacePublishingOperation();
  }

  void _invalidateAllProviders() {
    ref.invalidate(marketplaceManagementModulesProvider);
    ref.invalidate(marketplaceDashboardStatsProvider);
    ref.invalidate(marketplaceFeaturedModulesProvider);
    ref.invalidate(marketplaceLatestModulesProvider);
    ref.invalidate(marketplaceRecommendedModulesProvider);
    ref.invalidate(marketplaceExplorerModulesProvider);
    ref.invalidate(marketplaceModuleDetailsProvider);
  }
}

final marketplacePublishingControllerProvider = NotifierProvider<MarketplacePublishingController, MarketplacePublishingOperation>(() {
  return MarketplacePublishingController();
});
