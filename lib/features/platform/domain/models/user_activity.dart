enum ActivityType {
  login,
  logout,
  passwordChange,
  roleAssignment,
  documentAccess,
  workflowApproval,
  reportDownload,
  aiUsage,
}

class UserActivity {
  final String id;
  final String userId;
  final DateTime timestamp;
  final ActivityType type;
  final String description;
  final String? deviceInfo;
  final String? location;
  final String? ipAddress;
  final String status;

  const UserActivity({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.type,
    required this.description,
    this.deviceInfo,
    this.location,
    this.ipAddress,
    this.status = 'success',
  });
}
