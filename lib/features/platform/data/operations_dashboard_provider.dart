import 'package:flutter_riverpod/flutter_riverpod.dart';

class OperationsDashboardState {
  final Map<String, dynamic> kpis;
  final Map<String, dynamic> charts;
  final Map<String, dynamic> widgets;
  final String timeframe;

  OperationsDashboardState({
    required this.kpis,
    required this.charts,
    required this.widgets,
    this.timeframe = 'Today',
  });

  OperationsDashboardState copyWith({
    Map<String, dynamic>? kpis,
    Map<String, dynamic>? charts,
    Map<String, dynamic>? widgets,
    String? timeframe,
  }) {
    return OperationsDashboardState(
      kpis: kpis ?? this.kpis,
      charts: charts ?? this.charts,
      widgets: widgets ?? this.widgets,
      timeframe: timeframe ?? this.timeframe,
    );
  }
}

class OperationsDashboardNotifier extends AsyncNotifier<OperationsDashboardState> {
  @override
  Future<OperationsDashboardState> build() async {
    return _fetchMockData('Today');
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

  Future<OperationsDashboardState> _fetchMockData(String timeframe) async {
    await Future.delayed(const Duration(milliseconds: 600));

    double multiplier = 1.0;
    if (timeframe == 'This Week') multiplier = 5.0;
    if (timeframe == 'This Month') multiplier = 20.0;
    if (timeframe == 'Custom Range') multiplier = 12.0;

    return OperationsDashboardState(
      timeframe: timeframe,
      kpis: {
        'workflow_queue': (45 * multiplier).toInt(),
        'workflow_growth': 5.2,
        'pending_approvals': (12 * multiplier).toInt(),
        'approvals_growth': -2.1,
        'notification_status': (99.8 - (multiplier * 0.01)).toStringAsFixed(1), // success rate %
        'notification_growth': 0.1,
        'failed_notifications': (3 * multiplier).toInt(),
        'failed_growth': -15.0,
        'docs_processing': (128 * multiplier).toInt(),
        'docs_growth': 18.5,
        'active_sessions': (850 * (multiplier > 1 ? 1.2 : 1)).toInt(),
        'sessions_growth': 4.2,
      },
      charts: {
        'workflow_performance': [
          {'label': 'Mon', 'value': 120 * multiplier},
          {'label': 'Tue', 'value': 145 * multiplier},
          {'label': 'Wed', 'value': 130 * multiplier},
          {'label': 'Thu', 'value': 160 * multiplier},
          {'label': 'Fri', 'value': 180 * multiplier},
          {'label': 'Sat', 'value': 80 * multiplier},
          {'label': 'Sun', 'value': 65 * multiplier},
        ],
        'approval_trends': [
          {'label': 'Mon', 'value': 25 * multiplier},
          {'label': 'Tue', 'value': 30 * multiplier},
          {'label': 'Wed', 'value': 22 * multiplier},
          {'label': 'Thu', 'value': 40 * multiplier},
          {'label': 'Fri', 'value': 45 * multiplier},
          {'label': 'Sat', 'value': 10 * multiplier},
          {'label': 'Sun', 'value': 5 * multiplier},
        ],
        'notification_delivery': [
          {'label': 'Mon', 'value': 5000 * multiplier},
          {'label': 'Tue', 'value': 5200 * multiplier},
          {'label': 'Wed', 'value': 5100 * multiplier},
          {'label': 'Thu', 'value': 5800 * multiplier},
          {'label': 'Fri', 'value': 6000 * multiplier},
          {'label': 'Sat', 'value': 2000 * multiplier},
          {'label': 'Sun', 'value': 1800 * multiplier},
        ],
      },
      widgets: {
        'recent_activities': [
          {'user': 'Alice Smith', 'action': 'Approved PO-2026-451', 'time': '5 mins ago', 'type': 'approval'},
          {'user': 'System', 'action': 'Retry Notification Delivery', 'time': '12 mins ago', 'type': 'system'},
          {'user': 'Bob Johnson', 'action': 'Uploaded 50 Invoices', 'time': '34 mins ago', 'type': 'document'},
          {'user': 'Carol White', 'action': 'Rejected Leave Request', 'time': '1 hour ago', 'type': 'approval'},
          {'user': 'System', 'action': 'Workflow "Daily Backup" Completed', 'time': '2 hours ago', 'type': 'workflow'},
          {'user': 'Dave Brown', 'action': 'Logged In', 'time': '2 hours ago', 'type': 'user'},
        ],
        'failed_notifications_list': [
          {'recipient': 'vendor@example.com', 'reason': 'Bounce (Hard)', 'time': '10:45 AM'},
          {'recipient': 'alerts@acme.corp', 'reason': 'Timeout', 'time': '09:12 AM'},
          {'recipient': 'john.doe@company.com', 'reason': 'Invalid Address', 'time': 'Yesterday'},
        ]
      },
    );
  }
}

final operationsDashboardNotifierProvider = AsyncNotifierProvider<OperationsDashboardNotifier, OperationsDashboardState>(() {
  return OperationsDashboardNotifier();
});
