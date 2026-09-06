import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coreaxis/core/utils/version_utils.dart';
import 'package:collection/collection.dart';
import 'package:coreaxis/features/marketplace/application/marketplace_providers.dart';
import 'package:coreaxis/features/solution_blueprint/domain/models/solution_blueprint.dart';
import 'package:coreaxis/features/solution_blueprint/domain/models/marketplace_module_reference.dart';
import 'package:coreaxis/features/solution_blueprint/mock/mock_blueprint_repository.dart';

final mockBlueprintRepositoryProvider = Provider<MockBlueprintRepository>((ref) {
  return MockBlueprintRepository();
});

final blueprintListProvider = FutureProvider<List<SolutionBlueprint>>((ref) async {
  final repo = ref.watch(mockBlueprintRepositoryProvider);
  return repo.getBlueprints();
});

class BlueprintEditorState {
  final SolutionBlueprint? blueprint;
  final bool isLoading;
  final String? error;

  const BlueprintEditorState({
    this.blueprint,
    this.isLoading = false,
    this.error,
  });

  BlueprintEditorState copyWith({
    SolutionBlueprint? blueprint,
    bool? isLoading,
    String? error,
  }) {
    return BlueprintEditorState(
      blueprint: blueprint ?? this.blueprint,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class BlueprintEditorController extends Notifier<BlueprintEditorState> {
  @override
  BlueprintEditorState build() {
    return const BlueprintEditorState();
  }

  Future<void> loadBlueprint(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(mockBlueprintRepositoryProvider);
      final blueprint = await repo.getBlueprintById(id);
      if (blueprint == null) {
        state = state.copyWith(isLoading: false, error: 'Blueprint not found');
        return;
      }
      
      // Perform validation and check for updates upon load
      final validatedBlueprint = await _validateBlueprint(blueprint);
      state = state.copyWith(blueprint: validatedBlueprint, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<SolutionBlueprint> _validateBlueprint(SolutionBlueprint blueprint) async {
    final marketplaceRepo = ref.read(marketplaceRepositoryProvider);
    final modules = await marketplaceRepo.getManagementModules();
    
    final errors = <String>[];
    final warnings = <String>[];
    
    final updatedReferences = <MarketplaceModuleReference>[];
    
    for (final refModule in blueprint.moduleReferences) {
      try {
        final marketplaceModule = modules.firstWhere((m) => m.id == refModule.marketplaceModuleId);
        
        // Check if there is an update
        final latestVersion = marketplaceModule.latestPublishedVersion;
        bool hasUpdate = false;
        if (latestVersion != '0.0.0' && latestVersion != refModule.exactPublishedVersion) {
          hasUpdate = true;
          warnings.add('${marketplaceModule.name} has a newer version ($latestVersion) available.');
        }
        
        // Find the specific release being referenced
        try {
          final release = marketplaceModule.releases.firstWhere((r) => r.version == refModule.exactPublishedVersion);
          
          // Check dependencies
          for (final dep in release.dependencies) {
            final depReference = updatedReferences.firstWhereOrNull((r) => r.marketplaceModuleId == dep.moduleId) ??
                blueprint.moduleReferences.firstWhereOrNull((r) => r.marketplaceModuleId == dep.moduleId);

            if (depReference == null) {
              errors.add('${marketplaceModule.name} (${refModule.exactPublishedVersion}) requires ${dep.moduleCode}, which is missing from the Blueprint.');
            } else {
              // Validate version constraint
              if (!VersionUtils.satisfiesConstraint(depReference.exactPublishedVersion, dep.requiredVersion)) {
                errors.add('${marketplaceModule.name} (${refModule.exactPublishedVersion}) requires ${dep.moduleCode} at ${dep.requiredVersion}, but found ${depReference.exactPublishedVersion}.');
              }
            }
          }
        } catch (_) {
          errors.add('Referenced version ${refModule.exactPublishedVersion} for module ${marketplaceModule.name} does not exist.');
        }
        
        updatedReferences.add(refModule.copyWith(hasUpdateAvailable: hasUpdate));
      } catch (_) {
        errors.add('Module ID ${refModule.marketplaceModuleId} not found in the Marketplace.');
        updatedReferences.add(refModule);
      }
    }
    
    final validationResult = BlueprintValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
    
    return blueprint.copyWith(
      moduleReferences: updatedReferences,
      validationResult: validationResult,
    );
  }

  Future<void> addModuleReference(String moduleId, String moduleCode, String version) async {
    final blueprint = state.blueprint;
    if (blueprint == null) return;
    
    // Check if already exists
    if (blueprint.moduleReferences.any((r) => r.marketplaceModuleId == moduleId)) {
      state = state.copyWith(error: 'Module already added to blueprint');
      return;
    }
    
    final newRef = MarketplaceModuleReference(marketplaceModuleId: moduleId, moduleCode: moduleCode, exactPublishedVersion: version);
    final updatedReferences = List<MarketplaceModuleReference>.from(blueprint.moduleReferences)..add(newRef);
    
    final tempBlueprint = blueprint.copyWith(moduleReferences: updatedReferences);
    final validatedBlueprint = await _validateBlueprint(tempBlueprint);
    
    state = state.copyWith(blueprint: validatedBlueprint, error: null);
  }

  Future<void> removeModuleReference(String moduleId) async {
    final blueprint = state.blueprint;
    if (blueprint == null) return;
    
    final updatedReferences = blueprint.moduleReferences.where((r) => r.marketplaceModuleId != moduleId).toList();
    
    final tempBlueprint = blueprint.copyWith(moduleReferences: updatedReferences);
    final validatedBlueprint = await _validateBlueprint(tempBlueprint);
    
    state = state.copyWith(blueprint: validatedBlueprint, error: null);
  }
  
  Future<void> saveBlueprint() async {
    final blueprint = state.blueprint;
    if (blueprint == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(mockBlueprintRepositoryProvider);
      await repo.updateBlueprint(blueprint);
      ref.invalidate(blueprintListProvider);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final blueprintEditorControllerProvider = NotifierProvider<BlueprintEditorController, BlueprintEditorState>(() {
  return BlueprintEditorController();
});
