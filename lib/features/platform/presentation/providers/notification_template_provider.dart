import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_template_model.dart';

class NotificationTemplateState {
  final List<NotificationTemplate> templates;
  final String searchQuery;
  final String activeCategory;

  NotificationTemplateState({
    required this.templates,
    this.searchQuery = '',
    this.activeCategory = 'All',
  });

  NotificationTemplateState copyWith({
    List<NotificationTemplate>? templates,
    String? searchQuery,
    String? activeCategory,
  }) {
    return NotificationTemplateState(
      templates: templates ?? this.templates,
      searchQuery: searchQuery ?? this.searchQuery,
      activeCategory: activeCategory ?? this.activeCategory,
    );
  }

  List<NotificationTemplate> get filteredTemplates {
    return templates.where((template) {
      if (activeCategory != 'All' && template.category != activeCategory) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!template.name.toLowerCase().contains(query) &&
            !template.code.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}

class NotificationTemplateNotifier extends Notifier<NotificationTemplateState> {
  @override
  NotificationTemplateState build() {
    return NotificationTemplateState(templates: _generateMockTemplates());
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setActiveCategory(String category) {
    state = state.copyWith(activeCategory: category);
  }

  void addTemplate(NotificationTemplate template) {
    state = state.copyWith(templates: [...state.templates, template]);
  }

  void updateTemplate(NotificationTemplate updatedTemplate) {
    state = state.copyWith(
      templates: state.templates.map((t) => t.id == updatedTemplate.id ? updatedTemplate : t).toList(),
    );
  }

  void deleteTemplate(String id) {
    state = state.copyWith(
      templates: state.templates.where((t) => t.id != id).toList(),
    );
  }

  void duplicateTemplate(String id) {
    final original = state.templates.firstWhere((t) => t.id == id);
    final duplicated = original.copyWith(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      name: '${original.name} (Copy)',
      code: '${original.code}_COPY',
      status: 'Draft',
      updatedAt: DateTime.now(),
    );
    addTemplate(duplicated);
  }

  List<NotificationTemplate> _generateMockTemplates() {
    return [
      NotificationTemplate(
        id: 'TPL_1001',
        name: 'Approval Request Standard',
        code: 'APP_REQ_001',
        channel: 'Email',
        language: 'en',
        category: 'Approval',
        status: 'Active',
        subject: 'Action Required: Approval for {{WorkflowName}}',
        body: 'Hello {{UserName}},\n\nA new approval request requires your attention for {{WorkflowName}}.\n\nPlease review the details within the platform.\n\nBest,\n{{TenantName}} Team',
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      NotificationTemplate(
        id: 'TPL_1002',
        name: 'Approval Approved',
        code: 'APP_RES_OK',
        channel: 'Email',
        language: 'en',
        category: 'Approval',
        status: 'Active',
        subject: 'Approved: {{WorkflowName}}',
        body: 'Hello {{UserName}},\n\nYour request for {{WorkflowName}} has been approved.\n\nStatus: {{ApprovalStatus}}\n\nBest,\n{{TenantName}} Team',
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      NotificationTemplate(
        id: 'TPL_1003',
        name: 'Workflow Task Assigned SMS',
        code: 'WF_TASK_SMS',
        channel: 'SMS',
        language: 'en',
        category: 'Workflow',
        status: 'Active',
        subject: '',
        body: 'Hi {{UserName}}, you have been assigned a new task: {{WorkflowName}}. Log in to {{Organization}} ERP to view.',
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationTemplate(
        id: 'TPL_1004',
        name: 'Invoice Overdue Warning',
        code: 'FIN_INV_WARN',
        channel: 'Email',
        language: 'en',
        category: 'Finance',
        status: 'Draft',
        subject: 'URGENT: Invoice Overdue',
        body: 'Dear {{UserName}},\n\nThis is a reminder that an invoice is overdue in {{Organization}}.\nDate: {{CurrentDate}}\n\nPlease review immediately.',
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      NotificationTemplate(
        id: 'TPL_1005',
        name: 'System Maintenance Alert',
        code: 'SYS_MAINT',
        channel: 'Push',
        language: 'en',
        category: 'System',
        status: 'Inactive',
        subject: 'Scheduled Maintenance',
        body: 'System maintenance scheduled for {{CurrentDate}}. Expect minor disruptions.',
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }
}

final notificationTemplateProvider = NotifierProvider<NotificationTemplateNotifier, NotificationTemplateState>(() {
  return NotificationTemplateNotifier();
});
