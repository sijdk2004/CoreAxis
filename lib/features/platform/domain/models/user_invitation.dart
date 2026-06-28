class UserInvitation {
  final String id;
  final String email;
  final String role;
  final String organization;
  final String invitedBy;
  final DateTime invitationDate;
  final DateTime expiryDate;
  final String status; // 'Pending', 'Accepted', 'Expired', 'Cancelled'

  const UserInvitation({
    required this.id,
    required this.email,
    required this.role,
    required this.organization,
    required this.invitedBy,
    required this.invitationDate,
    required this.expiryDate,
    required this.status,
  });

  UserInvitation copyWith({
    String? id,
    String? email,
    String? role,
    String? organization,
    String? invitedBy,
    DateTime? invitationDate,
    DateTime? expiryDate,
    String? status,
  }) {
    return UserInvitation(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      organization: organization ?? this.organization,
      invitedBy: invitedBy ?? this.invitedBy,
      invitationDate: invitationDate ?? this.invitationDate,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
    );
  }
}
