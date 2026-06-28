import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/organization.dart';

final organizationDetailProvider = FutureProvider.family<Organization, String>((ref, id) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 800));
  
  // Return mock organization based on ID
  return Organization(
    id: id,
    name: 'Mock Organization $id',
    code: id.toUpperCase(),
    tenantId: 'TEN-1001',
    tenantName: 'Stellar Tech',
    industry: 'Technology',
    branchCount: 4,
    employeeCount: 1540,
    country: 'United States',
    status: 'Active',
    logoUrl: 'https://ui-avatars.com/api/?name=Org+$id&background=random',
    createdAt: DateTime.now().subtract(const Duration(days: 120)),
  );
});
