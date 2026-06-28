import 'dart:math';
import '../domain/models/tenant.dart';

class MockTenantRepository {
  List<Tenant> _tenants = [];
  final _random = Random(42); // Seed for deterministic mock data

  MockTenantRepository() {
    _generateMockTenants();
  }

  void _generateMockTenants() {
    final statuses = ['Active', 'Active', 'Active', 'Trial', 'Suspended', 'Expired'];
    final plans = ['Trial', 'Standard', 'Premium', 'Enterprise'];
    final prefixes = ['Acme', 'Global', 'Stark', 'Wayne', 'Oscorp', 'Cyber', 'Data', 'Nova', 'Apex', 'Vertex'];
    final suffixes = ['Corp', 'Industries', 'Enterprises', 'Systems', 'Solutions', 'Dynamics', 'Tech', 'Labs', 'Group'];

    for (int i = 0; i < 50; i++) {
      final name = '${prefixes[_random.nextInt(prefixes.length)]} ${suffixes[_random.nextInt(suffixes.length)]} ${i + 1}';
      final code = name.replaceAll(' ', '').toUpperCase().substring(0, min(8, name.length - 1)) + '${1000 + i}';
      final status = statuses[_random.nextInt(statuses.length)];
      
      String plan = plans[_random.nextInt(plans.length)];
      if (status == 'Trial') plan = 'Trial';

      final createdAt = DateTime.now().subtract(Duration(days: _random.nextInt(1000)));
      final lastActivity = DateTime.now().subtract(Duration(hours: _random.nextInt(720)));

      _tenants.add(
        Tenant(
          id: 'TEN-${1000 + i}',
          name: name,
          code: code,
          logoUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
          organizationCount: _random.nextInt(5) + 1,
          userCount: _random.nextInt(500) + 10,
          subscriptionPlan: plan,
          status: status,
          createdAt: createdAt,
          lastActivity: lastActivity,
        ),
      );
    }
  }

  Future<List<Tenant>> getTenants() async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate network latency
    return [..._tenants];
  }

  Future<void> updateTenantStatus(List<String> ids, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _tenants = _tenants.map((t) {
      if (ids.contains(t.id)) {
        return t.copyWith(status: newStatus, lastActivity: DateTime.now());
      }
      return t;
    }).toList();
  }

  Future<void> deleteTenants(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _tenants.removeWhere((t) => ids.contains(t.id));
  }
}
