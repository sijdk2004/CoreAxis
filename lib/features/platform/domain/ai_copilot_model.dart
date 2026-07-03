import 'package:flutter/material.dart';

enum ChatRole { user, assistant, system }

enum RichContentType { none, table, chart, card }

class ChatMessage {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;
  final bool isStreaming;
  final RichContentType richContentType;
  final Map<String, dynamic>? richData;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
    this.richContentType = RichContentType.none,
    this.richData,
  });

  ChatMessage copyWith({
    String? content,
    bool? isStreaming,
    RichContentType? richContentType,
    Map<String, dynamic>? richData,
  }) {
    return ChatMessage(
      id: id,
      role: role,
      content: content ?? this.content,
      timestamp: timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      richContentType: richContentType ?? this.richContentType,
      richData: richData ?? this.richData,
    );
  }
}

class CopilotConversation {
  final String id;
  final String title;
  final DateTime updatedAt;
  final List<ChatMessage> messages;
  final bool isPinned;
  final bool isFavorite;

  const CopilotConversation({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.messages,
    this.isPinned = false,
    this.isFavorite = false,
  });

  CopilotConversation copyWith({
    String? title,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
    bool? isPinned,
    bool? isFavorite,
  }) {
    return CopilotConversation(
      id: id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class CopilotState {
  final List<CopilotConversation> conversations;
  final String activeConversationId;
  final bool isTyping;
  final List<String> recentPrompts;
  final List<String> suggestedPrompts;

  CopilotState({
    required this.conversations,
    required this.activeConversationId,
    this.isTyping = false,
    this.recentPrompts = const [],
    this.suggestedPrompts = const [],
  });

  CopilotState copyWith({
    List<CopilotConversation>? conversations,
    String? activeConversationId,
    bool? isTyping,
    List<String>? recentPrompts,
    List<String>? suggestedPrompts,
  }) {
    return CopilotState(
      conversations: conversations ?? this.conversations,
      activeConversationId: activeConversationId ?? this.activeConversationId,
      isTyping: isTyping ?? this.isTyping,
      recentPrompts: recentPrompts ?? this.recentPrompts,
      suggestedPrompts: suggestedPrompts ?? this.suggestedPrompts,
    );
  }

  CopilotConversation? get activeConversation {
    try {
      return conversations.firstWhere((c) => c.id == activeConversationId);
    } catch (e) {
      return null;
    }
  }
}
