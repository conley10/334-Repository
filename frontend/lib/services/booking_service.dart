import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/parking_session.dart';
import '../utils/sydney_time.dart';
import 'api_client.dart';

class BookingService {
  BookingService({
    ApiClient? apiClient,
    FlutterSecureStorage? storage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _storage = storage ?? const FlutterSecureStorage();

  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

<<<<<<< HEAD
  static const _sessionsKey = 'parkingSessionsV2';
  static const bool useRealApi = false;

  Future<List<ParkingSession>> getSessions() async {
    final local = await _loadLocal();
    if (local.isNotEmpty) return local;

    if (useRealApi) {
      final response = await _apiClient.get('/bookings');
      if (response is List) {
        return response
            .map((e) => ParkingSession.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
=======
  static const bool useRealApi = true;

  Future<List<BookingModel>> getBookings({String? status}) async {
    if (!useRealApi) {
      return [
        const BookingModel(
          bookingID: 1,
          zone: 'Zone A',
          vehicle: 'ABC123',
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
>>>>>>> 2140271 (zones)
    }

    return <ParkingSession>[];
  }

  Future<void> saveSessions(List<ParkingSession> sessions) async {
    final payload = sessions.map((s) => s.toJson()).toList();
    await _storage.write(key: _sessionsKey, value: jsonEncode(payload));
  }

  Future<void> seedDemoSessions({
    required String driverName,
    required String vehiclePlate,
  }) async {
    final existing = await _loadLocal();
    if (existing.isNotEmpty) return;

    final utcNow = SydneyTime.nowUtc();
    final sydneyToday = SydneyTime.nowSydney();
    final tomorrow = sydneyToday.add(const Duration(days: 1));
    final dayAfter = sydneyToday.add(const Duration(days: 2));
    final plate = vehiclePlate.isNotEmpty ? vehiclePlate : 'ABC-1234';

    final demo = <ParkingSession>[
      ParkingSession(
        id: '1',
        zoneTitle: 'Zone C - South Arts',
        vehiclePlate: plate,
        driverName: driverName,
        startTime: SydneyTime.sydneyDateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9),
        endTime: SydneyTime.sydneyDateTime(tomorrow.year, tomorrow.month, tomorrow.day, 13),
        status: SessionStatus.upcoming,
      ),
      ParkingSession(
        id: '2',
        zoneTitle: 'Library Deck - Level 3',
        vehiclePlate: plate,
        driverName: driverName,
        startTime: utcNow.subtract(const Duration(minutes: 30)),
        endTime: utcNow.add(const Duration(hours: 2)),
        status: SessionStatus.active,
      ),
      ParkingSession(
        id: '3',
        zoneTitle: 'Zone A - Academic North',
        vehiclePlate: plate,
        driverName: driverName,
        startTime: SydneyTime.sydneyDateTime(dayAfter.year, dayAfter.month, dayAfter.day, 14),
        endTime: SydneyTime.sydneyDateTime(dayAfter.year, dayAfter.month, dayAfter.day, 17),
        status: SessionStatus.upcoming,
      ),
    ];

    await saveSessions(demo);
  }

  Future<void> addSession(ParkingSession session) async {
    final list = await _loadLocal();
    list.insert(0, session);
    await saveSessions(list);
  }

  Future<void> cancelSession(String id) async {
    final list = await _loadLocal();
    list.removeWhere((s) => s.id == id);
    await saveSessions(list);
  }

  Future<void> rescheduleSession(
    String id, {
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final list = await _loadLocal();
    final index = list.indexWhere((s) => s.id == id);
    if (index < 0) return;
    list[index] = list[index].copyWith(
      startTime: startTime.toUtc(),
      endTime: endTime.toUtc(),
      status: SessionStatus.upcoming,
    );
    await saveSessions(list);
  }

  Future<List<ParkingSession>> _loadLocal() async {
    final raw = await _storage.read(key: _sessionsKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => ParkingSession.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearSessions() async {
    await _storage.delete(key: _sessionsKey);
  }
}
