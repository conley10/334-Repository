import '../models/zone.dart';
import '../models/parking_spot.dart';
import 'api_client.dart';

class ZoneService {
  ZoneService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Zone>> getZones() async {
    final response = await _apiClient.get('/zones', authenticated: false);

    if (response is List) {
      return response
          .map((item) => Zone.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return <Zone>[];
  }

  Future<List<ParkingSpot>> getSpotsForZone(int zoneId) async {
    final response = await _apiClient.get(
      '/zones/$zoneId/spots',
      authenticated: false,
    );

    if (response is List) {
      return response
          .map((item) => ParkingSpot.fromJson(item as Map<String, dynamic>))
          .where((spot) => spot.isAvailable)
          .toList();
    }

    return <ParkingSpot>[];
  }
}