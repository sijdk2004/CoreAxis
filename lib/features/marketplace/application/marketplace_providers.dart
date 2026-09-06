import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/marketplace_category.dart';
import '../domain/models/marketplace_module.dart';
import '../domain/models/marketplace_module_lifecycle_state.dart';
import '../mock/mock_marketplace_repository.dart';

// --- Repository ---
final marketplaceRepositoryProvider = Provider<MockMarketplaceRepository>((ref) {
  return MockMarketplaceRepository();
});

// --- Dashboard Providers ---
final marketplaceDashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final repo = ref.watch(marketplaceRepositoryProvider);
  return repo.getDashboardStatistics();
});

final marketplaceFeaturedModulesProvider = FutureProvider<List<MarketplaceModule>>((ref) {
  final repo = ref.watch(marketplaceRepositoryProvider);
  return repo.getFeaturedModules();
});

final marketplaceLatestModulesProvider = FutureProvider<List<MarketplaceModule>>((ref) {
  final repo = ref.watch(marketplaceRepositoryProvider);
  return repo.getLatestModules();
});

final marketplaceRecommendedModulesProvider = FutureProvider<List<MarketplaceModule>>((ref) {
  final repo = ref.watch(marketplaceRepositoryProvider);
  return repo.getRecommendedModules();
});

final marketplaceInstalledModulesProvider = FutureProvider<List<MarketplaceModule>>((ref) {
  final repo = ref.watch(marketplaceRepositoryProvider);
  return repo.getInstalledModules();
});

// --- Explorer & Filter Providers ---
final marketplaceCategoriesProvider = FutureProvider<List<MarketplaceCategory>>((ref) {
  final repo = ref.watch(marketplaceRepositoryProvider);
  return repo.getCategories();
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String value) => state = value;
}
final marketplaceSearchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() => SearchQueryNotifier());

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? value) => state = value;
}
final marketplaceSelectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, String?>(() => SelectedCategoryNotifier());

class SelectedStatusNotifier extends Notifier<MarketplaceModuleLifecycleState?> {
  @override
  MarketplaceModuleLifecycleState? build() => null;
  void update(MarketplaceModuleLifecycleState? value) => state = value;
}
final marketplaceSelectedStatusProvider = NotifierProvider<SelectedStatusNotifier, MarketplaceModuleLifecycleState?>(() => SelectedStatusNotifier());

enum MarketplaceViewMode { grid, list }
class ViewModeNotifier extends Notifier<MarketplaceViewMode> {
  @override
  MarketplaceViewMode build() => MarketplaceViewMode.grid;
  void update(MarketplaceViewMode value) => state = value;
}
final marketplaceViewModeProvider = NotifierProvider<ViewModeNotifier, MarketplaceViewMode>(() => ViewModeNotifier());

final marketplaceExplorerModulesProvider = FutureProvider<List<MarketplaceModule>>((ref) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final query = ref.watch(marketplaceSearchQueryProvider);
  final categoryId = ref.watch(marketplaceSelectedCategoryProvider);
  final status = ref.watch(marketplaceSelectedStatusProvider);

  return repo.filterModules(categoryId: categoryId, query: query, status: status);
});

// --- Module Details Provider ---
final marketplaceModuleDetailsProvider = FutureProvider.family<MarketplaceModule?, String>((ref, id) {
  final repo = ref.watch(marketplaceRepositoryProvider);
  return repo.getModuleById(id);
});

// --- Favorites State ---
class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggleFavorite(String moduleId) {
    if (state.contains(moduleId)) {
      state = {...state}..remove(moduleId);
    } else {
      state = {...state, moduleId};
    }
  }

  bool isFavorite(String moduleId) {
    return state.contains(moduleId);
  }
}

final marketplaceFavoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(() {
  return FavoritesNotifier();
});

// --- Lifecycle Operations ---
enum MarketplaceOperationState {
  idle,
  validating,
  installing,
  updating,
  success,
  failure,
}

class MarketplaceOperation {
  final MarketplaceOperationState state;
  final String? error;
  
  const MarketplaceOperation({this.state = MarketplaceOperationState.idle, this.error});
}

class MarketplaceLifecycleController extends Notifier<MarketplaceOperation> {
  @override
  MarketplaceOperation build() => const MarketplaceOperation();

  Future<void> installModule(String moduleId) async {
    state = const MarketplaceOperation(state: MarketplaceOperationState.validating);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      
      // Validation occurs inside installModule in repo
      state = const MarketplaceOperation(state: MarketplaceOperationState.installing);
      await repo.installModule(moduleId);
      
      state = const MarketplaceOperation(state: MarketplaceOperationState.success);
      _invalidateAllProviders();
    } catch (e) {
      state = MarketplaceOperation(state: MarketplaceOperationState.failure, error: e.toString());
    }
  }

  Future<void> updateModule(String moduleId) async {
    state = const MarketplaceOperation(state: MarketplaceOperationState.validating);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      
      state = const MarketplaceOperation(state: MarketplaceOperationState.updating);
      await repo.updateModule(moduleId);
      
      state = const MarketplaceOperation(state: MarketplaceOperationState.success);
      _invalidateAllProviders();
    } catch (e) {
      state = MarketplaceOperation(state: MarketplaceOperationState.failure, error: e.toString());
    }
  }

  void reset() {
    state = const MarketplaceOperation();
  }

  void _invalidateAllProviders() {
    // Invalidate providers so UI refreshes with new module states
    ref.invalidate(marketplaceDashboardStatsProvider);
    ref.invalidate(marketplaceFeaturedModulesProvider);
    ref.invalidate(marketplaceLatestModulesProvider);
    ref.invalidate(marketplaceRecommendedModulesProvider);
    ref.invalidate(marketplaceInstalledModulesProvider);
    ref.invalidate(marketplaceExplorerModulesProvider);
    ref.invalidate(marketplaceModuleDetailsProvider);
  }
}

final marketplaceLifecycleControllerProvider = NotifierProvider<MarketplaceLifecycleController, MarketplaceOperation>(() {
  return MarketplaceLifecycleController();
});
