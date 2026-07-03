import 'package:flutter/material.dart';

enum DashboardWidgetType {
  kpiCard('KPI Card', Icons.score),
  chart('Chart', Icons.bar_chart),
  table('Table', Icons.table_chart),
  map('Map', Icons.map),
  gauge('Gauge', Icons.speed),
  calendar('Calendar', Icons.calendar_today),
  timeline('Timeline', Icons.timeline),
  heatmap('Heatmap', Icons.grid_view),
  pivot('Pivot Table', Icons.pivot_table_chart);

  final String label;
  final IconData icon;
  const DashboardWidgetType(this.label, this.icon);
}

class DashboardDataSource {
  final String id;
  final String name;
  final IconData icon;

  const DashboardDataSource({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class DashboardWidgetConfig {
  final String id;
  final DashboardWidgetType type;
  final Offset position;
  final Size size;
  final String title;

  // Mock property bindings
  final String? dataSourceId;
  final String colorScheme;
  final String filter;
  final String dateRange;

  const DashboardWidgetConfig({
    required this.id,
    required this.type,
    required this.position,
    required this.size,
    required this.title,
    this.dataSourceId,
    this.colorScheme = 'Default',
    this.filter = 'None',
    this.dateRange = 'Last 30 Days',
  });

  DashboardWidgetConfig copyWith({
    String? id,
    DashboardWidgetType? type,
    Offset? position,
    Size? size,
    String? title,
    String? dataSourceId,
    String? colorScheme,
    String? filter,
    String? dateRange,
  }) {
    return DashboardWidgetConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      size: size ?? this.size,
      title: title ?? this.title,
      dataSourceId: dataSourceId ?? this.dataSourceId,
      colorScheme: colorScheme ?? this.colorScheme,
      filter: filter ?? this.filter,
      dateRange: dateRange ?? this.dateRange,
    );
  }
}

class DashboardBuilderState {
  final List<DashboardWidgetConfig> widgets;
  final String? selectedWidgetId;
  final bool isPreviewMode;

  // History for undo/redo
  final List<List<DashboardWidgetConfig>> history;
  final int historyIndex;

  const DashboardBuilderState({
    this.widgets = const [],
    this.selectedWidgetId,
    this.isPreviewMode = false,
    this.history = const [],
    this.historyIndex = -1,
  });

  DashboardBuilderState copyWith({
    List<DashboardWidgetConfig>? widgets,
    String? selectedWidgetId,
    bool? isPreviewMode,
    List<List<DashboardWidgetConfig>>? history,
    int? historyIndex,
    bool clearSelectedWidget = false,
  }) {
    return DashboardBuilderState(
      widgets: widgets ?? this.widgets,
      selectedWidgetId: clearSelectedWidget ? null : (selectedWidgetId ?? this.selectedWidgetId),
      isPreviewMode: isPreviewMode ?? this.isPreviewMode,
      history: history ?? this.history,
      historyIndex: historyIndex ?? this.historyIndex,
    );
  }
}
