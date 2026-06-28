import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkflowSettingsState {
  final bool isLoading;
  final bool isSaving;
  final bool saveSuccess;

  // General
  final int defaultTimeoutHours;
  final String businessCalendar;
  final String workingHoursStart;
  final String workingHoursEnd;

  // Execution
  final bool parallelProcessing;
  final int retryCount;
  final String queueStrategy;

  // Notifications
  final bool emailEnabled;
  final bool smsEnabled;
  final bool whatsappEnabled;
  final bool pushEnabled;

  // Escalations
  final int reminderIntervalHours;
  final String defaultEscalationRule;

  // Versioning
  final bool autoVersion;
  final String draftHandling;

  // Security
  final bool inheritPermissions;
  final bool auditLogging;

  WorkflowSettingsState({
    this.isLoading = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.defaultTimeoutHours = 24,
    this.businessCalendar = 'Standard 5-Day',
    this.workingHoursStart = '09:00',
    this.workingHoursEnd = '17:00',
    this.parallelProcessing = true,
    this.retryCount = 3,
    this.queueStrategy = 'FIFO',
    this.emailEnabled = true,
    this.smsEnabled = false,
    this.whatsappEnabled = false,
    this.pushEnabled = true,
    this.reminderIntervalHours = 4,
    this.defaultEscalationRule = 'Manager Review',
    this.autoVersion = true,
    this.draftHandling = 'Keep indefinitely',
    this.inheritPermissions = true,
    this.auditLogging = true,
  });

  WorkflowSettingsState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? saveSuccess,
    int? defaultTimeoutHours,
    String? businessCalendar,
    String? workingHoursStart,
    String? workingHoursEnd,
    bool? parallelProcessing,
    int? retryCount,
    String? queueStrategy,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? whatsappEnabled,
    bool? pushEnabled,
    int? reminderIntervalHours,
    String? defaultEscalationRule,
    bool? autoVersion,
    String? draftHandling,
    bool? inheritPermissions,
    bool? auditLogging,
  }) {
    return WorkflowSettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      defaultTimeoutHours: defaultTimeoutHours ?? this.defaultTimeoutHours,
      businessCalendar: businessCalendar ?? this.businessCalendar,
      workingHoursStart: workingHoursStart ?? this.workingHoursStart,
      workingHoursEnd: workingHoursEnd ?? this.workingHoursEnd,
      parallelProcessing: parallelProcessing ?? this.parallelProcessing,
      retryCount: retryCount ?? this.retryCount,
      queueStrategy: queueStrategy ?? this.queueStrategy,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      reminderIntervalHours: reminderIntervalHours ?? this.reminderIntervalHours,
      defaultEscalationRule: defaultEscalationRule ?? this.defaultEscalationRule,
      autoVersion: autoVersion ?? this.autoVersion,
      draftHandling: draftHandling ?? this.draftHandling,
      inheritPermissions: inheritPermissions ?? this.inheritPermissions,
      auditLogging: auditLogging ?? this.auditLogging,
    );
  }
}

class WorkflowSettingsNotifier extends Notifier<WorkflowSettingsState> {
  @override
  WorkflowSettingsState build() {
    return WorkflowSettingsState(); // Initialize with defaults
  }

  void updateSetting({
    int? defaultTimeoutHours,
    String? businessCalendar,
    String? workingHoursStart,
    String? workingHoursEnd,
    bool? parallelProcessing,
    int? retryCount,
    String? queueStrategy,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? whatsappEnabled,
    bool? pushEnabled,
    int? reminderIntervalHours,
    String? defaultEscalationRule,
    bool? autoVersion,
    String? draftHandling,
    bool? inheritPermissions,
    bool? auditLogging,
  }) {
    state = state.copyWith(
      saveSuccess: false, // reset success state on edit
      defaultTimeoutHours: defaultTimeoutHours,
      businessCalendar: businessCalendar,
      workingHoursStart: workingHoursStart,
      workingHoursEnd: workingHoursEnd,
      parallelProcessing: parallelProcessing,
      retryCount: retryCount,
      queueStrategy: queueStrategy,
      emailEnabled: emailEnabled,
      smsEnabled: smsEnabled,
      whatsappEnabled: whatsappEnabled,
      pushEnabled: pushEnabled,
      reminderIntervalHours: reminderIntervalHours,
      defaultEscalationRule: defaultEscalationRule,
      autoVersion: autoVersion,
      draftHandling: draftHandling,
      inheritPermissions: inheritPermissions,
      auditLogging: auditLogging,
    );
  }

  Future<void> saveSettings() async {
    state = state.copyWith(isSaving: true, saveSuccess: false);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    state = state.copyWith(isSaving: false, saveSuccess: true);
    
    // Reset success banner after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (state.saveSuccess) {
        state = state.copyWith(saveSuccess: false);
      }
    });
  }
}

final workflowSettingsProvider = NotifierProvider<WorkflowSettingsNotifier, WorkflowSettingsState>(() {
  return WorkflowSettingsNotifier();
});
