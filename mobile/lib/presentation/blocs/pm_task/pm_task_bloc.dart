import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/pm_task_repository.dart';
import 'pm_task_event.dart';
import 'pm_task_state.dart';

class PmTaskBloc extends Bloc<PmTaskEvent, PmTaskState> {
  final PmTaskRepository _repository;

  PmTaskBloc({required PmTaskRepository repository})
      : _repository = repository,
        super(PmTaskInitial()) {
    on<LoadPmTasks>(_onLoadPmTasks);
    on<LoadPmTaskDetail>(_onLoadPmTaskDetail);
    on<CreatePmTask>(_onCreatePmTask);
    on<UpdatePmTask>(_onUpdatePmTask);
    on<CompletePmTask>(_onCompletePmTask);
    on<UpdateChecklistItem>(_onUpdateChecklistItem);
    on<DeletePmTask>(_onDeletePmTask);
    on<SearchPmTasks>(_onSearchPmTasks);
  }

  Future<void> _onLoadPmTasks(LoadPmTasks event, Emitter<PmTaskState> emit) async {
    emit(PmTaskLoading());
    try {
      final result = await _repository.getPmTasks(
        page: event.page,
        limit: event.limit,
        search: event.search,
        status: event.status,
        machineId: event.machineId,
        assignedTo: event.assignedTo,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(PmTaskListLoaded(
        tasks: result.items,
        total: result.total,
        page: result.page,
        hasMore: result.items.length == event.limit,
      ));
    } catch (e) {
      emit(PmTaskError(message: e.toString()));
    }
  }

  Future<void> _onLoadPmTaskDetail(LoadPmTaskDetail event, Emitter<PmTaskState> emit) async {
    emit(PmTaskLoading());
    try {
      final task = await _repository.getPmTask(event.pmId);
      emit(PmTaskDetailLoaded(task: task));
    } catch (e) {
      emit(PmTaskError(message: e.toString()));
    }
  }

  Future<void> _onCreatePmTask(CreatePmTask event, Emitter<PmTaskState> emit) async {
    emit(PmTaskLoading());
    try {
      await _repository.createPmTask(
        machineId: event.machineId,
        title: event.title,
        description: event.description,
        scheduledDate: event.scheduledDate,
        assignedTo: event.assignedTo,
        checklist: event.checklist,
        notes: event.notes,
      );
      emit(PmTaskOperationSuccess(message: 'สร้างงาน PM สำเร็จ'));
    } catch (e) {
      emit(PmTaskError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePmTask(UpdatePmTask event, Emitter<PmTaskState> emit) async {
    emit(PmTaskLoading());
    try {
      await _repository.updatePmTask(
        pmId: event.pmId,
        title: event.title,
        description: event.description,
        scheduledDate: event.scheduledDate,
        assignedTo: event.assignedTo,
        status: event.status,
        notes: event.notes,
      );
      emit(PmTaskOperationSuccess(message: 'แก้ไขงาน PM สำเร็จ'));
    } catch (e) {
      emit(PmTaskError(message: e.toString()));
    }
  }

  Future<void> _onCompletePmTask(CompletePmTask event, Emitter<PmTaskState> emit) async {
    emit(PmTaskLoading());
    try {
      await _repository.completePmTask(
        pmId: event.pmId,
        completedDate: event.completedDate,
        notes: event.notes,
      );
      emit(PmTaskOperationSuccess(message: 'เสร็จสิ้นงาน PM สำเร็จ'));
    } catch (e) {
      emit(PmTaskError(message: e.toString()));
    }
  }

  Future<void> _onUpdateChecklistItem(UpdateChecklistItem event, Emitter<PmTaskState> emit) async {
    try {
      await _repository.updateChecklistItem(
        pmId: event.pmId,
        checklistId: event.checklistId,
        itemId: event.itemId,
        isCompleted: event.isCompleted,
      );
      // Reload detail
      final task = await _repository.getPmTask(event.pmId);
      emit(PmTaskDetailLoaded(task: task));
    } catch (e) {
      emit(PmTaskError(message: e.toString()));
    }
  }

  Future<void> _onDeletePmTask(DeletePmTask event, Emitter<PmTaskState> emit) async {
    emit(PmTaskLoading());
    try {
      await _repository.deletePmTask(event.pmId);
      emit(PmTaskOperationSuccess(message: 'ลบงาน PM สำเร็จ'));
    } catch (e) {
      emit(PmTaskError(message: e.toString()));
    }
  }

  Future<void> _onSearchPmTasks(SearchPmTasks event, Emitter<PmTaskState> emit) async {
    emit(PmTaskLoading());
    try {
      final result = await _repository.getPmTasks(search: event.query);
      emit(PmTaskListLoaded(
        tasks: result.items,
        total: result.total,
        page: 1,
        hasMore: result.items.length == 20,
      ));
    } catch (e) {
      emit(PmTaskError(message: e.toString()));
    }
  }
}
