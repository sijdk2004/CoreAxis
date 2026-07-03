class DocumentViewerContext {
  final String id;
  final String name;
  final String type; // 'pdf', 'word', 'excel', 'image', 'cad'
  final double sizeMb;
  final String owner;
  final String category;
  final List<String> tags;
  final String status;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String version;
  final String description;
  
  final List<DocumentVersion> versions;
  final List<DocumentComment> comments;
  final List<DocumentAuditLog> auditLogs;
  final List<String> sharedWith;

  DocumentViewerContext({
    required this.id,
    required this.name,
    required this.type,
    required this.sizeMb,
    required this.owner,
    required this.category,
    required this.tags,
    required this.status,
    required this.createdAt,
    required this.modifiedAt,
    required this.version,
    required this.description,
    required this.versions,
    required this.comments,
    required this.auditLogs,
    required this.sharedWith,
  });
}

class DocumentVersion {
  final String versionNumber;
  final String author;
  final DateTime date;
  final String notes;

  DocumentVersion({
    required this.versionNumber,
    required this.author,
    required this.date,
    required this.notes,
  });
}

class DocumentComment {
  final String author;
  final String text;
  final DateTime date;

  DocumentComment({
    required this.author,
    required this.text,
    required this.date,
  });
}

class DocumentAuditLog {
  final String action;
  final String user;
  final DateTime timestamp;
  final String ipAddress;

  DocumentAuditLog({
    required this.action,
    required this.user,
    required this.timestamp,
    required this.ipAddress,
  });
}
