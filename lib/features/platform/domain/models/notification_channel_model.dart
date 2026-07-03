class NotificationChannel {
  final String id;
  final String name;
  final String provider;
  final bool isEnabled;
  final int messagesSent;
  final double successRate;
  final String configStatus;

  // Mock Config fields
  final String apiKey;
  final String senderName;
  final String senderEmail;
  final String webhookUrl;

  NotificationChannel({
    required this.id,
    required this.name,
    required this.provider,
    required this.isEnabled,
    required this.messagesSent,
    required this.successRate,
    required this.configStatus,
    this.apiKey = '',
    this.senderName = '',
    this.senderEmail = '',
    this.webhookUrl = '',
  });

  NotificationChannel copyWith({
    String? id,
    String? name,
    String? provider,
    bool? isEnabled,
    int? messagesSent,
    double? successRate,
    String? configStatus,
    String? apiKey,
    String? senderName,
    String? senderEmail,
    String? webhookUrl,
  }) {
    return NotificationChannel(
      id: id ?? this.id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      isEnabled: isEnabled ?? this.isEnabled,
      messagesSent: messagesSent ?? this.messagesSent,
      successRate: successRate ?? this.successRate,
      configStatus: configStatus ?? this.configStatus,
      apiKey: apiKey ?? this.apiKey,
      senderName: senderName ?? this.senderName,
      senderEmail: senderEmail ?? this.senderEmail,
      webhookUrl: webhookUrl ?? this.webhookUrl,
    );
  }
}

class ChannelUsageDataPoint {
  final String month;
  final int emailVolume;
  final int smsVolume;
  final int pushVolume;

  ChannelUsageDataPoint(this.month, this.emailVolume, this.smsVolume, this.pushVolume);
}
