import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/machine_repository.dart';
import 'machine_event.dart';
import 'machine_state.dart';

class MachineBloc extends Bloc<MachineEvent, MachineState> {
  final MachineRepository _repository;

  MachineBloc({required MachineRepository repository})
      : _repository = repository,
        super(MachineInitial()) {
    on<LoadMachines>(_onLoadMachines);
    on<LoadMachineDetail>(_onLoadMachineDetail);
    on<CreateMachine>(_onCreateMachine);
    on<UpdateMachine>(_onUpdateMachine);
    on<DeleteMachine>(_onDeleteMachine);
    on<SearchMachines>(_onSearchMachines);
  }

  Future<void> _onLoadMachines(
    LoadMachines event,
    Emitter<MachineState> emit,
  ) async {
    emit(MachineLoading());

    try {
      final result = await _repository.getMachines(
        page: event.page,
        limit: event.limit,
        search: event.search,
        status: event.status,
        department: event.department,
      );

      emit(MachineListLoaded(
        machines: result.items,
        total: result.total,
        page: result.page,
        hasMore: result.items.length == event.limit,
      ));
    } catch (e) {
      emit(MachineError(message: e.toString()));
    }
  }

  Future<void> _onLoadMachineDetail(
    LoadMachineDetail event,
    Emitter<MachineState> emit,
  ) async {
    emit(MachineLoading());

    try {
      final machine = await _repository.getMachine(event.machineId);
      emit(MachineDetailLoaded(machine: machine));
    } catch (e) {
      emit(MachineError(message: e.toString()));
    }
  }

  Future<void> _onCreateMachine(
    CreateMachine event,
    Emitter<MachineState> emit,
  ) async {
    emit(MachineLoading());

    try {
      await _repository.createMachine(
        name: event.name,
        model: event.model,
        serialNumber: event.serialNumber,
        location: event.location,
        department: event.department,
        installDate: event.installDate,
        status: event.status,
      );

      emit(MachineOperationSuccess(message: 'เพิ่มเครื่องจักรสำเร็จ'));
    } catch (e) {
      emit(MachineError(message: e.toString()));
    }
  }

  Future<void> _onUpdateMachine(
    UpdateMachine event,
    Emitter<MachineState> emit,
  ) async {
    emit(MachineLoading());

    try {
      await _repository.updateMachine(
        machineId: event.machineId,
        name: event.name,
        model: event.model,
        serialNumber: event.serialNumber,
        location: event.location,
        department: event.department,
        installDate: event.installDate,
        status: event.status,
      );

      emit(MachineOperationSuccess(message: 'แก้ไขเครื่องจักรสำเร็จ'));
    } catch (e) {
      emit(MachineError(message: e.toString()));
    }
  }

  Future<void> _onDeleteMachine(
    DeleteMachine event,
    Emitter<MachineState> emit,
  ) async {
    emit(MachineLoading());

    try {
      await _repository.deleteMachine(event.machineId);
      emit(MachineOperationSuccess(message: 'ลบเครื่องจักรสำเร็จ'));
    } catch (e) {
      emit(MachineError(message: e.toString()));
    }
  }

  Future<void> _onSearchMachines(
    SearchMachines event,
    Emitter<MachineState> emit,
  ) async {
    emit(MachineLoading());

    try {
      final result = await _repository.getMachines(
        search: event.query,
      );

      emit(MachineListLoaded(
        machines: result.items,
        total: result.total,
        page: 1,
        hasMore: result.items.length == 20,
      ));
    } catch (e) {
      emit(MachineError(message: e.toString()));
    }
  }
}
