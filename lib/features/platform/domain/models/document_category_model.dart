class DocumentCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final int documentCount;
  final String retentionPolicy;
  final String visibility;
  final List<String> allowedFileTypes;
  final double maxFileSizeMb;
  final String status;

  DocumentCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.documentCount,
    required this.retentionPolicy,
    required this.visibility,
    required this.allowedFileTypes,
    required this.maxFileSizeMb,
    required this.status,
  });

  DocumentCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    int? documentCount,
    String? retentionPolicy,
    String? visibility,
    List<String>? allowedFileTypes,
    double? maxFileSizeMb,
    String? status,
  }) {
    return DocumentCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      documentCount: documentCount ?? this.documentCount,
      retentionPolicy: retentionPolicy ?? this.retentionPolicy,
      visibility: visibility ?? this.visibility,
      allowedFileTypes: allowedFileTypes ?? this.allowedFileTypes,
      maxFileSizeMb: maxFileSizeMb ?? this.maxFileSizeMb,
      status: status ?? this.status,
    );
  }
}
