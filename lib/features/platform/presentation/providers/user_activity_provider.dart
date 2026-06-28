import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_activity.dart';
import 'package:intl/intl.dart';

// ── State ──────────────────────────────────────────────────────────────────

class UserActivityState {
  final String userId;
  final List<UserActivity> allActivities;
  final List<UserActivity> filteredActivities;
  final String timeFilter;
  final String typeFilter;
  final String viewMode;
  final bool isLoading;
  final Map<String, dynamic> charts;
  final Map<String, dynamic> stats;

  const UserActivityState({
    this.userId = '',
    this.allActivities = const [],
    this.filteredActivities = const [],
    this.timeFilter = 'This Week',
    this.typeFilter = 'All',
    this.viewMode = 'timeline',
    this.isLoading = true,
    this.charts = const {},
    this.stats = const {},
  });

  UserActivityState copyWith({
    String? userId,
    List<UserActivity>? allActivities,
    List<UserActivity>? filteredActivities,
    String? timeFilter,
    String? typeFilter,
    String? viewMode,
    bool? isLoading,
    Map<String, dynamic>? charts,
    Map<String, dynamic>? stats,
  }) =>
      UserActivityState(
        userId: userId ?? this.userId,
        allActivities: allActivities ?? this.allActivities,
        filteredActivities: filteredActivities ?? this.filteredActivities,
        timeFilter: timeFilter ?? this.timeFilter,
        typeFilter: typeFilter ?? this.typeFilter,
        viewMode: viewMode ?? this.viewMode,
        isLoading: isLoading ?? this.isLoading,
        charts: charts ?? this.charts,
        stats: stats ?? this.stats,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────

class UserActivityNotifier extends Notifier<UserActivityState> {
  @override
  UserActivityState build() {
    return const UserActivityState();
  }

  void init(String userId) {
    state = state.copyWith(userId: userId, isLoading: true);
    _loadMockData(userId);
  }

  Future<void> _loadMockData(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final random = Random();
    final now = DateTime.now();
    final List<UserActivity> mockData = [];

    final types = ActivityType.values;
    final devices = [
      'MacBook Pro (macOS)',
      'iPhone 14 Pro (iOS)',
      'Windows PC (Windows 11)',
    ];
    final locations = ['New York, US', 'London, UK', 'Remote VPN', 'Office Network'];
    final ips = ['192.168.1.45', '10.0.0.22', '172.16.254.1'];

    for (int i = 0; i < 50; i++) {
      final timestamp = now.subtract(Duration(
        days: random.nextInt(30),
        hours: random.nextInt(24),
        minutes: random.nextInt(60),
      ));

      final type = types[random.nextInt(types.length)];
      final String description;
      switch (type) {
        case ActivityType.login:
          description = 'Successfully logged into the platform.';
          break;
        case ActivityType.logout:
          description = 'User manually logged out.';
          break;
        case ActivityType.passwordChange:
          description = 'Changed account password.';
          break;
        case ActivityType.roleAssignment:
          description = 'Assigned new role by Administrator.';
          break;
        case ActivityType.documentAccess:
          description = 'Accessed secure document (Q3_Financials.pdf).';
          break;
        case ActivityType.workflowApproval:
          final poNum = random.nextInt(9999);
          description = 'Approved Purchase Order PO-2026-$poNum.';
          break;
        case ActivityType.reportDownload:
          description = 'Downloaded monthly performance report.';
          break;
        case ActivityType.aiUsage:
          description = 'Used AI Assistant to query sales data.';
          break;
      }

      mockData.add(UserActivity(
        id: 'act_${i}_${random.nextInt(10000)}',
        userId: userId,
        timestamp: timestamp,
        type: type,
        description: description,
        deviceInfo: devices[random.nextInt(devices.length)],
        location: locations[random.nextInt(locations.length)],
        ipAddress: ips[random.nextInt(ips.length)],
        status: random.nextDouble() > 0.9 ? 'failed' : 'success',
      ));
    }

    mockData.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final todayCount = mockData
        .where((a) => a.timestamp.isAfter(now.subtract(const Duration(days: 1))))
        .length;

    final Map<String, int> moduleUsage = {
      'Authentication': mockData
          .where((a) => a.type == ActivityType.login || a.type == ActivityType.logout)
          .length,
      'Documents': mockData.where((a) => a.type == ActivityType.documentAccess).length,
      'Workflows': mockData.where((a) => a.type == ActivityType.workflowApproval).length,
      'AI Assistant': mockData.where((a) => a.type == ActivityType.aiUsage).length,
    };

    final topModule =
        moduleUsage.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final Map<String, dynamic> stats = {
      'recentCount': todayCount,
      'mostUsedModule': topModule,
      'primaryLocation': locations[0],
      'primaryDevice': devices[0],
    };

    final List<Map<String, dynamic>> trendData = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      trendData.add({
        'day': DateFormat('E').format(date),
        'count': random.nextInt(15) + 2,
      });
    }

    final List<Map<String, dynamic>> usageChartData = [];
    int idx = 0;
    moduleUsage.forEach((key, value) {
      usageChartData.add({'module': key, 'value': value, 'index': idx++});
    });

    final Map<String, dynamic> charts = {
      'activity_trend': trendData,
      'module_usage': usageChartData,
    };

    state = state.copyWith(
      allActivities: mockData,
      isLoading: false,
      charts: charts,
      stats: stats,
    );

    _applyFilters();
  }

  void setTimeFilter(String filter) {
    state = state.copyWith(timeFilter: filter);
    _applyFilters();
  }

  void setTypeFilter(String filter) {
    state = state.copyWith(typeFilter: filter);
    _applyFilters();
  }

  void setViewMode(String mode) {
    state = state.copyWith(viewMode: mode);
  }

  void _applyFilters() {
    final now = DateTime.now();
    List<UserActivity> filtered = List<UserActivity>.from(state.allActivities);

    switch (state.timeFilter) {
      case 'Today':
        filtered = filtered
            .where((a) => a.timestamp.isAfter(now.subtract(const Duration(days: 1))))
            .toList();
        break;
      case 'This Week':
        filtered = filtered
            .where((a) => a.timestamp.isAfter(now.subtract(const Duration(days: 7))))
            .toList();
        break;
      case 'This Month':
        filtered = filtered
            .where((a) => a.timestamp.isAfter(now.subtract(const Duration(days: 30))))
            .toList();
        break;
      default:
        break;
    }

    if (state.typeFilter != 'All') {
      final typeEnum = ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == state.typeFilter,
        orElse: () => ActivityType.login,
      );
      filtered = filtered.where((a) => a.type == typeEnum).toList();
    }

    state = state.copyWith(filteredActivities: filtered);
  }
}

// ── Provider (plain NotifierProvider, userId passed via init()) ────────────

final userActivityProvider =
    NotifierProvider<UserActivityNotifier, UserActivityState>(
  UserActivityNotifier.new,
);
