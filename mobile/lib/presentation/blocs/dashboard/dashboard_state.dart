import '../../../data/models/dashboard_summary_model.dart';
import '../../../data/models/dashboard_analytics_model.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardSummaryLoaded extends DashboardState {
  final DashboardSummary summary;

  DashboardSummaryLoaded({required this.summary});
}

class DashboardAnalyticsLoaded extends DashboardState {
  final DashboardAnalytics analytics;

  DashboardAnalyticsLoaded({required this.analytics});
}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  final DashboardAnalytics? analytics;

  DashboardLoaded({
    required this.summary,
    this.analytics,
  });
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError({required this.message});
}
