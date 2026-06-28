import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkflowStep {
  final int order;
  final String name;
  final String type;
  final String assignedRole;
  final int slaHours;
  final String status; // 'active', 'completed', 'pending'
  final String description;

  const WorkflowStep({
    required this.order,
    required this.name,
    required this.type,
    required this.assignedRole,
    required this.slaHours,
    required this.status,
    required this.description,
  });
}

class WorkflowVersion {
  final String version;
  final DateTime publishedAt;
  final String publishedBy;
  final String changeNotes;
  final bool isCurrent;

  const WorkflowVersion({
    required this.version,
    required this.publishedAt,
    required this.publishedBy,
    required this.changeNotes,
    required this.isCurrent,
  });
}

class WorkflowExecutionRecord {
  final String id;
  final String initiator;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final String duration;

  const WorkflowExecutionRecord({
    required this.id,
    required this.initiator,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.duration,
  });
}

class WorkflowAuditLog {
  final DateTime timestamp;
  final String actor;
  final String action;
  final String details;

  const WorkflowAuditLog({
    required this.timestamp,
    required this.actor,
    required this.action,
    required this.details,
  });
}

class WorkflowDetail {
  final String id;
  final String name;
  final String code;
  final String category;
  final String version;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String description;
  final List<WorkflowStep> steps;
  final List<WorkflowVersion> versions;
  final List<WorkflowExecutionRecord> executions;
  final List<WorkflowAuditLog> auditLogs;

  // KPI stats
  final int totalExecutions;
  final int successfulExecutions;
  final int failedExecutions;
  final String avgDuration;
  final double completionRate;
  final double failureRate;
  final int pendingApprovals;
  final List<double> executionTrend;

  const WorkflowDetail({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.version,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.publishedAt,
    required this.description,
    required this.steps,
    required this.versions,
    required this.executions,
    required this.auditLogs,
    required this.totalExecutions,
    required this.successfulExecutions,
    required this.failedExecutions,
    required this.avgDuration,
    required this.completionRate,
    required this.failureRate,
    required this.pendingApprovals,
    required this.executionTrend,
  });
}

final workflowDetailProvider = FutureProvider.family<WorkflowDetail, String>((ref, id) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return _getMockDetail(id);
});

WorkflowDetail _getMockDetail(String id) {
  return WorkflowDetail(
    id: id,
    name: 'Standard PO Approval Workflow',
    code: 'WF-PUR-001',
    category: 'Purchase',
    version: 'v2.1.0',
    status: 'Published',
    createdBy: 'Platform Admin',
    createdAt: DateTime.now().subtract(const Duration(days: 120)),
    publishedAt: DateTime.now().subtract(const Duration(days: 5)),
    description: 'This workflow manages the standard purchase order approval process for all procurement activities under a specified monetary threshold. It ensures compliance with internal controls and auditing requirements.',
    totalExecutions: 1248,
    successfulExecutions: 1190,
    failedExecutions: 58,
    avgDuration: '1h 42m',
    completionRate: 0.953,
    failureRate: 0.047,
    pendingApprovals: 12,
    executionTrend: [45, 62, 55, 78, 80, 95, 112, 104, 130, 118, 142, 136],
    steps: [
      const WorkflowStep(order: 1, name: 'PO Request Submitted', type: 'Start', assignedRole: 'Requestor', slaHours: 0, status: 'completed', description: 'Purchase order raised by the requesting department.'),
      const WorkflowStep(order: 2, name: 'Department Head Review', type: 'Approval', assignedRole: 'Dept Head', slaHours: 24, status: 'active', description: 'Department head verifies the necessity and budget alignment.'),
      const WorkflowStep(order: 3, name: 'Finance Verification', type: 'Approval', assignedRole: 'Finance Admin', slaHours: 48, status: 'pending', description: 'Finance team checks vendor credit, payment terms, and GL codes.'),
      const WorkflowStep(order: 4, name: 'Management Sign-off', type: 'Approval', assignedRole: 'VP Procurement', slaHours: 24, status: 'pending', description: 'Final management approval for POs above threshold limit.'),
      const WorkflowStep(order: 5, name: 'Notify Vendor', type: 'Notification', assignedRole: 'System', slaHours: 1, status: 'pending', description: 'Automated email sent to vendor with approved PO details.'),
      const WorkflowStep(order: 6, name: 'Completed', type: 'End', assignedRole: 'System', slaHours: 0, status: 'pending', description: 'Workflow completes and PO is marked as Approved.'),
    ],
    versions: [
      WorkflowVersion(version: 'v2.1.0', publishedAt: DateTime.now().subtract(const Duration(days: 5)), publishedBy: 'Admin User', changeNotes: 'Reduced SLA for Finance Verification from 72h to 48h.', isCurrent: true),
      WorkflowVersion(version: 'v2.0.0', publishedAt: DateTime.now().subtract(const Duration(days: 45)), publishedBy: 'Admin User', changeNotes: 'Added VP Procurement step for high-value POs.', isCurrent: false),
      WorkflowVersion(version: 'v1.2.1', publishedAt: DateTime.now().subtract(const Duration(days: 90)), publishedBy: 'Finance Lead', changeNotes: 'Bugfix: Notification email template corrected.', isCurrent: false),
      WorkflowVersion(version: 'v1.2.0', publishedAt: DateTime.now().subtract(const Duration(days: 120)), publishedBy: 'Finance Lead', changeNotes: 'Added Notify Vendor step on approval.', isCurrent: false),
    ],
    executions: [
      WorkflowExecutionRecord(id: 'EXEC-2301', initiator: 'John Doe', startTime: DateTime.now().subtract(const Duration(hours: 2)), endTime: DateTime.now().subtract(const Duration(minutes: 30)), status: 'completed', duration: '1h 30m'),
      WorkflowExecutionRecord(id: 'EXEC-2300', initiator: 'Jane Smith', startTime: DateTime.now().subtract(const Duration(hours: 5)), status: 'running', duration: '5h 12m'),
      WorkflowExecutionRecord(id: 'EXEC-2299', initiator: 'System', startTime: DateTime.now().subtract(const Duration(hours: 8)), endTime: DateTime.now().subtract(const Duration(hours: 6)), status: 'failed', duration: '2h 04m'),
      WorkflowExecutionRecord(id: 'EXEC-2298', initiator: 'Bob Johnson', startTime: DateTime.now().subtract(const Duration(days: 1)), endTime: DateTime.now().subtract(const Duration(hours: 22)), status: 'completed', duration: '2h 10m'),
      WorkflowExecutionRecord(id: 'EXEC-2297', initiator: 'Alice Brown', startTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)), endTime: DateTime.now().subtract(const Duration(days: 1)), status: 'completed', duration: '3h 05m'),
    ],
    auditLogs: [
      WorkflowAuditLog(timestamp: DateTime.now().subtract(const Duration(days: 5)), actor: 'Admin User', action: 'Published', details: 'Workflow published as version v2.1.0'),
      WorkflowAuditLog(timestamp: DateTime.now().subtract(const Duration(days: 6)), actor: 'Admin User', action: 'Updated', details: 'SLA for Finance step changed to 48h'),
      WorkflowAuditLog(timestamp: DateTime.now().subtract(const Duration(days: 45)), actor: 'Admin User', action: 'Published', details: 'Workflow published as version v2.0.0'),
      WorkflowAuditLog(timestamp: DateTime.now().subtract(const Duration(days: 46)), actor: 'Finance Lead', action: 'Step Added', details: 'Added VP Procurement approval step'),
    ],
  );
}
