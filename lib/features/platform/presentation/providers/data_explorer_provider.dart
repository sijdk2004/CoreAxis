import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/data_explorer_model.dart';

class DataExplorerState {
  final ExplorerEntity selectedEntity;
  final ExplorerDataModel data;
  final String searchQuery;

  DataExplorerState({
    required this.selectedEntity,
    required this.data,
    this.searchQuery = '',
  });

  DataExplorerState copyWith({
    ExplorerEntity? selectedEntity,
    ExplorerDataModel? data,
    String? searchQuery,
  }) {
    return DataExplorerState(
      selectedEntity: selectedEntity ?? this.selectedEntity,
      data: data ?? this.data,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Map<String, dynamic>> get filteredRows {
    if (searchQuery.isEmpty) return data.rows;
    final query = searchQuery.toLowerCase();
    
    return data.rows.where((row) {
      return row.values.any((value) => value.toString().toLowerCase().contains(query));
    }).toList();
  }
}

final dataExplorerProvider = NotifierProvider<DataExplorerNotifier, DataExplorerState>(() {
  return DataExplorerNotifier();
});

class DataExplorerNotifier extends Notifier<DataExplorerState> {
  @override
  DataExplorerState build() {
    return DataExplorerState(
      selectedEntity: ExplorerEntity.users,
      data: _getMockDataForEntity(ExplorerEntity.users),
    );
  }

  void selectEntity(ExplorerEntity entity) {
    state = state.copyWith(
      selectedEntity: entity,
      data: _getMockDataForEntity(entity),
      searchQuery: '',
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  ExplorerDataModel _getMockDataForEntity(ExplorerEntity entity) {
    switch (entity) {
      case ExplorerEntity.users:
        return ExplorerDataModel(
          entity: entity,
          columns: [
            ExplorerColumn(key: 'id', title: 'User ID', type: String),
            ExplorerColumn(key: 'name', title: 'Full Name', type: String),
            ExplorerColumn(key: 'email', title: 'Email Address', type: String),
            ExplorerColumn(key: 'role', title: 'System Role', type: String),
            ExplorerColumn(key: 'status', title: 'Status', type: String),
            ExplorerColumn(key: 'lastLogin', title: 'Last Login', type: String),
          ],
          rows: [
            {'id': 'USR-001', 'name': 'Sarah Jenkins', 'email': 'sarah@coreaxis.com', 'role': 'Admin', 'status': 'Active', 'lastLogin': '2023-10-24 09:12'},
            {'id': 'USR-002', 'name': 'David Chen', 'email': 'david@coreaxis.com', 'role': 'Manager', 'status': 'Active', 'lastLogin': '2023-10-24 08:30'},
            {'id': 'USR-003', 'name': 'Amanda Smith', 'email': 'amanda@coreaxis.com', 'role': 'User', 'status': 'Inactive', 'lastLogin': '2023-10-15 14:22'},
            {'id': 'USR-004', 'name': 'Michael Ross', 'email': 'michael@coreaxis.com', 'role': 'User', 'status': 'Active', 'lastLogin': '2023-10-23 11:45'},
            {'id': 'USR-005', 'name': 'Elena Rodriguez', 'email': 'elena@coreaxis.com', 'role': 'Manager', 'status': 'Active', 'lastLogin': '2023-10-24 10:05'},
          ],
        );
      case ExplorerEntity.organizations:
        return ExplorerDataModel(
          entity: entity,
          columns: [
            ExplorerColumn(key: 'id', title: 'Org ID', type: String),
            ExplorerColumn(key: 'name', title: 'Organization Name', type: String),
            ExplorerColumn(key: 'region', title: 'Region', type: String),
            ExplorerColumn(key: 'employees', title: 'Employees', type: int),
            ExplorerColumn(key: 'revenue', title: 'Annual Rev', type: String),
          ],
          rows: [
            {'id': 'ORG-100', 'name': 'Acme Corp', 'region': 'North America', 'employees': 1250, 'revenue': '\$50M'},
            {'id': 'ORG-101', 'name': 'Stark Industries', 'region': 'Global', 'employees': 55000, 'revenue': '\$12B'},
            {'id': 'ORG-102', 'name': 'Globex', 'region': 'Europe', 'employees': 340, 'revenue': '\$15M'},
          ],
        );
      case ExplorerEntity.furnitureErp:
        return ExplorerDataModel(
          entity: entity,
          columns: [
            ExplorerColumn(key: 'sku', title: 'SKU', type: String),
            ExplorerColumn(key: 'product', title: 'Product Name', type: String),
            ExplorerColumn(key: 'category', title: 'Category', type: String),
            ExplorerColumn(key: 'stock', title: 'In Stock', type: int),
            ExplorerColumn(key: 'price', title: 'Unit Price', type: String),
          ],
          rows: [
            {'sku': 'F-CHR-01', 'product': 'Ergonomic Office Chair', 'category': 'Seating', 'stock': 145, 'price': '\$299.99'},
            {'sku': 'F-DSK-02', 'product': 'Standing Desk Pro', 'category': 'Desks', 'stock': 32, 'price': '\$499.50'},
            {'sku': 'F-CAB-05', 'product': 'Filing Cabinet 3-Drawer', 'category': 'Storage', 'stock': 88, 'price': '\$150.00'},
            {'sku': 'F-LMP-11', 'product': 'LED Desk Lamp', 'category': 'Accessories', 'stock': 210, 'price': '\$45.00'},
          ],
        );
      default:
        // Generic fallback for other mock entities
        return ExplorerDataModel(
          entity: entity,
          columns: [
            ExplorerColumn(key: 'id', title: 'ID', type: String),
            ExplorerColumn(key: 'data', title: 'Data', type: String),
            ExplorerColumn(key: 'timestamp', title: 'Timestamp', type: String),
          ],
          rows: [
            {'id': 'REC-001', 'data': 'Sample Data 1', 'timestamp': '2023-10-24 10:00'},
            {'id': 'REC-002', 'data': 'Sample Data 2', 'timestamp': '2023-10-24 11:30'},
            {'id': 'REC-003', 'data': 'Sample Data 3', 'timestamp': '2023-10-24 12:45'},
          ],
        );
    }
  }
}
