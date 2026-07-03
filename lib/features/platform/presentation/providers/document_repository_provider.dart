import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/document_repository_model.dart';
import 'dart:math';

class DocumentRepositoryState {
  final List<DocumentFolder> folders; // root folders
  final List<DocumentFile> allFiles;
  final String currentFolderId;
  final Set<String> selectedFileIds;
  final String? previewFileId;
  final RepositoryViewMode viewMode;
  final String searchQuery;

  DocumentRepositoryState({
    required this.folders,
    required this.allFiles,
    required this.currentFolderId,
    this.selectedFileIds = const {},
    this.previewFileId,
    this.viewMode = RepositoryViewMode.table,
    this.searchQuery = '',
  });

  DocumentRepositoryState copyWith({
    List<DocumentFolder>? folders,
    List<DocumentFile>? allFiles,
    String? currentFolderId,
    Set<String>? selectedFileIds,
    String? previewFileId,
    bool clearPreview = false,
    RepositoryViewMode? viewMode,
    String? searchQuery,
  }) {
    return DocumentRepositoryState(
      folders: folders ?? this.folders,
      allFiles: allFiles ?? this.allFiles,
      currentFolderId: currentFolderId ?? this.currentFolderId,
      selectedFileIds: selectedFileIds ?? this.selectedFileIds,
      previewFileId: clearPreview ? null : (previewFileId ?? this.previewFileId),
      viewMode: viewMode ?? this.viewMode,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<DocumentFile> get currentFiles {
    return allFiles.where((f) {
      if (f.folderId != currentFolderId) return false;
      if (searchQuery.isNotEmpty) {
        return f.name.toLowerCase().contains(searchQuery.toLowerCase());
      }
      return true;
    }).toList();
  }

  List<DocumentFolder> get breadcrumbs {
    final List<DocumentFolder> path = [];
    String? current = currentFolderId;
    
    // Simple mock traversal (in a real app, use a proper recursive lookup or flatten map)
    while (current != null) {
      DocumentFolder? found = _findFolderInTree(folders, current);
      if (found != null) {
        path.insert(0, found);
        current = found.parentId;
      } else {
        break;
      }
    }
    return path;
  }
  
  DocumentFolder? _findFolderInTree(List<DocumentFolder> tree, String id) {
    for (var f in tree) {
      if (f.id == id) return f;
      var foundInChild = _findFolderInTree(f.children, id);
      if (foundInChild != null) return foundInChild;
    }
    return null;
  }
}

class DocumentRepositoryNotifier extends Notifier<DocumentRepositoryState> {
  @override
  DocumentRepositoryState build() {
    final rootFolders = _generateMockFolders();
    return DocumentRepositoryState(
      folders: rootFolders,
      allFiles: _generateMockFiles(rootFolders),
      currentFolderId: 'root', // root level
    );
  }

  void selectFolder(String folderId) {
    state = state.copyWith(
      currentFolderId: folderId,
      selectedFileIds: {}, // clear selection on navigate
      clearPreview: true,
    );
  }

  void toggleFolderExpansion(String folderId) {
    // In a real app we'd deeply clone and update the tree.
    // For mock purposes, we'll modify the instance since it's local state mock.
    DocumentFolder? folder = state._findFolderInTree(state.folders, folderId);
    if (folder != null) {
      folder.isExpanded = !folder.isExpanded;
      // Force rebuild
      state = state.copyWith(folders: List.from(state.folders));
    }
  }

  void toggleFileSelection(String fileId) {
    final selected = Set<String>.from(state.selectedFileIds);
    if (selected.contains(fileId)) {
      selected.remove(fileId);
    } else {
      selected.add(fileId);
    }
    state = state.copyWith(selectedFileIds: selected);
  }

  void selectAll() {
    final selected = Set<String>.from(state.currentFiles.map((e) => e.id));
    state = state.copyWith(selectedFileIds: selected);
  }

  void clearSelection() {
    state = state.copyWith(selectedFileIds: {});
  }

  void selectPreview(String fileId) {
    state = state.copyWith(previewFileId: fileId);
  }
  
  void closePreview() {
    state = state.copyWith(clearPreview: true);
  }

  void setViewMode(RepositoryViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }
  
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void deleteSelected() {
    final remaining = state.allFiles.where((f) => !state.selectedFileIds.contains(f.id)).toList();
    state = state.copyWith(
      allFiles: remaining,
      selectedFileIds: {},
      clearPreview: true,
    );
  }

  void archiveSelected() {
    final updated = state.allFiles.map((f) {
      if (state.selectedFileIds.contains(f.id)) {
        return f.copyWith(status: 'Archived');
      }
      return f;
    }).toList();
    state = state.copyWith(allFiles: updated, selectedFileIds: {});
  }

  List<DocumentFolder> _generateMockFolders() {
    return [
      DocumentFolder(id: 'root', name: 'My Files', isExpanded: true, children: [
        DocumentFolder(id: 'f1', name: 'Financials 2026', parentId: 'root', children: [
          DocumentFolder(id: 'f1_1', name: 'Q1 Reports', parentId: 'f1'),
          DocumentFolder(id: 'f1_2', name: 'Invoices', parentId: 'f1'),
        ]),
        DocumentFolder(id: 'f2', name: 'HR Policies', parentId: 'root'),
        DocumentFolder(id: 'f3', name: 'Project Assets', parentId: 'root', children: [
          DocumentFolder(id: 'f3_1', name: 'Design', parentId: 'f3'),
        ]),
      ]),
      DocumentFolder(id: 'shared', name: 'Shared with me', isExpanded: false),
    ];
  }

  List<DocumentFile> _generateMockFiles(List<DocumentFolder> rootFolders) {
    final r = Random();
    final list = <DocumentFile>[];
    
    // Flat list of folder IDs
    final folderIds = ['root', 'f1', 'f1_1', 'f1_2', 'f2', 'f3', 'f3_1', 'shared'];
    
    final names = ['Q1_Financial_Summary', 'Vendor_Contract_V2', 'Employee_Handbook', 'Architecture_Diagram', 'Meeting_Notes', 'Budget_Proposal', 'Brand_Guidelines'];
    final types = ['pdf', 'doc', 'xls', 'img', 'ppt'];
    final orgs = ['Acme Corp', 'Globex', 'Internal'];
    final modules = ['Finance', 'HR', 'IT', 'Marketing'];
    final statuses = ['Active', 'Draft', 'Archived', 'Pending Review'];

    for (int i = 0; i < 60; i++) {
      final type = types[r.nextInt(types.length)];
      list.add(DocumentFile(
        id: 'DOC-${10000 + i}',
        name: '${names[r.nextInt(names.length)]}_$i.$type',
        folderId: folderIds[r.nextInt(folderIds.length)],
        category: 'General',
        owner: 'System Admin',
        organization: orgs[r.nextInt(orgs.length)],
        module: modules[r.nextInt(modules.length)],
        version: 'v${r.nextInt(5) + 1}.0',
        sizeMb: r.nextDouble() * 25,
        lastModified: DateTime.now().subtract(Duration(days: r.nextInt(100), hours: r.nextInt(24))),
        status: statuses[r.nextInt(statuses.length)],
        type: type,
        isFavorite: r.nextBool(),
      ));
    }
    return list;
  }
}

final documentRepositoryProvider = NotifierProvider<DocumentRepositoryNotifier, DocumentRepositoryState>(() {
  return DocumentRepositoryNotifier();
});
