class RepairStatusChart {
  final String status;
  final int count;
  final double percentage;

  RepairStatusChart({
    required this.status,
    required this.count,
    required this.percentage,
  });

  factory RepairStatusChart.fromJson(Map<String, dynamic> json) {
    return RepairStatusChart(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Pending';
      case 'in_progress': return 'In Progress';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }
}

class MonthlyCostChart {
  final String month;
  final int year;
  final double totalCost;
  final int repairCount;

  MonthlyCostChart({
    required this.month,
    required this.year,
    required this.totalCost,
    required this.repairCount,
  });

  factory MonthlyCostChart.fromJson(Map<String, dynamic> json) {
    return MonthlyCostChart(
      month: json['month'] ?? '',
      year: json['year'] ?? 0,
      totalCost: (json['total_cost'] ?? 0).toDouble(),
      repairCount: json['repair_count'] ?? 0,
    );
  }

  String get costLabel => '฿${totalCost.toStringAsFixed(0)}';
}

class PMStatusChart {
  final String status;
  final int count;
  final double percentage;

  PMStatusChart({
    required this.status,
    required this.count,
    required this.percentage,
  });

  factory PMStatusChart.fromJson(Map<String, dynamic> json) {
    return PMStatusChart(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'scheduled': return 'Scheduled';
      case 'in_progress': return 'In Progress';
      case 'completed': return 'Completed';
      case 'overdue': return 'Overdue';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }
}

class DepartmentCost {
  final String department;
  final double cost;
  final double percentage;

  DepartmentCost({
    required this.department,
    required this.cost,
    required this.percentage,
  });

  factory DepartmentCost.fromJson(Map<String, dynamic> json) {
    return DepartmentCost(
      department: json['department'] ?? '',
      cost: (json['cost'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  String get costLabel => '฿${cost.toStringAsFixed(0)}';
}

class MachineHealth {
  final String machineId;
  final String machineName;
  final String status;
  final DateTime? lastRepairDate;
  final int repairCount;
  final double healthScore;

  MachineHealth({
    required this.machineId,
    required this.machineName,
    required this.status,
    this.lastRepairDate,
    required this.repairCount,
    required this.healthScore,
  });

  factory MachineHealth.fromJson(Map<String, dynamic> json) {
    return MachineHealth(
      machineId: json['machine_id'] ?? '',
      machineName: json['machine_name'] ?? '',
      status: json['status'] ?? '',
      lastRepairDate: json['last_repair_date'] != null
          ? DateTime.parse(json['last_repair_date'])
          : null,
      repairCount: json['repair_count'] ?? 0,
      healthScore: (json['health_score'] ?? 0).toDouble(),
    );
  }

  String get healthScoreLabel => '${healthScore.toStringAsFixed(0)}%';
}

class DashboardAnalytics {
  final String period;
  final String startDate;
  final String endDate;
  final List<RepairStatusChart> repairStatusChart;
  final List<MonthlyCostChart> monthlyCostChart;
  final List<PMStatusChart> pmStatusChart;
  final List<TopIssue> topIssues;
  final List<DepartmentCost> departmentCosts;
  final List<MachineHealth> machineHealth;
  final int totalRepairs;
  final double totalCost;
  final double averageMttr;
  final double averageMtbf;

  DashboardAnalytics({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.repairStatusChart,
    required this.monthlyCostChart,
    required this.pmStatusChart,
    required this.topIssues,
    required this.departmentCosts,
    required this.machineHealth,
    required this.totalRepairs,
    required this.totalCost,
    required this.averageMttr,
    required this.averageMtbf,
  });

  factory DashboardAnalytics.fromJson(Map<String, dynamic> json) {
    return DashboardAnalytics(
      period: json['period'] ?? 'month',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      repairStatusChart: (json['repair_status_chart'] as List?)
              ?.map((c) => RepairStatusChart.fromJson(c))
              .toList() ??
          [],
      monthlyCostChart: (json['monthly_cost_chart'] as List?)
              ?.map((c) => MonthlyCostChart.fromJson(c))
              .toList() ??
          [],
      pmStatusChart: (json['pm_status_chart'] as List?)
              ?.map((c) => PMStatusChart.fromJson(c))
              .toList() ??
          [],
      topIssues: (json['top_issues'] as List?)
              ?.map((t) => TopIssue.fromJson(t))
              .toList() ??
          [],
      departmentCosts: (json['department_costs'] as List?)
              ?.map((d) => DepartmentCost.fromJson(d))
              .toList() ??
          [],
      machineHealth: (json['machine_health'] as List?)
              ?.map((m) => MachineHealth.fromJson(m))
              .toList() ??
          [],
      totalRepairs: json['total_repairs'] ?? 0,
      totalCost: (json['total_cost'] ?? 0).toDouble(),
      averageMttr: (json['average_mttr'] ?? 0).toDouble(),
      averageMtbf: (json['average_mtbf'] ?? 0).toDouble(),
    );
  }

  String get totalCostLabel => '฿${totalCost.toStringAsFixed(0)}';
}
