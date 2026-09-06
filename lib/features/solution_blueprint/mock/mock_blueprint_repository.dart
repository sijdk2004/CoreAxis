import 'package:coreaxis/features/solution_blueprint/domain/models/solution_blueprint.dart';

class MockBlueprintRepository {
  final List<SolutionBlueprint> _blueprints = [];

  MockBlueprintRepository() {
    _seedData();
  }

  void _seedData() {
    _blueprints.addAll([
      const SolutionBlueprint(
        id: 'bp-1',
        name: 'FurniFlow Standard',
        description: 'Standard furniture manufacturing blueprint.',
        industry: 'Manufacturing',
        state: BlueprintState.published,
        moduleReferences: [],
      ),
      const SolutionBlueprint(
        id: 'bp-2',
        name: 'FurniFlow Lite',
        description: 'Lightweight version for small workshops.',
        industry: 'Manufacturing',
        state: BlueprintState.draft,
        moduleReferences: [],
      ),
    ]);
  }

  Future<List<SolutionBlueprint>> getBlueprints() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_blueprints);
  }

  Future<SolutionBlueprint?> getBlueprintById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _blueprints.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<SolutionBlueprint> createBlueprint(String name, String industry, String description) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newBlueprint = SolutionBlueprint(
      id: 'bp-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      industry: industry,
      description: description,
    );
    _blueprints.add(newBlueprint);
    return newBlueprint;
  }

  Future<void> updateBlueprint(SolutionBlueprint blueprint) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _blueprints.indexWhere((b) => b.id == blueprint.id);
    if (index != -1) {
      _blueprints[index] = blueprint;
    } else {
      throw Exception('Blueprint not found');
    }
  }
}
