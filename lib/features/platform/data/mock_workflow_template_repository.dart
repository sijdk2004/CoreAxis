import '../domain/models/workflow_template.dart';

class MockWorkflowTemplateRepository {
  Future<List<WorkflowTemplate>> getTemplates() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      const WorkflowTemplate(
        id: 'wt1',
        name: 'Quotation Approval',
        category: 'Sales',
        steps: 3,
        complexity: 'Simple',
        estimatedSetupTime: '10 mins',
      ),
      const WorkflowTemplate(
        id: 'wt2',
        name: 'Purchase Approval',
        category: 'Purchase',
        steps: 4,
        complexity: 'Medium',
        estimatedSetupTime: '15 mins',
      ),
      const WorkflowTemplate(
        id: 'wt3',
        name: 'Leave Approval',
        category: 'HR',
        steps: 2,
        complexity: 'Simple',
        estimatedSetupTime: '5 mins',
      ),
      const WorkflowTemplate(
        id: 'wt4',
        name: 'Expense Approval',
        category: 'Finance',
        steps: 3,
        complexity: 'Simple',
        estimatedSetupTime: '10 mins',
      ),
      const WorkflowTemplate(
        id: 'wt5',
        name: 'Production Release',
        category: 'Manufacturing',
        steps: 6,
        complexity: 'Complex',
        estimatedSetupTime: '30 mins',
      ),
      const WorkflowTemplate(
        id: 'wt6',
        name: 'Inventory Adjustment',
        category: 'Inventory',
        steps: 4,
        complexity: 'Medium',
        estimatedSetupTime: '15 mins',
      ),
      const WorkflowTemplate(
        id: 'wt7',
        name: 'Delivery Approval',
        category: 'Sales', // User had Delivery in Sales/Logistics, 'Sales' category is valid
        steps: 3,
        complexity: 'Medium',
        estimatedSetupTime: '15 mins',
      ),
      const WorkflowTemplate(
        id: 'wt8',
        name: 'Invoice Approval',
        category: 'Finance',
        steps: 4,
        complexity: 'Medium',
        estimatedSetupTime: '20 mins',
      ),
    ];
  }
}
