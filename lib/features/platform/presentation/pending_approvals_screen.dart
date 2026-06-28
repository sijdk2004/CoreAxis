import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../domain/models/approval_request.dart';
import 'providers/pending_approvals_provider.dart';
import 'package:intl/intl.dart';

class PendingApprovalsScreen extends ConsumerStatefulWidget {
  const PendingApprovalsScreen({super.key});

  @override
  ConsumerState<PendingApprovalsScreen> createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends ConsumerState<PendingApprovalsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(pendingApprovalsProvider);
    final notifier = ref.read(pendingApprovalsProvider.notifier);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    // Listen to selection changes to open drawer
    ref.listen<PendingApprovalsState>(pendingApprovalsProvider, (prev, next) {
      if (prev?.selectedRequest == null && next.selectedRequest != null) {
        _scaffoldKey.currentState?.openEndDrawer();
      } else if (prev?.selectedRequest != null && next.selectedRequest == null) {
        // If drawer is open, we can't reliably close it without popping navigator,
        // but state clears properly. We rely on the drawer's onClose to clear state.
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surface,
      endDrawer: _buildDetailDrawer(theme, state.selectedRequest, notifier),
      onEndDrawerChanged: (isOpen) {
        if (!isOpen) {
          notifier.selectRequest(null);
        }
      },
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Pending Approvals'),
        centerTitle: false,
        actions: [
          _buildToolbar(theme, state, notifier, isDesktop),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerColor.withOpacity(0.5), height: 1.0),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatsAndFiltersRow(theme, state, notifier, isDesktop),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
          if (state.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(child: _buildDataTable(theme, state, notifier, isDesktop)),
        ],
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme, PendingApprovalsState state, PendingApprovalsNotifier notifier, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDesktop)
            Container(
              width: 250,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search ID, Type, Workflow...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  prefixIcon: const Icon(LucideIcons.search, size: 16),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: notifier.setSearchQuery,
              ),
            ),
          const SizedBox(width: 16),
          IconButton(icon: const Icon(LucideIcons.filter), tooltip: 'Advanced Filters', onPressed: () {}),
          IconButton(icon: const Icon(LucideIcons.refreshCw), tooltip: 'Refresh', onPressed: notifier.refresh),
          if (state.selectedIds.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(height: 24, width: 1, color: theme.dividerColor),
            const SizedBox(width: 8),
            Text('${state.selectedIds.length} selected', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: notifier.approveSelected,
              icon: const Icon(LucideIcons.check, size: 16),
              label: const Text('Approve'),
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: notifier.rejectSelected,
              icon: const Icon(LucideIcons.x, size: 16, color: Colors.red),
              label: const Text('Reject', style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(width: 8),
            IconButton(icon: const Icon(LucideIcons.users), tooltip: 'Delegate Selected', onPressed: notifier.delegateSelected),
          ],
          const SizedBox(width: 8),
          IconButton(icon: const Icon(LucideIcons.download), tooltip: 'Export', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildStatsAndFiltersRow(ThemeData theme, PendingApprovalsState state, PendingApprovalsNotifier notifier, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatMetric(theme, 'Pending', state.pendingCount, Colors.orange),
              _buildStatMetric(theme, 'High Priority', state.highPriorityCount, Colors.red),
              _buildStatMetric(theme, 'Overdue', state.overdueCount, Colors.purple),
              _buildStatMetric(theme, 'Delegated', state.delegatedCount, Colors.blue),
              _buildStatMetric(theme, 'Escalated', state.escalatedCount, Colors.redAccent),
            ],
          ),
          const SizedBox(height: 24),
          // Quick Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'My Approvals', 'Delegated', 'High Priority', 'Escalated', 'Overdue', 'Awaiting Review']
                  .map((filter) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: state.activeQuickFilter == filter,
                          onSelected: (val) {
                            if (val) notifier.setQuickFilter(filter);
                          },
                        ),
                      ))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatMetric(ThemeData theme, String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text('$value', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildDataTable(ThemeData theme, PendingApprovalsState state, PendingApprovalsNotifier notifier, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double usable = constraints.maxWidth - 32; // 16px padding each side
        final bool allSelected = state.filteredRequests.isNotEmpty && state.selectedIds.length == state.filteredRequests.length;

        // Column widths
        final wCb = 40.0;
        final wId = 100.0;
        final wType = 120.0;
        final wWorkflow = usable * 0.18;
        final wReqBy = 120.0;
        final wStep = 130.0;
        final wPriority = 90.0;
        final wDate = 100.0;
        final wStatus = 100.0;
        final wActions = 50.0;

        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              child: Row(
                children: [
                  SizedBox(width: wCb, child: Checkbox(value: allSelected, onChanged: (val) => notifier.toggleAll(val ?? false))),
                  SizedBox(width: wId, child: Text('ID', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                  SizedBox(width: wType, child: Text('Type', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                  SizedBox(width: wWorkflow, child: Text('Workflow', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                  SizedBox(width: wReqBy, child: Text('Requester', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                  SizedBox(width: wStep, child: Text('Current Step', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                  SizedBox(width: wPriority, child: Text('Priority', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                  SizedBox(width: wDate, child: Text('Due Date', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                  SizedBox(width: wStatus, child: Text('Status', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold))),
                  SizedBox(width: wActions, child: const Text('')),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor),
            // Body
            Expanded(
              child: ListView.builder(
                itemCount: state.filteredRequests.length,
                itemBuilder: (context, index) {
                  final req = state.filteredRequests[index];
                  final isSelected = state.selectedIds.contains(req.id);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.3) : null,
                      border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: wCb, child: Checkbox(value: isSelected, onChanged: (_) => notifier.toggleSelection(req.id))),
                        SizedBox(width: wId, child: Text(req.id, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
                        SizedBox(width: wType, child: Text(req.requestType, style: theme.textTheme.bodyMedium)),
                        SizedBox(width: wWorkflow, child: Text(req.workflow, style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
                        SizedBox(width: wReqBy, child: Text(req.requestedBy, style: theme.textTheme.bodyMedium)),
                        SizedBox(width: wStep, child: Text(req.currentStep, style: theme.textTheme.bodyMedium)),
                        SizedBox(width: wPriority, child: _buildPriorityBadge(req.priority)),
                        SizedBox(width: wDate, child: Text(DateFormat('MMM dd').format(req.dueDate), style: theme.textTheme.bodyMedium?.copyWith(color: req.dueDate.isBefore(DateTime.now()) ? Colors.red : null))),
                        SizedBox(width: wStatus, child: _buildStatusBadge(req.status)),
                        SizedBox(
                          width: wActions,
                          child: PopupMenuButton<String>(
                            icon: const Icon(LucideIcons.moreVertical, size: 20),
                            onSelected: (val) {
                              if (val == 'View') {
                                notifier.selectRequest(req);
                              } else {
                                notifier.actionSingle(req.id, val);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'View', child: Text('View Details')),
                              const PopupMenuItem(value: 'Approve', child: Text('Approve', style: TextStyle(color: Colors.green))),
                              const PopupMenuItem(value: 'Reject', child: Text('Reject', style: TextStyle(color: Colors.red))),
                              const PopupMenuItem(value: 'Delegate', child: Text('Delegate')),
                              const PopupMenuItem(value: 'Clarify', child: Text('Request Clarification')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color = Colors.blue;
    if (priority == 'High') color = Colors.red;
    if (priority == 'Medium') color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(priority, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'Pending') color = Colors.orange;
    if (status == 'Escalated') color = Colors.red;
    if (status == 'Delegated') color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  // ─── DRAWER ───────────────────────────────────────────────────────────
  Widget _buildDetailDrawer(ThemeData theme, ApprovalRequest? req, PendingApprovalsNotifier notifier) {
    if (req == null) return const Drawer(child: SizedBox());

    return Drawer(
      width: 500,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.colorScheme.surface,
          title: Text(req.id, style: theme.textTheme.titleMedium),
          actions: [
            IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.of(context).pop()),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req.workflow, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPriorityBadge(req.priority),
                        const SizedBox(width: 8),
                        _buildStatusBadge(req.status),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(theme, 'Request Summary'),
                    Text(req.summary, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 24),
                    _buildSectionHeader(theme, 'Details'),
                    _buildDetailRow('Requester', req.requestedBy),
                    _buildDetailRow('Submitted', DateFormat('MMM dd, yyyy - HH:mm').format(req.submittedDate)),
                    _buildDetailRow('Due', DateFormat('MMM dd, yyyy - HH:mm').format(req.dueDate)),
                    const SizedBox(height: 24),
                    _buildSectionHeader(theme, 'Approval Timeline'),
                    ...req.timeline.map((t) => _buildTimelineEvent(theme, t)),
                    const SizedBox(height: 24),
                    _buildSectionHeader(theme, 'Attachments'),
                    if (req.attachments.isEmpty) const Text('No attachments') else ...req.attachments.map((a) => _buildAttachment(theme, a)),
                    const SizedBox(height: 24),
                    _buildSectionHeader(theme, 'Comments'),
                    if (req.comments.isEmpty) const Text('No comments') else ...req.comments.map((c) => _buildComment(theme, c)),
                  ],
                ),
              ),
            ),
            // Decision Panel
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: theme.dividerColor)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            notifier.actionSingle(req.id, 'Approve');
                            Navigator.of(context).pop();
                          },
                          style: FilledButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Approve'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            notifier.actionSingle(req.id, 'Reject');
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Reject'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      notifier.actionSingle(req.id, 'Clarify');
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(LucideIcons.messageSquare, size: 16),
                    label: const Text('Request Clarification'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTimelineEvent(ThemeData theme, TimelineEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                event.isCompleted ? LucideIcons.checkCircle2 : (event.isCurrent ? LucideIcons.circleDot : LucideIcons.circle),
                color: event.isCompleted ? Colors.green : (event.isCurrent ? Colors.blue : Colors.grey),
                size: 20,
              ),
              if (!event.isCurrent) // Simulate line for non-last items (simplified)
                Container(height: 24, width: 2, color: theme.dividerColor),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: event.isCurrent ? FontWeight.bold : FontWeight.normal)),
                Text(event.subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Text(DateFormat('MMM dd').format(event.time), style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAttachment(ThemeData theme, Attachment a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: theme.dividerColor), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(LucideIcons.file, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.fileName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(a.fileSize, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
          IconButton(icon: const Icon(LucideIcons.download), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildComment(ThemeData theme, Comment c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(c.user, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(DateFormat('MMM dd, HH:mm').format(c.time), style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Text(c.text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
