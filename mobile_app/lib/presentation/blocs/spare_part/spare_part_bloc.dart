import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/spare_part_repository.dart';
import 'spare_part_event.dart';
import 'spare_part_state.dart';

class SparePartBloc extends Bloc<SparePartEvent, SparePartState> {
  final SparePartRepository _repository;

  SparePartBloc({required SparePartRepository repository})
      : _repository = repository,
        super(SparePartInitial()) {
    on<LoadSpareParts>(_onLoadSpareParts);
    on<LoadSparePartDetail>(_onLoadSparePartDetail);
    on<CreateSparePart>(_onCreateSparePart);
    on<UpdateSparePart>(_onUpdateSparePart);
    on<UpdateStock>(_onUpdateStock);
    on<DeleteSparePart>(_onDeleteSparePart);
    on<LoadStockSummary>(_onLoadStockSummary);
    on<SearchSpareParts>(_onSearchSpareParts);
  }

  Future<void> _onLoadSpareParts(
    LoadSpareParts event,
    Emitter<SparePartState> emit,
  ) async {
    emit(SparePartLoading());

    try {
      final result = await _repository.getSpareParts(
        page: event.page,
        limit: event.limit,
        search: event.search,
        category: event.category,
        lowStock: event.lowStock,
      );

      emit(SparePartListLoaded(
        spareParts: result.items,
        total: result.total,
        page: result.page,
        hasMore: result.items.length == event.limit,
      ));
    } catch (e) {
      emit(SparePartError(message: e.toString()));
    }
  }

  Future<void> _onLoadSparePartDetail(
    LoadSparePartDetail event,
    Emitter<SparePartState> emit,
  ) async {
    emit(SparePartLoading());

    try {
      final sparePart = await _repository.getSparePart(event.partId);
      emit(SparePartDetailLoaded(sparePart: sparePart));
    } catch (e) {
      emit(SparePartError(message: e.toString()));
    }
  }

  Future<void> _onCreateSparePart(
    CreateSparePart event,
    Emitter<SparePartState> emit,
  ) async {
    emit(SparePartLoading());

    try {
      await _repository.createSparePart(
        name: event.name,
        partNumber: event.partNumber,
        category: event.category,
        description: event.description,
        unitPrice: event.unitPrice,
        stockQty: event.stockQty,
        minStock: event.minStock,
        unit: event.unit,
        imageUrl: event.imageUrl,
      );

      emit(SparePartOperationSuccess(message: 'เพิ่มอะไหล่สำเร็จ'));
    } catch (e) {
      emit(SparePartError(message: e.toString()));
    }
  }

  Future<void> _onUpdateSparePart(
    UpdateSparePart event,
    Emitter<SparePartState> emit,
  ) async {
    emit(SparePartLoading());

    try {
      await _repository.updateSparePart(
        partId: event.partId,
        name: event.name,
        partNumber: event.partNumber,
        category: event.category,
        description: event.description,
        unitPrice: event.unitPrice,
        stockQty: event.stockQty,
        minStock: event.minStock,
        unit: event.unit,
        imageUrl: event.imageUrl,
        isActive: event.isActive,
      );

      emit(SparePartOperationSuccess(message: 'แก้ไขอะไหล่สำเร็จ'));
    } catch (e) {
      emit(SparePartError(message: e.toString()));
    }
  }

  Future<void> _onUpdateStock(
    UpdateStock event,
    Emitter<SparePartState> emit,
  ) async {
    emit(SparePartLoading());

    try {
      await _repository.updateStock(
        partId: event.partId,
        quantity: event.quantity,
        reason: event.reason,
      );

      emit(SparePartOperationSuccess(message: 'อัพเดท stock สำเร็จ'));
    } catch (e) {
      emit(SparePartError(message: e.toString()));
    }
  }

  Future<void> _onDeleteSparePart(
    DeleteSparePart event,
    Emitter<SparePartState> emit,
  ) async {
    emit(SparePartLoading());

    try {
      await _repository.deleteSparePart(event.partId);
      emit(SparePartOperationSuccess(message: 'ลบอะไหล่สำเร็จ'));
    } catch (e) {
      emit(SparePartError(message: e.toString()));
    }
  }

  Future<void> _onLoadStockSummary(
    LoadStockSummary event,
    Emitter<SparePartState> emit,
  ) async {
    emit(SparePartLoading());

    try {
      final summary = await _repository.getStockSummary();
      emit(StockSummaryLoaded(summary: summary));
    } catch (e) {
      emit(SparePartError(message: e.toString()));
    }
  }

  Future<void> _onSearchSpareParts(
    SearchSpareParts event,
    Emitter<SparePartState> emit,
  ) async {
    emit(SparePartLoading());

    try {
      final result = await _repository.getSpareParts(
        search: event.query,
      );

      emit(SparePartListLoaded(
        spareParts: result.items,
        total: result.total,
        page: 1,
        hasMore: result.items.length == 20,
      ));
    } catch (e) {
      emit(SparePartError(message: e.toString()));
    }
  }
}
