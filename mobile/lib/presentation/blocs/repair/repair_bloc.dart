import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/repair_repository.dart';
import 'repair_event.dart';
import 'repair_state.dart';

class RepairBloc extends Bloc<RepairEvent, RepairState> {
  final RepairRepository _repository;

  RepairBloc({required RepairRepository repository})
      : _repository = repository,
        super(RepairInitial()) {
    on<LoadRepairs>(_onLoadRepairs);
    on<LoadRepairDetail>(_onLoadRepairDetail);
    on<CreateRepair>(_onCreateRepair);
    on<AssignRepair>(_onAssignRepair);
    on<UpdateRepairStatus>(_onUpdateRepairStatus);
    on<CompleteRepair>(_onCompleteRepair);
    on<SearchRepairs>(_onSearchRepairs);
  }

  Future<void> _onLoadRepairs(
    LoadRepairs event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading());

    try {
      final result = await _repository.getRepairs(
        page: event.page,
        limit: event.limit,
        search: event.search,
        status: event.status,
        priority: event.priority,
        machineId: event.machineId,
        assignedTo: event.assignedTo,
      );

      emit(RepairListLoaded(
        repairs: result.items,
        total: result.total,
        page: result.page,
        hasMore: result.items.length == event.limit,
      ));
    } catch (e) {
      emit(RepairError(message: e.toString()));
    }
  }

  Future<void> _onLoadRepairDetail(
    LoadRepairDetail event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading());

    try {
      final repair = await _repository.getRepair(event.repairId);
      emit(RepairDetailLoaded(repair: repair));
    } catch (e) {
      emit(RepairError(message: e.toString()));
    }
  }

  Future<void> _onCreateRepair(
    CreateRepair event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading());

    try {
      await _repository.createRepair(
        machineId: event.machineId,
        title: event.title,
        description: event.description,
        priority: event.priority,
        estimatedTime: event.estimatedTime,
        estimatedCost: event.estimatedCost,
        notes: event.notes,
      );

      emit(RepairOperationSuccess(message: 'สร้างงานซ่อมสำเร็จ'));
    } catch (e) {
      emit(RepairError(message: e.toString()));
    }
  }

  Future<void> _onAssignRepair(
    AssignRepair event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading());

    try {
      await _repository.assignRepair(
        repairId: event.repairId,
        assignedTo: event.assignedTo,
      );

      emit(RepairOperationSuccess(message: 'มอบหมายงานสำเร็จ'));
    } catch (e) {
      emit(RepairError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRepairStatus(
    UpdateRepairStatus event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading());

    try {
      await _repository.updateStatus(
        repairId: event.repairId,
        status: event.status,
        notes: event.notes,
      );

      emit(RepairOperationSuccess(message: 'อัพเดทสถานะสำเร็จ'));
    } catch (e) {
      emit(RepairError(message: e.toString()));
    }
  }

  Future<void> _onCompleteRepair(
    CompleteRepair event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading());

    try {
      await _repository.completeRepair(
        repairId: event.repairId,
        actualTime: event.actualTime,
        actualCost: event.actualCost,
        notes: event.notes,
      );

      emit(RepairOperationSuccess(message: 'เสร็จสิ้นงานสำเร็จ'));
    } catch (e) {
      emit(RepairError(message: e.toString()));
    }
  }

  Future<void> _onSearchRepairs(
    SearchRepairs event,
    Emitter<RepairState> emit,
  ) async {
    emit(RepairLoading());

    try {
      final result = await _repository.getRepairs(
        search: event.query,
      );

      emit(RepairListLoaded(
        repairs: result.items,
        total: result.total,
        page: 1,
        hasMore: result.items.length == 20,
      ));
    } catch (e) {
      emit(RepairError(message: e.toString()));
    }
  }
}
