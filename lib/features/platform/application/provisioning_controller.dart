import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coreaxis/features/platform/domain/models/provisioning_request.dart';
import 'package:coreaxis/features/platform/domain/models/provisioning_operation.dart';
import 'package:coreaxis/features/platform/application/provisioning_providers.dart';

class ProvisioningController extends Notifier<AsyncValue<ProvisioningOperation?>> {
  @override
  AsyncValue<ProvisioningOperation?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> startOrResumeProvisioning(ProvisioningRequest request) async {
    final repo = ref.read(mockProvisioningRepositoryProvider);
    
    // Check if idempotency operation already exists
    ProvisioningOperation? operation = await repo.getOperationByRequestId(request.provisioningRequestId);
    
    if (operation == null) {
      operation = ProvisioningOperation(
        id: 'OP-${DateTime.now().millisecondsSinceEpoch}',
        request: request,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repo.saveOperation(operation);
    }

    if (operation.processState == ProvisioningProcessState.completed) {
      state = AsyncValue.data(operation);
      return;
    }

    state = AsyncValue.data(operation.copyWith(operationState: ProvisioningOperationState.running));
    _executeSaga(operation);
  }

  Future<void> _executeSaga(ProvisioningOperation initialOp) async {
    var op = initialOp;
    final repo = ref.read(mockProvisioningRepositoryProvider);
    
    Future<void> updateState(ProvisioningProcessState pState, {String? tId, String? oId, String? csId, String? auId}) async {
      op = op.copyWith(
        processState: pState,
        tenantId: tId,
        organizationId: oId,
        customerSolutionId: csId,
        adminUserId: auId,
        updatedAt: DateTime.now(),
      );
      await repo.saveOperation(op);
      state = AsyncValue.data(op);
    }

    try {
      // 1. Tenant Creation
      if (op.request.isNewTenant && (op.processState.index < ProvisioningProcessState.tenant_created.index)) {
        final tenantAdapter = ref.read(tenantProvisioningAdapterProvider);
        final tenant = await tenantAdapter.createTenant(
          name: op.request.newTenantName!,
          provisioningRequestId: op.request.provisioningRequestId,
        );
        await updateState(ProvisioningProcessState.tenant_created, tId: tenant.id);
      } else if (!op.request.isNewTenant && op.tenantId == null) {
        // Reuse existing tenant
        await updateState(ProvisioningProcessState.tenant_created, tId: op.request.existingTenantId);
      }

      // 2. Organization Setup
      if (op.processState.index < ProvisioningProcessState.organization_created.index) {
        if (op.request.existingOrganizationId != null) {
           await updateState(ProvisioningProcessState.organization_created, oId: op.request.existingOrganizationId);
        } else {
           final orgAdapter = ref.read(organizationProvisioningAdapterProvider);
           final tenantAdapter = ref.read(tenantProvisioningAdapterProvider);
           final tenant = await tenantAdapter.getTenant(op.tenantId!);
           final org = await orgAdapter.createOrganization(
             tenantId: op.tenantId!,
             tenantName: tenant?.name ?? 'Unknown',
             name: op.request.newOrganizationName!,
             industry: op.request.newOrganizationIndustry ?? 'N/A',
             country: op.request.newOrganizationCountry ?? 'N/A',
             provisioningRequestId: op.request.provisioningRequestId,
           );
           await updateState(ProvisioningProcessState.organization_created, oId: org.id);
        }
      }

      // 3. Solution Assignment (M5 & M7)
      if (op.processState.index < ProvisioningProcessState.solution_assigned.index) {
        final solutionDefAdapter = ref.read(solutionDefinitionAdapterProvider);
        final def = await solutionDefAdapter.getSolutionDefinition(op.request.sourceSolutionDefinitionId);
        
        final csAdapter = ref.read(customerSolutionProvisioningAdapterProvider);
        final cs = await csAdapter.createCustomerSolution(
          tenantId: op.tenantId!,
          sourceSolutionDefinitionId: op.request.sourceSolutionDefinitionId,
          exactSolutionDefinitionVersion: '1.0.0', // In a real app we'd get this from the def object
          provisioningRequestId: op.request.provisioningRequestId,
        );
        await updateState(ProvisioningProcessState.solution_assigned, csId: cs.id);
      }

      // 4. Module Activation (M2)
      if (op.processState.index < ProvisioningProcessState.modules_activated.index) {
        // Mock extracting dependencies from solution definition
        final def = await ref.read(solutionDefinitionAdapterProvider).getSolutionDefinition(op.request.sourceSolutionDefinitionId);
        final moduleIds = ['mod_fin_001']; // Assuming a mock module
        final m2Adapter = ref.read(marketplaceDependencyAdapterProvider);
        await m2Adapter.validateDependencies(moduleIds);
        await updateState(ProvisioningProcessState.modules_activated);
      }

      // 5. Entitlement Check
      if (op.processState.index < ProvisioningProcessState.entitlements_checked.index) {
        final entitlementAdapter = ref.read(mockEntitlementAdapterProvider);
        final isEntitled = await entitlementAdapter.checkEntitlement(op.tenantId!, op.request.sourceSolutionDefinitionId);
        if (!isEntitled) throw Exception('EntitlementCheckFailed');
        await updateState(ProvisioningProcessState.entitlements_checked);
      }

      // 6. Configuration defaults
      if (op.processState.index < ProvisioningProcessState.configuration_applied.index) {
        final csAdapter = ref.read(customerSolutionProvisioningAdapterProvider);
        await csAdapter.resolveEffectiveConfiguration(op.customerSolutionId!);
        await updateState(ProvisioningProcessState.configuration_applied);
      }

      // 7. Initial Data Setup
      if (op.processState.index < ProvisioningProcessState.initial_data_setup.index) {
        await Future.delayed(const Duration(milliseconds: 500));
        await updateState(ProvisioningProcessState.initial_data_setup);
      }

      // 8. Administrator Creation
      if (op.processState.index < ProvisioningProcessState.admin_created.index) {
        final userAdapter = ref.read(userProvisioningAdapterProvider);
        final admin = await userAdapter.createInitialAdministrator(
          tenantId: op.tenantId!,
          organizationId: op.organizationId!,
          name: op.request.adminName,
          email: op.request.adminEmail,
          provisioningRequestId: op.request.provisioningRequestId,
        );
        await updateState(ProvisioningProcessState.admin_created, auId: admin.id);
      }

      // 9. Completion & Runtime Availability (M7)
      if (op.processState.index < ProvisioningProcessState.completed.index) {
        final csAdapter = ref.read(customerSolutionProvisioningAdapterProvider);
        await csAdapter.activateCustomerSolution(op.customerSolutionId!);
        
        op = op.copyWith(
          processState: ProvisioningProcessState.completed,
          operationState: ProvisioningOperationState.success,
          updatedAt: DateTime.now(),
        );
        await repo.saveOperation(op);
        state = AsyncValue.data(op);
      }
      
    } catch (e) {
      op = op.copyWith(
        operationState: ProvisioningOperationState.error,
        errorMessage: e.toString(),
        updatedAt: DateTime.now(),
      );
      await repo.saveOperation(op);
      state = AsyncValue.data(op);
    }
  }
}

final provisioningControllerProvider = NotifierProvider<ProvisioningController, AsyncValue<ProvisioningOperation?>>(() {
  return ProvisioningController();
});
