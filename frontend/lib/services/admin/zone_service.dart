import '../api_client.dart';
import '../../models/admin/parking_zone.dart';

class ZoneService {
  ZoneService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  final ApiClient _apiClient;
  static const bool useRealApi = true;

  ZoneType _backendToFlutterType(String zoneType, String accessLevel) {
    switch (zoneType.toLowerCase()) {
      case 'ev': return ZoneType.ev;
      case 'accessible': return ZoneType.accessible;
      case 'regular':
        switch (accessLevel.toLowerCase()) {
          case 'student': return ZoneType.student;
          case 'staff': return ZoneType.staff;
          case 'visitor': return ZoneType.visitor;
          default: return ZoneType.visitor;
        }
      default: return ZoneType.visitor;
    }
  }

  Map<String, String> _flutterTypeToBackend(ZoneType type) {
    switch (type) {
      case ZoneType.student:   return {'zoneType': 'regular',     'accessLevel': 'student'};
      case ZoneType.staff:     return {'zoneType': 'regular',     'accessLevel': 'staff'};
      case ZoneType.visitor:   return {'zoneType': 'regular',     'accessLevel': 'visitor'};
      case ZoneType.ev:        return {'zoneType': 'EV',          'accessLevel': 'student'};
      case ZoneType.accessible:return {'zoneType': 'accessible',  'accessLevel': 'student'};
    }
  }

  ParkingZone _zoneFromDto(Map<String, dynamic> dto) {
    final zoneType   = dto['zoneType']   as String? ?? '';
    final accessLevel = dto['accessLevel'] as String? ?? '';
    return ParkingZone(
      zoneID: dto['zoneID'] as int?,
      name: dto['name'] as String? ?? '',
      type: _backendToFlutterType(zoneType, accessLevel),
      totalSpots: dto['capacity'] as int? ?? 0,
      // TODO(backend): ZoneDto doesn't expose availableSpots — defaulting to capacity until backend adds it
      availableSpots: dto['capacity'] as int? ?? 0,
      hourlyRate: (dto['pricePerHour'] as num? ?? 0).toDouble(),
      // TODO(backend): ZoneDto doesn't expose status — defaulting to active
      status: ZoneStatus.active,
    );
  }

  Map<String, dynamic> _zoneToRequestBody(ParkingZone zone, {bool isCreate = false}) {
    final typeFields = _flutterTypeToBackend(zone.type);
    return {
      'name': zone.name,
      'capacity': zone.totalSpots,
      'pricePerHour': zone.hourlyRate,
      'maxDuration': 120, // TODO(backend): hardcoded 2-hour default — frontend doesn't model this yet
      'accessLevel': typeFields['accessLevel'],
      'zoneType': typeFields['zoneType'],
      'geoJson': '{}', // TODO(backend): hardcoded placeholder — frontend doesn't capture geometry yet
    };
  }

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
    final response = await _apiClient.get('/admin/zones', authenticated: false);
    if (response is List) return response.map((e) => _zoneFromDto(e as Map<String, dynamic>)).toList();
    return <ParkingZone>[];
  }

  Future<void> createZone(ParkingZone zone) async {
    if (!useRealApi) { await Future.delayed(const Duration(milliseconds: 400)); return; }
    await _apiClient.post('/admin/zones', body: _zoneToRequestBody(zone, isCreate: true), authenticated: false);
  }

  Future<void> updateZone(ParkingZone zone) async {
    if (!useRealApi) { await Future.delayed(const Duration(milliseconds: 400)); return; }
    await _apiClient.patch('/admin/zones/${zone.zoneID}', body: _zoneToRequestBody(zone, isCreate: false), authenticated: false);
  }

  Future<void> deleteZone(int zoneID) async {
    if (!useRealApi) { await Future.delayed(const Duration(milliseconds: 400)); return; }
    await _apiClient.delete('/admin/zones/$zoneID', authenticated: false);
  }
}
