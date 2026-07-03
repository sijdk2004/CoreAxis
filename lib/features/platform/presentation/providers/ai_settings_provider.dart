import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_settings_model.dart';

class AiSettingsState {
  final AiSettingsModel settings;
  final bool isSaving;
  final String activeTab;

  const AiSettingsState({
    required this.settings,
    this.isSaving = false,
    this.activeTab = 'General',
  });

  AiSettingsState copyWith({
    AiSettingsModel? settings,
    bool? isSaving,
    String? activeTab,
  }) {
    return AiSettingsState(
      settings: settings ?? this.settings,
      isSaving: isSaving ?? this.isSaving,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

class AiSettingsNotifier extends Notifier<AiSettingsState> {
  @override
  AiSettingsState build() {
    return const AiSettingsState(
      settings: AiSettingsModel(
        enableAi: true,
        allowFileAnalysis: true,
        allowReportGeneration: true,
        defaultModel: 'GPT-4 Turbo',
        maxDailyRequests: 5000,
        conversationRetention: '90 Days',
        auditAiUsage: true,
      ),
    );
  }

  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab);
  }

  void updateSettings(AiSettingsModel newSettings) {
    state = state.copyWith(settings: newSettings);
  }

  Future<void> saveSettings() async {
    state = state.copyWith(isSaving: true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isSaving: false);
  }
}

final aiSettingsProvider = NotifierProvider<AiSettingsNotifier, AiSettingsState>(() {
  return AiSettingsNotifier();
});
