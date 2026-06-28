import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiInsightsState {
  final Map<String, dynamic> kpis;
  final Map<String, dynamic> charts;
  final Map<String, dynamic> widgets;

  AiInsightsState({
    required this.kpis,
    required this.charts,
    required this.widgets,
  });
}

class AiInsightsNotifier extends AsyncNotifier<AiInsightsState> {
  @override
  Future<AiInsightsState> build() async {
    return _fetchMockData();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final data = await _fetchMockData();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AiInsightsState> _fetchMockData() async {
    await Future.delayed(const Duration(milliseconds: 700));

    return AiInsightsState(
      kpis: {
        'ai_requests': 14250,
        'requests_growth': 12.5,
        'saved_time': '340h',
        'saved_time_growth': 8.2,
        'automation_rate': 68.4,
        'automation_growth': 2.1,
        'predicted_revenue': '\$1.2M',
        'revenue_growth': 15.0,
      },
      charts: {
        'revenue_forecast': [
          {'label': 'Jul', 'actual': 100, 'predicted': 105},
          {'label': 'Aug', 'actual': 110, 'predicted': 112},
          {'label': 'Sep', 'actual': 115, 'predicted': 118},
          {'label': 'Oct', 'actual': null, 'predicted': 125},
          {'label': 'Nov', 'actual': null, 'predicted': 135},
          {'label': 'Dec', 'actual': null, 'predicted': 150},
        ],
      },
      widgets: {
        'tenant_health_scores': [
          {'name': 'Acme Corp', 'score': 98},
          {'name': 'Stark Industries', 'score': 85},
          {'name': 'Wayne Enterprises', 'score': 72},
          {'name': 'Oscorp', 'score': 45},
          {'name': 'Global Dynamics', 'score': 91},
        ],
        'optimization_suggestions': [
          {'title': 'Workflow Approval Time can be reduced by 30%', 'description': 'AI identified bottlenecks in the secondary review stage. Re-routing non-critical approvals could save 40 hours/week.', 'impact': 'High'},
          {'title': 'Consolidate Vendor Payments', 'description': 'Batch processing payments on Thursdays minimizes transaction fees based on historical patterns.', 'impact': 'Medium'},
        ],
        'risk_alerts': [
          {'title': 'Declining Usage: Tenant ABC', 'description': 'Usage dropped by 45% in the last 2 weeks.', 'severity': 'High'},
          {'title': 'Inventory Bottleneck Predicted', 'description': 'Raw materials for Product line X likely to face shortages by next month.', 'severity': 'Medium'},
          {'title': 'Abnormal Login Patterns', 'description': 'Spike in off-hours access detected from Region Y.', 'severity': 'Low'},
        ],
        'recommendations_feed': [
          {'title': 'Enable Auto-Approval for PO < \$500', 'time': '10 mins ago', 'type': 'workflow'},
          {'title': 'Re-engage Tenant ABC with Custom Offer', 'time': '2 hours ago', 'type': 'sales'},
          {'title': 'Optimize Server Resources in Region X', 'time': '5 hours ago', 'type': 'infra'},
          {'title': 'Update Compliance Policies for EU Region', 'time': 'Yesterday', 'type': 'legal'},
        ]
      },
    );
  }
}

final aiInsightsProvider = AsyncNotifierProvider<AiInsightsNotifier, AiInsightsState>(() {
  return AiInsightsNotifier();
});
