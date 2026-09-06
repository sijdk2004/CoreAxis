import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_definition.dart';
import 'package:coreaxis/features/solution_management/mock/mock_solution_definition_repository.dart';

final mockSolutionDefinitionRepositoryProvider = Provider<MockSolutionDefinitionRepository>((ref) {
  return MockSolutionDefinitionRepository();
});

final solutionDefinitionListProvider = FutureProvider<List<SolutionDefinition>>((ref) async {
  final repo = ref.watch(mockSolutionDefinitionRepositoryProvider);
  return repo.getDefinitions();
});

final solutionDefinitionProvider = FutureProvider.family<SolutionDefinition, String>((ref, id) async {
  final repo = ref.watch(mockSolutionDefinitionRepositoryProvider);
  final definition = await repo.getDefinitionById(id);
  if (definition == null) {
    throw Exception('Solution definition $id not found');
  }
  return definition;
});

class SolutionManagementState {
  final bool isLoading;
  final String? error;

  const SolutionManagementState({
    this.isLoading = false,
    this.error,
  });

  SolutionManagementState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return SolutionManagementState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SolutionManagementController extends Notifier<SolutionManagementState> {
  @override
  SolutionManagementState build() {
    return const SolutionManagementState();
  }

  Future<void> _transitionState(SolutionDefinition definition, SolutionDefinitionState targetState) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (definition.state == SolutionDefinitionState.published) {
        throw Exception('Cannot transition a published Solution Definition.');
      }
      
      final repo = ref.read(mockSolutionDefinitionRepositoryProvider);
      final updatedDefinition = definition.copyWith(state: targetState);
      await repo.updateDefinition(updatedDefinition);
      
      ref.invalidate(solutionDefinitionListProvider);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> transitionToDesign(SolutionDefinition definition) async {
    if (definition.state != SolutionDefinitionState.draft) {
      throw Exception('Can only transition to design from draft.');
    }
    await _transitionState(definition, SolutionDefinitionState.design);
  }

  Future<void> transitionToConfiguration(SolutionDefinition definition) async {
    if (definition.state != SolutionDefinitionState.design && definition.state != SolutionDefinitionState.draft) {
      throw Exception('Can only transition to configuration from draft or design.');
    }
    await _transitionState(definition, SolutionDefinitionState.configuration);
  }

  Future<void> transitionToValidation(SolutionDefinition definition) async {
    if (definition.state != SolutionDefinitionState.configuration) {
      throw Exception('Can only transition to validation from configuration.');
    }
    await _transitionState(definition, SolutionDefinitionState.validation);
  }

  Future<void> transitionToPreview(SolutionDefinition definition) async {
    if (definition.state != SolutionDefinitionState.validation) {
      throw Exception('Can only transition to preview from validation.');
    }
    await _transitionState(definition, SolutionDefinitionState.preview);
  }

  Future<void> publish(SolutionDefinition definition) async {
    if (definition.state != SolutionDefinitionState.preview && definition.state != SolutionDefinitionState.validation) {
      throw Exception('Can only publish from preview or validation.');
    }
    await _transitionState(definition, SolutionDefinitionState.published);
  }
}

final solutionManagementControllerProvider = NotifierProvider<SolutionManagementController, SolutionManagementState>(() {
  return SolutionManagementController();
});
