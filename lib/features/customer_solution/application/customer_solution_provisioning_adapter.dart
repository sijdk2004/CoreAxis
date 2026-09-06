import 'package:coreaxis/features/platform/domain/contracts/provisioning_boundaries.dart';
import 'package:coreaxis/features/customer_solution/data/mock_customer_solution_repository.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution_lifecycle.dart';
import 'package:coreaxis/features/customer_solution/domain/services/customer_solution_configuration_resolver.dart';

class CustomerSolutionProvisioningAdapter implements ICustomerSolutionProvisioningAdapter {
  final MockCustomerSolutionRepository _repository;

  CustomerSolutionProvisioningAdapter(this._repository);

  @override
  Future<dynamic> createCustomerSolution({
    required String tenantId,
    required String sourceSolutionDefinitionId,
    required String exactSolutionDefinitionVersion,
    required String provisioningRequestId,
  }) async {
    final hash = provisioningRequestId.hashCode.abs();
    final newId = 'CS-NEW-$hash';
    
    // Idempotency check
    final solutions = await _repository.getSolutionsForTenant(tenantId);
    try {
      return solutions.firstWhere((s) => s.id == newId);
    } catch (_) {
      final newSolution = CustomerSolution(
        id: newId,
        tenantId: tenantId,
        sourceSolutionDefinitionId: sourceSolutionDefinitionId,
        exactSolutionDefinitionVersion: exactSolutionDefinitionVersion,
        lifecycleState: CustomerSolutionLifecycle.provisioning,
        moduleConfigurations: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return await _repository.createSolution(newSolution);
    }
  }

  @override
  Future<void> activateCustomerSolution(String customerSolutionId) async {
    await _repository.updateLifecycle(customerSolutionId, CustomerSolutionLifecycle.active);
  }

  @override
  Future<void> resolveEffectiveConfiguration(String customerSolutionId) async {
    final solution = await _repository.getSolutionById(customerSolutionId);
    if (solution == null) throw Exception('CustomerSolution not found');
    
    final resolver = CustomerSolutionConfigurationResolver();
    final snapshot = resolver.resolve(solution);
    
    final updatedSolution = solution.copyWith(effectiveConfigurationSnapshot: snapshot);
    await _repository.updateSolution(updatedSolution);
  }
}
