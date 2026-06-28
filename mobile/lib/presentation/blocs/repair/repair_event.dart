abstract class RepairEvent {}

class LoadRepairs extends RepairEvent {
  final int page;
  final int limit;
  final String? search;
  final String? status;
  final String? priority;
  final String? machineId;
  final String? assignedTo;

  LoadRepairs({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.status,
    this.priority,
    this.machineId,
    this.assignedTo,
  });
}

class LoadRepairDetail extends RepairEvent {
  final String repairId;

  LoadRepairDetail({required this.repairId});
}

class CreateRepair extends RepairEvent {
  final String machineId;
  final String title;
  final String? description;
  final String priority;
  final int? estimatedTime;
  final double? estimatedCost;
  final String? notes;

  CreateRepair({
    required this.machineId,
    required this.title,
    this.description,
    this.priority = 'medium',
    this.estimatedTime,
    this.estimatedCost,
    this.notes,
  });
}

class AssignRepair extends RepairEvent {
  final String repairId;
  final String assignedTo;

  AssignRepair({
    required this.repairId,
    required this.assignedTo,
  });
}

class UpdateRepairStatus extends RepairEvent {
  final String repairId;
  final String status;
  final String? notes;

  UpdateRepairStatus({
    required this.repairId,
    required this.status,
    this.notes,
  });
}

class CompleteRepair extends RepairEvent {
  final String repairId;
  final int? actualTime;
  final double? actualCost;
  final String? notes;

  CompleteRepair({
    required this.repairId,
    this.actualTime,
    this.actualCost,
    this.notes,
  });
}

class SearchRepairs extends RepairEvent {
  final String query;

  SearchRepairs({required this.query});
}
