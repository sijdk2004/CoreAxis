import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/report_builder_model.dart';
import 'dart:math';

final reportBuilderProvider = NotifierProvider<ReportBuilderNotifier, ReportBuilderState>(() {
  return ReportBuilderNotifier();
});

class ReportBuilderNotifier extends Notifier<ReportBuilderState> {
  @override
  ReportBuilderState build() {
    return const ReportBuilderState();
  }

  void _pushHistory(List<CanvasComponent> newComponents) {
    final currentHistory = state.history.sublist(0, state.historyIndex + 1);
    currentHistory.add(state.components);
    
    state = state.copyWith(
      components: newComponents,
      history: currentHistory,
      historyIndex: currentHistory.length,
    );
  }

  void addComponent(ComponentType type, Offset position) {
    final newComponent = CanvasComponent(
      id: 'COMP-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      position: position,
      size: const Size(400, 300),
      title: 'New ${type.label}',
    );

    final newComponents = List<CanvasComponent>.from(state.components)..add(newComponent);
    _pushHistory(newComponents);
    selectComponent(newComponent.id);
  }

  void updateComponentPosition(String id, Offset newPosition) {
    final newComponents = state.components.map((c) {
      if (c.id == id) {
        return c.copyWith(position: newPosition);
      }
      return c;
    }).toList();
    
    // Don't push to history for every micro-movement, just update state directly
    // In a real app we'd debounce this before pushing to history
    state = state.copyWith(components: newComponents);
  }
  
  void commitComponentMove() {
      // Call this when dragging ends to save to history
      final currentHistory = state.history.sublist(0, state.historyIndex + 1);
      currentHistory.add(state.components);
      state = state.copyWith(
        history: currentHistory,
        historyIndex: currentHistory.length,
      );
  }

  void updateComponentSize(String id, Size newSize) {
    final newComponents = state.components.map((c) {
      if (c.id == id) {
        return c.copyWith(size: newSize);
      }
      return c;
    }).toList();
    
    state = state.copyWith(components: newComponents);
  }

  void selectComponent(String? id) {
    state = state.copyWith(selectedComponentId: id ?? '');
  }

  void removeComponent(String id) {
    final newComponents = state.components.where((c) => c.id != id).toList();
    _pushHistory(newComponents);
    if (state.selectedComponentId == id) {
      selectComponent(null);
    }
  }

  void addFieldToComponent(String componentId, String fieldName, String target) {
    final newComponents = state.components.map((c) {
      if (c.id == componentId) {
        if (target == 'columns' && !c.columns.contains(fieldName)) {
          return c.copyWith(columns: [...c.columns, fieldName]);
        } else if (target == 'values' && !c.values.contains(fieldName)) {
          return c.copyWith(values: [...c.values, fieldName]);
        } else if (target == 'filters' && !c.filters.contains(fieldName)) {
          return c.copyWith(filters: [...c.filters, fieldName]);
        }
      }
      return c;
    }).toList();
    
    _pushHistory(newComponents);
  }
  
  void removeFieldFromComponent(String componentId, String fieldName, String target) {
      final newComponents = state.components.map((c) {
        if (c.id == componentId) {
          if (target == 'columns') {
            return c.copyWith(columns: c.columns.where((f) => f != fieldName).toList());
          } else if (target == 'values') {
            return c.copyWith(values: c.values.where((f) => f != fieldName).toList());
          } else if (target == 'filters') {
            return c.copyWith(filters: c.filters.where((f) => f != fieldName).toList());
          }
        }
        return c;
      }).toList();
      
      _pushHistory(newComponents);
  }

  void undo() {
    if (state.historyIndex > 0) {
      final newIndex = state.historyIndex - 1;
      state = state.copyWith(
        components: state.history[newIndex],
        historyIndex: newIndex,
      );
    } else if (state.historyIndex == 0) {
        // Revert to empty initial state
        state = state.copyWith(
            components: [],
            historyIndex: -1,
        );
    }
  }

  void redo() {
    if (state.historyIndex < state.history.length - 1) {
      final newIndex = state.historyIndex + 1;
      state = state.copyWith(
        components: state.history[newIndex],
        historyIndex: newIndex,
      );
    }
  }

  void togglePreview() {
    state = state.copyWith(isPreviewMode: !state.isPreviewMode);
    selectComponent(null);
  }

  // Mock Data Sources
  List<DataSourceEntity> get availableDataSources => [
    DataSourceEntity(id: 'ds1', name: 'Users', icon: LucideIcons.users, fields: const ['ID', 'Name', 'Email', 'Role', 'Status', 'Last Login']),
    DataSourceEntity(id: 'ds2', name: 'Organizations', icon: LucideIcons.building, fields: const ['Org ID', 'Name', 'Industry', 'Region', 'Employee Count', 'Revenue']),
    DataSourceEntity(id: 'ds3', name: 'Tenants', icon: LucideIcons.layoutGrid, fields: const ['Tenant ID', 'Domain', 'Plan Tier', 'Created Date', 'Status']),
    DataSourceEntity(id: 'ds4', name: 'Workflows', icon: LucideIcons.workflow, fields: const ['Workflow ID', 'Name', 'Creator', 'Executions', 'Success Rate', 'Avg Duration']),
    DataSourceEntity(id: 'ds5', name: 'Approvals', icon: LucideIcons.checkSquare, fields: const ['Approval ID', 'Type', 'Requester', 'Approver', 'Status', 'SLA Breached']),
    DataSourceEntity(id: 'ds6', name: 'Notifications', icon: LucideIcons.bell, fields: const ['Message ID', 'Channel', 'Recipient', 'Sent Time', 'Open Rate', 'Click Rate']),
    DataSourceEntity(id: 'ds7', name: 'Documents', icon: LucideIcons.fileText, fields: const ['Doc ID', 'Title', 'Category', 'Size', 'Uploader', 'Views', 'Downloads']),
    DataSourceEntity(id: 'ds8', name: 'Audit Logs', icon: LucideIcons.shieldCheck, fields: const ['Event ID', 'Action', 'User', 'IP Address', 'Resource', 'Timestamp', 'Severity']),
  ];
  
  List<DataSourceEntity> get industryPacks => [
      DataSourceEntity(id: 'pack1', name: 'Furniture ERP', icon: LucideIcons.sofa, fields: const ['Order ID', 'Product SKU', 'Wood Type', 'Fabric', 'Factory Line', 'Shipping Status']),
  ];
}
