import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/document_category_model.dart';
import 'dart:math';

class DocumentCategoryState {
  final List<DocumentCategory> allCategories;
  final String searchQuery;

  DocumentCategoryState({
    required this.allCategories,
    this.searchQuery = '',
  });

  DocumentCategoryState copyWith({
    List<DocumentCategory>? allCategories,
    String? searchQuery,
  }) {
    return DocumentCategoryState(
      allCategories: allCategories ?? this.allCategories,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<DocumentCategory> get currentCategories {
    if (searchQuery.isEmpty) return allCategories;
    return allCategories.where((c) => c.name.toLowerCase().contains(searchQuery.toLowerCase()) || c.description.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  int get totalCategories => allCategories.length;
  int get activeCategories => allCategories.where((c) => c.status == 'Active').length;
  int get archivedCategories => allCategories.where((c) => c.status == 'Archived').length;
  int get totalDocuments => allCategories.fold(0, (sum, c) => sum + c.documentCount);
}

class DocumentCategoryNotifier extends Notifier<DocumentCategoryState> {
  @override
  DocumentCategoryState build() {
    return DocumentCategoryState(allCategories: _generateMockCategories());
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void addCategory(DocumentCategory category) {
    state = state.copyWith(allCategories: [...state.allCategories, category]);
  }

  void updateCategory(DocumentCategory category) {
    final updated = state.allCategories.map((c) => c.id == category.id ? category : c).toList();
    state = state.copyWith(allCategories: updated);
  }

  void deleteCategory(String id) {
    final remaining = state.allCategories.where((c) => c.id != id).toList();
    state = state.copyWith(allCategories: remaining);
  }

  void archiveCategory(String id) {
    final updated = state.allCategories.map((c) {
      if (c.id == id) {
        return c.copyWith(status: 'Archived');
      }
      return c;
    }).toList();
    state = state.copyWith(allCategories: updated);
  }

  List<DocumentCategory> _generateMockCategories() {
    return [
      DocumentCategory(
        id: 'CAT-001',
        name: 'Financials',
        description: 'Invoices, receipts, and financial statements.',
        icon: 'dollarSign',
        color: 'green',
        documentCount: 450,
        retentionPolicy: '7 Years',
        visibility: 'Restricted',
        allowedFileTypes: ['pdf', 'xls', 'csv'],
        maxFileSizeMb: 50.0,
        status: 'Active',
      ),
      DocumentCategory(
        id: 'CAT-002',
        name: 'Human Resources',
        description: 'Employee records, policies, and onboarding docs.',
        icon: 'users',
        color: 'purple',
        documentCount: 1250,
        retentionPolicy: 'Indefinite',
        visibility: 'Restricted',
        allowedFileTypes: ['pdf', 'doc', 'docx'],
        maxFileSizeMb: 25.0,
        status: 'Active',
      ),
      DocumentCategory(
        id: 'CAT-003',
        name: 'Legal & Compliance',
        description: 'Contracts, NDAs, and regulatory compliance.',
        icon: 'scale',
        color: 'red',
        documentCount: 890,
        retentionPolicy: '10 Years',
        visibility: 'Restricted',
        allowedFileTypes: ['pdf'],
        maxFileSizeMb: 100.0,
        status: 'Active',
      ),
      DocumentCategory(
        id: 'CAT-004',
        name: 'General Assets',
        description: 'Logos, branding, and presentation templates.',
        icon: 'image',
        color: 'blue',
        documentCount: 3400,
        retentionPolicy: '1 Year',
        visibility: 'Public',
        allowedFileTypes: ['png', 'jpg', 'svg', 'ppt'],
        maxFileSizeMb: 250.0,
        status: 'Active',
      ),
      DocumentCategory(
        id: 'CAT-005',
        name: 'Legacy Projects',
        description: 'Archived project documentation.',
        icon: 'archive',
        color: 'grey',
        documentCount: 12000,
        retentionPolicy: '3 Years',
        visibility: 'Public',
        allowedFileTypes: ['*'],
        maxFileSizeMb: 500.0,
        status: 'Archived',
      ),
    ];
  }
}

final documentCategoryProvider = NotifierProvider<DocumentCategoryNotifier, DocumentCategoryState>(() {
  return DocumentCategoryNotifier();
});
