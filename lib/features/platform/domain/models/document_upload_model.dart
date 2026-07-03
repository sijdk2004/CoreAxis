enum UploadTaskStatus { pending, uploading, completed, failed, cancelled }

class UploadTaskItem {
  final String id;
  final String fileName;
  final double fileSizeMb;
  final UploadTaskStatus status;
  final double progress; // 0.0 to 1.0
  final String? errorMessage;
  
  // Metadata
  final String category;
  final String organization;
  final String module;
  final String folder;
  final String tags;
  final String description;

  UploadTaskItem({
    required this.id,
    required this.fileName,
    required this.fileSizeMb,
    required this.status,
    required this.progress,
    this.errorMessage,
    required this.category,
    required this.organization,
    required this.module,
    required this.folder,
    required this.tags,
    required this.description,
  });

  UploadTaskItem copyWith({
    String? id,
    String? fileName,
    double? fileSizeMb,
    UploadTaskStatus? status,
    double? progress,
    String? errorMessage,
    String? category,
    String? organization,
    String? module,
    String? folder,
    String? tags,
    String? description,
    bool clearError = false,
  }) {
    return UploadTaskItem(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileSizeMb: fileSizeMb ?? this.fileSizeMb,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      category: category ?? this.category,
      organization: organization ?? this.organization,
      module: module ?? this.module,
      folder: folder ?? this.folder,
      tags: tags ?? this.tags,
      description: description ?? this.description,
    );
  }
}
