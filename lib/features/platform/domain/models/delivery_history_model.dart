class DeliveryHistoryItem {
  final String id;
  final String notificationName;
  final String recipient;
  final String channel;
  final DateTime deliveredAt;
  final DateTime? readAt;
  final String status;
  final String provider;
  final Duration duration;

  DeliveryHistoryItem({
    required this.id,
    required this.notificationName,
    required this.recipient,
    required this.channel,
    required this.deliveredAt,
    this.readAt,
    required this.status,
    required this.provider,
    required this.duration,
  });
}
