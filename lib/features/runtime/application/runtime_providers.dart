import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/local_storage/secure_storage_service.dart';
import '../../../core/network/providers/network_providers.dart';
import '../../customer_solution/domain/models/customer_solution.dart';
import '../../customer_solution/domain/models/customer_solution_lifecycle.dart';
import '../../customer_solution/application/customer_solution_providers.dart';
import '../../auth/presentation/rbac_provider.dart';
import '../domain/models/runtime_context.dart';
import '../domain/models/module_runtime_descriptor.dart';
import '../data/legacy_module_registry.dart';
import '../../platform/application/provisioning_providers.dart';

// --- Authoritative Platform Context Dependencies ---
// The runtime must consume authoritative platform context rather than reinventing it.
// In this mock architecture, we derive current tenant from SecureStorage.
final currentTenantIdProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  final tenantId = await storage.getTenantId();
  return tenantId;
});

final currentOrganizationIdProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  return await storage.getOrganizationId();
});

// For MVP, we mock the selection of the active CustomerSolution
// In reality, this would come from a "Select Solution" UI.
final activeCustomerSolutionIdProvider = Provider<String?>((ref) => 'sol_101'); // Hardcoded mock selection

// --- Runtime Snapshot Provider ---
// Provides the deeply immutable snapshot of the selected CustomerSolution.
final runtimeContextProvider = FutureProvider<RuntimeContext?>((ref) async {
  final tenantId = await ref.watch(currentTenantIdProvider.future);
  final orgId = await ref.watch(currentOrganizationIdProvider.future);
  final solutionId = ref.watch(activeCustomerSolutionIdProvider);
  
  if (tenantId == null || solutionId == null || orgId == null) return null;
  
  final orgRepo = ref.watch(mockOrganizationRepositoryProvider);
  final organization = await orgRepo.getOrganizationById(orgId);
  
  if (organization == null || organization.tenantId != tenantId) {
    throw Exception('Tenant Isolation Violation: Organization does not belong to current tenant.');
  }

  final repo = ref.watch(mockCustomerSolutionRepositoryProvider);
  
  try {
    final CustomerSolution? solution = await repo.getSolutionById(solutionId);
    if (solution == null) return null;
    
    // Validate Tenant Isolation
    if (solution.tenantId != tenantId) {
      throw Exception('Tenant Isolation Violation: Solution does not belong to current tenant.');
    }
    
    final snapshot = solution.effectiveConfigurationSnapshot;
    if (snapshot == null) {
      throw StateError('Invalid Runtime State: Active CustomerSolution is missing effective configuration snapshot.');
    }
    
    return RuntimeContext.fromCustomerSolution(
      solution: solution,
      organizationId: organization.id,
      effectiveConfigurationSnapshot: snapshot.resolvedConfiguration,
    );
  } catch (e) {
    // If not found or tenant mismatch
    return null;
  }
});

// --- Derived Runtime Providers ---

/// Returns a list of modules that are enabled in the CustomerSolution AND have a valid Runtime Descriptor.
final enabledRuntimeModulesProvider = Provider<AsyncValue<List<ModuleRuntimeDescriptor>>>((ref) {
  return ref.watch(runtimeContextProvider).whenData((context) {
    if (context == null) return [];
    
    final enabledModules = <ModuleRuntimeDescriptor>[];
    
    for (final config in context.moduleConfigurations) {
      // Assuming all modules in the configurations list are enabled.
      final descriptor = LegacyModuleRegistry.getDescriptor(config.reference.moduleCode);
      if (descriptor != null && descriptor.isAvailable) {
        enabledModules.add(descriptor);
      }
    }
    
    return enabledModules;
  });
});

/// Computes the final dynamic sidebar navigation by evaluating RBAC permissions against enabled modules.
final runtimeNavigationProvider = Provider<AsyncValue<List<ModuleRuntimeDescriptor>>>((ref) {
  final rbacState = ref.watch(rbacProvider);
  return ref.watch(enabledRuntimeModulesProvider).whenData((enabledModules) {
    return enabledModules.where((module) {
      // Use the actual existing RBAC API
      return rbacState.hasPermission(module.requiredPermission);
    }).toList();
  });
});

/// Provides the effective runtime configuration snapshot for consumption by modules.
final effectiveConfigurationProvider = Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  return ref.watch(runtimeContextProvider).whenData((context) {
    return context?.effectiveRuntimeConfiguration ?? {};
  });
});

/// Evaluates if the current requested route is allowed based on RuntimeContext and RBAC.
final routeAuthorizationProvider = Provider.family<AsyncValue<bool>, String>((ref, routePath) {
  return ref.watch(enabledRuntimeModulesProvider).whenData((enabledModules) {
    final rbacState = ref.watch(rbacProvider);
    
    // Find the module that owns this route
    ModuleRuntimeDescriptor? owningModule;
    for (final module in enabledModules) {
      if (module.ownsRoute(routePath)) {
        owningModule = module;
        break;
      }
    }
    
    if (owningModule == null) {
      // If the route belongs to a runtime module that isn't enabled/available, reject it.
      // If it belongs to a completely unknown module but is prefixed as a runtime route, 
      // we reject it by default in the router guard.
      return false;
    }
    
    // Final RBAC check using existing Platform Core RBAC API
    return rbacState.hasPermission(owningModule.requiredPermission);
  });
});
