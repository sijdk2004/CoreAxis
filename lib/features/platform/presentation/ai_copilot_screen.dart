import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

import 'providers/ai_copilot_provider.dart';
import '../domain/ai_copilot_model.dart';

class AiCopilotScreen extends ConsumerStatefulWidget {
  const AiCopilotScreen({super.key});

  @override
  ConsumerState<AiCopilotScreen> createState() => _AiCopilotScreenState();
}

class _AiCopilotScreenState extends ConsumerState<AiCopilotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSubmit() {
    if (_textController.text.trim().isNotEmpty) {
      ref.read(aiCopilotProvider.notifier).sendMessage(_textController.text);
      _textController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiCopilotProvider);
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP);
    
    // Auto scroll when messages change
    ref.listen<CopilotState>(aiCopilotProvider, (previous, next) {
      if (previous?.activeConversation?.messages.length != next.activeConversation?.messages.length ||
          (next.activeConversation?.messages.isNotEmpty == true && next.activeConversation!.messages.last.isStreaming)) {
        Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
      }
    });

    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar (History)
          if (isDesktop)
            Container(
              width: 280,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: theme.dividerColor)),
                color: theme.colorScheme.surface,
              ),
              child: _buildLeftSidebar(context, state),
            ),
            
          // Center Chat Window
          Expanded(
            child: Column(
              children: [
                _buildHeader(context, state),
                Expanded(
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    child: _buildChatArea(context, state),
                  ),
                ),
                _buildInputArea(context, state),
              ],
            ),
          ),
          
          // Right Sidebar (Context)
          if (isDesktop)
            Container(
              width: 300,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: theme.dividerColor)),
                color: theme.colorScheme.surface,
              ),
              child: _buildRightSidebar(context, state),
            ),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar(BuildContext context, CopilotState state) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(aiCopilotProvider.notifier).createNewConversation();
            },
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('New Chat'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildSidebarSectionTitle(context, 'Pinned & Favorites'),
              ...state.conversations
                  .where((c) => c.isPinned || c.isFavorite)
                  .map((c) => _buildConversationItem(context, c, state.activeConversationId == c.id)),
                  
              const SizedBox(height: 16),
              _buildSidebarSectionTitle(context, 'Recent Chats'),
              ...state.conversations
                  .where((c) => !c.isPinned && !c.isFavorite)
                  .map((c) => _buildConversationItem(context, c, state.activeConversationId == c.id)),
                  
              const SizedBox(height: 16),
              _buildSidebarSectionTitle(context, 'Recent Prompts'),
              ...state.recentPrompts.map((p) => ListTile(
                dense: true,
                leading: const Icon(LucideIcons.history, size: 16),
                title: Text(p, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  _textController.text = p;
                },
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  Widget _buildConversationItem(BuildContext context, CopilotConversation conv, bool isActive) {
    final theme = Theme.of(context);
    return ListTile(
      selected: isActive,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      leading: Icon(
        conv.isPinned ? LucideIcons.pin : LucideIcons.messageSquare,
        size: 18,
        color: isActive ? theme.colorScheme.primary : null,
      ),
      title: Text(
        conv.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? theme.colorScheme.primary : null,
        ),
      ),
      onTap: () {
        ref.read(aiCopilotProvider.notifier).selectConversation(conv.id);
      },
    );
  }

  Widget _buildRightSidebar(BuildContext context, CopilotState state) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Context', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        _buildContextCard(
          context, 
          'Current Organization', 
          'Acme Corp',
          LucideIcons.building2,
        ),
        const SizedBox(height: 12),
        _buildContextCard(
          context, 
          'Current User', 
          'Alice Smith (Admin)',
          LucideIcons.user,
        ),
        
        const SizedBox(height: 24),
        Text('Recent Activity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildActivityTimeline(context),
        
        const SizedBox(height: 24),
        Text('Suggested Prompts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...state.suggestedPrompts.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ActionChip(
            label: Text(p, style: const TextStyle(fontSize: 12)),
            onPressed: () {
              _textController.text = p;
              _handleSubmit();
            },
          ),
        )),
      ],
    );
  }

  Widget _buildContextCard(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodySmall),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimelineItem(context, 'Generated Q2 Report', '10 mins ago'),
        _buildTimelineItem(context, 'Approved PO-1042', '1 hour ago'),
        _buildTimelineItem(context, 'Modified Workflow Settings', '3 hours ago'),
      ],
    );
  }

  Widget _buildTimelineItem(BuildContext context, String title, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4, right: 12),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13)),
                Text(time, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CopilotState state) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.sparkles, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enterprise AI Copilot', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(state.activeConversation?.title ?? 'New Conversation', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(icon: const Icon(LucideIcons.share), onPressed: () {}),
          IconButton(icon: const Icon(LucideIcons.moreVertical), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildChatArea(BuildContext context, CopilotState state) {
    final activeConv = state.activeConversation;
    if (activeConv == null || activeConv.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.bot, size: 64, color: Theme.of(context).dividerColor),
            const SizedBox(height: 16),
            Text('How can I assist you today?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Ask me anything about your ERP data.', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ).animate().fade().scale(),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: activeConv.messages.length + (state.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == activeConv.messages.length) {
          return _buildTypingIndicator(context);
        }
        return _buildMessage(context, activeConv.messages[index]);
      },
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: const Icon(LucideIcons.bot, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text('AI is thinking...', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ).animate().fade(),
    );
  }

  Widget _buildMessage(BuildContext context, ChatMessage msg) {
    final isUser = msg.role == ChatRole.user;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(LucideIcons.sparkles, color: Colors.blue, size: 18),
            ),
            const SizedBox(width: 16),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser ? theme.colorScheme.primary : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: isUser ? null : Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.content, 
                        style: TextStyle(color: isUser ? theme.colorScheme.onPrimary : null, height: 1.5),
                      ),
                      
                      if (msg.isStreaming)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Icon(LucideIcons.penLine, size: 12, color: theme.colorScheme.primary).animate().fade().scale(),
                        ),
                        
                      if (msg.richContentType != RichContentType.none && !msg.isStreaming && msg.richData != null) ...[
                        const SizedBox(height: 16),
                        _buildRichContent(context, msg),
                      ],
                    ],
                  ),
                ),
                if (!isUser && !msg.isStreaming) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMessageAction(context, LucideIcons.copy, 'Copy'),
                      _buildMessageAction(context, LucideIcons.download, 'Export'),
                      _buildMessageAction(context, LucideIcons.refreshCw, 'Regenerate'),
                      const SizedBox(width: 8),
                      Text(DateFormat('HH:mm').format(msg.timestamp), style: theme.textTheme.bodySmall),
                    ],
                  )
                ],
                if (isUser) ...[
                  const SizedBox(height: 4),
                  Text(DateFormat('HH:mm').format(msg.timestamp), style: theme.textTheme.bodySmall),
                ]
              ],
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 16),
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(LucideIcons.user, color: theme.colorScheme.onPrimaryContainer),
            ),
          ],
        ],
      ).animate().fade(duration: const Duration(milliseconds: 200)),
    );
  }

  Widget _buildRichContent(BuildContext context, ChatMessage msg) {
    if (msg.richContentType == RichContentType.table) {
      final cols = msg.richData!['columns'] as List<String>;
      final rows = msg.richData!['rows'] as List<List<String>>;
      
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
          columns: cols.map((c) => DataColumn(label: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
          rows: rows.map((r) => DataRow(cells: r.map((c) => DataCell(Text(c))).toList())).toList(),
        ),
      );
    } else if (msg.richContentType == RichContentType.chart) {
      final title = msg.richData!['title'] as String;
      final data = msg.richData!['data'] as List<int>;
      final labels = msg.richData!['labels'] as List<String>;
      
      return Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  barGroups: data.asMap().entries.map((e) => BarChartGroupData(
                    x: e.key,
                    barRods: [BarChartRodData(toY: e.value.toDouble(), color: Colors.blue, width: 16, borderRadius: BorderRadius.circular(4))],
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMessageAction(BuildContext context, IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(icon, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, CopilotState state) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Ask your ERP Copilot...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.mic),
                          onPressed: () {}, // Voice Mock
                          tooltip: 'Use Voice',
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.paperclip),
                          onPressed: () {},
                          tooltip: 'Attach Data',
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  onSubmitted: (_) => _handleSubmit(),
                  enabled: !state.isTyping,
                ),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                onPressed: state.isTyping ? null : _handleSubmit,
                elevation: 0,
                child: const Icon(LucideIcons.send),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'AI Copilot can make mistakes. Check important info.',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
