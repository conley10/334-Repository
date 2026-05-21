import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_client.dart';
import '../models/vehicle.dart';

class VehicleService {
  VehicleService({
    ApiClient? apiClient,
    FlutterSecureStorage? storage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _storage = storage ?? const FlutterSecureStorage();

  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

<<<<<<< HEAD
  static const _vehiclesKey = 'registeredVehicles';

  /// Set true when `GET/POST /vehicles` is fully implemented on the API.
  static const bool useRealApi = false;

  Future<List<Vehicle>> getVehicles() async {
    final local = await _loadLocalVehicles();
    if (local.isNotEmpty) return local;

    if (useRealApi) {
      final response = await _apiClient.get('/vehicles');
      if (response is List) {
        return response
            .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    return <Vehicle>[];
  }

  Future<void> clearRegisteredVehicles() async {
    await _storage.delete(key: _vehiclesKey);
=======
  static const bool useRealApi = true;

  Future<List<Vehicle>> getVehicles() async {
    if (!useRealApi) {
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
    }

    final response = await _apiClient.get('/vehicles');

    if (response is List) {
      return response
          .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return <Vehicle>[];
>>>>>>> 2140271 (zones)
  }

  Future<void> registerVehicle({required String licensePlate}) async {
    final plate = licensePlate.trim().toUpperCase();
    if (plate.isEmpty) return;

    final existing = await _loadLocalVehicles();
    final alreadyRegistered = existing.any(
      (v) => v.licensePlate.toUpperCase() == plate,
    );

    if (!alreadyRegistered) {
      final nextId = existing.isEmpty
          ? 1
          : (existing.map((v) => v.vehicleID ?? 0).reduce((a, b) => a > b ? a : b) + 1);
      existing.add(Vehicle(vehicleID: nextId, licensePlate: plate));
      await _saveLocalVehicles(existing);
    }

    if (useRealApi) {
      await _apiClient.post(
        '/vehicles',
        body: {'licensePlate': plate},
      );
    }
  }

  Future<List<Vehicle>> _loadLocalVehicles() async {
    final raw = await _storage.read(key: _vehiclesKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map>()
          .map((item) => Vehicle.fromJson(Map<String, dynamic>.from(item)))
          .where((v) => v.licensePlate.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalVehicles(List<Vehicle> vehicles) async {
    final payload = vehicles
        .map(
          (v) => <String, dynamic>{
            if (v.vehicleID != null) 'vehicleID': v.vehicleID,
            'licensePlate': v.licensePlate,
            if (v.userID != null) 'userID': v.userID,
          },
        )
        .toList();
    await _storage.write(key: _vehiclesKey, value: jsonEncode(payload));
  }
}
