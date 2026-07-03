enum ChangeAction {
  create,
  update,
  delete,
}

enum ChangeType {
  added,
  modified,
  removed,
}

class FieldChange {
  final String fieldName;
  final String? beforeValue;
  final String? afterValue;
  final ChangeType changeType;

  const FieldChange({
    required this.fieldName,
    this.beforeValue,
    this.afterValue,
    required this.changeType,
  });
}

class DataChangeRecord {
  final String id;
  final String entityId;
  final String entityName;
  final String entityType;
  final String changedBy;
  final String userAvatarUrl;
  final DateTime changedOn;
  final String module;
  final ChangeAction action;
  final List<FieldChange> changes;
  final Map<String, dynamic> rawBeforeJson;
  final Map<String, dynamic> rawAfterJson;

  const DataChangeRecord({
    required this.id,
    required this.entityId,
    required this.entityName,
    required this.entityType,
    required this.changedBy,
    required this.userAvatarUrl,
    required this.changedOn,
    required this.module,
    required this.action,
    required this.changes,
    required this.rawBeforeJson,
    required this.rawAfterJson,
  });
}

class DataHistoryModel {
  final List<DataChangeRecord> records;

  const DataHistoryModel({
    required this.records,
  });

  DataHistoryModel copyWith({
    List<DataChangeRecord>? records,
  }) {
    return DataHistoryModel(
      records: records ?? this.records,
    );
  }
}
