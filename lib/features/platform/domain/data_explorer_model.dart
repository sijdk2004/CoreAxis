enum ExplorerEntity { users, organizations, workflows, approvals, notifications, audit, documents, furnitureErp }

class ExplorerColumn {
  final String key;
  final String title;
  final Type type;

  ExplorerColumn({required this.key, required this.title, required this.type});
}

class ExplorerDataModel {
  final ExplorerEntity entity;
  final List<ExplorerColumn> columns;
  final List<Map<String, dynamic>> rows;

  ExplorerDataModel({
    required this.entity,
    required this.columns,
    required this.rows,
  });
}
