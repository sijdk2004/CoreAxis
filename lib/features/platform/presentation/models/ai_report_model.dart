import 'package:flutter/foundation.dart';

@immutable
class AIReportKpi {
  final String label;
  final String value;
  final String trend;
  final bool isPositive;

  const AIReportKpi({
    required this.label,
    required this.value,
    required this.trend,
    required this.isPositive,
  });
}

@immutable
class AIReportChartData {
  final String label;
  final double value;

  const AIReportChartData({
    required this.label,
    required this.value,
  });
}

@immutable
class AIReportTableColumn {
  final String label;
  final String key;

  const AIReportTableColumn({
    required this.label,
    required this.key,
  });
}

@immutable
class AIReportSection {
  final String title;
  final String type; // 'kpi', 'chart', 'table'
  
  // For KPIs
  final List<AIReportKpi>? kpis;
  
  // For Charts (simplified)
  final String? chartType; // 'bar', 'line', 'pie'
  final List<AIReportChartData>? chartData;
  
  // For Tables
  final List<AIReportTableColumn>? tableColumns;
  final List<Map<String, dynamic>>? tableData;

  const AIReportSection({
    required this.title,
    required this.type,
    this.kpis,
    this.chartType,
    this.chartData,
    this.tableColumns,
    this.tableData,
  });
}

@immutable
class AIReport {
  final String id;
  final String title;
  final String prompt;
  final DateTime generatedAt;
  final List<AIReportSection> sections;

  const AIReport({
    required this.id,
    required this.title,
    required this.prompt,
    required this.generatedAt,
    required this.sections,
  });
}
