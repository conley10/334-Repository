import '../models/zone.dart';
import 'api_client.dart';

class ZoneService {
  ZoneService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Zone>> getZones() async {
    final response = await _apiClient.get('/zones');

    if (response is List) {
      return response
          .map((item) => Zone.fromJson(item))
          .toList();
    }

    return [];
  }
}