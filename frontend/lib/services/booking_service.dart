import 'api_client.dart';
import '../models/booking.dart';

class BookingService {
  BookingService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  static const bool useRealApi = true;

  Future<List<BookingModel>> getBookings({String? status}) async {
    final response = await _apiClient.get(
      '/bookings',
      authenticated: false,
      queryParameters: status == null ? null : {'status': status},
    );

    if (response is List) {
      return response
          .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return <BookingModel>[];
  }

  Future<BookingModel> createBooking({
    required DateTime startTime,
    required DateTime endTime,
    required int userID,
    required int spotId,
    required int vehicleId,
  }) async {
    final response = await _apiClient.post(
      '/bookings',
      authenticated: false,
      body: {
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
        'userID': userID,
        'spotID': spotId,
        'vehicleID': vehicleId,
      },
    );

    return BookingModel.fromJson(response as Map<String, dynamic>);
  }
}