class AiKpis {
  final int requestsToday;
  final int activeUsers;
  final int automationHoursSaved;
  final int recommendations;
  final int reportsGenerated;
  final int workflowsTriggered;
  final int predictionsGenerated;
  final double successRate;

  AiKpis({
    required this.requestsToday,
    required this.activeUsers,
    required this.automationHoursSaved,
    required this.recommendations,
    required this.reportsGenerated,
    required this.workflowsTriggered,
    required this.predictionsGenerated,
    required this.successRate,
  });
}

class AiUsageTrend {
  final String date;
  final int requests;

  AiUsageTrend({required this.date, required this.requests});
}

class DepartmentUsage {
  final String department;
  final int usageCount;

  DepartmentUsage({required this.department, required this.usageCount});
}

class RequestTypeDistribution {
  final String type;
  final int count;

  RequestTypeDistribution({required this.type, required this.count});
}

class AutomationTrend {
  final String date;
  final int hoursSaved;

  AutomationTrend({required this.date, required this.hoursSaved});
}

class RecentConversation {
  final String id;
  final String topic;
  final String user;
  final String time;

  RecentConversation({
    required this.id,
    required this.topic,
    required this.user,
    required this.time,
  });
}

class PendingSuggestion {
  final String id;
  final String description;
  final String impact;

  PendingSuggestion({
    required this.id,
    required this.description,
    required this.impact,
  });
}

class AiHealthStatus {
  final String service;
  final String status;
  final int uptime; // percentage

  AiHealthStatus({
    required this.service,
    required this.status,
    required this.uptime,
  });
}

class AiDashboardState {
  final bool isLoading;
  final AiKpis? kpis;
  final List<AiUsageTrend> usageTrends;
  final List<DepartmentUsage> departmentUsage;
  final List<RequestTypeDistribution> requestTypes;
  final List<AutomationTrend> automationTrends;
  final List<RecentConversation> recentConversations;
  final List<PendingSuggestion> pendingSuggestions;
  final List<String> topFeatures;
  final List<String> popularPrompts;
  final List<AiHealthStatus> healthStatus;
  
  final String timeFilter;
  final String organizationFilter;
  final String departmentFilter;

  AiDashboardState({
    this.isLoading = false,
    this.kpis,
    this.usageTrends = const [],
    this.departmentUsage = const [],
    this.requestTypes = const [],
    this.automationTrends = const [],
    this.recentConversations = const [],
    this.pendingSuggestions = const [],
    this.topFeatures = const [],
    this.popularPrompts = const [],
    this.healthStatus = const [],
    this.timeFilter = 'Today',
    this.organizationFilter = 'All',
    this.departmentFilter = 'All',
  });

  AiDashboardState copyWith({
    bool? isLoading,
    AiKpis? kpis,
    List<AiUsageTrend>? usageTrends,
    List<DepartmentUsage>? departmentUsage,
    List<RequestTypeDistribution>? requestTypes,
    List<AutomationTrend>? automationTrends,
    List<RecentConversation>? recentConversations,
    List<PendingSuggestion>? pendingSuggestions,
    List<String>? topFeatures,
    List<String>? popularPrompts,
    List<AiHealthStatus>? healthStatus,
    String? timeFilter,
    String? organizationFilter,
    String? departmentFilter,
  }) {
    return AiDashboardState(
      isLoading: isLoading ?? this.isLoading,
      kpis: kpis ?? this.kpis,
      usageTrends: usageTrends ?? this.usageTrends,
      departmentUsage: departmentUsage ?? this.departmentUsage,
      requestTypes: requestTypes ?? this.requestTypes,
      automationTrends: automationTrends ?? this.automationTrends,
      recentConversations: recentConversations ?? this.recentConversations,
      pendingSuggestions: pendingSuggestions ?? this.pendingSuggestions,
      topFeatures: topFeatures ?? this.topFeatures,
      popularPrompts: popularPrompts ?? this.popularPrompts,
      healthStatus: healthStatus ?? this.healthStatus,
      timeFilter: timeFilter ?? this.timeFilter,
      organizationFilter: organizationFilter ?? this.organizationFilter,
      departmentFilter: departmentFilter ?? this.departmentFilter,
    );
  }
}
