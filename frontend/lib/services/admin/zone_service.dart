import '../api_client.dart';
import '../../models/admin/parking_zone.dart';

class ZoneService {
  ZoneService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  final ApiClient _apiClient;
  static const bool useRealApi = false;

  Future<List<ParkingZone>> getZones() async {
    if (!useRealApi) {
      return const [
        ParkingZone(zoneID: 1, name: 'North Campus Deck', type: ZoneType.staff, totalSpots: 240, availableSpots: 18, hourlyRate: 4.50, status: ZoneStatus.active),
        ParkingZone(zoneID: 2, name: 'South Deck Level 1', type: ZoneType.student, totalSpots: 180, availableSpots: 47, hourlyRate: 2.00, status: ZoneStatus.active),
        ParkingZone(zoneID: 3, name: 'South Deck Level 2', type: ZoneType.student, totalSpots: 180, availableSpots: 0, hourlyRate: 2.00, status: ZoneStatus.active),
        ParkingZone(zoneID: 4, name: 'Innovation Hub Visitor', type: ZoneType.visitor, totalSpots: 80, availableSpots: 56, hourlyRate: 6.00, status: ZoneStatus.active),
        ParkingZone(zoneID: 5, name: 'East Perimeter EV Charging', type: ZoneType.ev, totalSpots: 24, availableSpots: 8, hourlyRate: 8.00, status: ZoneStatus.active),
        ParkingZone(zoneID: 6, name: 'Science West Underpass', type: ZoneType.staff, totalSpots: 120, availableSpots: 73, hourlyRate: 4.50, status: ZoneStatus.maintenance),
        ParkingZone(zoneID: 7, name: 'Library Accessible Lot', type: ZoneType.accessible, totalSpots: 30, availableSpots: 22, hourlyRate: 0.00, status: ZoneStatus.active),
        ParkingZone(zoneID: 8, name: 'Old West Lot', type: ZoneType.visitor, totalSpots: 60, availableSpots: 60, hourlyRate: 5.00, status: ZoneStatus.closed),
      ];
    }
    final response = await _apiClient.get('/zones');
    if (response is List) return response.map((e) => ParkingZone.fromJson(e)).toList();
    return <ParkingZone>[];
  }

  Future<void> createZone(ParkingZone zone) async {
    if (!useRealApi) { await Future.delayed(const Duration(milliseconds: 400)); return; }
    await _apiClient.post('/zones', body: {
      'name': zone.name, 'type': zone.type.name, 'totalSpots': zone.totalSpots,
      'availableSpots': zone.availableSpots, 'hourlyRate': zone.hourlyRate, 'status': zone.status.name,
    });
  }

  Future<void> updateZone(ParkingZone zone) async {
    if (!useRealApi) { await Future.delayed(const Duration(milliseconds: 400)); return; }
    await _apiClient.patch('/zones/${zone.zoneID}', body: {
      'name': zone.name, 'type': zone.type.name, 'totalSpots': zone.totalSpots,
      'availableSpots': zone.availableSpots, 'hourlyRate': zone.hourlyRate, 'status': zone.status.name,
    });
  }

  Future<void> deleteZone(int zoneID) async {
    if (!useRealApi) { await Future.delayed(const Duration(milliseconds: 400)); return; }
    await _apiClient.delete('/zones/$zoneID');
  }
}
