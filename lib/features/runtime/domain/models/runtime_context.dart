import 'package:coreaxis/features/customer_solution/domain/models/customer_solution.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution_lifecycle.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_module_configuration.dart';
import 'dart:convert';

/// Represents a deep immutable snapshot of the active CustomerSolution at runtime.
/// It provides the explicit boundary between the runtime environment and the underlying
/// mutable domain repository.
class RuntimeContext {
  final String tenantId;
  final String? organizationId;
  final String customerSolutionId;
  final String exactSolutionDefinitionVersion;
  final CustomerSolutionLifecycle lifecycleState;
  final List<SolutionModuleConfiguration> moduleConfigurations;
  final Map<String, dynamic> effectiveRuntimeConfiguration;

  const RuntimeContext({
    required this.tenantId,
    this.organizationId,
    required this.customerSolutionId,
    required this.exactSolutionDefinitionVersion,
    required this.lifecycleState,
    required this.moduleConfigurations,
    required this.effectiveRuntimeConfiguration,
  });

  /// Factory constructor that takes an active [CustomerSolution] and produces a deep
  /// immutable snapshot safe for runtime consumption.
  factory RuntimeContext.fromCustomerSolution({
    required CustomerSolution solution,
    required Map<String, dynamic> effectiveConfigurationSnapshot,
    String? organizationId,
  }) {
    // Perform deep copy of the module configurations
    final copiedModules = CustomerSolution.deepCopyModules(solution.moduleConfigurations);

    return RuntimeContext(
      tenantId: solution.tenantId,
      organizationId: organizationId,
      customerSolutionId: solution.id,
      exactSolutionDefinitionVersion: solution.exactSolutionDefinitionVersion,
      lifecycleState: solution.lifecycleState,
      moduleConfigurations: List.unmodifiable(copiedModules),
      effectiveRuntimeConfiguration: Map.unmodifiable(
        jsonDecode(jsonEncode(effectiveConfigurationSnapshot)) as Map<String, dynamic>,
      ),
    );
  }

  /// Check if a specific module is enabled in this context
  bool isModuleEnabled(String moduleCode) {
    return moduleConfigurations.any((m) => m.reference.moduleCode == moduleCode);
  }
}
