import '../../../data/models/spare_part_model.dart';

abstract class SparePartState {}

class SparePartInitial extends SparePartState {}

class SparePartLoading extends SparePartState {}

class SparePartListLoaded extends SparePartState {
  final List<SparePartModel> spareParts;
  final int total;
  final int page;
  final bool hasMore;

  SparePartListLoaded({
    required this.spareParts,
    required this.total,
    required this.page,
    required this.hasMore,
  });
}

class SparePartDetailLoaded extends SparePartState {
  final SparePartModel sparePart;

  SparePartDetailLoaded({required this.sparePart});
}

class StockSummaryLoaded extends SparePartState {
  final StockSummary summary;

  StockSummaryLoaded({required this.summary});
}

class SparePartOperationSuccess extends SparePartState {
  final String message;

  SparePartOperationSuccess({required this.message});
}

class SparePartError extends SparePartState {
  final String message;

  SparePartError({required this.message});
}
