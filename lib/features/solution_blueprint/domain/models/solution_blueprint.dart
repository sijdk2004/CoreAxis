import 'marketplace_module_reference.dart';

enum BlueprintState {
  draft,
  validated,
  published,
  deprecated,
  retired,
}

class BlueprintValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const BlueprintValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });
}

class SolutionBlueprint {
  final String id;
  final String name;
  final String description;
  final String industry;
  
  /// The collection of marketplace modules selected for this Blueprint.
  /// Modifying this list creates a new logical version of the blueprint graph.
  final List<MarketplaceModuleReference> moduleReferences;

  /// Blueprint-level defaults (e.g. language, currency)
  final Map<String, dynamic> configurationDefaults;

  final BlueprintState state;
  final BlueprintValidationResult? validationResult;

  const SolutionBlueprint({
    required this.id,
    required this.name,
    this.description = '',
    this.industry = '',
    this.moduleReferences = const [],
    this.configurationDefaults = const {},
    this.state = BlueprintState.draft,
    this.validationResult,
  });

  SolutionBlueprint copyWith({
    String? id,
    String? name,
    String? description,
    String? industry,
    List<MarketplaceModuleReference>? moduleReferences,
    Map<String, dynamic>? configurationDefaults,
    BlueprintState? state,
    BlueprintValidationResult? validationResult,
  }) {
    return SolutionBlueprint(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      moduleReferences: moduleReferences ?? this.moduleReferences,
      configurationDefaults: configurationDefaults ?? this.configurationDefaults,
      state: state ?? this.state,
      validationResult: validationResult ?? this.validationResult,
    );
  }
}
