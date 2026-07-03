enum SharePermission { view, download, edit, owner }
enum ShareType { user, role, organization, externalLink }

class ReportShareModel {
  final String id;
  final String reportName;
  final String recipientName; // User name, Role name, or Org name
  final ShareType type;
  final SharePermission permission;
  final DateTime sharedAt;
  final DateTime? expiresAt;
  final String? externalLink;

  ReportShareModel({
    required this.id,
    required this.reportName,
    required this.recipientName,
    required this.type,
    required this.permission,
    required this.sharedAt,
    this.expiresAt,
    this.externalLink,
  });

  ReportShareModel copyWith({
    String? id,
    String? reportName,
    String? recipientName,
    ShareType? type,
    SharePermission? permission,
    DateTime? sharedAt,
    DateTime? expiresAt,
    String? externalLink,
  }) {
    return ReportShareModel(
      id: id ?? this.id,
      reportName: reportName ?? this.reportName,
      recipientName: recipientName ?? this.recipientName,
      type: type ?? this.type,
      permission: permission ?? this.permission,
      sharedAt: sharedAt ?? this.sharedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      externalLink: externalLink ?? this.externalLink,
    );
  }
}
