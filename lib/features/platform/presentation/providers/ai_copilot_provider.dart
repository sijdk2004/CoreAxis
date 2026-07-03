import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/ai_copilot_model.dart';
import 'dart:math';

final aiCopilotProvider = NotifierProvider<AiCopilotNotifier, CopilotState>(() {
  return AiCopilotNotifier();
});

class AiCopilotNotifier extends Notifier<CopilotState> {
  @override
  CopilotState build() {
    return CopilotState(
      activeConversationId: 'conv-1',
      conversations: [
        CopilotConversation(
          id: 'conv-1',
          title: 'New Conversation',
          updatedAt: DateTime.now(),
          isPinned: false,
          isFavorite: false,
          messages: [
            ChatMessage(
              id: 'msg-1',
              role: ChatRole.assistant,
              content: 'Hello! I am your Enterprise AI Copilot. I can help you analyze data, generate reports, summarize workflows, or answer questions about your organization. What would you like to do today?',
              timestamp: DateTime.now(),
            ),
          ],
        ),
        CopilotConversation(
          id: 'conv-2',
          title: 'Q2 Sales Analysis',
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          isPinned: true,
          isFavorite: true,
          messages: [
            ChatMessage(
              id: 'msg-old-1',
              role: ChatRole.user,
              content: 'Show me the top organizations by revenue for Q2.',
              timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 10)),
            ),
            ChatMessage(
              id: 'msg-old-2',
              role: ChatRole.assistant,
              content: 'Here are the top performing organizations for Q2:',
              timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 9)),
              richContentType: RichContentType.table,
              richData: const {
                'columns': ['Organization', 'Revenue', 'Growth'],
                'rows': [
                  ['Acme Corp', '\$1.2M', '+15%'],
                  ['Global Tech', '\$980K', '+8%'],
                  ['Stellar Inc', '\$850K', '-2%'],
                ],
              }
            ),
          ],
        ),
        CopilotConversation(
          id: 'conv-3',
          title: 'Pending Approvals',
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          isPinned: false,
          isFavorite: false,
          messages: [],
        ),
      ],
      recentPrompts: [
        'Analyze user growth.',
        'Which reports are most viewed?',
        'List inactive tenants.',
      ],
      suggestedPrompts: [
        'Show pending approvals.',
        'Generate workflow summary.',
        'Show top organizations.',
        'Generate executive summary.',
        'What workflows are failing?',
      ],
    );
  }

  void selectConversation(String id) {
    state = state.copyWith(activeConversationId: id);
  }

  void createNewConversation() {
    final newId = 'conv-${DateTime.now().millisecondsSinceEpoch}';
    final newConv = CopilotConversation(
      id: newId,
      title: 'New Conversation',
      updatedAt: DateTime.now(),
      messages: [
        ChatMessage(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          role: ChatRole.assistant,
          content: 'Hello! I am your Enterprise AI Copilot. How can I assist you?',
          timestamp: DateTime.now(),
        ),
      ],
    );

    state = state.copyWith(
      conversations: [newConv, ...state.conversations],
      activeConversationId: newId,
    );
  }

  Future<void> sendMessage(String text) async {
    final activeConv = state.activeConversation;
    if (activeConv == null || text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: 'msg-u-${DateTime.now().millisecondsSinceEpoch}',
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
    );

    // Add user message
    _updateConversation(activeConv.copyWith(
      messages: [...activeConv.messages, userMsg],
      updatedAt: DateTime.now(),
    ));

    state = state.copyWith(isTyping: true);

    // Simulate AI thinking and streaming
    await Future.delayed(const Duration(milliseconds: 1500));

    final aiMsgId = 'msg-ai-${DateTime.now().millisecondsSinceEpoch}';
    String fullResponse = _generateMockResponse(text);
    
    // Check for rich content triggers based on prompt keywords
    RichContentType richType = RichContentType.none;
    Map<String, dynamic>? richData;
    
    final lowerText = text.toLowerCase();
    if (lowerText.contains('table') || lowerText.contains('list') || lowerText.contains('approvals')) {
      richType = RichContentType.table;
      richData = {
        'columns': ['ID', 'Type', 'Requester', 'Amount'],
        'rows': [
          ['PO-1042', 'Purchase', 'Alice S.', '\$4,500'],
          ['EXP-899', 'Expense', 'Bob J.', '\$320'],
          ['INV-441', 'Invoice', 'Charlie B.', '\$12,000'],
        ]
      };
      fullResponse = 'Here is the data you requested:';
    } else if (lowerText.contains('chart') || lowerText.contains('growth') || lowerText.contains('analyze')) {
      richType = RichContentType.chart;
      richData = {
        'title': 'User Growth (Last 6 Months)',
        'data': [120, 150, 180, 220, 300, 450],
        'labels': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
      };
      fullResponse = 'Here is the analysis of the user growth trend:';
    }

    // Streaming effect
    String streamedContent = '';
    final words = fullResponse.split(' ');
    
    for (int i = 0; i < words.length; i++) {
      streamedContent += (i == 0 ? '' : ' ') + words[i];
      
      final currentConv = state.activeConversation;
      if (currentConv != null) {
        final messages = List<ChatMessage>.from(currentConv.messages);
        
        // If it's the first word, add the message. Otherwise update the last message.
        if (i == 0) {
          messages.add(ChatMessage(
            id: aiMsgId,
            role: ChatRole.assistant,
            content: streamedContent,
            timestamp: DateTime.now(),
            isStreaming: true,
          ));
        } else {
          messages[messages.length - 1] = messages.last.copyWith(content: streamedContent);
        }
        
        _updateConversation(currentConv.copyWith(messages: messages));
        
        // Minor delay for stream effect
        await Future.delayed(Duration(milliseconds: 50 + Random().nextInt(50)));
      }
    }

    // Finalize message with rich content
    final finalConv = state.activeConversation;
    if (finalConv != null) {
      final messages = List<ChatMessage>.from(finalConv.messages);
      messages[messages.length - 1] = messages.last.copyWith(
        isStreaming: false,
        richContentType: richType,
        richData: richData,
      );
      
      _updateConversation(finalConv.copyWith(
        messages: messages,
        title: finalConv.title == 'New Conversation' ? text : finalConv.title,
      ));
    }
    
    state = state.copyWith(isTyping: false);
  }

  void _updateConversation(CopilotConversation conv) {
    final index = state.conversations.indexWhere((c) => c.id == conv.id);
    if (index >= 0) {
      final newConversations = List<CopilotConversation>.from(state.conversations);
      newConversations[index] = conv;
      state = state.copyWith(conversations: newConversations);
    }
  }

  String _generateMockResponse(String query) {
    final lowerQuery = query.toLowerCase();
    
    if (lowerQuery.contains('hello') || lowerQuery.contains('hi')) {
      return "Hello! How can I assist you with your ERP tasks today?";
    } else if (lowerQuery.contains('summary')) {
      return "Based on the recent data, the organization has performed well this quarter. Overall revenue is up by 12%, and operational costs have decreased by 4% due to the new automated workflows.";
    } else if (lowerQuery.contains('tenant')) {
      return "I found 3 inactive tenants in the system. They have had no login activity in the last 90 days. Would you like me to initiate the offboarding workflow for them?";
    } else {
      return "I've analyzed your request regarding '${query}'. As an AI assistant, I can confirm that the system is operating normally and all records are up to date. Is there a specific metric you'd like me to dive deeper into?";
    }
  }
}
