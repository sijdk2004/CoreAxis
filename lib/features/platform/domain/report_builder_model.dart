import 'package:flutter/material.dart';

enum ComponentType {
  table('Table', Icons.table_chart),
  chart('Chart', Icons.bar_chart),
  pie('Pie Chart', Icons.pie_chart),
  bar('Bar Chart', Icons.bar_chart),
  line('Line Chart', Icons.show_chart),
  area('Area Chart', Icons.area_chart),
  kpi('KPI', Icons.score),
  gauge('Gauge', Icons.speed),
  pivot('Pivot Table', Icons.pivot_table_chart),
  heatmap('Heatmap', Icons.map),
  treeMap('Tree Map', Icons.account_tree);

  final String label;
  final IconData icon;
  const ComponentType(this.label, this.icon);
}

class DataSourceEntity {
  final String id;
  final String name;
  final IconData icon;
  final List<String> fields;

  const DataSourceEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.fields,
  });
}

class CanvasComponent {
  final String id;
  final ComponentType type;
  final Offset position;
  final Size size;
  final String title;
  
  // Assigned data properties
  final List<String> columns;
  final List<String> values;
  final List<String> filters;

  const CanvasComponent({
    required this.id,
    required this.type,
    required this.position,
    required this.size,
    required this.title,
    this.columns = const [],
    this.values = const [],
    this.filters = const [],
  });

  CanvasComponent copyWith({
    String? id,
    ComponentType? type,
    Offset? position,
    Size? size,
    String? title,
    List<String>? columns,
    List<String>? values,
    List<String>? filters,
  }) {
    return CanvasComponent(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      size: size ?? this.size,
      title: title ?? this.title,
      columns: columns ?? this.columns,
      values: values ?? this.values,
      filters: filters ?? this.filters,
    );
  }
}

class ReportBuilderState {
  final List<CanvasComponent> components;
  final String? selectedComponentId;
  final bool isPreviewMode;
  
  // History for undo/redo
  final List<List<CanvasComponent>> history;
  final int historyIndex;

  const ReportBuilderState({
    this.components = const [],
    this.selectedComponentId,
    this.isPreviewMode = false,
    this.history = const [],
    this.historyIndex = -1,
  });

  ReportBuilderState copyWith({
    List<CanvasComponent>? components,
    String? selectedComponentId,
    bool? isPreviewMode,
    List<List<CanvasComponent>>? history,
    int? historyIndex,
  }) {
    return ReportBuilderState(
      components: components ?? this.components,
      selectedComponentId: selectedComponentId == '' ? null : (selectedComponentId ?? this.selectedComponentId), // Pass empty string to clear
      isPreviewMode: isPreviewMode ?? this.isPreviewMode,
      history: history ?? this.history,
      historyIndex: historyIndex ?? this.historyIndex,
    );
  }
}
