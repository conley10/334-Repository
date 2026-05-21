import 'api_client.dart';
import '../models/vehicle.dart';

class VehicleService {
  VehicleService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  static const bool useRealApi = false;

  Future<List<Vehicle>> getVehicles() async {
    // DEMO MODE until backend exists
    return [
      const Vehicle(
        vehicleID: 1,
        licensePlate: 'ABC123',
        userID: 1,
      ),
      const Vehicle(
        vehicleID: 2,
        licensePlate: 'XYZ789',
        userID: 1,
      ),
    ];

    /*
    // REAL API MODE later
    final response = await _apiClient.get('/vehicles');

    if (response is List) {
      return response
          .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return <Vehicle>[];
    */
  }

  Future<void> registerVehicle({required String licensePlate}) async {
    await _apiClient.post(
      '/vehicles',
      body: {'licensePlate': licensePlate},
    );
  }
}