enum ScheduleFrequency { daily, weekly, monthly, yearly }
enum DeliveryMethod { email, sms, whatsapp, inApp }
enum ExportFormat { pdf, excel, csv }
enum ScheduleStatus { active, paused, failed }

class ScheduledReportModel {
  final String id;
  final String name;
  final String reportName;
  final ScheduleFrequency frequency;
  final List<String> recipients;
  final List<DeliveryMethod> deliveryMethods;
  final ExportFormat exportFormat;
  final DateTime? lastRun;
  final DateTime nextRun;
  final ScheduleStatus status;

  ScheduledReportModel({
    required this.id,
    required this.name,
    required this.reportName,
    required this.frequency,
    required this.recipients,
    required this.deliveryMethods,
    required this.exportFormat,
    this.lastRun,
    required this.nextRun,
    required this.status,
  });

  ScheduledReportModel copyWith({
    String? id,
    String? name,
    String? reportName,
    ScheduleFrequency? frequency,
    List<String>? recipients,
    List<DeliveryMethod>? deliveryMethods,
    ExportFormat? exportFormat,
    DateTime? lastRun,
    DateTime? nextRun,
    ScheduleStatus? status,
  }) {
    return ScheduledReportModel(
      id: id ?? this.id,
      name: name ?? this.name,
      reportName: reportName ?? this.reportName,
      frequency: frequency ?? this.frequency,
      recipients: recipients ?? this.recipients,
      deliveryMethods: deliveryMethods ?? this.deliveryMethods,
      exportFormat: exportFormat ?? this.exportFormat,
      lastRun: lastRun ?? this.lastRun,
      nextRun: nextRun ?? this.nextRun,
      status: status ?? this.status,
    );
  }
}
