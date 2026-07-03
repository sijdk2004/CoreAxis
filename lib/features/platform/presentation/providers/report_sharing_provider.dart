import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../../domain/report_sharing_model.dart';

class ReportSharingState {
  final List<ReportShareModel> shares;
  final String searchQuery;

  ReportSharingState({
    required this.shares,
    this.searchQuery = '',
  });

  ReportSharingState copyWith({
    List<ReportShareModel>? shares,
    String? searchQuery,
  }) {
    return ReportSharingState(
      shares: shares ?? this.shares,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<ReportShareModel> filteredShares(ShareType tabType) {
    var filtered = shares.where((s) => s.type == tabType).toList();

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((s) => 
        s.reportName.toLowerCase().contains(query) || 
        s.recipientName.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }
}

final reportSharingProvider = NotifierProvider<ReportSharingNotifier, ReportSharingState>(() {
  return ReportSharingNotifier();
});

class ReportSharingNotifier extends Notifier<ReportSharingState> {
  final _random = Random();
  
  String _generateId() => 'shr_${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(1000)}';

  @override
  ReportSharingState build() {
    return ReportSharingState(
      shares: [
        ReportShareModel(
          id: 'shr_1',
          reportName: 'Q3 Financial Summary',
          recipientName: 'Sarah Jenkins',
          type: ShareType.user,
          permission: SharePermission.owner,
          sharedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        ReportShareModel(
          id: 'shr_2',
          reportName: 'Q3 Financial Summary',
          recipientName: 'David Chen',
          type: ShareType.user,
          permission: SharePermission.edit,
          sharedAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        ReportShareModel(
          id: 'shr_3',
          reportName: 'Employee Performance',
          recipientName: 'HR Managers',
          type: ShareType.role,
          permission: SharePermission.view,
          sharedAt: DateTime.now().subtract(const Duration(days: 5)),
          expiresAt: DateTime.now().add(const Duration(days: 25)),
        ),
        ReportShareModel(
          id: 'shr_4',
          reportName: 'Global Sales Dashboard',
          recipientName: 'EMEA Division',
          type: ShareType.organization,
          permission: SharePermission.download,
          sharedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ReportShareModel(
          id: 'shr_5',
          reportName: 'Public Product Catalog',
          recipientName: 'External Vendors',
          type: ShareType.externalLink,
          permission: SharePermission.view,
          sharedAt: DateTime.now().subtract(const Duration(hours: 4)),
          externalLink: 'https://erp.coreaxis.com/share/pub_xyz123',
          expiresAt: DateTime.now().add(const Duration(days: 7)),
        ),
      ],
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updatePermission(String id, SharePermission newPermission) {
    final updatedShares = state.shares.map((s) {
      if (s.id == id) {
        return s.copyWith(permission: newPermission);
      }
      return s;
    }).toList();
    state = state.copyWith(shares: updatedShares);
  }

  void revokeShare(String id) {
    state = state.copyWith(
      shares: state.shares.where((s) => s.id != id).toList(),
    );
  }

  void createShare({
    required String reportName,
    required String recipientName,
    required ShareType type,
    required SharePermission permission,
    DateTime? expiresAt,
  }) {
    final newShare = ReportShareModel(
      id: _generateId(),
      reportName: reportName,
      recipientName: recipientName,
      type: type,
      permission: permission,
      sharedAt: DateTime.now(),
      expiresAt: expiresAt,
      externalLink: type == ShareType.externalLink ? 'https://erp.coreaxis.com/share/${_generateId()}' : null,
    );

    state = state.copyWith(shares: [...state.shares, newShare]);
  }
}
