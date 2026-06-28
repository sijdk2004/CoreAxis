import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../domain/models/tenant.dart';
import 'tenant_provider.dart';

class TenantAnalyticsState {
  final Tenant tenant;
  final Map<String, dynamic> kpis;
  final Map<String, dynamic> charts;
  final List<List<double>> dailyActivityHeatmap;
  final List<Map<String, dynamic>> activeUsers;
  final List<Map<String, dynamic>> popularModules;
  final List<Map<String, dynamic>> slowestWorkflows;
  final List<Map<String, dynamic>> insights;

  TenantAnalyticsState({
    required this.tenant,
    required this.kpis,
    required this.charts,
    required this.dailyActivityHeatmap,
    required this.activeUsers,
    required this.popularModules,
    required this.slowestWorkflows,
    required this.insights,
  });
}

final tenantAnalyticsProvider = FutureProvider.family<TenantAnalyticsState, String>((ref, id) async {
  await Future.delayed(const Duration(milliseconds: 700));

  final repo = ref.read(tenantRepositoryProvider);
  final allTenants = await repo.getTenants();
  
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

  final random = Random(id.hashCode);

  List<List<double>> generateHeatmap() {
    List<List<double>> data = [];
    for (int i = 0; i < 7; i++) { // 7 days
      List<double> dayData = [];
      for (int j = 0; j < 24; j++) { // 24 hours
        // Simulate more activity during work hours (9-17)
        if (j > 8 && j < 18) {
          dayData.add(random.nextDouble() * 0.8 + 0.2);
        } else {
          dayData.add(random.nextDouble() * 0.3);
        }
      }
      data.add(dayData);
    }
    return data;
  }

  return TenantAnalyticsState(
    tenant: tenant,
    kpis: {
      'revenue': '\$12,450.00',
      'users': tenant.userCount.toString(),
      'organizations': tenant.organizationCount.toString(),
      'storage_used': '145.2 GB',
      'api_calls': '1.2M',
      'workflows_executed': '45,210',
    },
    charts: {
      'revenue_trend': [
        {'label': 'Jan', 'value': 8500},
        {'label': 'Feb', 'value': 9200},
        {'label': 'Mar', 'value': 10500},
        {'label': 'Apr', 'value': 11200},
        {'label': 'May', 'value': 11800},
        {'label': 'Jun', 'value': 12450},
      ],
      'user_growth': [
        {'label': 'Jan', 'value': tenant.userCount > 50 ? tenant.userCount - 45 : 1},
        {'label': 'Feb', 'value': tenant.userCount > 30 ? tenant.userCount - 20 : 5},
        {'label': 'Mar', 'value': tenant.userCount > 15 ? tenant.userCount - 10 : 10},
        {'label': 'Apr', 'value': tenant.userCount > 5 ? tenant.userCount - 2 : 12},
        {'label': 'May', 'value': tenant.userCount},
        {'label': 'Jun', 'value': tenant.userCount + 5},
      ],
      'login_trend': [
        {'label': 'Mon', 'value': 420},
        {'label': 'Tue', 'value': 550},
        {'label': 'Wed', 'value': 600},
        {'label': 'Thu', 'value': 580},
        {'label': 'Fri', 'value': 490},
        {'label': 'Sat', 'value': 120},
        {'label': 'Sun', 'value': 95},
      ],
      'storage_growth': [
        {'label': 'W1', 'value': 120.5},
        {'label': 'W2', 'value': 125.0},
        {'label': 'W3', 'value': 132.8},
        {'label': 'W4', 'value': 145.2},
      ],
      'module_usage': [
        {'label': 'Sales', 'value': 35},
        {'label': 'Production', 'value': 25},
        {'label': 'Inventory', 'value': 20},
        {'label': 'Finance', 'value': 15},
        {'label': 'HR', 'value': 5},
      ],
    },
    dailyActivityHeatmap: generateHeatmap(),
    activeUsers: [
      {'name': 'Sarah Jenkins', 'role': 'Admin', 'activity': '142 logins this week', 'avatar': 'https://ui-avatars.com/api/?name=Sarah+Jenkins&background=random'},
      {'name': 'Mike Ross', 'role': 'Sales Manager', 'activity': '98 logins this week', 'avatar': 'https://ui-avatars.com/api/?name=Mike+Ross&background=random'},
      {'name': 'Harvey Specter', 'role': 'CEO', 'activity': '75 logins this week', 'avatar': 'https://ui-avatars.com/api/?name=Harvey+Specter&background=random'},
      {'name': 'Donna Paulsen', 'role': 'Operations', 'activity': '215 actions today', 'avatar': 'https://ui-avatars.com/api/?name=Donna+Paulsen&background=random'},
    ],
    popularModules: [
      {'name': 'Sales Orders', 'usage': '45%', 'trend': '+5%'},
      {'name': 'Inventory Tracking', 'usage': '32%', 'trend': '+2%'},
      {'name': 'Production Board', 'usage': '15%', 'trend': '-1%'},
      {'name': 'Financial Reports', 'usage': '8%', 'trend': '+10%'},
    ],
    slowestWorkflows: [
      {'name': 'End of Month Reconciliation', 'avg_time': '4.5 mins', 'status': 'Warning'},
      {'name': 'Bulk Inventory Update', 'avg_time': '2.1 mins', 'status': 'Normal'},
      {'name': 'Payroll Processing', 'avg_time': '1.8 mins', 'status': 'Normal'},
      {'name': 'Customer Data Export', 'avg_time': '1.2 mins', 'status': 'Normal'},
    ],
    insights: [
      {'title': 'Storage Limit Warning', 'description': 'Tenant is approaching 80% of their 200GB storage limit.', 'type': 'warning'},
      {'title': 'Anomaly Detected', 'description': 'Unusually high login activity detected on Saturday at 2 AM.', 'type': 'alert'},
      {'title': 'Optimization Opportunity', 'description': 'Users frequently switch between Sales and Inventory. Suggest enabling split-pane view.', 'type': 'insight'},
      {'title': 'Feature Adoption', 'description': 'The new AI Forecasting module has seen a 40% adoption rate this month.', 'type': 'success'},
    ]
  );
});
