import '../../../data/models/pm_task_model.dart';

abstract class PmTaskState {}

class PmTaskInitial extends PmTaskState {}

class PmTaskLoading extends PmTaskState {}

class PmTaskListLoaded extends PmTaskState {
  final List<PMTaskModel> tasks;
  final int total;
  final int page;
  final bool hasMore;

  PmTaskListLoaded({
    required this.tasks,
    required this.total,
    required this.page,
    required this.hasMore,
  });
}

class PmTaskDetailLoaded extends PmTaskState {
  final PMTaskModel task;

  PmTaskDetailLoaded({required this.task});
}

class PmTaskOperationSuccess extends PmTaskState {
  final String message;

  PmTaskOperationSuccess({required this.message});
}

class PmTaskError extends PmTaskState {
  final String message;

  PmTaskError({required this.message});
}
