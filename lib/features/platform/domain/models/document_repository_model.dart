class DocumentFolder {
  final String id;
  final String name;
  final String? parentId;
  final List<DocumentFolder> children;
  
  bool isExpanded;

  DocumentFolder({
    required this.id,
    required this.name,
    this.parentId,
    this.children = const [],
    this.isExpanded = false,
  });

  DocumentFolder copyWith({
    String? id,
    String? name,
    String? parentId,
    List<DocumentFolder>? children,
    bool? isExpanded,
  }) {
    return DocumentFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class DocumentFile {
  final String id;
  final String name;
  final String folderId;
  final String category;
  final String owner;
  final String organization;
  final String module;
  final String version;
  final double sizeMb;
  final DateTime lastModified;
  final String status;
  final String type;
  final bool isFavorite;

  DocumentFile({
    required this.id,
    required this.name,
    required this.folderId,
    required this.category,
    required this.owner,
    required this.organization,
    required this.module,
    required this.version,
    required this.sizeMb,
    required this.lastModified,
    required this.status,
    required this.type,
    this.isFavorite = false,
  });

  DocumentFile copyWith({
    String? id,
    String? name,
    String? folderId,
    String? category,
    String? owner,
    String? organization,
    String? module,
    String? version,
    double? sizeMb,
    DateTime? lastModified,
    String? status,
    String? type,
    bool? isFavorite,
  }) {
    return DocumentFile(
      id: id ?? this.id,
      name: name ?? this.name,
      folderId: folderId ?? this.folderId,
      category: category ?? this.category,
      owner: owner ?? this.owner,
      organization: organization ?? this.organization,
      module: module ?? this.module,
      version: version ?? this.version,
      sizeMb: sizeMb ?? this.sizeMb,
      lastModified: lastModified ?? this.lastModified,
      status: status ?? this.status,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

enum RepositoryViewMode { grid, table, list }
