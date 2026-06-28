class RecentActivity {
  final String activityId;
  final String activityType;
  final String title;
  final String? description;
  final DateTime timestamp;
  final String? userName;

  RecentActivity({
    required this.activityId,
    required this.activityType,
    required this.title,
    this.description,
    required this.timestamp,
    this.userName,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      activityId: json['activity_id'] ?? '',
      activityType: json['activity_type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      userName: json['user_name'],
    );
  }
}

class TopIssue {
  final String issue;
  final int count;
  final double percentage;

  TopIssue({
    required this.issue,
    required this.count,
    required this.percentage,
  });

  factory TopIssue.fromJson(Map<String, dynamic> json) {
    return TopIssue(
      issue: json['issue'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class DashboardSummary {
  final int totalMachines;
  final int activeMachines;
  final int totalRepairs;
  final int pendingRepairs;
  final int inProgressRepairs;
  final int completedRepairs;
  final int totalPmTasks;
  final int overduePmTasks;
  final int completedPmTasks;
  final int totalSpareParts;
  final int lowStockParts;
  final int outOfStockParts;
  final double totalRepairCost;
  final double totalSparePartValue;
  final double mtbfDays;
  final double mttrHours;
  final List<RecentActivity> recentActivities;
  final List<TopIssue> topIssues;

  DashboardSummary({
    required this.totalMachines,
    required this.activeMachines,
    required this.totalRepairs,
    required this.pendingRepairs,
    required this.inProgressRepairs,
    required this.completedRepairs,
    required this.totalPmTasks,
    required this.overduePmTasks,
    required this.completedPmTasks,
    required this.totalSpareParts,
    required this.lowStockParts,
    required this.outOfStockParts,
    required this.totalRepairCost,
    required this.totalSparePartValue,
    required this.mtbfDays,
    required this.mttrHours,
    required this.recentActivities,
    required this.topIssues,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalMachines: json['total_machines'] ?? 0,
      activeMachines: json['active_machines'] ?? 0,
      totalRepairs: json['total_repairs'] ?? 0,
      pendingRepairs: json['pending_repairs'] ?? 0,
      inProgressRepairs: json['in_progress_repairs'] ?? 0,
      completedRepairs: json['completed_repairs'] ?? 0,
      totalPmTasks: json['total_pm_tasks'] ?? 0,
      overduePmTasks: json['overdue_pm_tasks'] ?? 0,
      completedPmTasks: json['completed_pm_tasks'] ?? 0,
      totalSpareParts: json['total_spare_parts'] ?? 0,
      lowStockParts: json['low_stock_parts'] ?? 0,
      outOfStockParts: json['out_of_stock_parts'] ?? 0,
      totalRepairCost: (json['total_repair_cost'] ?? 0).toDouble(),
      totalSparePartValue: (json['total_spare_part_value'] ?? 0).toDouble(),
      mtbfDays: (json['mtbf_days'] ?? 0).toDouble(),
      mttrHours: (json['mttr_hours'] ?? 0).toDouble(),
      recentActivities: (json['recent_activities'] as List?)
              ?.map((a) => RecentActivity.fromJson(a))
              .toList() ??
          [],
      topIssues: (json['top_issues'] as List?)
              ?.map((t) => TopIssue.fromJson(t))
              .toList() ??
          [],
    );
  }

  String get totalRepairCostLabel => '฿${totalRepairCost.toStringAsFixed(0)}';
  String get totalSparePartValueLabel => '฿${totalSparePartValue.toStringAsFixed(0)}';
}
