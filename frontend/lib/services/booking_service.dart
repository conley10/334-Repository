import 'api_client.dart';
import '../models/booking.dart';

class BookingService {
  BookingService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  static const bool useRealApi = false;

  Future<List<BookingModel>> getBookings({String? status}) async {
    if (!useRealApi) {
      return [
        const BookingModel(
          bookingID: 1,
          zone: 'Zone A',
          vehicle: 'fdgjdfgk',
          hours: 2,
          rate: 4.5,
        ),
        const BookingModel(
          bookingID: 2,
          zone: 'Zone B',
          vehicle: 'XYZ789',
          hours: 3,
          rate: 4.5,
        ),
      ];
    }

    final response = await _apiClient.get(
      '/bookings',
      queryParameters: status == null ? null : {'status': status},
    );

    if (response is List) {
      return response
          .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return <BookingModel>[];
  }

  Future<void> createBooking({
    required DateTime startTime,
    required DateTime endTime,
    required int spotId,
    required int vehicleId,
  }) async {
    if (!useRealApi) {
      await Future.delayed(const Duration(milliseconds: 600));
      return;
    }

    await _apiClient.post(
      '/bookings',
      body: {
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
        'spotID': spotId,
        'vehicleID': vehicleId,
      },
    );
  }
}