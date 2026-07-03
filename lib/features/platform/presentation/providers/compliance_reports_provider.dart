import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/compliance_reports_model.dart';

final complianceReportsProvider = NotifierProvider<ComplianceReportsNotifier, AsyncValue<ComplianceReportsModel>>(() {
  return ComplianceReportsNotifier();
});

class ComplianceReportsNotifier extends Notifier<AsyncValue<ComplianceReportsModel>> {
  @override
  AsyncValue<ComplianceReportsModel> build() {
    _loadMockData();
    return const AsyncValue.loading();
  }

  Future<void> _loadMockData() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final templates = [
      const ComplianceTemplate(
        id: 'TPL-001',
        name: 'ISO 27001 Access Review',
        description: 'Comprehensive report of user access rights and privilege changes to meet ISO 27001 A.9 requirements.',
        standard: 'ISO 27001',
        icon: LucideIcons.shieldCheck,
      ),
      const ComplianceTemplate(
        id: 'TPL-002',
        name: 'SOC 2 Security Audit',
        description: 'Detailed log of security events, failed logins, and authorization changes for SOC 2 compliance.',
        standard: 'SOC 2',
        icon: LucideIcons.fileCheck2,
      ),
      const ComplianceTemplate(
        id: 'TPL-003',
        name: 'GDPR Data Processing',
        description: 'Tracks PII access, modifications, and deletion requests for GDPR compliance.',
        standard: 'GDPR',
        icon: LucideIcons.globe,
      ),
      const ComplianceTemplate(
        id: 'TPL-004',
        name: 'Internal Audit Summary',
        description: 'General system configuration and critical entity modifications for internal review.',
        standard: 'Internal',
        icon: LucideIcons.building,
      ),
      const ComplianceTemplate(
        id: 'TPL-005',
        name: 'Security Incident Report',
        description: 'Summary of detected anomalies, risk distributions, and automated mitigations.',
        standard: 'Security',
        icon: LucideIcons.alertTriangle,
      ),
      const ComplianceTemplate(
        id: 'TPL-006',
        name: 'User Activity Report',
        description: 'Chronological list of all actions performed by selected users or roles.',
        standard: 'Activity',
        icon: LucideIcons.users,
      ),
      const ComplianceTemplate(
        id: 'TPL-007',
        name: 'Permission Changes',
        description: 'Audit trail of all RBAC assignments, role modifications, and policy updates.',
        standard: 'RBAC',
        icon: LucideIcons.key,
      ),
      const ComplianceTemplate(
        id: 'TPL-008',
        name: 'Workflow Modifications',
        description: 'History of changes to workflow definitions, approval steps, and automations.',
        standard: 'Workflow',
        icon: LucideIcons.gitMerge,
      ),
    ];

    final history = [
      ComplianceReportHistory(
        id: 'REP-901',
        templateName: 'ISO 27001 Access Review',
        generatedOn: DateTime.now().subtract(const Duration(days: 1)),
        generatedBy: 'System Administrator',
        format: 'PDF',
        status: ReportStatus.completed,
      ),
      ComplianceReportHistory(
        id: 'REP-902',
        templateName: 'SOC 2 Security Audit',
        generatedOn: DateTime.now().subtract(const Duration(days: 3)),
        generatedBy: 'Jane Smith',
        format: 'Excel',
        status: ReportStatus.completed,
      ),
      ComplianceReportHistory(
        id: 'REP-903',
        templateName: 'GDPR Data Processing',
        generatedOn: DateTime.now().add(const Duration(hours: 2)),
        generatedBy: 'Scheduled System Task',
        format: 'PDF',
        status: ReportStatus.scheduled,
      ),
      ComplianceReportHistory(
        id: 'REP-904',
        templateName: 'User Activity Report',
        generatedOn: DateTime.now().subtract(const Duration(minutes: 5)),
        generatedBy: 'Admin User',
        format: 'PDF',
        status: ReportStatus.processing,
      ),
    ];

    state = AsyncValue.data(ComplianceReportsModel(
      templates: templates,
      history: history,
      selectedTemplateId: templates.first.id,
      filterStartDate: DateTime.now().subtract(const Duration(days: 30)),
      filterEndDate: DateTime.now(),
    ));
  }

  void selectTemplate(String templateId) {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(selectedTemplateId: templateId));
    }
  }

  void updateDateRange(DateTime start, DateTime end) {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(filterStartDate: start, filterEndDate: end));
    }
  }
}
