import 'dart:math';
import 'package:coreaxis/features/platform/domain/models/organization.dart';

class MockOrganizationRepository {
  final List<Organization> _organizations = [];

  MockOrganizationRepository() {
    _seedData();
  }

  void _seedData() {
    final random = Random(42); // Deterministic seed
    final industries = ['Manufacturing', 'Trading', 'Service', 'Technology', 'Healthcare'];
    final countries = ['United States', 'United Kingdom', 'Canada', 'India', 'Germany', 'Japan', 'Australia'];
    final statuses = ['Active', 'Active', 'Active', 'Inactive'];
    final tenants = ['Stellar Tech', 'Global Logistics', 'Acme Corp', 'Wayne Enterprises', 'Stark Industries'];

    for (int i = 0; i < 50; i++) {
      final name = 'Organization ${i + 1}';
      final isService = random.nextBool();
      _organizations.add(Organization(
        id: 'org_${1000 + i}',
        name: name,
        code: 'ORG${1000 + i}',
        tenantId: 'TEN-${1000 + random.nextInt(5)}', // Simulate matching to tenants
        tenantName: tenants[random.nextInt(tenants.length)],
        industry: industries[random.nextInt(industries.length)],
        branchCount: isService ? 1 : random.nextInt(20) + 1,
        employeeCount: random.nextInt(5000) + 10,
        country: countries[random.nextInt(countries.length)],
        status: statuses[random.nextInt(statuses.length)],
        logoUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
        createdAt: DateTime.now().subtract(Duration(days: random.nextInt(365 * 3))),
      ));
    }
  }

  Future<List<Organization>> getOrganizations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_organizations);
  }

  Future<List<Organization>> getOrganizationsForTenant(String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _organizations.where((o) => o.tenantId == tenantId).toList();
  }

  Future<Organization?> getOrganizationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _organizations.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Organization> createOrganization(Organization organization) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_organizations.any((o) => o.id == organization.id)) {
      throw Exception('Organization with this ID already exists.');
    }
    _organizations.add(organization);
    return organization;
  }
}
