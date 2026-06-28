abstract class DashboardEvent {}

class LoadDashboard extends DashboardEvent {}

class LoadDashboardSummary extends DashboardEvent {}

class LoadDashboardAnalytics extends DashboardEvent {
  final String period;
  final String? startDate;
  final String? endDate;

  LoadDashboardAnalytics({
    this.period = 'month',
    this.startDate,
    this.endDate,
  });
}

class RefreshDashboard extends DashboardEvent {}
