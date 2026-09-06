import 'package:coreaxis/features/platform/domain/models/provisioning_request.dart';
import 'package:coreaxis/features/platform/domain/models/provisioning_operation.dart';

class MockProvisioningRepository {
  final List<ProvisioningOperation> _operations = [];

  MockProvisioningRepository() {
    _seedData();
  }

  void _seedData() {
    _operations.addAll([
      ProvisioningOperation(
        id: 'OP-1001',
        request: ProvisioningRequest(
          provisioningRequestId: 'req-1',
          isNewTenant: true,
          newTenantName: 'Stellar Tech',
          newOrganizationName: 'Stellar Tech US',
          sourceSolutionDefinitionId: 'sd-1',
          adminName: 'Alice Admin',
          adminEmail: 'alice@stellar.tech',
        ),
        processState: ProvisioningProcessState.completed,
        operationState: ProvisioningOperationState.success,
        tenantId: 'TEN-1000',
        organizationId: 'org_1000',
        customerSolutionId: 'CS-1000',
        adminUserId: 'USR-1000',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2, hours: -1)),
      ),
      ProvisioningOperation(
        id: 'OP-1002',
        request: ProvisioningRequest(
          provisioningRequestId: 'req-2',
          isNewTenant: false,
          existingTenantId: 'TEN-1001',
          newOrganizationName: 'Global Logistics EU',
          sourceSolutionDefinitionId: 'sd-2',
          adminName: 'Bob Admin',
          adminEmail: 'bob@global.logistics',
        ),
        processState: ProvisioningProcessState.modules_activated,
        operationState: ProvisioningOperationState.error,
        errorMessage: 'Dependency Validation Failed',
        tenantId: 'TEN-1001',
        organizationId: 'org_1001',
        customerSolutionId: 'CS-1001',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      )
    ]);
  }

  Future<ProvisioningOperation> saveOperation(ProvisioningOperation operation) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _operations.indexWhere((o) => o.id == operation.id);
    if (index >= 0) {
      _operations[index] = operation;
    } else {
      _operations.add(operation);
    }
    return operation;
  }

  Future<ProvisioningOperation?> getOperationByRequestId(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _operations.firstWhere((o) => o.request.provisioningRequestId == requestId);
    } catch (_) {
      return null;
    }
  }

  Future<List<ProvisioningOperation>> getAllOperations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_operations);
  }
}
