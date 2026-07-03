class QueueItem {
  final String id;
  final String notificationName;
  final String recipient;
  final String channel;
  final String priority;
  final int retryCount;
  final String status;
  final DateTime createdAt;

  QueueItem({
    required this.id,
    required this.notificationName,
    required this.recipient,
    required this.channel,
    required this.priority,
    required this.retryCount,
    required this.status,
    required this.createdAt,
  });

  QueueItem copyWith({
    String? id,
    String? notificationName,
    String? recipient,
    String? channel,
    String? priority,
    int? retryCount,
    String? status,
    DateTime? createdAt,
  }) {
    return QueueItem(
      id: id ?? this.id,
      notificationName: notificationName ?? this.notificationName,
      recipient: recipient ?? this.recipient,
      channel: channel ?? this.channel,
      priority: priority ?? this.priority,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
