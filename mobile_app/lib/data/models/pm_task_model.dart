class ChecklistItem {
  final String checklistId;
  final String itemName;
  final bool isRequired;
  final bool isCompleted;
  final int sortOrder;
  final DateTime? completedAt;

  ChecklistItem({
    required this.checklistId,
    required this.itemName,
    required this.isRequired,
    required this.isCompleted,
    required this.sortOrder,
    this.completedAt,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      checklistId: json['checklist_id'] ?? '',
      itemName: json['item_name'] ?? '',
      isRequired: json['is_required'] ?? true,
      isCompleted: json['is_completed'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }
}

class PMTaskModel {
  final String pmId;
  final String machineId;
  final String? machineName;
  final String? machineModel;
  final String? assignedTo;
  final String? assignedName;
  final String title;
  final String? description;
  final String scheduledDate;
  final String? completedDate;
  final String status;
  final String? notes;
  final List<ChecklistItem> checklist;
  final Map<String, dynamic>? checklistProgress;
  final DateTime createdAt;
  final DateTime updatedAt;

  PMTaskModel({
    required this.pmId,
    required this.machineId,
    this.machineName,
    this.machineModel,
    this.assignedTo,
    this.assignedName,
    required this.title,
    this.description,
    required this.scheduledDate,
    this.completedDate,
    required this.status,
    this.notes,
    this.checklist = const [],
    this.checklistProgress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PMTaskModel.fromJson(Map<String, dynamic> json) {
    return PMTaskModel(
      pmId: json['pm_id'] ?? '',
      machineId: json['machine_id'] ?? '',
      machineName: json['machine_name'],
      machineModel: json['machine_model'],
      assignedTo: json['assigned_to'],
      assignedName: json['assigned_name'],
      title: json['title'] ?? '',
      description: json['description'],
      scheduledDate: json['scheduled_date'] ?? '',
      completedDate: json['completed_date'],
      status: json['status'] ?? 'scheduled',
      notes: json['notes'],
      checklist: (json['checklist'] as List?)
              ?.map((c) => ChecklistItem.fromJson(c))
              .toList() ??
          [],
      checklistProgress: json['checklist_progress'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'scheduled':
        return 'Scheduled';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'overdue':
        return 'Overdue';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  int get checklistTotal => checklistProgress?['total'] ?? 0;
  int get checklistCompleted => checklistProgress?['completed'] ?? 0;
  int get checklistPercentage => checklistProgress?['percentage'] ?? 0;
}

class PMTaskListResponse {
  final List<PMTaskModel> items;
  final int total;
  final int page;
  final int limit;

  PMTaskListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PMTaskListResponse.fromJson(Map<String, dynamic> json) {
    return PMTaskListResponse(
      items: (json['items'] as List)
          .map((item) => PMTaskModel.fromJson(item))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
    );
  }
}
