import '../../../data/models/repair_model.dart';

abstract class RepairState {}

class RepairInitial extends RepairState {}

class RepairLoading extends RepairState {}

class RepairListLoaded extends RepairState {
  final List<RepairModel> repairs;
  final int total;
  final int page;
  final bool hasMore;

  RepairListLoaded({
    required this.repairs,
    required this.total,
    required this.page,
    required this.hasMore,
  });
}

class RepairDetailLoaded extends RepairState {
  final RepairModel repair;

  RepairDetailLoaded({required this.repair});
}

class RepairOperationSuccess extends RepairState {
  final String message;

  RepairOperationSuccess({required this.message});
}

class RepairError extends RepairState {
  final String message;

  RepairError({required this.message});
}
