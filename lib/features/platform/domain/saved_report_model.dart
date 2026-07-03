enum ReportStatus { active, archived, draft }

class SavedReportModel {
  final String id;
  final String name;
  final String owner;
  final DateTime created;
  final DateTime? lastRun;
  final int views;
  final ReportStatus status;
  final bool isFavorite;
  final bool isShared;

  SavedReportModel({
    required this.id,
    required this.name,
    required this.owner,
    required this.created,
    this.lastRun,
    required this.views,
    required this.status,
    required this.isFavorite,
    required this.isShared,
  });

  SavedReportModel copyWith({
    String? id,
    String? name,
    String? owner,
    DateTime? created,
    DateTime? lastRun,
    int? views,
    ReportStatus? status,
    bool? isFavorite,
    bool? isShared,
  }) {
    return SavedReportModel(
      id: id ?? this.id,
      name: name ?? this.name,
      owner: owner ?? this.owner,
      created: created ?? this.created,
      lastRun: lastRun ?? this.lastRun,
      views: views ?? this.views,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      isShared: isShared ?? this.isShared,
    );
  }
}
