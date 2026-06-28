abstract class PmTaskEvent {}

class LoadPmTasks extends PmTaskEvent {
  final int page;
  final int limit;
  final String? search;
  final String? status;
  final String? machineId;
  final String? assignedTo;
  final String? startDate;
  final String? endDate;

  LoadPmTasks({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.status,
    this.machineId,
    this.assignedTo,
    this.startDate,
    this.endDate,
  });
}

class LoadPmTaskDetail extends PmTaskEvent {
  final String pmId;

  LoadPmTaskDetail({required this.pmId});
}

class CreatePmTask extends PmTaskEvent {
  final String machineId;
  final String title;
  final String? description;
  final String scheduledDate;
  final String? assignedTo;
  final List<Map<String, dynamic>>? checklist;
  final String? notes;

  CreatePmTask({
    required this.machineId,
    required this.title,
    this.description,
    required this.scheduledDate,
    this.assignedTo,
    this.checklist,
    this.notes,
  });
}

class UpdatePmTask extends PmTaskEvent {
  final String pmId;
  final String? title;
  final String? description;
  final String? scheduledDate;
  final String? assignedTo;
  final String? status;
  final String? notes;

  UpdatePmTask({
    required this.pmId,
    this.title,
    this.description,
    this.scheduledDate,
    this.assignedTo,
    this.status,
    this.notes,
  });
}

class CompletePmTask extends PmTaskEvent {
  final String pmId;
  final String? completedDate;
  final String? notes;

  CompletePmTask({
    required this.pmId,
    this.completedDate,
    this.notes,
  });
}

class UpdateChecklistItem extends PmTaskEvent {
  final String pmId;
  final String checklistId;
  final String itemId;
  final bool isCompleted;

  UpdateChecklistItem({
    required this.pmId,
    required this.checklistId,
    required this.itemId,
    required this.isCompleted,
  });
}

class DeletePmTask extends PmTaskEvent {
  final String pmId;

  DeletePmTask({required this.pmId});
}

class SearchPmTasks extends PmTaskEvent {
  final String query;

  SearchPmTasks({required this.query});
}
