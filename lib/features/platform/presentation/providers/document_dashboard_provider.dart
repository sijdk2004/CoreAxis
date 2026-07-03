import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/document_dashboard_model.dart';
import 'dart:math';

class DocumentDashboardState {
  final DocumentDashboardKpis kpis;
  final List<DocumentTrendData> storageGrowth;
  final List<DocumentCategoryStat> categoryStats;
  final List<DocumentTrendData> uploadTrend;
  final List<DocumentTrendData> accessTrend;
  final List<DocumentWidgetListItem> recentUploads;
  final List<DocumentWidgetListItem> recentlyViewed;
  final List<DocumentWidgetListItem> pendingApproval;
  final List<DocumentWidgetListItem> favoriteDocuments;
  final List<DocumentWidgetListItem> recentlyShared;

  final String dateFilter;
  final String orgFilter;
  final String categoryFilter;

  DocumentDashboardState({
    required this.kpis,
    required this.storageGrowth,
    required this.categoryStats,
    required this.uploadTrend,
    required this.accessTrend,
    required this.recentUploads,
    required this.recentlyViewed,
    required this.pendingApproval,
    required this.favoriteDocuments,
    required this.recentlyShared,
    this.dateFilter = 'This Month',
    this.orgFilter = 'All Organizations',
    this.categoryFilter = 'All Categories',
  });

  DocumentDashboardState copyWith({
    DocumentDashboardKpis? kpis,
    List<DocumentTrendData>? storageGrowth,
    List<DocumentCategoryStat>? categoryStats,
    List<DocumentTrendData>? uploadTrend,
    List<DocumentTrendData>? accessTrend,
    List<DocumentWidgetListItem>? recentUploads,
    List<DocumentWidgetListItem>? recentlyViewed,
    List<DocumentWidgetListItem>? pendingApproval,
    List<DocumentWidgetListItem>? favoriteDocuments,
    List<DocumentWidgetListItem>? recentlyShared,
    String? dateFilter,
    String? orgFilter,
    String? categoryFilter,
  }) {
    return DocumentDashboardState(
      kpis: kpis ?? this.kpis,
      storageGrowth: storageGrowth ?? this.storageGrowth,
      categoryStats: categoryStats ?? this.categoryStats,
      uploadTrend: uploadTrend ?? this.uploadTrend,
      accessTrend: accessTrend ?? this.accessTrend,
      recentUploads: recentUploads ?? this.recentUploads,
      recentlyViewed: recentlyViewed ?? this.recentlyViewed,
      pendingApproval: pendingApproval ?? this.pendingApproval,
      favoriteDocuments: favoriteDocuments ?? this.favoriteDocuments,
      recentlyShared: recentlyShared ?? this.recentlyShared,
      dateFilter: dateFilter ?? this.dateFilter,
      orgFilter: orgFilter ?? this.orgFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
    );
  }
}

class DocumentDashboardNotifier extends AsyncNotifier<DocumentDashboardState> {
  String _dateFilter = 'This Month';
  String _orgFilter = 'All Organizations';
  String _categoryFilter = 'All Categories';

  @override
  Future<DocumentDashboardState> build() async {
    return _fetchMockData();
  }

  void setFilters({String? date, String? org, String? category}) {
    if (date != null) _dateFilter = date;
    if (org != null) _orgFilter = org;
    if (category != null) _categoryFilter = category;
    
    // Trigger a refetch to show loading state
    state = const AsyncValue.loading();
    _fetchMockData().then((data) {
      state = AsyncValue.data(data);
    }).catchError((error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    });
  }

  Future<DocumentDashboardState> _fetchMockData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Optional: Simulate an error for demonstration if a specific filter is chosen
    if (_orgFilter == 'Simulate Error') {
      throw Exception('Failed to connect to the Document Engine API.');
    }

    final r = Random();
    
    final kpis = DocumentDashboardKpis(
      totalDocuments: 142050,
      storageUsedGb: 1450.5,
      newDocumentsToday: 342,
      sharedDocuments: 12500,
      versionedDocuments: 45000,
      expiringDocuments: 120,
      archivedDocuments: 35000,
      averageFileSizeMb: 2.4,
    );

    final storageGrowth = List.generate(12, (index) {
      return DocumentTrendData(
        DateTime.now().subtract(Duration(days: 30 * (11 - index))),
        1000.0 + (index * 40) + r.nextDouble() * 20,
      );
    });

    final uploadTrend = List.generate(14, (index) {
      return DocumentTrendData(
        DateTime.now().subtract(Duration(days: 13 - index)),
        200.0 + r.nextInt(150),
      );
    });

    final accessTrend = List.generate(14, (index) {
      return DocumentTrendData(
        DateTime.now().subtract(Duration(days: 13 - index)),
        5000.0 + r.nextInt(2000),
      );
    });

    final categoryStats = [
      DocumentCategoryStat('Invoices', 45),
      DocumentCategoryStat('Contracts', 25),
      DocumentCategoryStat('Reports', 15),
      DocumentCategoryStat('Policies', 10),
      DocumentCategoryStat('Other', 5),
    ];

    List<DocumentWidgetListItem> generateList(int count) {
      final names = ['Q3 Financial Report', 'Vendor Contract 2026', 'Employee Handbook', 'Design Assets', 'Meeting Notes', 'Architecture Diagram'];
      final types = ['pdf', 'doc', 'xls', 'img'];
      final authors = ['Alice Smith', 'Bob Jones', 'System', 'Charlie Brown'];
      return List.generate(count, (index) => DocumentWidgetListItem(
        id: 'DOC-${r.nextInt(9000) + 1000}',
        name: names[r.nextInt(names.length)],
        type: types[r.nextInt(types.length)],
        date: DateTime.now().subtract(Duration(hours: r.nextInt(48))),
        sizeMb: r.nextDouble() * 15,
        author: authors[r.nextInt(authors.length)],
      ));
    }

    // Optional: Simulate empty state if a specific filter is chosen
    if (_orgFilter == 'Simulate Empty') {
      return DocumentDashboardState(
        kpis: DocumentDashboardKpis(
          totalDocuments: 0, storageUsedGb: 0, newDocumentsToday: 0, sharedDocuments: 0, 
          versionedDocuments: 0, expiringDocuments: 0, archivedDocuments: 0, averageFileSizeMb: 0,
        ),
        storageGrowth: [], categoryStats: [], uploadTrend: [], accessTrend: [],
        recentUploads: [], recentlyViewed: [], pendingApproval: [], favoriteDocuments: [], recentlyShared: [],
        dateFilter: _dateFilter, orgFilter: _orgFilter, categoryFilter: _categoryFilter,
      );
    }

    return DocumentDashboardState(
      kpis: kpis,
      storageGrowth: storageGrowth,
      categoryStats: categoryStats,
      uploadTrend: uploadTrend,
      accessTrend: accessTrend,
      recentUploads: generateList(4),
      recentlyViewed: generateList(4),
      pendingApproval: generateList(3),
      favoriteDocuments: generateList(3),
      recentlyShared: generateList(4),
      dateFilter: _dateFilter,
      orgFilter: _orgFilter,
      categoryFilter: _categoryFilter,
    );
  }
}

final documentDashboardProvider = AsyncNotifierProvider<DocumentDashboardNotifier, DocumentDashboardState>(() {
  return DocumentDashboardNotifier();
});
