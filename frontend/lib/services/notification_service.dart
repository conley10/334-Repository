import 'api_client.dart';
import '../models/notification.dart';

class NotificationService {
  NotificationService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  static const bool useRealApi = true;

  Future<List<NotificationModel>> getNotifications() async {
    if (!useRealApi) {
      return [
        NotificationModel(
          notificationID: 1,
          type: 'booking_confirmation',
          message: 'Your booking for Zone A has been confirmed.',
          sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
          channel: 'push',
        ),
        NotificationModel(
          notificationID: 2,
          type: 'expiry_warning',
          message: 'Your parking session at Zone B expires in 15 minutes.',
          sentAt: DateTime.now().subtract(const Duration(hours: 2)),
          channel: 'push',
        ),
        NotificationModel(
          notificationID: 3,
          type: 'violation_alert',
          message: 'A parking violation has been recorded for vehicle ABC 123.',
          sentAt: DateTime.now().subtract(const Duration(days: 1)),
          channel: 'email',
        ),
      ];
    }

    final response = await _apiClient.get('/notifications');

    if (response is List) {
      return response
          .map((item) =>
              NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return <NotificationModel>[];
  }
}