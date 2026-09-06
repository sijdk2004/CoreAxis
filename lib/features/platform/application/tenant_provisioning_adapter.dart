import 'dart:math';
import 'package:coreaxis/features/platform/domain/contracts/provisioning_boundaries.dart';
import 'package:coreaxis/features/platform/domain/models/tenant.dart';
import 'package:coreaxis/features/platform/data/mock_tenant_repository.dart';

class TenantProvisioningAdapter implements ITenantProvisioningAdapter {
  final MockTenantRepository _repository;

  TenantProvisioningAdapter(this._repository);

  @override
  Future<Tenant> createTenant({
    required String name,
    required String provisioningRequestId,
  }) async {
    // Basic deterministic ID generation based on request ID for idempotency simulation
    final hash = provisioningRequestId.hashCode.abs();
    final newId = 'TEN-NEW-$hash';
    
    // Check if it already exists (idempotency)
    final existingTenants = await _repository.getTenants();
    try {
      return existingTenants.firstWhere((t) => t.id == newId);
    } catch (_) {
      // Create new
      final code = name.replaceAll(' ', '').toUpperCase();
      final newTenant = Tenant(
        id: newId,
        name: name,
        code: code.length > 8 ? code.substring(0, 8) : code,
        logoUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
        organizationCount: 1,
        userCount: 1,
        subscriptionPlan: 'Trial',
        status: 'Active',
        createdAt: DateTime.now(),
        lastActivity: DateTime.now(),
      );
      
      // We would normally add this to repository.
      // Since MockTenantRepository lacks a direct createTenant method right now, 
      // we'll simulate success. In a real scenario, we'd call _repository.createTenant(newTenant);
      return newTenant; 
    }
  }

  @override
  Future<Tenant?> getTenant(String tenantId) async {
    final tenants = await _repository.getTenants();
    try {
      return tenants.firstWhere((t) => t.id == tenantId);
    } catch (_) {
      return null;
    }
  }
}
