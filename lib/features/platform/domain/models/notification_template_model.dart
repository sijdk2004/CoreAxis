class NotificationTemplate {
  final String id;
  final String name;
  final String code;
  final String channel; // Email, SMS, Push, WhatsApp
  final String language; // en, es, fr, etc.
  final String category; // Workflow, Approval, Sales, etc.
  final String status; // Active, Draft, Inactive
  final String subject;
  final String body;
  final DateTime updatedAt;

  NotificationTemplate({
    required this.id,
    required this.name,
    required this.code,
    required this.channel,
    required this.language,
    required this.category,
    required this.status,
    required this.subject,
    required this.body,
    required this.updatedAt,
  });

  NotificationTemplate copyWith({
    String? id,
    String? name,
    String? code,
    String? channel,
    String? language,
    String? category,
    String? status,
    String? subject,
    String? body,
    DateTime? updatedAt,
  }) {
    return NotificationTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      channel: channel ?? this.channel,
      language: language ?? this.language,
      category: category ?? this.category,
      status: status ?? this.status,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
