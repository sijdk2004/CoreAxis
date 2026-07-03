enum NotificationViewType { table, card, timeline }

class NotificationMessage {
  final String id;
  final String title;
  final String message;
  final String module;
  final String recipient;
  final String channel;
  final String priority;
  final String status;
  final DateTime createdTime;
  final DateTime? readTime;
  final List<String> attachments;
  final String deliveryInfo;
  final List<NotificationHistoryEvent> history;

  NotificationMessage({
    required this.id,
    required this.title,
    required this.message,
    required this.module,
    required this.recipient,
    required this.channel,
    required this.priority,
    required this.status,
    required this.createdTime,
    this.readTime,
    this.attachments = const [],
    required this.deliveryInfo,
    this.history = const [],
  });

  NotificationMessage copyWith({
    String? status,
    DateTime? readTime,
  }) {
    return NotificationMessage(
      id: id,
      title: title,
      message: message,
      module: module,
      recipient: recipient,
      channel: channel,
      priority: priority,
      status: status ?? this.status,
      createdTime: createdTime,
      readTime: readTime ?? this.readTime,
      attachments: attachments,
      deliveryInfo: deliveryInfo,
      history: history,
    );
  }
}

class NotificationHistoryEvent {
  final DateTime timestamp;
  final String status;
  final String description;

  NotificationHistoryEvent(this.timestamp, this.status, this.description);
}
