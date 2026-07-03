class BroadcastCampaign {
  final String id;
  final String name;
  final String type;
  final List<String> audience;
  final String channel;
  final String status;
  final String priority;
  final String message;
  final DateTime? scheduleDate;
  final int recipients;
  final int delivered;
  final int opened;
  final int failed;
  final DateTime createdAt;

  BroadcastCampaign({
    required this.id,
    required this.name,
    required this.type,
    required this.audience,
    required this.channel,
    required this.status,
    required this.priority,
    required this.message,
    this.scheduleDate,
    this.recipients = 0,
    this.delivered = 0,
    this.opened = 0,
    this.failed = 0,
    required this.createdAt,
  });

  BroadcastCampaign copyWith({
    String? id,
    String? name,
    String? type,
    List<String>? audience,
    String? channel,
    String? status,
    String? priority,
    String? message,
    DateTime? scheduleDate,
    int? recipients,
    int? delivered,
    int? opened,
    int? failed,
    DateTime? createdAt,
  }) {
    return BroadcastCampaign(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      audience: audience ?? this.audience,
      channel: channel ?? this.channel,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      message: message ?? this.message,
      scheduleDate: scheduleDate ?? this.scheduleDate,
      recipients: recipients ?? this.recipients,
      delivered: delivered ?? this.delivered,
      opened: opened ?? this.opened,
      failed: failed ?? this.failed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CampaignChartData {
  final String label;
  final double value;

  CampaignChartData(this.label, this.value);
}
