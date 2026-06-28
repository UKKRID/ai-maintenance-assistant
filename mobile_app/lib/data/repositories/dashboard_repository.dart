import '../datasources/remote/dashboard_remote_datasource.dart';
import '../models/dashboard_summary_model.dart';
import '../models/dashboard_analytics_model.dart';

class DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepository({required DashboardRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<DashboardSummary> getSummary() async {
    try {
      return await _remoteDataSource.getSummary();
    } catch (e) {
      throw DashboardException(message: 'ดึงข้อมูล Summary ไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<DashboardAnalytics> getAnalytics({
    String period = 'month',
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _remoteDataSource.getAnalytics(
        period: period,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw DashboardException(message: 'ดึงข้อมูล Analytics ไม่สำเร็จ: ${e.toString()}');
    }
  }
}

class DashboardException implements Exception {
  final String message;

  DashboardException({required this.message});

  @override
  String toString() => 'DashboardException: $message';
}
