import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coreaxis/features/platform/application/provisioning_controller.dart';
import 'package:coreaxis/features/platform/application/provisioning_providers.dart';
import 'package:coreaxis/features/platform/domain/models/provisioning_request.dart';
import 'package:coreaxis/features/platform/domain/models/provisioning_operation.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('ProvisioningController Tests', () {
    test('Idempotency: Same request ID resumes operation without duplicating', () async {
      final req = ProvisioningRequest(
        provisioningRequestId: 'req-idemp-1',
        isNewTenant: true,
        newTenantName: 'Idemp Test Tenant',
        newOrganizationName: 'Idemp Org',
        sourceSolutionDefinitionId: 'sd-1',
        adminName: 'Admin',
        adminEmail: 'admin@idemp.com',
      );

      final controller = container.read(provisioningControllerProvider.notifier);
      
      // Keep the provider alive
      final sub = container.listen(provisioningControllerProvider, (_, __) {});

      await controller.startOrResumeProvisioning(req);
      
      // Wait for completion
      final repo = container.read(mockProvisioningRepositoryProvider);
      ProvisioningOperation? op1;
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        op1 = await repo.getOperationByRequestId('req-idemp-1');
        if (op1?.processState == ProvisioningProcessState.completed) break;
      }
      expect(op1, isNotNull);
      expect(op1!.tenantId, isNotNull);

      // Re-run
      await controller.startOrResumeProvisioning(req);
      
      ProvisioningOperation? op2;
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        op2 = await repo.getOperationByRequestId('req-idemp-1');
        if (op2?.processState == ProvisioningProcessState.completed) break;
      }
      
      expect(op1.id, equals(op2!.id)); // Same operation
      sub.close();
    });
    
    test('Tenant Isolation: Org only accessible under correct tenant', () async {
       final req = ProvisioningRequest(
        provisioningRequestId: 'req-iso-1',
        isNewTenant: true,
        newTenantName: 'Iso Tenant',
        newOrganizationName: 'Iso Org',
        sourceSolutionDefinitionId: 'sd-1',
        adminName: 'Admin',
        adminEmail: 'admin@iso.com',
      );

      final controller = container.read(provisioningControllerProvider.notifier);
      final sub = container.listen(provisioningControllerProvider, (_, __) {});

      await controller.startOrResumeProvisioning(req);
      
      final repo = container.read(mockProvisioningRepositoryProvider);
      ProvisioningOperation? op;
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        op = await repo.getOperationByRequestId('req-iso-1');
        if (op?.processState == ProvisioningProcessState.completed) break;
      }
      
      final orgAdapter = container.read(mockOrganizationRepositoryProvider);
      final tenantOrgs = await orgAdapter.getOrganizationsForTenant(op!.tenantId!);
      
      expect(tenantOrgs.isNotEmpty, isTrue);
      expect(tenantOrgs.first.id, equals(op.organizationId));
      
      final otherTenantOrgs = await orgAdapter.getOrganizationsForTenant('DIFFERENT-TENANT');
      expect(otherTenantOrgs.any((o) => o.id == op!.organizationId), isFalse);
      sub.close();
    });
  });
}
