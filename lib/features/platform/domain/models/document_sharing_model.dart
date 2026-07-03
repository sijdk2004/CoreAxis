import 'dart:math';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum PermissionTargetType { user, role, organization, publicLink }

enum PermissionLevel { view, download, edit, delete, share, owner }

extension PermissionLevelExt on PermissionLevel {
  String get label {
    switch (this) {
      case PermissionLevel.view:     return 'View';
      case PermissionLevel.download: return 'Download';
      case PermissionLevel.edit:     return 'Edit';
      case PermissionLevel.delete:   return 'Delete';
      case PermissionLevel.share:    return 'Share';
      case PermissionLevel.owner:    return 'Owner';
    }
  }

  int get rank {
    switch (this) {
      case PermissionLevel.view:     return 1;
      case PermissionLevel.download: return 2;
      case PermissionLevel.edit:     return 3;
      case PermissionLevel.delete:   return 4;
      case PermissionLevel.share:    return 5;
      case PermissionLevel.owner:    return 6;
    }
  }

  static PermissionLevel fromString(String s) {
    switch (s) {
      case 'Download': return PermissionLevel.download;
      case 'Edit':     return PermissionLevel.edit;
      case 'Delete':   return PermissionLevel.delete;
      case 'Share':    return PermissionLevel.share;
      case 'Owner':    return PermissionLevel.owner;
      default:         return PermissionLevel.view;
    }
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

class DocumentPermission {
  final String id;
  final String documentId;
  final String targetId;
  final String targetName;
  final String? targetAvatar; // initials or email
  final PermissionTargetType type;
  final PermissionLevel permissionLevel;
  final DateTime? expiryDate;
  final DateTime grantedAt;
  final String grantedBy;
  final bool isActive;
  // Public link specific
  final String? linkUrl;
  final String? linkToken;
  final int? linkViewCount;

  const DocumentPermission({
    required this.id,
    required this.documentId,
    required this.targetId,
    required this.targetName,
    this.targetAvatar,
    required this.type,
    required this.permissionLevel,
    this.expiryDate,
    required this.grantedAt,
    required this.grantedBy,
    this.isActive = true,
    this.linkUrl,
    this.linkToken,
    this.linkViewCount,
  });

  DocumentPermission copyWith({
    String? id,
    String? documentId,
    String? targetId,
    String? targetName,
    String? targetAvatar,
    PermissionTargetType? type,
    PermissionLevel? permissionLevel,
    DateTime? expiryDate,
    DateTime? grantedAt,
    String? grantedBy,
    bool? isActive,
    String? linkUrl,
    String? linkToken,
    int? linkViewCount,
    bool clearExpiry = false,
  }) {
    return DocumentPermission(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      targetAvatar: targetAvatar ?? this.targetAvatar,
      type: type ?? this.type,
      permissionLevel: permissionLevel ?? this.permissionLevel,
      expiryDate: clearExpiry ? null : (expiryDate ?? this.expiryDate),
      grantedAt: grantedAt ?? this.grantedAt,
      grantedBy: grantedBy ?? this.grantedBy,
      isActive: isActive ?? this.isActive,
      linkUrl: linkUrl ?? this.linkUrl,
      linkToken: linkToken ?? this.linkToken,
      linkViewCount: linkViewCount ?? this.linkViewCount,
    );
  }

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());
  bool get expiresInWarning =>
      expiryDate != null &&
      !isExpired &&
      expiryDate!.difference(DateTime.now()).inDays <= 7;
}

// ─── Mock Data Helper ─────────────────────────────────────────────────────────

class DocumentSharingMockData {
  static List<DocumentPermission> generate(String documentId) {
    final r = Random(documentId.hashCode);
    final now = DateTime.now();

    final users = [
      ('u_1', 'Alice Smith',    'alice@acmecorp.com',   'AS'),
      ('u_2', 'Bob Jones',      'bob@acmecorp.com',     'BJ'),
      ('u_3', 'Charlie Davis',  'charlie@acmecorp.com', 'CD'),
      ('u_4', 'Dana White',     'dana@acmecorp.com',    'DW'),
      ('u_5', 'Eve Adams',      'eve@acmecorp.com',     'EA'),
      ('u_6', 'Frank Castle',   'frank@acmecorp.com',   'FC'),
    ];
    final roles = [
      ('r_1', 'Finance Team'),
      ('r_2', 'HR Managers'),
      ('r_3', 'Compliance Officers'),
      ('r_4', 'Executive Team'),
      ('r_5', 'Auditors'),
    ];
    final orgs = [
      ('o_1', 'Acme Corp (External)'),
      ('o_2', 'Partner Logistics Ltd'),
      ('o_3', 'Vendor Network'),
    ];

    final perms = <DocumentPermission>[];

    // Owner always first
    perms.add(DocumentPermission(
      id: '${documentId}_owner',
      documentId: documentId,
      targetId: 'u_1',
      targetName: 'Alice Smith',
      targetAvatar: 'AS',
      type: PermissionTargetType.user,
      permissionLevel: PermissionLevel.owner,
      grantedAt: now.subtract(const Duration(days: 30)),
      grantedBy: 'System',
      isActive: true,
    ));

    // 2-3 random users
    final userCount = r.nextInt(2) + 2;
    final shuffledUsers = [...users.skip(1)]..shuffle(r);
    for (int i = 0; i < userCount && i < shuffledUsers.length; i++) {
      final u = shuffledUsers[i];
      final levels = [PermissionLevel.view, PermissionLevel.download, PermissionLevel.edit, PermissionLevel.share];
      perms.add(DocumentPermission(
        id: '${documentId}_u_$i',
        documentId: documentId,
        targetId: u.$1,
        targetName: u.$2,
        targetAvatar: u.$4,
        type: PermissionTargetType.user,
        permissionLevel: levels[r.nextInt(levels.length)],
        expiryDate: r.nextBool() ? now.add(Duration(days: r.nextInt(60) + 1)) : null,
        grantedAt: now.subtract(Duration(days: r.nextInt(20) + 1)),
        grantedBy: 'Alice Smith',
        isActive: true,
      ));
    }

    // 1-2 roles
    final roleCount = r.nextInt(2) + 1;
    final shuffledRoles = [...roles]..shuffle(r);
    for (int i = 0; i < roleCount; i++) {
      final ro = shuffledRoles[i];
      perms.add(DocumentPermission(
        id: '${documentId}_r_$i',
        documentId: documentId,
        targetId: ro.$1,
        targetName: ro.$2,
        targetAvatar: ro.$2.substring(0, 2).toUpperCase(),
        type: PermissionTargetType.role,
        permissionLevel: r.nextBool() ? PermissionLevel.view : PermissionLevel.download,
        expiryDate: r.nextBool() ? now.add(Duration(days: r.nextInt(90) + 1)) : null,
        grantedAt: now.subtract(Duration(days: r.nextInt(15) + 1)),
        grantedBy: 'Alice Smith',
        isActive: true,
      ));
    }

    // 1 org
    if (r.nextBool()) {
      final org = orgs[r.nextInt(orgs.length)];
      perms.add(DocumentPermission(
        id: '${documentId}_o_1',
        documentId: documentId,
        targetId: org.$1,
        targetName: org.$2,
        targetAvatar: org.$2.substring(0, 2).toUpperCase(),
        type: PermissionTargetType.organization,
        permissionLevel: r.nextBool() ? PermissionLevel.view : PermissionLevel.download,
        expiryDate: now.add(Duration(days: r.nextInt(30) + 7)),
        grantedAt: now.subtract(Duration(days: r.nextInt(10) + 1)),
        grantedBy: 'Alice Smith',
        isActive: true,
      ));
    }

    // 0-2 public links
    final linkCount = r.nextInt(3);
    final linkNames = ['Vendor Review Link', 'Client Preview', 'External Audit Link'];
    for (int i = 0; i < linkCount; i++) {
      final token = '${documentId.hashCode.abs().toString().substring(0, 4)}${r.nextInt(9999).toString().padLeft(4, '0')}';
      perms.add(DocumentPermission(
        id: '${documentId}_lnk_$i',
        documentId: documentId,
        targetId: 'link_$i',
        targetName: linkNames[i % linkNames.length],
        type: PermissionTargetType.publicLink,
        permissionLevel: PermissionLevel.view,
        expiryDate: now.add(Duration(days: r.nextInt(20) + 7)),
        grantedAt: now.subtract(Duration(days: r.nextInt(5) + 1)),
        grantedBy: 'Alice Smith',
        isActive: true,
        linkUrl: 'https://erp.acmecorp.com/share/$token',
        linkToken: token,
        linkViewCount: r.nextInt(50),
      ));
    }

    return perms;
  }
}
