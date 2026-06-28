import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/tenant.dart';
import 'tenant_provider.dart';

class TenantDetailState {
  final Tenant tenant;
  final Map<String, dynamic> charts;
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> activities;

  TenantDetailState({
    required this.tenant,
    required this.charts,
    required this.stats,
    required this.activities,
  });
}

final tenantDetailProvider = FutureProvider.family<TenantDetailState, String>((ref, id) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 600));

  final repo = ref.read(tenantRepositoryProvider);
  final allTenants = await repo.getTenants();
  
  // Find tenant or create a mock fallback if not found (e.g. newly created)
  final tenant = allTenants.firstWhere(
    (t) => t.id == id,
    orElse: () => Tenant(
      id: id,
      name: 'Newly Created Tenant',
      code: 'NEW-TEN',
      logoUrl: 'https://ui-avatars.com/api/?name=New+Tenant&background=random',
      organizationCount: 0,
      userCount: 1,
      subscriptionPlan: 'Trial',
      status: 'Active',
      createdAt: DateTime.now(),
      lastActivity: DateTime.now(),
    ),
  );

  return TenantDetailState(
    tenant: tenant,
    stats: {
      'total_users': tenant.userCount,
      'active_users': (tenant.userCount * 0.8).round(),
      'storage_used': '12.4 GB',
      'storage_limit': '50 GB',
      'api_requests': '1.2M',
      'system_health': '99.9%',
    },
    charts: {
      'user_growth': [
        {'label': 'Jan', 'value': 10},
        {'label': 'Feb', 'value': 25},
        {'label': 'Mar', 'value': 45},
        {'label': 'Apr', 'value': 80},
        {'label': 'May', 'value': tenant.userCount > 100 ? 120 : tenant.userCount},
        {'label': 'Jun', 'value': tenant.userCount},
      ],
      'revenue_trend': [
        {'label': 'Jan', 'value': 500},
        {'label': 'Feb', 'value': 500},
        {'label': 'Mar', 'value': 1200},
        {'label': 'Apr', 'value': 1200},
        {'label': 'May', 'value': 2500},
        {'label': 'Jun', 'value': 2999},
      ],
      'storage_usage': [
        {'label': 'Documents', 'value': 60},
        {'label': 'Images', 'value': 25},
        {'label': 'Database', 'value': 10},
        {'label': 'Logs', 'value': 5},
      ],
    },
    activities: [
      {'title': 'User John Doe logged in', 'time': '10 mins ago', 'type': 'auth'},
      {'title': 'New Organization "Sales Dept" created', 'time': '2 hours ago', 'type': 'org'},
      {'title': 'Subscription upgraded to Professional', 'time': 'Yesterday', 'type': 'billing'},
      {'title': 'API token generated', 'time': '3 days ago', 'type': 'system'},
    ],
  );
});
