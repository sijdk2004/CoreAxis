import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

// ─── Models ───────────────────────────────────────────────────────────────────

enum ChatRole { user, assistant, system }

class ChatMessage {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;
  final bool isLoading;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isLoading = false,
  });

  ChatMessage copyWith({String? content, bool? isLoading}) {
    return ChatMessage(
      id: id,
      role: role,
      content: content ?? this.content,
      timestamp: timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AiConversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<ChatMessage> messages;

  const AiConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  AiConversation copyWith({List<ChatMessage>? messages, String? title}) {
    return AiConversation(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      messages: messages ?? this.messages,
    );
  }
}

class AiAssistantState {
  final List<AiConversation> conversations;
  final String activeConversationId;
  final bool isTyping;

  AiAssistantState({
    required this.conversations,
    required this.activeConversationId,
    this.isTyping = false,
  });

  AiAssistantState copyWith({
    List<AiConversation>? conversations,
    String? activeConversationId,
    bool? isTyping,
  }) {
    return AiAssistantState(
      conversations: conversations ?? this.conversations,
      activeConversationId: activeConversationId ?? this.activeConversationId,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  AiConversation get activeConversation =>
      conversations.firstWhere((c) => c.id == activeConversationId);
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final _mockResponses = [
  'Based on the platform data, your tenant **Acme Corp** has seen a **23% increase** in active users this month. The primary drivers are the new onboarding workflows and the automated welcome notification campaign.\n\nKey insights:\n- 📈 Peak usage hours: 9 AM – 11 AM IST\n- 🏆 Most active department: Finance Team\n- ⚠️ 3 users have not completed mandatory compliance training',
  'I\'ve analyzed the workflow bottlenecks across your platform. The **Invoice Approval** workflow has an average cycle time of **4.2 days**, which is 40% above your SLA target.\n\nRecommended actions:\n1. Add a parallel approval step for amounts under ₹50,000\n2. Enable auto-escalation after 48 hours of inactivity\n3. Consider delegating to Finance Team leads during manager absence',
  'The document repository currently contains **2,847 documents** across 14 categories. Storage utilization is at **67%** of quota.\n\nTop consumers:\n- 📁 Financial Reports: 34% of storage\n- 📁 HR Documents: 21% of storage\n- 📁 Technical Specs: 18% of storage\n\n**Recommendation**: Archive documents older than 2 years to reduce active storage by an estimated 28%.',
  'Security analysis for the last 30 days:\n\n✅ **0 critical security incidents**\n⚠️ **12 failed login attempts** detected from IP `203.0.113.42` — recommend blocking\n🔒 **3 users** have not enabled MFA — compliance risk\n\nOverall security posture: **Good (82/100)**',
  'I\'ve reviewed your notification delivery data. Here\'s the channel performance summary:\n\n| Channel | Delivered | Open Rate |\n|---------|-----------|----------|\n| Email | 98.2% | 34.1% |\n| In-App | 99.9% | 76.3% |\n| Webhook | 94.1% | N/A |\n\n**In-app notifications** are performing exceptionally well. Consider migrating some email-only alerts to in-app for faster response times.',
  'I can help with that! To create a new approval workflow for Purchase Orders, here\'s a suggested configuration:\n\n1. **Trigger**: New PO document with status "Pending Approval"\n2. **Step 1**: Department Manager approval (SLA: 24h)\n3. **Step 2**: Finance Review for amounts > ₹1,00,000 (SLA: 48h)\n4. **Step 3**: CFO Final Approval for amounts > ₹10,00,000 (SLA: 72h)\n5. **Outcome**: Auto-notify requester and update document status\n\nShall I draft the full workflow configuration?',
  'Your platform has **4 tenants** with the following health scores:\n\n🟢 **Acme Corp**: 94/100 — Excellent\n🟡 **TechStart Inc**: 76/100 — Good, storage nearing limit\n🔴 **Global Textiles**: 58/100 — Needs attention, 3 failed integrations\n🟢 **Sunrise Retail**: 89/100 — Very Good\n\nWould you like me to generate detailed remediation plans for the underperforming tenants?',
];

class AiAssistantNotifier extends Notifier<AiAssistantState> {
  @override
  AiAssistantState build() {
    final now = DateTime.now();
    final conversation1 = AiConversation(
      id: 'conv_1',
      title: 'Platform Analytics',
      createdAt: now.subtract(const Duration(days: 1)),
      messages: [
        ChatMessage(
          id: 'msg_0',
          role: ChatRole.assistant,
          content: 'Hello! I\'m **CoreAxis AI**, your intelligent ERP assistant. I can help you with:\n\n- 📊 **Analytics & Insights** — Trends, anomalies, and performance metrics\n- ⚙️ **Workflow Optimization** — Bottleneck analysis and recommendations\n- 🔒 **Security Monitoring** — Risk detection and compliance guidance\n- 👥 **User & Tenant Management** — Actionable user insights\n- 📄 **Document Intelligence** — Usage patterns and storage optimization\n\nWhat would you like to explore today?',
          timestamp: now.subtract(const Duration(days: 1)),
        ),
        ChatMessage(
          id: 'msg_1',
          role: ChatRole.user,
          content: 'Show me a summary of Acme Corp\'s user activity this month.',
          timestamp: now.subtract(const Duration(hours: 23)),
        ),
        ChatMessage(
          id: 'msg_2',
          role: ChatRole.assistant,
          content: _mockResponses[0],
          timestamp: now.subtract(const Duration(hours: 23)),
        ),
        ChatMessage(
          id: 'msg_3',
          role: ChatRole.user,
          content: 'What are the main workflow bottlenecks?',
          timestamp: now.subtract(const Duration(hours: 2)),
        ),
        ChatMessage(
          id: 'msg_4',
          role: ChatRole.assistant,
          content: _mockResponses[1],
          timestamp: now.subtract(const Duration(hours: 2)),
        ),
      ],
    );

    final conversation2 = AiConversation(
      id: 'conv_2',
      title: 'Security Review',
      createdAt: now.subtract(const Duration(hours: 6)),
      messages: [
        ChatMessage(
          id: 'msg_s0',
          role: ChatRole.assistant,
          content: 'Hello! I\'m **CoreAxis AI**. How can I assist you today?',
          timestamp: now.subtract(const Duration(hours: 6)),
        ),
        ChatMessage(
          id: 'msg_s1',
          role: ChatRole.user,
          content: 'Give me a security analysis for the last 30 days.',
          timestamp: now.subtract(const Duration(hours: 5)),
        ),
        ChatMessage(
          id: 'msg_s2',
          role: ChatRole.assistant,
          content: _mockResponses[3],
          timestamp: now.subtract(const Duration(hours: 5)),
        ),
      ],
    );

    return AiAssistantState(
      conversations: [conversation1, conversation2],
      activeConversationId: 'conv_1',
    );
  }

  void selectConversation(String id) {
    state = state.copyWith(activeConversationId: id);
  }

  void newConversation() {
    final id = 'conv_${DateTime.now().millisecondsSinceEpoch}';
    final conv = AiConversation(
      id: id,
      title: 'New Conversation',
      createdAt: DateTime.now(),
      messages: [
        ChatMessage(
          id: 'init_$id',
          role: ChatRole.assistant,
          content: 'Hello! I\'m **CoreAxis AI**, your intelligent ERP assistant. How can I help you today?',
          timestamp: DateTime.now(),
        ),
      ],
    );
    state = state.copyWith(
      conversations: [conv, ...state.conversations],
      activeConversationId: id,
    );
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      role: ChatRole.user,
      content: content,
      timestamp: DateTime.now(),
    );

    final loadingMsg = ChatMessage(
      id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
      role: ChatRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );

    // Add user message + loading
    final updatedConv = state.activeConversation.copyWith(
      messages: [...state.activeConversation.messages, userMsg, loadingMsg],
      title: state.activeConversation.messages.length <= 1
          ? content.substring(0, content.length.clamp(0, 30))
          : null,
    );
    state = state.copyWith(
      conversations: state.conversations.map((c) => c.id == updatedConv.id ? updatedConv : c).toList(),
      isTyping: true,
    );

    // Simulate response delay
    await Future.delayed(Duration(milliseconds: 800 + Random().nextInt(1200)));

    final response = _mockResponses[Random().nextInt(_mockResponses.length)];
    final assistantMsg = ChatMessage(
      id: 'resp_${DateTime.now().millisecondsSinceEpoch}',
      role: ChatRole.assistant,
      content: response,
      timestamp: DateTime.now(),
    );

    final finalConv = updatedConv.copyWith(
      messages: updatedConv.messages
          .where((m) => !m.isLoading)
          .toList()
          ..add(assistantMsg),
    );

    state = state.copyWith(
      conversations: state.conversations.map((c) => c.id == finalConv.id ? finalConv : c).toList(),
      isTyping: false,
    );
  }
}

final aiAssistantProvider = NotifierProvider<AiAssistantNotifier, AiAssistantState>(() {
  return AiAssistantNotifier();
});

// ─── Screen ────────────────────────────────────────────────────────────────────

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    ref.read(aiAssistantProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(aiAssistantProvider);

    // Auto scroll when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Row(
        children: [
          // Conversation History Sidebar
          _buildConversationSidebar(context, theme, state),
          const VerticalDivider(width: 1),
          // Chat Area
          Expanded(
            child: Column(
              children: [
                _buildChatHeader(context, theme, state),
                const Divider(height: 1),
                Expanded(child: _buildMessageList(context, theme, state)),
                _buildQuickPrompts(context, theme),
                const Divider(height: 1),
                _buildInputArea(context, theme, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationSidebar(BuildContext context, ThemeData theme, AiAssistantState state) {
    return Container(
      width: 260,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.sparkles, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CoreAxis AI', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        Text('ERP Intelligence', style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => ref.read(aiAssistantProvider.notifier).newConversation(),
                    icon: const Icon(LucideIcons.plus, size: 14),
                    label: const Text('New Chat'),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Recent', style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            )),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: state.conversations.length,
              itemBuilder: (ctx, i) {
                final conv = state.conversations[i];
                final isActive = conv.id == state.activeConversationId;
                return ListTile(
                  dense: true,
                  selected: isActive,
                  selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  leading: Icon(
                    LucideIcons.messageSquare,
                    size: 16,
                    color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    conv.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${conv.messages.length - 1} messages',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  onTap: () => ref.read(aiAssistantProvider.notifier).selectConversation(conv.id),
                );
              },
            ),
          ),
          // Capabilities
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Model', style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('CoreAxis Intelligence v2.1', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('Online', style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHeader(BuildContext context, ThemeData theme, AiAssistantState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.sparkles, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.activeConversation.title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (state.isTyping)
                  Text('CoreAxis AI is typing...', style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            tooltip: 'New Chat',
            onPressed: () => ref.read(aiAssistantProvider.notifier).newConversation(),
          ),
          IconButton(
            icon: const Icon(LucideIcons.download, size: 18),
            tooltip: 'Export Conversation',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exporting conversation...')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, ThemeData theme, AiAssistantState state) {
    final messages = state.activeConversation.messages;
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: messages.length,
      itemBuilder: (ctx, i) {
        final msg = messages[i];
        return _buildMessageBubble(context, theme, msg, i);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, ThemeData theme, ChatMessage msg, int i) {
    final isUser = msg.role == ChatRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.sparkles, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: msg.isLoading
                  ? _buildTypingIndicator(theme)
                  : _buildMarkdownContent(context, theme, msg.content, isUser),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.1, end: 0),
          if (isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text('A', style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        ).animate(onPlay: (c) => c.repeat()).moveY(
              begin: 0,
              end: -5,
              delay: Duration(milliseconds: 150 * i),
              duration: 400.ms,
              curve: Curves.easeInOut,
            ).then().moveY(begin: -5, end: 0, duration: 400.ms);
      }),
    );
  }

  Widget _buildMarkdownContent(BuildContext context, ThemeData theme, String content, bool isUser) {
    // Simple markdown-ish renderer
    final lines = content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: lines.map((line) {
        if (line.startsWith('# ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(line.substring(2),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isUser ? Colors.white : null,
                )),
          );
        } else if (line.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(line.substring(3),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isUser ? Colors.white : null,
                )),
          );
        } else if (line.startsWith('- ') || line.startsWith('• ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: isUser ? Colors.white70 : theme.colorScheme.primary)),
                Expanded(child: _inlineMarkdown(theme, line.substring(2), isUser)),
              ],
            ),
          );
        } else if (line.startsWith('1. ') || (line.length > 2 && line[1] == '.' && line[0].contains(RegExp(r'[0-9]')))) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4),
            child: _inlineMarkdown(theme, line, isUser),
          );
        } else if (line.trim().isEmpty) {
          return const SizedBox(height: 6);
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: _inlineMarkdown(theme, line, isUser),
          );
        }
      }).toList(),
    );
  }

  Widget _inlineMarkdown(ThemeData theme, String text, bool isUser) {
    // Simple bold processing
    final spans = <TextSpan>[];
    final parts = text.split('**');
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          fontWeight: i.isOdd ? FontWeight.bold : FontWeight.normal,
          color: isUser ? Colors.white : null,
        ),
      ));
    }
    return RichText(text: TextSpan(children: spans, style: theme.textTheme.bodySmall?.copyWith(
      color: isUser ? Colors.white : theme.colorScheme.onSurface,
      height: 1.5,
    )));
  }

  Widget _buildQuickPrompts(BuildContext context, ThemeData theme) {
    final prompts = [
      ('📊 Platform Overview', 'Give me a summary of platform health and key metrics'),
      ('🔒 Security Check', 'Analyze recent security events and flag any risks'),
      ('⚙️ Workflow Issues', 'What are the current workflow bottlenecks?'),
      ('📄 Document Stats', 'Show document repository usage and recommendations'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: prompts.map((p) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: OutlinedButton(
                onPressed: () {
                  _inputController.text = p.$2;
                  _sendMessage();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(p.$1, style: theme.textTheme.labelSmall),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, ThemeData theme, AiAssistantState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: TextField(
                controller: _inputController,
                maxLines: 4,
                minLines: 1,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Ask CoreAxis AI anything about your platform...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedOpacity(
            opacity: state.isTyping ? 0.5 : 1.0,
            duration: 200.ms,
            child: FloatingActionButton(
              onPressed: state.isTyping ? null : _sendMessage,
              mini: false,
              elevation: 0,
              child: const Icon(LucideIcons.sendHorizonal),
            ),
          ),
        ],
      ),
    );
  }
}
