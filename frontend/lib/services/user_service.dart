import 'api_client.dart';
import '../models/user.dart';

class UserService {
  UserService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<User> getCurrentUser() async {

    // DEMO MODE until backend exists
    return const User(
      userID: 1,
      name: 'TEST USER',
      email: 'conle@student.edu.au',
      role: 'Admin',
    );

    /*
    // REAL API MODE later
    final response = await _apiClient.get('/users/me');

    return User.fromJson(response);
    */
  }
}