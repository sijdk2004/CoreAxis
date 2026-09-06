import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution_lifecycle.dart';
import 'package:coreaxis/features/customer_solution/data/mock_customer_solution_repository.dart';
import 'package:coreaxis/features/platform/domain/models/tenant.dart';
import 'package:coreaxis/features/platform/presentation/providers/tenant_provider.dart';
import 'package:coreaxis/features/solution_management/application/solution_management_providers.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_definition.dart';

// The authoritative repository instance
final mockCustomerSolutionRepositoryProvider = Provider<MockCustomerSolutionRepository>((ref) {
  return MockCustomerSolutionRepository();
});

// Mock current tenant context for M7 isolation viewing
class CurrentTenantNotifier extends Notifier<String?> {
  @override
  String? build() {
    // Attempt to default to a tenant if available from the tenant list
    final tenantState = ref.watch(tenantListProvider);
    if (tenantState.allTenants.isNotEmpty) {
      return tenantState.allTenants.first.id;
    }
    return null;
  }
  
  void setTenant(String id) {
    state = id;
  }
}

final currentTenantIdProvider = NotifierProvider<CurrentTenantNotifier, String?>(() {
  return CurrentTenantNotifier();
});

// Ephemeral operation state for provisioning
enum ProvisioningOperationState {
  idle,
  validating,
  provisioning,
  success,
  failure
}

class ProvisioningOperationNotifier extends Notifier<ProvisioningOperationState> {
  String? _error;
  String? get error => _error;

  @override
  ProvisioningOperationState build() {
    return ProvisioningOperationState.idle;
  }

  Future<void> runProvisioning(Future<void> Function() operation) async {
    state = ProvisioningOperationState.validating;
    _error = null;
    
    try {
      state = ProvisioningOperationState.provisioning;
      await operation();
      state = ProvisioningOperationState.success;
    } catch (e) {
      _error = e.toString();
      state = ProvisioningOperationState.failure;
    }
  }
  
  void reset() {
    _error = null;
    state = ProvisioningOperationState.idle;
  }
}

final provisioningOperationProvider = NotifierProvider<ProvisioningOperationNotifier, ProvisioningOperationState>(() {
  return ProvisioningOperationNotifier();
});

// Controller for managing Customer Solutions
class CustomerSolutionListState {
  final List<CustomerSolution> solutions;
  final bool isLoading;
  final String? error;

  CustomerSolutionListState({
    this.solutions = const [],
    this.isLoading = false,
    this.error,
  });
  
  CustomerSolutionListState copyWith({
    List<CustomerSolution>? solutions,
    bool? isLoading,
    String? error,
  }) {
    return CustomerSolutionListState(
      solutions: solutions ?? this.solutions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CustomerSolutionController extends Notifier<CustomerSolutionListState> {
  @override
  CustomerSolutionListState build() {
    Future.microtask(() => loadForCurrentTenant());
    
    // Automatically reload if current tenant changes
    ref.listen(currentTenantIdProvider, (prev, next) {
      if (prev != next) {
        loadForCurrentTenant();
      }
    });
    
    return CustomerSolutionListState();
  }

  Future<void> loadForCurrentTenant() async {
    final tenantId = ref.read(currentTenantIdProvider);
    if (tenantId == null) {
      state = state.copyWith(solutions: [], isLoading: false);
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(mockCustomerSolutionRepositoryProvider);
      final solutions = await repo.getSolutionsForTenant(tenantId);
      state = state.copyWith(solutions: solutions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  Future<CustomerSolution> provisionCustomerSolution(CustomerSolution solution) async {
    final definitionRepo = ref.read(mockSolutionDefinitionRepositoryProvider);
    final sourceDef = await definitionRepo.getDefinitionById(solution.sourceSolutionDefinitionId);
    
    if (sourceDef == null) {
      throw Exception('Source SolutionDefinition not found.');
    }
    if (sourceDef.state != SolutionDefinitionState.published) {
      throw Exception('Only published SolutionDefinitions can be provisioned.');
    }

    final repo = ref.read(mockCustomerSolutionRepositoryProvider);
    final created = await repo.createSolution(solution);
    // Reload if the created solution belongs to the current tenant
    if (created.tenantId == ref.read(currentTenantIdProvider)) {
      await loadForCurrentTenant();
    }
    return created;
  }

  Future<void> activateCustomerSolution(String id) async {
    final repo = ref.read(mockCustomerSolutionRepositoryProvider);
    await repo.updateLifecycle(id, CustomerSolutionLifecycle.active);
    await loadForCurrentTenant();
  }

  Future<void> suspendCustomerSolution(String id) async {
    final repo = ref.read(mockCustomerSolutionRepositoryProvider);
    await repo.updateLifecycle(id, CustomerSolutionLifecycle.suspended);
    await loadForCurrentTenant();
  }

  Future<void> reactivateCustomerSolution(String id) async {
    final repo = ref.read(mockCustomerSolutionRepositoryProvider);
    await repo.updateLifecycle(id, CustomerSolutionLifecycle.active);
    await loadForCurrentTenant();
  }
}

final customerSolutionListProvider = NotifierProvider<CustomerSolutionController, CustomerSolutionListState>(() {
  return CustomerSolutionController();
});

// Single Customer Solution fetcher
final customerSolutionProvider = FutureProvider.family<CustomerSolution?, String>((ref, id) async {
  final repo = ref.read(mockCustomerSolutionRepositoryProvider);
  // Re-fetch when list changes to ensure we have the latest state (e.g., after lifecycle change)
  ref.watch(customerSolutionListProvider);
  return await repo.getSolutionById(id);
});
