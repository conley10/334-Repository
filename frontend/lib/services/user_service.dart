import 'api_client.dart';
import '../models/user.dart';

class UserService {
  UserService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// When true, loads profile from GET /users/me (works with BYPASS_AUTH; no bearer token needed).
  static const bool useRealApi = true;

  Future<User> getCurrentUser() async {
    if (!useRealApi) {
      return const User(
        userID: 2,
        name: 'John Student',
        email: 'john@student.edu',
        role: 'student',
      );
    }

    final response = await _apiClient.get(
      '/users/me',
      authenticated: false,
    );

    return User.fromJson(response as Map<String, dynamic>);
  }
}
