import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/data_history_model.dart';

final dataHistoryProvider = NotifierProvider<DataHistoryNotifier, AsyncValue<DataHistoryModel>>(() {
  return DataHistoryNotifier();
});

class DataHistoryNotifier extends Notifier<AsyncValue<DataHistoryModel>> {
  @override
  AsyncValue<DataHistoryModel> build() {
    _loadMockData();
    return const AsyncValue.loading();
  }

  Future<void> _loadMockData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final mockRecords = [
      DataChangeRecord(
        id: 'CHG-1001',
        entityId: 'ORG-001',
        entityName: 'Acme Corporation',
        entityType: 'Organization',
        changedBy: 'Admin User',
        userAvatarUrl: 'https://i.pravatar.cc/150?u=admin',
        changedOn: DateTime.now().subtract(const Duration(hours: 2)),
        module: 'Core Settings',
        action: ChangeAction.update,
        changes: const [
          FieldChange(fieldName: 'Billing Address', beforeValue: '123 Old St', afterValue: '456 New Ave', changeType: ChangeType.modified),
          FieldChange(fieldName: 'Contact Email', beforeValue: 'contact@acme.old', afterValue: 'billing@acme.new', changeType: ChangeType.modified),
          FieldChange(fieldName: 'VIP Status', beforeValue: null, afterValue: 'true', changeType: ChangeType.added),
        ],
        rawBeforeJson: {
          'id': 'ORG-001',
          'name': 'Acme Corporation',
          'billing_address': '123 Old St',
          'contact_email': 'contact@acme.old',
          'status': 'active',
        },
        rawAfterJson: {
          'id': 'ORG-001',
          'name': 'Acme Corporation',
          'billing_address': '456 New Ave',
          'contact_email': 'billing@acme.new',
          'vip_status': true,
          'status': 'active',
        },
      ),
      DataChangeRecord(
        id: 'CHG-1002',
        entityId: 'USR-892',
        entityName: 'John Doe',
        entityType: 'User',
        changedBy: 'System Administrator',
        userAvatarUrl: 'https://i.pravatar.cc/150?u=sysadmin',
        changedOn: DateTime.now().subtract(const Duration(days: 1)),
        module: 'RBAC',
        action: ChangeAction.update,
        changes: const [
          FieldChange(fieldName: 'Role', beforeValue: 'Viewer', afterValue: 'Editor', changeType: ChangeType.modified),
          FieldChange(fieldName: 'Department', beforeValue: 'Sales', afterValue: null, changeType: ChangeType.removed),
        ],
        rawBeforeJson: {
          'id': 'USR-892',
          'name': 'John Doe',
          'role': 'Viewer',
          'department': 'Sales',
        },
        rawAfterJson: {
          'id': 'USR-892',
          'name': 'John Doe',
          'role': 'Editor',
        },
      ),
      DataChangeRecord(
        id: 'CHG-1003',
        entityId: 'WF-554',
        entityName: 'Invoice Approval Workflow',
        entityType: 'Workflow',
        changedBy: 'Jane Smith',
        userAvatarUrl: 'https://i.pravatar.cc/150?u=jane',
        changedOn: DateTime.now().subtract(const Duration(days: 2)),
        module: 'Workflow Engine',
        action: ChangeAction.create,
        changes: const [
          FieldChange(fieldName: 'Workflow ID', beforeValue: null, afterValue: 'WF-554', changeType: ChangeType.added),
          FieldChange(fieldName: 'Steps', beforeValue: null, afterValue: '3 Steps', changeType: ChangeType.added),
        ],
        rawBeforeJson: {},
        rawAfterJson: {
          'id': 'WF-554',
          'name': 'Invoice Approval Workflow',
          'steps': 3,
          'active': true,
        },
      ),
      DataChangeRecord(
        id: 'CHG-1004',
        entityId: 'DOC-112',
        entityName: 'Q3 Financial Report',
        entityType: 'Document',
        changedBy: 'Finance Bot',
        userAvatarUrl: 'https://i.pravatar.cc/150?u=bot',
        changedOn: DateTime.now().subtract(const Duration(days: 3)),
        module: 'Document Engine',
        action: ChangeAction.delete,
        changes: const [
          FieldChange(fieldName: 'Status', beforeValue: 'Archived', afterValue: 'Deleted', changeType: ChangeType.modified),
        ],
        rawBeforeJson: {
          'id': 'DOC-112',
          'title': 'Q3 Financial Report',
          'status': 'Archived',
        },
        rawAfterJson: {
          'id': 'DOC-112',
          'title': 'Q3 Financial Report',
          'status': 'Deleted',
        },
      ),
    ];

    state = AsyncValue.data(DataHistoryModel(records: mockRecords));
  }
}
