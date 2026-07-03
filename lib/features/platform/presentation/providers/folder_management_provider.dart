import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/folder_management_model.dart';

class FolderManagementState {
  final List<ManagedFolder> rootFolders;
  final String currentFolderId;
  final String searchQuery;

  FolderManagementState({
    required this.rootFolders,
    required this.currentFolderId,
    this.searchQuery = '',
  });

  FolderManagementState copyWith({
    List<ManagedFolder>? rootFolders,
    String? currentFolderId,
    String? searchQuery,
  }) {
    return FolderManagementState(
      rootFolders: rootFolders ?? this.rootFolders,
      currentFolderId: currentFolderId ?? this.currentFolderId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  ManagedFolder? get currentFolder {
    return _findFolder(rootFolders, currentFolderId);
  }

  List<ManagedFolder> get currentChildren {
    final folder = currentFolder;
    if (folder == null) return rootFolders;
    
    if (searchQuery.isEmpty) return folder.children;
    return folder.children.where((c) => c.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  List<ManagedFolder> get breadcrumbs {
    final List<ManagedFolder> path = [];
    String? currentId = currentFolderId;
    
    while (currentId != null && currentId != 'root') {
      final found = _findFolder(rootFolders, currentId);
      if (found != null) {
        path.insert(0, found);
        currentId = found.parentId;
      } else {
        break;
      }
    }
    
    // Always insert a pseudo root at the beginning
    path.insert(0, ManagedFolder(
      id: 'root', name: 'Root', organization: '', owner: '', description: '', storageUsedMb: 0, documentsCount: 0, sharedWith: []
    ));

    return path;
  }
  
  // Helper
  ManagedFolder? _findFolder(List<ManagedFolder> nodes, String id) {
    if (id == 'root') return null;
    for (var node in nodes) {
      if (node.id == id) return node;
      var found = _findFolder(node.children, id);
      if (found != null) return found;
    }
    return null;
  }
}

class FolderManagementNotifier extends Notifier<FolderManagementState> {
  @override
  FolderManagementState build() {
    return FolderManagementState(
      rootFolders: _generateMockFolders(),
      currentFolderId: 'root',
    );
  }

  void selectFolder(String id) {
    state = state.copyWith(currentFolderId: id);
  }

  void toggleFolderExpansion(String id) {
    List<ManagedFolder> newRoots = _deepClone(state.rootFolders);
    ManagedFolder? folder = state._findFolder(newRoots, id);
    if (folder != null) {
      folder.isExpanded = !folder.isExpanded;
      state = state.copyWith(rootFolders: newRoots);
    }
  }
  
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void createFolder(ManagedFolder folder) {
    List<ManagedFolder> newRoots = _deepClone(state.rootFolders);
    if (folder.parentId == 'root' || folder.parentId == null) {
      newRoots.add(folder);
    } else {
      ManagedFolder? parent = state._findFolder(newRoots, folder.parentId!);
      if (parent != null) {
        parent.children.add(folder);
        parent.isExpanded = true;
      }
    }
    state = state.copyWith(rootFolders: newRoots);
  }

  void updateFolder(ManagedFolder folder) {
    List<ManagedFolder> newRoots = _deepClone(state.rootFolders);
    _updateNode(newRoots, folder);
    state = state.copyWith(rootFolders: newRoots);
  }

  void deleteFolder(String id) {
    List<ManagedFolder> newRoots = _deepClone(state.rootFolders);
    _deleteNode(newRoots, id);
    
    String nextCurrent = state.currentFolderId;
    if (state.currentFolderId == id) {
      nextCurrent = 'root';
    }
    
    state = state.copyWith(rootFolders: newRoots, currentFolderId: nextCurrent);
  }

  // Deep clone helper to trigger Riverpod rebuilds correctly
  List<ManagedFolder> _deepClone(List<ManagedFolder> nodes) {
    return nodes.map((n) => n.copyWith(children: _deepClone(n.children))).toList();
  }

  bool _updateNode(List<ManagedFolder> nodes, ManagedFolder updatedNode) {
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].id == updatedNode.id) {
        nodes[i] = updatedNode;
        return true;
      }
      if (_updateNode(nodes[i].children, updatedNode)) return true;
    }
    return false;
  }

  bool _deleteNode(List<ManagedFolder> nodes, String id) {
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].id == id) {
        nodes.removeAt(i);
        return true;
      }
      if (_deleteNode(nodes[i].children, id)) return true;
    }
    return false;
  }

  List<ManagedFolder> _generateMockFolders() {
    return [
      ManagedFolder(id: 'f1', name: 'Financials 2026', parentId: 'root', organization: 'Acme Corp', owner: 'Alice Smith', description: 'Financial documents for FY2026', storageUsedMb: 1250, documentsCount: 340, sharedWith: ['Auditors'], isExpanded: true, children: [
        ManagedFolder(id: 'f1_1', name: 'Q1 Reports', parentId: 'f1', organization: 'Acme Corp', owner: 'Alice Smith', description: 'Q1 specific reports', storageUsedMb: 250, documentsCount: 45, sharedWith: []),
        ManagedFolder(id: 'f1_2', name: 'Invoices', parentId: 'f1', organization: 'Acme Corp', owner: 'Bob Jones', description: 'Vendor invoices', storageUsedMb: 800, documentsCount: 295, sharedWith: ['AP Team']),
      ]),
      ManagedFolder(id: 'f2', name: 'HR Policies', parentId: 'root', organization: 'Acme Corp', owner: 'HR Dept', description: 'Global HR Policies', storageUsedMb: 50, documentsCount: 12, sharedWith: ['All Employees']),
      ManagedFolder(id: 'f3', name: 'Project Assets', parentId: 'root', organization: 'Globex', owner: 'Design Team', description: 'Shared project assets', storageUsedMb: 4500, documentsCount: 1200, sharedWith: ['External Agencies'], children: [
        ManagedFolder(id: 'f3_1', name: 'Logos', parentId: 'f3', organization: 'Globex', owner: 'Design Team', description: 'High-res logos', storageUsedMb: 150, documentsCount: 30, sharedWith: []),
      ]),
    ];
  }
}

final folderManagementProvider = NotifierProvider<FolderManagementNotifier, FolderManagementState>(() {
  return FolderManagementNotifier();
});
