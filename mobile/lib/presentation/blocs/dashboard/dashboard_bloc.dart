import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;

  DashboardBloc({required DashboardRepository repository})
      : _repository = repository,
        super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<LoadDashboardSummary>(_onLoadDashboardSummary);
    on<LoadDashboardAnalytics>(_onLoadDashboardAnalytics);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      final summary = await _repository.getSummary();
      emit(DashboardSummaryLoaded(summary: summary));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _onLoadDashboardSummary(
    LoadDashboardSummary event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      final summary = await _repository.getSummary();
      emit(DashboardSummaryLoaded(summary: summary));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _onLoadDashboardAnalytics(
    LoadDashboardAnalytics event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      final analytics = await _repository.getAnalytics(
        period: event.period,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(DashboardAnalyticsLoaded(analytics: analytics));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final summary = await _repository.getSummary();
      emit(DashboardSummaryLoaded(summary: summary));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }
}
