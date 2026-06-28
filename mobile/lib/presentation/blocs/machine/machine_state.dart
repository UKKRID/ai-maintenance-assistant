import '../../../data/models/machine_model.dart';

abstract class MachineState {}

class MachineInitial extends MachineState {}

class MachineLoading extends MachineState {}

class MachineListLoaded extends MachineState {
  final List<MachineModel> machines;
  final int total;
  final int page;
  final bool hasMore;

  MachineListLoaded({
    required this.machines,
    required this.total,
    required this.page,
    required this.hasMore,
  });
}

class MachineDetailLoaded extends MachineState {
  final MachineModel machine;

  MachineDetailLoaded({required this.machine});
}

class MachineOperationSuccess extends MachineState {
  final String message;

  MachineOperationSuccess({required this.message});
}

class MachineError extends MachineState {
  final String message;

  MachineError({required this.message});
}
