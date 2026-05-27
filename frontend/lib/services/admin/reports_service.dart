import '../api_client.dart';
import '../../models/admin/report_summary.dart';

class ReportsService {
  ReportsService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  final ApiClient _apiClient;
  static const bool useRealApi = true;

  Future<ReportSummary> getReportSummary() async {
    if (!useRealApi) {
      await Future.delayed(const Duration(milliseconds: 400));
      return const ReportSummary(totalUsers: 100, totalZones: 7, totalSpots: 1090, totalViolations: 200);
    }
    final response = await _apiClient.get('/admin/reports', authenticated: false);
    return ReportSummary.fromJson(response as Map<String, dynamic>);
  }
}
