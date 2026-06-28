class UserProfile {
  final String userId;
  
  // Personal Information
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String? signatureUrl;

  // Preferences
  final String language;
  final String timeZone;
  final String dateFormat;
  final String currency;

  // Appearance
  final String themeMode; // 'Light', 'Dark', 'System'
  final String sidebarMode; // 'Expanded', 'Collapsed'
  final String density; // 'Standard', 'Compact'

  // Notifications
  final bool emailEnabled;
  final bool smsEnabled;
  final bool pushEnabled;
  final bool whatsappEnabled;

  // Security
  final bool mfaEnabled;
  final String sessionTimeout; // e.g. '15 minutes', '30 minutes'
  final List<String> trustedDevices;

  const UserProfile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.signatureUrl,
    required this.language,
    required this.timeZone,
    required this.dateFormat,
    required this.currency,
    required this.themeMode,
    required this.sidebarMode,
    required this.density,
    required this.emailEnabled,
    required this.smsEnabled,
    required this.pushEnabled,
    required this.whatsappEnabled,
    required this.mfaEnabled,
    required this.sessionTimeout,
    required this.trustedDevices,
  });

  UserProfile copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? signatureUrl,
    String? language,
    String? timeZone,
    String? dateFormat,
    String? currency,
    String? themeMode,
    String? sidebarMode,
    String? density,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? pushEnabled,
    bool? whatsappEnabled,
    bool? mfaEnabled,
    String? sessionTimeout,
    List<String>? trustedDevices,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      language: language ?? this.language,
      timeZone: timeZone ?? this.timeZone,
      dateFormat: dateFormat ?? this.dateFormat,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      sidebarMode: sidebarMode ?? this.sidebarMode,
      density: density ?? this.density,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      trustedDevices: trustedDevices ?? this.trustedDevices,
    );
  }
}
