import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// --- MODELS ---
class ComponentUsageStats {
  final String componentName;
  final int currentUsage;
  final int recommendedUsage;
  final double complianceScore;
  final String status;

  const ComponentUsageStats({
    required this.componentName,
    required this.currentUsage,
    required this.recommendedUsage,
    required this.complianceScore,
    required this.status,
  });
}

class DesignSystemAuditState {
  final int activeTabIndex;
  final List<ComponentUsageStats> usageStats;
  final bool isDarkModePreview;
  final String activeDevicePreview; // 'Desktop', 'Tablet', 'Mobile'

  const DesignSystemAuditState({
    this.activeTabIndex = 0,
    this.usageStats = const [],
    this.isDarkModePreview = false,
    this.activeDevicePreview = 'Desktop',
  });

  DesignSystemAuditState copyWith({
    int? activeTabIndex,
    List<ComponentUsageStats>? usageStats,
    bool? isDarkModePreview,
    String? activeDevicePreview,
  }) {
    return DesignSystemAuditState(
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      usageStats: usageStats ?? this.usageStats,
      isDarkModePreview: isDarkModePreview ?? this.isDarkModePreview,
      activeDevicePreview: activeDevicePreview ?? this.activeDevicePreview,
    );
  }
}

// --- NOTIFIER ---
class DesignSystemAuditNotifier extends Notifier<DesignSystemAuditState> {
  @override
  DesignSystemAuditState build() {
    return const DesignSystemAuditState(
      usageStats: [
        ComponentUsageStats(componentName: 'Primary Button', currentUsage: 245, recommendedUsage: 250, complianceScore: 98.0, status: 'Compliant'),
        ComponentUsageStats(componentName: 'Secondary Button', currentUsage: 120, recommendedUsage: 120, complianceScore: 100.0, status: 'Compliant'),
        ComponentUsageStats(componentName: 'Cards (Premium)', currentUsage: 45, recommendedUsage: 50, complianceScore: 90.0, status: 'Review'),
        ComponentUsageStats(componentName: 'AppTable', currentUsage: 30, recommendedUsage: 30, complianceScore: 100.0, status: 'Compliant'),
        ComponentUsageStats(componentName: 'Custom Dialogs', currentUsage: 12, recommendedUsage: 0, complianceScore: 40.0, status: 'Non-Compliant'),
        ComponentUsageStats(componentName: 'Legacy Badges', currentUsage: 8, recommendedUsage: 0, complianceScore: 20.0, status: 'Deprecated'),
      ],
    );
  }

  void setActiveTab(int index) {
    state = state.copyWith(activeTabIndex: index);
  }

  void toggleDarkModePreview(bool isDark) {
    state = state.copyWith(isDarkModePreview: isDark);
  }

  void setActiveDevicePreview(String device) {
    state = state.copyWith(activeDevicePreview: device);
  }
}

final designSystemAuditProvider = NotifierProvider<DesignSystemAuditNotifier, DesignSystemAuditState>(DesignSystemAuditNotifier.new);
