class UserSession {
  final String id;
  final String userId;
  final String device;
  final String browser;
  final String os;
  final String ipAddress;
  final String location;
  final DateTime loginTime;
  final DateTime lastActivity;
  final String status; // 'Active', 'Expired'

  const UserSession({
    required this.id,
    required this.userId,
    required this.device,
    required this.browser,
    required this.os,
    required this.ipAddress,
    required this.location,
    required this.loginTime,
    required this.lastActivity,
    required this.status,
  });

  UserSession copyWith({
    String? id,
    String? userId,
    String? device,
    String? browser,
    String? os,
    String? ipAddress,
    String? location,
    DateTime? loginTime,
    DateTime? lastActivity,
    String? status,
  }) {
    return UserSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      device: device ?? this.device,
      browser: browser ?? this.browser,
      os: os ?? this.os,
      ipAddress: ipAddress ?? this.ipAddress,
      location: location ?? this.location,
      loginTime: loginTime ?? this.loginTime,
      lastActivity: lastActivity ?? this.lastActivity,
      status: status ?? this.status,
    );
  }
}
