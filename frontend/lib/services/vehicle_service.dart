import '../models/vehicle.dart';
import 'api_client.dart';

class VehicleService {
  VehicleService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

    Future<List<Vehicle>> getVehicles() async {
      final response = await _apiClient.get(
        '/vehicles',
        authenticated: false,
      );

      if (response is List) {
        return response
            .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
            .where((vehicle) => vehicle.userID == 2)
            .toList();
      }

      return <Vehicle>[];
    }

  Future<Vehicle> createVehicle({
    required String licensePlate,
  }) async {
    final response = await _apiClient.post(
      '/vehicles',
      authenticated: false,
      body: {
        'licensePlate': licensePlate,
      },
    );

    return Vehicle.fromJson(response as Map<String, dynamic>);
  }
}