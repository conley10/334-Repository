import '../api_client.dart';
import '../../models/admin/admin_user.dart';

class AdminUserService {
  AdminUserService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  final ApiClient _apiClient;
  static const bool useRealApi = true;

  AdminUser _userFromDto(Map<String, dynamic> dto) {
    UserRole role;
    switch ((dto['role'] as String? ?? '').toLowerCase()) {
      case 'student': role = UserRole.student; break;
      case 'staff': role = UserRole.staff; break;
      case 'faculty': role = UserRole.faculty; break;
      case 'admin': role = UserRole.admin; break;
      default: role = UserRole.student;
    }
    return AdminUser(
      userID: dto['userID'] as int?,
      name: dto['name'] as String? ?? '',
      email: dto['email'] as String? ?? '',
      role: role,
      status: switch ((dto['status'] as String? ?? '').toLowerCase()) {
        'suspended' => UserStatus.suspended,
        'pending'   => UserStatus.pending,
        _           => UserStatus.active,
      },
      joinedAt: DateTime.tryParse(dto['joinedAt'] as String? ?? '') ?? DateTime.now(),
      totalBookings: (dto['totalBookings'] as num?)?.toInt() ?? 0,
    );
  }

  Future<List<AdminUser>> getUsers() async {
    if (!useRealApi) {
      return [
        AdminUser(userID: 1, name: 'Marcus Thorne', email: 'm.thorne@campus.edu', role: UserRole.faculty, status: UserStatus.active, joinedAt: DateTime(2023, 9, 1), totalBookings: 142),
        AdminUser(userID: 2, name: 'Sarah Chen', email: 's.chen@campus.edu', role: UserRole.student, status: UserStatus.active, joinedAt: DateTime(2024, 2, 15), totalBookings: 38),
        AdminUser(userID: 3, name: 'James Patel', email: 'j.patel@campus.edu', role: UserRole.staff, status: UserStatus.active, joinedAt: DateTime(2022, 6, 10), totalBookings: 87),
        AdminUser(userID: 4, name: 'Emily Rodriguez', email: 'e.rodriguez@campus.edu', role: UserRole.student, status: UserStatus.suspended, joinedAt: DateTime(2024, 1, 20), totalBookings: 12),
        AdminUser(userID: 5, name: 'David Kim', email: 'd.kim@campus.edu', role: UserRole.admin, status: UserStatus.active, joinedAt: DateTime(2021, 3, 5), totalBookings: 24),
        AdminUser(userID: 6, name: 'Olivia Brown', email: 'o.brown@campus.edu', role: UserRole.faculty, status: UserStatus.active, joinedAt: DateTime(2023, 11, 12), totalBookings: 65),
        AdminUser(userID: 7, name: 'Liam Nguyen', email: 'l.nguyen@campus.edu', role: UserRole.student, status: UserStatus.pending, joinedAt: DateTime(2025, 8, 3), totalBookings: 0),
        AdminUser(userID: 8, name: 'Sophia Wilson', email: 's.wilson@campus.edu', role: UserRole.staff, status: UserStatus.active, joinedAt: DateTime(2024, 5, 22), totalBookings: 41),
        AdminUser(userID: 9, name: 'Noah Anderson', email: 'n.anderson@campus.edu', role: UserRole.student, status: UserStatus.active, joinedAt: DateTime(2024, 9, 14), totalBookings: 23),
        AdminUser(userID: 10, name: 'Ava Martinez', email: 'a.martinez@campus.edu', role: UserRole.faculty, status: UserStatus.suspended, joinedAt: DateTime(2022, 12, 8), totalBookings: 98),
      ];
    }
    final response = await _apiClient.get('/admin/users', authenticated: false);
    if (response is List) return response.map((e) => _userFromDto(e as Map<String, dynamic>)).toList();
    return <AdminUser>[];
  }

  Future<void> updateUserRole(int userID, UserRole newRole) async {
    if (!useRealApi) { await Future.delayed(const Duration(milliseconds: 400)); return; }
    await _apiClient.patch('/admin/users/$userID/role', body: {'role': newRole.name}, authenticated: false);
  }

  Future<void> updateUserStatus(int userID, UserStatus status) async {
    if (!useRealApi) { await Future.delayed(const Duration(milliseconds: 400)); return; }
    await _apiClient.patch('/admin/users/$userID/status', body: {'status': status.name}, authenticated: false);
  }
}
