import '../api_client.dart';
import '../../models/admin/admin_user.dart';

class AdminUserService {
  AdminUserService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  final ApiClient _apiClient;
  static const bool useRealApi = false;

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
    final response = await _apiClient.get('/admin/users');
    if (response is List) return response.map((e) => AdminUser.fromJson(e)).toList();
    return <AdminUser>[];
  }

  Future<void> updateUserStatus(int userID, UserStatus status) async {
    if (!useRealApi) { await Future.delayed(const Duration(milliseconds: 400)); return; }
    await _apiClient.patch('/admin/users/$userID', body: {'status': status.name});
  }
}
