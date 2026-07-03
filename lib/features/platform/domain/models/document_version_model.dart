class DetailedDocumentVersion {
  final String id;
  final String version;
  final String uploadedBy;
  final DateTime date;
  final String changes;
  final String status;
  final double sizeMb;

  DetailedDocumentVersion({
    required this.id,
    required this.version,
    required this.uploadedBy,
    required this.date,
    required this.changes,
    required this.status,
    required this.sizeMb,
  });
}
