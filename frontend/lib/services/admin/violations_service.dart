import 'package:flutter/material.dart';
import '../api_client.dart';
import '../../models/admin/command_center_data.dart';

class ViolationsService {
  ViolationsService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  final ApiClient _apiClient;
  static const bool useRealApi = true;

  AbnormalAlert _violationToAlert(Map<String, dynamic> dto) {
    final type = (dto['type'] as String? ?? '').toLowerCase();
    final userID = dto['userID'] as int? ?? 0;
    final sessionID = dto['sessionID'] as int?;

    AlertSeverity severity;
    IconData icon;
    String title;
    switch (type) {
      case 'overstay':
        severity = AlertSeverity.warning;
        icon = Icons.access_time;
        title = 'Overstay Violation';
        break;
      case 'wrongzone':
        severity = AlertSeverity.warning;
        icon = Icons.electric_car_outlined;
        title = 'Wrong Zone Violation';
        break;
      case 'unauthorised':
        severity = AlertSeverity.danger;
        icon = Icons.block;
        title = 'Unauthorised Entry';
        break;
      case 'escalated':
        severity = AlertSeverity.danger;
        icon = Icons.warning_amber_outlined;
        title = 'Escalated Violation';
        break;
      default:
        severity = AlertSeverity.info;
        icon = Icons.warning_amber_outlined;
        title = type.isNotEmpty ? '${type[0].toUpperCase()}${type.substring(1)}' : 'Unknown Violation';
    }

    return AbnormalAlert(
      severity: severity,
      icon: icon,
      title: title,
      description: 'User #$userID${sessionID != null ? ' · Session #$sessionID' : ''}',
    );
  }

  Future<List<AbnormalAlert>> getRecentAlerts({int limit = 5}) async {
    if (!useRealApi) {
      await Future.delayed(const Duration(milliseconds: 300));
      return CommandCenterMockData.alerts.take(limit).toList();
    }
    final response = await _apiClient.get('/admin/violations', authenticated: false);
    final dtos = (response as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((dto) => (dto['status'] as String? ?? '').toLowerCase() == 'unresolved')
        .toList()
      ..sort((a, b) {
        final aTime = DateTime.tryParse(a['detectedAt'] as String? ?? '') ?? DateTime(0);
        final bTime = DateTime.tryParse(b['detectedAt'] as String? ?? '') ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
    return dtos.take(limit).map(_violationToAlert).toList();
  }
}
