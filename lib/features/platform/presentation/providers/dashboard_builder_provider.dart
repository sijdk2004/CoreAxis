import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../../domain/dashboard_builder_model.dart';

final dashboardBuilderProvider = NotifierProvider<DashboardBuilderNotifier, DashboardBuilderState>(() {
  return DashboardBuilderNotifier();
});

class DashboardBuilderNotifier extends Notifier<DashboardBuilderState> {
  final _random = Random();
  
  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString() + _random.nextInt(1000).toString();

  @override
  DashboardBuilderState build() {
    return const DashboardBuilderState(
      widgets: [],
      history: [[]], // Initial empty state in history
      historyIndex: 0,
    );
  }

  final List<DashboardDataSource> availableDataSources = [
    const DashboardDataSource(id: 'ds_rev', name: 'Revenue', icon: Icons.attach_money),
    const DashboardDataSource(id: 'ds_work', name: 'Workflow', icon: Icons.schema),
    const DashboardDataSource(id: 'ds_prod', name: 'Production', icon: Icons.factory),
    const DashboardDataSource(id: 'ds_usr', name: 'Users', icon: Icons.people),
    const DashboardDataSource(id: 'ds_notif', name: 'Notifications', icon: Icons.notifications),
  ];

  void _saveHistory(List<DashboardWidgetConfig> newWidgets) {
    // If we're not at the end of the history, discard future states
    List<List<DashboardWidgetConfig>> newHistory = List.from(state.history.sublist(0, state.historyIndex + 1));
    newHistory.add(List.from(newWidgets));
    
    // Limit history to 20 steps
    if (newHistory.length > 20) {
      newHistory.removeAt(0);
    }
    
    state = state.copyWith(
      widgets: newWidgets,
      history: newHistory,
      historyIndex: newHistory.length - 1,
    );
  }

  void addWidget(DashboardWidgetType type, Offset position) {
    final newWidget = DashboardWidgetConfig(
      id: _generateId(),
      type: type,
      position: position,
      size: const Size(400, 300), // Default size
      title: 'New ${type.label}',
    );

    final newWidgets = List<DashboardWidgetConfig>.from(state.widgets)..add(newWidget);
    _saveHistory(newWidgets);
    selectWidget(newWidget.id);
  }

  void updateWidgetPosition(String id, Offset newPosition) {
    final newWidgets = state.widgets.map((w) {
      if (w.id == id) {
        return w.copyWith(position: newPosition);
      }
      return w;
    }).toList();
    
    state = state.copyWith(widgets: newWidgets);
  }
  
  void commitWidgetMove() {
    // Save to history after pan ends
    _saveHistory(state.widgets);
  }

  void updateWidgetSize(String id, Size newSize) {
    final newWidgets = state.widgets.map((w) {
      if (w.id == id) {
        return w.copyWith(size: newSize);
      }
      return w;
    }).toList();
    
    state = state.copyWith(widgets: newWidgets);
  }

  void removeWidget(String id) {
    final newWidgets = state.widgets.where((w) => w.id != id).toList();
    _saveHistory(newWidgets);
    if (state.selectedWidgetId == id) {
      selectWidget(null);
    }
  }

  void selectWidget(String? id) {
    state = state.copyWith(
      selectedWidgetId: id,
      clearSelectedWidget: id == null,
    );
  }

  void updateWidgetProperty(String id, String property, dynamic value) {
    final newWidgets = state.widgets.map((w) {
      if (w.id == id) {
        switch (property) {
          case 'title':
            return w.copyWith(title: value as String);
          case 'dataSourceId':
            return w.copyWith(dataSourceId: value as String?);
          case 'colorScheme':
            return w.copyWith(colorScheme: value as String);
          case 'filter':
            return w.copyWith(filter: value as String);
          case 'dateRange':
            return w.copyWith(dateRange: value as String);
          default:
            return w;
        }
      }
      return w;
    }).toList();
    
    _saveHistory(newWidgets);
  }

  void togglePreviewMode() {
    state = state.copyWith(
      isPreviewMode: !state.isPreviewMode,
      clearSelectedWidget: true,
    );
  }

  void undo() {
    if (state.historyIndex > 0) {
      final newIndex = state.historyIndex - 1;
      state = state.copyWith(
        widgets: List.from(state.history[newIndex]),
        historyIndex: newIndex,
        clearSelectedWidget: true,
      );
    }
  }

  void redo() {
    if (state.historyIndex < state.history.length - 1) {
      final newIndex = state.historyIndex + 1;
      state = state.copyWith(
        widgets: List.from(state.history[newIndex]),
        historyIndex: newIndex,
        clearSelectedWidget: true,
      );
    }
  }
}
