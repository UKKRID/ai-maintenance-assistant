class RepairModel {
  final String repairId;
  final String machineId;
  final String? machineName;
  final String? machineModel;
  final String reporterId;
  final String? reporterName;
  final String? assignedTo;
  final String? assignedName;
  final String title;
  final String? description;
  final String priority;
  final String status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? estimatedTime;
  final int? actualTime;
  final double? estimatedCost;
  final double? actualCost;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  RepairModel({
    required this.repairId,
    required this.machineId,
    this.machineName,
    this.machineModel,
    required this.reporterId,
    this.reporterName,
    this.assignedTo,
    this.assignedName,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.estimatedTime,
    this.actualTime,
    this.estimatedCost,
    this.actualCost,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RepairModel.fromJson(Map<String, dynamic> json) {
    return RepairModel(
      repairId: json['repair_id'] ?? '',
      machineId: json['machine_id'] ?? '',
      machineName: json['machine_name'],
      machineModel: json['machine_model'],
      reporterId: json['reporter_id'] ?? '',
      reporterName: json['reporter_name'],
      assignedTo: json['assigned_to'],
      assignedName: json['assigned_name'],
      title: json['title'] ?? '',
      description: json['description'],
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      estimatedTime: json['estimated_time'],
      actualTime: json['actual_time'],
      estimatedCost: json['estimated_cost']?.toDouble(),
      actualCost: json['actual_cost']?.toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'repair_id': repairId,
      'machine_id': machineId,
      'machine_name': machineName,
      'machine_model': machineModel,
      'reporter_id': reporterId,
      'reporter_name': reporterName,
      'assigned_to': assignedTo,
      'assigned_name': assignedName,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'estimated_time': estimatedTime,
      'actual_time': actualTime,
      'estimated_cost': estimatedCost,
      'actual_cost': actualCost,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get priorityLabel {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'critical':
        return 'Critical';
      default:
        return priority;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get estimatedTimeLabel {
    if (estimatedTime == null) return '-';
    if (estimatedTime! < 60) return '$estimatedTime min';
    final hours = estimatedTime! ~/ 60;
    final mins = estimatedTime! % 60;
    return mins == 0 ? '$hours hr' : '$hours hr $mins min';
  }

  String get actualTimeLabel {
    if (actualTime == null) return '-';
    if (actualTime! < 60) return '$actualTime min';
    final hours = actualTime! ~/ 60;
    final mins = actualTime! % 60;
    return mins == 0 ? '$hours hr' : '$hours hr $mins min';
  }

  String get estimatedCostLabel {
    if (estimatedCost == null) return '-';
    return '฿${estimatedCost!.toStringAsFixed(0)}';
  }

  String get actualCostLabel {
    if (actualCost == null) return '-';
    return '฿${actualCost!.toStringAsFixed(0)}';
  }
}

class RepairListResponse {
  final List<RepairModel> items;
  final int total;
  final int page;
  final int limit;

  RepairListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory RepairListResponse.fromJson(Map<String, dynamic> json) {
    return RepairListResponse(
      items: (json['items'] as List)
          .map((item) => RepairModel.fromJson(item))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
    );
  }
}
