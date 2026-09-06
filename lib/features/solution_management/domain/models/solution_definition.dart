import 'package:coreaxis/features/solution_management/domain/models/solution_module_configuration.dart';

enum SolutionDefinitionState {
  draft,
  design,
  configuration,
  validation,
  preview,
  published,
  maintenance,
  archived,
}

class SolutionDefinition {
  final String id;
  final String name;
  final String description;
  final String sourceBlueprintId;
  
  /// The inherited exact-version pinned modules from the Blueprint, wrapped with Solution-specific configuration.
  final List<SolutionModuleConfiguration> moduleConfigurations;

  /// Branding and navigation overrides.
  final Map<String, dynamic> solutionConfiguration;

  final SolutionDefinitionState state;

  const SolutionDefinition({
    required this.id,
    required this.name,
    required this.sourceBlueprintId,
    this.description = '',
    this.moduleConfigurations = const [],
    this.solutionConfiguration = const {},
    this.state = SolutionDefinitionState.draft,
  });

  SolutionDefinition copyWith({
    String? id,
    String? name,
    String? description,
    String? sourceBlueprintId,
    List<SolutionModuleConfiguration>? moduleConfigurations,
    Map<String, dynamic>? solutionConfiguration,
    SolutionDefinitionState? state,
  }) {
    return SolutionDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sourceBlueprintId: sourceBlueprintId ?? this.sourceBlueprintId,
      moduleConfigurations: moduleConfigurations ?? this.moduleConfigurations,
      solutionConfiguration: solutionConfiguration ?? this.solutionConfiguration,
      state: state ?? this.state,
    );
  }
}

