import 'provisioning_request.dart';

enum ProvisioningProcessState {
  pending,
  tenant_created,
  organization_created,
  solution_assigned,
  modules_activated,
  entitlements_checked,
  configuration_applied,
  initial_data_setup,
  admin_created,
  completed,
  failed
}

enum ProvisioningOperationState {
  idle,
  running,
  success,
  error
}

class ProvisioningOperation {
  final String id;
  final ProvisioningRequest request;
  final ProvisioningProcessState processState;
  final ProvisioningOperationState operationState;
  final String? errorMessage;
  
  // Accumulated references
  final String? tenantId;
  final String? organizationId;
  final String? customerSolutionId;
  final String? adminUserId;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  ProvisioningOperation({
    required this.id,
    required this.request,
    this.processState = ProvisioningProcessState.pending,
    this.operationState = ProvisioningOperationState.idle,
    this.errorMessage,
    this.tenantId,
    this.organizationId,
    this.customerSolutionId,
    this.adminUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  ProvisioningOperation copyWith({
    ProvisioningProcessState? processState,
    ProvisioningOperationState? operationState,
    String? errorMessage,
    String? tenantId,
    String? organizationId,
    String? customerSolutionId,
    String? adminUserId,
    DateTime? updatedAt,
  }) {
    return ProvisioningOperation(
      id: id,
      request: request,
      processState: processState ?? this.processState,
      operationState: operationState ?? this.operationState,
      errorMessage: errorMessage ?? this.errorMessage,
      tenantId: tenantId ?? this.tenantId,
      organizationId: organizationId ?? this.organizationId,
      customerSolutionId: customerSolutionId ?? this.customerSolutionId,
      adminUserId: adminUserId ?? this.adminUserId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
