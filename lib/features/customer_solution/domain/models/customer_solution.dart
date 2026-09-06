import 'dart:convert';
import 'package:coreaxis/features/solution_management/domain/models/solution_module_configuration.dart';
import 'customer_solution_lifecycle.dart';
import 'effective_runtime_configuration_snapshot.dart';

class CustomerSolution {
  final String id;
  final String tenantId;
  final String sourceSolutionDefinitionId;
  final String exactSolutionDefinitionVersion;
  final List<SolutionModuleConfiguration> moduleConfigurations;
  final CustomerSolutionLifecycle lifecycleState;
  final EffectiveRuntimeConfigurationSnapshot? effectiveConfigurationSnapshot;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerSolution({
    required this.id,
    required this.tenantId,
    required this.sourceSolutionDefinitionId,
    required this.exactSolutionDefinitionVersion,
    this.moduleConfigurations = const [],
    this.lifecycleState = CustomerSolutionLifecycle.provisioning,
    this.effectiveConfigurationSnapshot,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Ensures a deep copy is made of all nested configurations to guarantee immutability.
  static List<SolutionModuleConfiguration> deepCopyModules(List<SolutionModuleConfiguration> modules) {
    return modules.map((m) {
      // Deep copy configuration map using JSON encode/decode
      final copiedConfig = m.configuration.isNotEmpty 
          ? jsonDecode(jsonEncode(m.configuration)) as Map<String, dynamic>
          : <String, dynamic>{};
          
      // Deep copy blueprint configuration in reference
      final copiedRefConfig = m.reference.blueprintConfiguration.isNotEmpty
          ? jsonDecode(jsonEncode(m.reference.blueprintConfiguration)) as Map<String, dynamic>
          : <String, dynamic>{};
          
      return m.copyWith(
        configuration: copiedConfig,
        reference: m.reference.copyWith(
          blueprintConfiguration: copiedRefConfig,
        )
      );
    }).toList();
  }

  CustomerSolution copyWith({
    String? id,
    String? tenantId,
    String? sourceSolutionDefinitionId,
    String? exactSolutionDefinitionVersion,
    List<SolutionModuleConfiguration>? moduleConfigurations,
    CustomerSolutionLifecycle? lifecycleState,
    EffectiveRuntimeConfigurationSnapshot? effectiveConfigurationSnapshot,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerSolution(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      sourceSolutionDefinitionId: sourceSolutionDefinitionId ?? this.sourceSolutionDefinitionId,
      exactSolutionDefinitionVersion: exactSolutionDefinitionVersion ?? this.exactSolutionDefinitionVersion,
      moduleConfigurations: moduleConfigurations ?? this.moduleConfigurations,
      lifecycleState: lifecycleState ?? this.lifecycleState,
      effectiveConfigurationSnapshot: effectiveConfigurationSnapshot ?? this.effectiveConfigurationSnapshot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
