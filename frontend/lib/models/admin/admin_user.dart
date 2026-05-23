enum UserRole { student, staff, faculty, admin }
enum UserStatus { active, suspended, pending }

class AdminUser {
  final int? userID;
  final String name;
  final String email;
  final UserRole role;
  final UserStatus status;
  final DateTime joinedAt;
  final int totalBookings;

  const AdminUser({
    this.userID,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinedAt,
    required this.totalBookings,
  });

  String get roleLabel {
    switch (role) {
      case UserRole.student: return 'Student';
      case UserRole.staff: return 'Staff';
      case UserRole.faculty: return 'Faculty';
      case UserRole.admin: return 'Admin';
    }
  }

  String get statusLabel {
    switch (status) {
      case UserStatus.active: return 'Active';
      case UserStatus.suspended: return 'Suspended';
      case UserStatus.pending: return 'Pending';
    }
  }

  String get joinedText {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[joinedAt.month - 1]} ${joinedAt.day}, ${joinedAt.year}';
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      userID: json['userID'] as int?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: _parseRole(json['role'] as String?),
      status: _parseStatus(json['status'] as String?),
      joinedAt: DateTime.tryParse(json['joinedAt'] as String? ?? '') ?? DateTime.now(),
      totalBookings: json['totalBookings'] as int? ?? 0,
    );
  }

  static UserRole _parseRole(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'student': return UserRole.student;
      case 'staff': return UserRole.staff;
      case 'faculty': return UserRole.faculty;
      case 'admin': return UserRole.admin;
      default: return UserRole.student;
    }
  }

  static UserStatus _parseStatus(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'active': return UserStatus.active;
      case 'suspended': return UserStatus.suspended;
      case 'pending': return UserStatus.pending;
      default: return UserStatus.active;
    }
  }

  AdminUser copyWith({UserStatus? status}) {
    return AdminUser(
      userID: userID,
      name: name,
      email: email,
      role: role,
      status: status ?? this.status,
      joinedAt: joinedAt,
      totalBookings: totalBookings,
    );
  }
}
