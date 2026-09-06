import 'package:coreaxis/features/platform/domain/contracts/provisioning_boundaries.dart';
import 'package:coreaxis/features/platform/domain/models/organization.dart';
import 'package:coreaxis/features/platform/data/mock_organization_repository.dart';

class OrganizationProvisioningAdapter implements IOrganizationProvisioningAdapter {
  final MockOrganizationRepository _repository;

  OrganizationProvisioningAdapter(this._repository);

  @override
  Future<Organization> createOrganization({
    required String tenantId,
    required String tenantName,
    required String name,
    required String industry,
    required String country,
    required String provisioningRequestId,
  }) async {
    final hash = provisioningRequestId.hashCode.abs();
    final newId = 'ORG-NEW-$hash';
    
    // Idempotency
    final orgs = await _repository.getOrganizationsForTenant(tenantId);
    try {
      return orgs.firstWhere((o) => o.id == newId);
    } catch (_) {
      final code = name.replaceAll(' ', '').toUpperCase();
      final newOrg = Organization(
        id: newId,
        name: name,
        code: code.length > 8 ? code.substring(0, 8) : code,
        tenantId: tenantId,
        tenantName: tenantName,
        industry: industry,
        branchCount: 1,
        employeeCount: 1,
        country: country,
        status: 'Active',
        logoUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
        createdAt: DateTime.now(),
      );
      
      return await _repository.createOrganization(newOrg);
    }
  }
}
