import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coreaxis/features/solution_blueprint/application/blueprint_providers.dart';
import 'package:coreaxis/features/solution_management/application/solution_management_providers.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_definition.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_module_configuration.dart';

class ComposerSessionState {
  final SolutionDefinition? definition;
  final bool isLoading;
  final String? error;
  final bool isNew;

  const ComposerSessionState({
    this.definition,
    this.isLoading = false,
    this.error,
    this.isNew = true,
  });

  ComposerSessionState copyWith({
    SolutionDefinition? definition,
    bool? isLoading,
    String? error,
    bool? isNew,
  }) {
    return ComposerSessionState(
      definition: definition ?? this.definition,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isNew: isNew ?? this.isNew,
    );
  }
}

class ComposerSessionController extends Notifier<ComposerSessionState> {
  @override
  ComposerSessionState build() {
    return const ComposerSessionState();
  }

  Future<void> initializeFromBlueprint(String blueprintId) async {
    state = state.copyWith(isLoading: true, error: null, isNew: true);
    try {
      final blueprintRepo = ref.read(mockBlueprintRepositoryProvider);
      final blueprint = await blueprintRepo.getBlueprintById(blueprintId);
      
      if (blueprint == null) {
        state = state.copyWith(isLoading: false, error: 'Blueprint not found');
        return;
      }
      
      // Inherit module configurations via copy and wrap in SolutionModuleConfiguration
      final inheritedModules = blueprint.moduleReferences
          .map((refItem) => SolutionModuleConfiguration(reference: refItem.copyWith()))
          .toList();
      
      final definition = SolutionDefinition(
        id: 'sd-${DateTime.now().millisecondsSinceEpoch}',
        name: '${blueprint.name} Instance',
        sourceBlueprintId: blueprintId,
        moduleConfigurations: inheritedModules,
        solutionConfiguration: Map.from(blueprint.configurationDefaults),
      );
      
      state = state.copyWith(definition: definition, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadExistingDefinition(String definitionId) async {
    state = state.copyWith(isLoading: true, error: null, isNew: false);
    try {
      final repo = ref.read(mockSolutionDefinitionRepositoryProvider);
      final definition = await repo.getDefinitionById(definitionId);
      
      if (definition == null) {
        state = state.copyWith(isLoading: false, error: 'Definition not found');
        return;
      }
      
      if (definition.state == SolutionDefinitionState.published) {
        state = state.copyWith(isLoading: false, error: 'Cannot edit a published definition in Composer.');
        return;
      }
      
      state = state.copyWith(definition: definition, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateName(String name) {
    if (state.definition == null) return;
    state = state.copyWith(definition: state.definition!.copyWith(name: name));
  }

  void updateDescription(String description) {
    if (state.definition == null) return;
    state = state.copyWith(definition: state.definition!.copyWith(description: description));
  }

  void updateConfiguration(String key, dynamic value) {
    if (state.definition == null) return;
    final currentConfig = Map<String, dynamic>.from(state.definition!.solutionConfiguration);
    currentConfig[key] = value;
    state = state.copyWith(definition: state.definition!.copyWith(solutionConfiguration: currentConfig));
  }

  Future<void> saveDefinition() async {
    final definition = state.definition;
    if (definition == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(mockSolutionDefinitionRepositoryProvider);
      if (state.isNew) {
        await repo.createDefinition(definition);
        // Only flip isNew to false after successful creation
        state = state.copyWith(isNew: false);
      } else {
        await repo.updateDefinition(definition);
      }
      
      ref.invalidate(solutionDefinitionListProvider);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final composerSessionControllerProvider = NotifierProvider<ComposerSessionController, ComposerSessionState>(() {
  return ComposerSessionController();
});

