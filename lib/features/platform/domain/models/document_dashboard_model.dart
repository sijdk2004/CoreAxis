class DocumentDashboardKpis {
  final int totalDocuments;
  final double storageUsedGb;
  final int newDocumentsToday;
  final int sharedDocuments;
  final int versionedDocuments;
  final int expiringDocuments;
  final int archivedDocuments;
  final double averageFileSizeMb;

  DocumentDashboardKpis({
    required this.totalDocuments,
    required this.storageUsedGb,
    required this.newDocumentsToday,
    required this.sharedDocuments,
    required this.versionedDocuments,
    required this.expiringDocuments,
    required this.archivedDocuments,
    required this.averageFileSizeMb,
  });
}

class DocumentTrendData {
  final DateTime date;
  final double volume;

  DocumentTrendData(this.date, this.volume);
}

class DocumentCategoryStat {
  final String category;
  final double count;

  DocumentCategoryStat(this.category, this.count);
}

class DocumentWidgetListItem {
  final String id;
  final String name;
  final String type; // 'pdf', 'doc', 'xls', 'img'
  final DateTime date;
  final double sizeMb;
  final String author;

  DocumentWidgetListItem({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.sizeMb,
    required this.author,
  });
}
