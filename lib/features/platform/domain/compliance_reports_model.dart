import 'package:flutter/material.dart';

enum ReportStatus {
  completed,
  failed,
  processing,
  scheduled
}

class ComplianceTemplate {
  final String id;
  final String name;
  final String description;
  final String standard;
  final IconData icon;

  const ComplianceTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.standard,
    required this.icon,
  });
}

class ComplianceReportHistory {
  final String id;
  final String templateName;
  final DateTime generatedOn;
  final String generatedBy;
  final String format;
  final ReportStatus status;

  const ComplianceReportHistory({
    required this.id,
    required this.templateName,
    required this.generatedOn,
    required this.generatedBy,
    required this.format,
    required this.status,
  });
}

class ComplianceReportsModel {
  final List<ComplianceTemplate> templates;
  final List<ComplianceReportHistory> history;
  final String? selectedTemplateId;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final String? filterOrganizationId;
  final String? filterDepartmentId;
  final String? filterModuleId;

  const ComplianceReportsModel({
    required this.templates,
    required this.history,
    this.selectedTemplateId,
    this.filterStartDate,
    this.filterEndDate,
    this.filterOrganizationId,
    this.filterDepartmentId,
    this.filterModuleId,
  });

  ComplianceReportsModel copyWith({
    List<ComplianceTemplate>? templates,
    List<ComplianceReportHistory>? history,
    String? selectedTemplateId,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    String? filterOrganizationId,
    String? filterDepartmentId,
    String? filterModuleId,
  }) {
    return ComplianceReportsModel(
      templates: templates ?? this.templates,
      history: history ?? this.history,
      selectedTemplateId: selectedTemplateId ?? this.selectedTemplateId,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
      filterOrganizationId: filterOrganizationId ?? this.filterOrganizationId,
      filterDepartmentId: filterDepartmentId ?? this.filterDepartmentId,
      filterModuleId: filterModuleId ?? this.filterModuleId,
    );
  }
}
