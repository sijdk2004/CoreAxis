import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:math';

enum ActivityEventType {
  userCreated,
  workflowApproved,
  documentUploaded,
  productionStarted,
  salesOrderCreated,
  notificationSent,
  aiGeneratedReport
}

class ActivityEventModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final ActivityEventType type;

  const ActivityEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });

  IconData get icon {
    switch (type) {
      case ActivityEventType.userCreated:
        return LucideIcons.userPlus;
      case ActivityEventType.workflowApproved:
        return LucideIcons.checkCircle2;
      case ActivityEventType.documentUploaded:
        return LucideIcons.uploadCloud;
      case ActivityEventType.productionStarted:
        return LucideIcons.factory;
      case ActivityEventType.salesOrderCreated:
        return LucideIcons.shoppingCart;
      case ActivityEventType.notificationSent:
        return LucideIcons.bell;
      case ActivityEventType.aiGeneratedReport:
        return LucideIcons.sparkles;
    }
  }

  Color get color {
    switch (type) {
      case ActivityEventType.userCreated:
        return Colors.blue;
      case ActivityEventType.workflowApproved:
        return Colors.green;
      case ActivityEventType.documentUploaded:
        return Colors.orange;
      case ActivityEventType.productionStarted:
        return Colors.amber;
      case ActivityEventType.salesOrderCreated:
        return Colors.purple;
      case ActivityEventType.notificationSent:
        return Colors.red;
      case ActivityEventType.aiGeneratedReport:
        return Colors.indigo;
    }
  }

  static ActivityEventModel generateRandom() {
    final random = Random();
    final type = ActivityEventType.values[random.nextInt(ActivityEventType.values.length)];
    final String title;
    final String description;

    switch (type) {
      case ActivityEventType.userCreated:
        title = 'New User Created';
        description = 'A new user account was registered and activated in the region: ${['NA', 'EU', 'APAC'][random.nextInt(3)]}.';
        break;
      case ActivityEventType.workflowApproved:
        title = 'Workflow Approved';
        description = 'Manager ${['Sarah', 'John', 'Emily', 'Michael'][random.nextInt(4)]} approved the pending expense workflow.';
        break;
      case ActivityEventType.documentUploaded:
        title = 'Document Uploaded';
        description = 'File "${['Q3_Report', 'Invoice_982', 'Contract_Draft', 'Design_Specs'][random.nextInt(4)]}.pdf" was successfully uploaded to the repository.';
        break;
      case ActivityEventType.productionStarted:
        title = 'Production Started';
        description = 'Batch #${1000 + random.nextInt(9000)} has begun processing on Line ${1 + random.nextInt(5)}.';
        break;
      case ActivityEventType.salesOrderCreated:
        title = 'Sales Order Created';
        description = 'Order #${10000 + random.nextInt(90000)} was placed by ${['Acme Corp', 'Global Tech', 'Stark Ind.', 'Wayne Ent.'][random.nextInt(4)]}.';
        break;
      case ActivityEventType.notificationSent:
        title = 'Notification Sent';
        description = 'Automated system alert dispatched to ${5 + random.nextInt(20)} users regarding system maintenance.';
        break;
      case ActivityEventType.aiGeneratedReport:
        title = 'AI Generated Report';
        description = 'CoreAxis AI successfully synthesized weekly performance metrics into a new dashboard report.';
        break;
    }

    return ActivityEventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString() + random.nextInt(1000).toString(),
      title: title,
      description: description,
      timestamp: DateTime.now(),
      type: type,
    );
  }
}
