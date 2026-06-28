import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlatformDashboardState {
  final Map<String, dynamic> kpis;
  final Map<String, dynamic> charts;
  final Map<String, dynamic> widgets;
  final String timeframe;

  PlatformDashboardState({
    required this.kpis,
    required this.charts,
    required this.widgets,
    this.timeframe = 'YTD',
  });

  PlatformDashboardState copyWith({
    Map<String, dynamic>? kpis,
    Map<String, dynamic>? charts,
    Map<String, dynamic>? widgets,
    String? timeframe,
  }) {
    return PlatformDashboardState(
      kpis: kpis ?? this.kpis,
      charts: charts ?? this.charts,
      widgets: widgets ?? this.widgets,
      timeframe: timeframe ?? this.timeframe,
    );
  }
}

class PlatformDashboardNotifier extends AsyncNotifier<PlatformDashboardState> {
  @override
  Future<PlatformDashboardState> build() async {
    return _fetchMockData('YTD');
  }

  Future<void> setTimeframe(String timeframe) async {
    state = const AsyncValue.loading();
    try {
      final data = await _fetchMockData(timeframe);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<PlatformDashboardState> _fetchMockData(String timeframe) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Realistic Mock Data for Executive Dashboard
    return PlatformDashboardState(
      timeframe: timeframe,
      kpis: {
        'total_tenants': 142,
        'tenants_growth': 12.5,
        'active_organizations': 324,
        'orgs_growth': 8.2,
        'active_users': 15840,
        'users_growth': 15.4,
        'workflow_executions': 124500,
        'workflows_growth': 22.1,
        'pending_approvals': 432,
        'approvals_growth': -5.0,
        'documents_stored': 850, // in GB
        'documents_growth': 10.5,
        'ai_requests': 45200,
        'ai_requests_growth': 34.2,
        'monthly_revenue': 425000,
        'revenue_growth': 18.5,
      },
      charts: {
        'tenant_growth_trend': [
          {'month': 'Jan', 'value': 100},
          {'month': 'Feb', 'value': 105},
          {'month': 'Mar', 'value': 112},
          {'month': 'Apr', 'value': 120},
          {'month': 'May', 'value': 130},
          {'month': 'Jun', 'value': 142},
        ],
        'user_activity_trend': [
          {'month': 'Jan', 'value': 12000},
          {'month': 'Feb', 'value': 12500},
          {'month': 'Mar', 'value': 13200},
          {'month': 'Apr', 'value': 14100},
          {'month': 'May', 'value': 15000},
          {'month': 'Jun', 'value': 15840},
        ],
        'workflow_execution_trend': [
          {'month': 'Jan', 'value': 90000},
          {'month': 'Feb', 'value': 95000},
          {'month': 'Mar', 'value': 102000},
          {'month': 'Apr', 'value': 110000},
          {'month': 'May', 'value': 118000},
          {'month': 'Jun', 'value': 124500},
        ],
      },
      widgets: {
        'recent_activities': [
          {'id': '1', 'action': 'New Tenant Onboarded', 'entity': 'Acme Corp', 'time': '10 mins ago', 'type': 'tenant'},
          {'id': '2', 'action': 'Workflow Failed', 'entity': 'Invoice Processing', 'time': '45 mins ago', 'type': 'error'},
          {'id': '3', 'action': 'AI Model Retrained', 'entity': 'Demand Forecasting', 'time': '2 hours ago', 'type': 'ai'},
          {'id': '4', 'action': 'System Backup', 'entity': 'Database Snapshots', 'time': '5 hours ago', 'type': 'system'},
          {'id': '5', 'action': 'New User Role Created', 'entity': 'Regional Manager', 'time': '1 day ago', 'type': 'security'},
        ],
        'top_tenants': [
          {'name': 'Stellar Furniture', 'users': 1250, 'revenue': '\$45k/mo'},
          {'name': 'Global Retailers', 'users': 980, 'revenue': '\$32k/mo'},
          {'name': 'TechSpaces', 'users': 850, 'revenue': '\$28k/mo'},
          {'name': 'HomeGoods Co', 'users': 720, 'revenue': '\$21k/mo'},
        ],
        'pending_tasks': [
          {'task': 'Approve Platform Upgrade', 'priority': 'High', 'due': 'Today'},
          {'task': 'Review New Privacy Policy', 'priority': 'Medium', 'due': 'Tomorrow'},
          {'task': 'Audit Tenant Storage Usage', 'priority': 'Medium', 'due': 'In 3 days'},
          {'task': 'Setup Billing Integration', 'priority': 'High', 'due': 'Next Week'},
        ],
      },
    );
  }
}

final platformDashboardNotifierProvider = AsyncNotifierProvider<PlatformDashboardNotifier, PlatformDashboardState>(() {
  return PlatformDashboardNotifier();
});
