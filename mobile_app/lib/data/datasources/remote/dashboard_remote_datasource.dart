import '../../models/dashboard_summary_model.dart';
import '../../models/dashboard_analytics_model.dart';
import '../../../../services/api/api_client.dart';

class DashboardRemoteDataSource {
  final ApiClient _apiClient;

  DashboardRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<DashboardSummary> getSummary() async {
    final response = await _apiClient.get('/api/dashboard/summary');
    return DashboardSummary.fromJson(response);
  }

  Future<DashboardAnalytics> getAnalytics({
    String period = 'month',
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'period': period,
    };

    if (startDate != null && startDate.isNotEmpty) {
      queryParams['start_date'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['end_date'] = endDate;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final response = await _apiClient.get('/api/dashboard/analytics?$queryString');
    return DashboardAnalytics.fromJson(response);
  }
}
