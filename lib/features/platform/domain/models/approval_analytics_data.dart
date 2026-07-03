class ApprovalAnalyticsData {
  final Map<String, String> kpis;
  final List<ChartDataPoint> trendData;
  final List<CategoryDataPoint> departmentData;
  final List<CategoryDataPoint> slaCompliance;
  final List<PerformanceDataPoint> approverPerformance;
  final List<HeatmapDataPoint> activityHeatmap;
  final List<String> topBottlenecks;
  final List<String> slowestApprovers;
  final List<String> fastestApprovers;
  final String pendingTrends;
  final List<String> aiRecommendations;

  ApprovalAnalyticsData({
    required this.kpis,
    required this.trendData,
    required this.departmentData,
    required this.slaCompliance,
    required this.approverPerformance,
    required this.activityHeatmap,
    required this.topBottlenecks,
    required this.slowestApprovers,
    required this.fastestApprovers,
    required this.pendingTrends,
    required this.aiRecommendations,
  });
}

class ChartDataPoint {
  final String label;
  final double value;
  final double? secondaryValue;

  ChartDataPoint(this.label, this.value, [this.secondaryValue]);
}

class CategoryDataPoint {
  final String category;
  final double value;
  final String? colorHex;

  CategoryDataPoint(this.category, this.value, [this.colorHex]);
}

class PerformanceDataPoint {
  final String name;
  final double volume;
  final double averageTimeHours;

  PerformanceDataPoint(this.name, this.volume, this.averageTimeHours);
}

class HeatmapDataPoint {
  final int dayOfWeek; // 0 (Mon) to 6 (Sun)
  final int hourOfDay; // 0 to 23
  final int intensity; // e.g., number of approvals

  HeatmapDataPoint(this.dayOfWeek, this.hourOfDay, this.intensity);
}
