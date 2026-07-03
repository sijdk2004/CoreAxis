import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/document_sharing_model.dart';

// ─── State per document ───────────────────────────────────────────────────────

class DocumentSharingState {
  final List<DocumentPermission> permissions;
  final bool isLoaded;

  const DocumentSharingState({
    this.permissions = const [],
    this.isLoaded = false,
  });

  DocumentSharingState copyWith({
    List<DocumentPermission>? permissions,
    bool? isLoaded,
  }) {
    return DocumentSharingState(
      permissions: permissions ?? this.permissions,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  List<DocumentPermission> get users =>
      permissions.where((p) => p.type == PermissionTargetType.user).toList();
  List<DocumentPermission> get roles =>
      permissions.where((p) => p.type == PermissionTargetType.role).toList();
  List<DocumentPermission> get organizations =>
      permissions.where((p) => p.type == PermissionTargetType.organization).toList();
  List<DocumentPermission> get publicLinks =>
      permissions.where((p) => p.type == PermissionTargetType.publicLink).toList();

  int get totalCount =>
      permissions.where((p) => p.type != PermissionTargetType.publicLink).length;
  bool get hasExpiring => permissions.any((p) => p.expiresInWarning);
  bool get hasExpired  => permissions.any((p) => p.isExpired);
}

// ─── Global notifier managing all document sharing states ─────────────────────
//
// Uses a Map<documentId, DocumentSharingState> so we can handle multiple
// documents without needing NotifierProvider.family (which isn't available
// in this codebase's Riverpod version in a simple Notifier form).

class DocumentSharingNotifier extends Notifier<Map<String, DocumentSharingState>> {
  @override
  Map<String, DocumentSharingState> build() {
    return {};
  }

  // ── Initialization ────────────────────────────────────────────────────────

  DocumentSharingState stateFor(String documentId) {
    if (!state.containsKey(documentId)) {
      // Lazily initialize — kick off async load
      Future.microtask(() => _load(documentId));
      // Return loading placeholder
      return const DocumentSharingState(isLoaded: false);
    }
    return state[documentId]!;
  }

  Future<void> _load(String documentId) async {
    if (state[documentId]?.isLoaded == true) return; // Already loaded

    await Future.delayed(const Duration(milliseconds: 400));

    final perms = DocumentSharingMockData.generate(documentId);
    state = {
      ...state,
      documentId: DocumentSharingState(
        permissions: perms,
        isLoaded: true,
      ),
    };
  }

  Future<void> refresh(String documentId) async {
    state = {
      ...state,
      documentId: const DocumentSharingState(isLoaded: false),
    };
    await _load(documentId);
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  void addPermission(String documentId, DocumentPermission permission) {
    final current = state[documentId] ?? const DocumentSharingState(isLoaded: true);
    state = {
      ...state,
      documentId: current.copyWith(
        permissions: [...current.permissions, permission],
      ),
    };
  }

  void revokePermission(String documentId, String permissionId) {
    final current = state[documentId];
    if (current == null) return;
    state = {
      ...state,
      documentId: current.copyWith(
        permissions: current.permissions
            .where((p) => p.id != permissionId)
            .toList(),
      ),
    };
  }

  void updatePermissionLevel(
    String documentId,
    String permissionId,
    PermissionLevel newLevel,
  ) {
    final current = state[documentId];
    if (current == null) return;
    state = {
      ...state,
      documentId: current.copyWith(
        permissions: current.permissions.map((p) {
          if (p.id == permissionId) return p.copyWith(permissionLevel: newLevel);
          return p;
        }).toList(),
      ),
    };
  }

  void updateExpiry(String documentId, String permissionId, DateTime? newExpiry) {
    final current = state[documentId];
    if (current == null) return;
    state = {
      ...state,
      documentId: current.copyWith(
        permissions: current.permissions.map((p) {
          if (p.id == permissionId) {
            return newExpiry == null
                ? p.copyWith(clearExpiry: true)
                : p.copyWith(expiryDate: newExpiry);
          }
          return p;
        }).toList(),
      ),
    };
  }
}

final documentSharingProvider =
    NotifierProvider<DocumentSharingNotifier, Map<String, DocumentSharingState>>(
  DocumentSharingNotifier.new,
);
