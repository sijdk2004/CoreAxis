import 'package:flutter/foundation.dart';

@immutable
class AiSettingsModel {
  final bool enableAi;
  final bool allowFileAnalysis;
  final bool allowReportGeneration;
  final String defaultModel;
  final int maxDailyRequests;
  final String conversationRetention; // e.g. "30 Days", "90 Days", "Forever"
  final bool auditAiUsage;
  
  // Tab states or extra details could also go here
  final bool anonymizeData;
  final bool requireApprovalForExecution;
  final String loggingLevel;

  const AiSettingsModel({
    required this.enableAi,
    required this.allowFileAnalysis,
    required this.allowReportGeneration,
    required this.defaultModel,
    required this.maxDailyRequests,
    required this.conversationRetention,
    required this.auditAiUsage,
    this.anonymizeData = true,
    this.requireApprovalForExecution = true,
    this.loggingLevel = 'Detailed',
  });

  AiSettingsModel copyWith({
    bool? enableAi,
    bool? allowFileAnalysis,
    bool? allowReportGeneration,
    String? defaultModel,
    int? maxDailyRequests,
    String? conversationRetention,
    bool? auditAiUsage,
    bool? anonymizeData,
    bool? requireApprovalForExecution,
    String? loggingLevel,
  }) {
    return AiSettingsModel(
      enableAi: enableAi ?? this.enableAi,
      allowFileAnalysis: allowFileAnalysis ?? this.allowFileAnalysis,
      allowReportGeneration: allowReportGeneration ?? this.allowReportGeneration,
      defaultModel: defaultModel ?? this.defaultModel,
      maxDailyRequests: maxDailyRequests ?? this.maxDailyRequests,
      conversationRetention: conversationRetention ?? this.conversationRetention,
      auditAiUsage: auditAiUsage ?? this.auditAiUsage,
      anonymizeData: anonymizeData ?? this.anonymizeData,
      requireApprovalForExecution: requireApprovalForExecution ?? this.requireApprovalForExecution,
      loggingLevel: loggingLevel ?? this.loggingLevel,
    );
  }
}
