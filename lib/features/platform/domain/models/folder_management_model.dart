class ManagedFolder {
  final String id;
  final String name;
  final String? parentId;
  final String organization;
  final String owner;
  final String description;
  final double storageUsedMb;
  final int documentsCount;
  final List<String> sharedWith;
  final List<ManagedFolder> children;
  
  bool isExpanded;

  ManagedFolder({
    required this.id,
    required this.name,
    this.parentId,
    required this.organization,
    required this.owner,
    required this.description,
    required this.storageUsedMb,
    required this.documentsCount,
    required this.sharedWith,
    this.children = const [],
    this.isExpanded = false,
  });

  ManagedFolder copyWith({
    String? id,
    String? name,
    String? parentId,
    String? organization,
    String? owner,
    String? description,
    double? storageUsedMb,
    int? documentsCount,
    List<String>? sharedWith,
    List<ManagedFolder>? children,
    bool? isExpanded,
  }) {
    return ManagedFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      organization: organization ?? this.organization,
      owner: owner ?? this.owner,
      description: description ?? this.description,
      storageUsedMb: storageUsedMb ?? this.storageUsedMb,
      documentsCount: documentsCount ?? this.documentsCount,
      sharedWith: sharedWith ?? this.sharedWith,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
