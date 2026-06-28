import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/ai_repository.dart';
import '../../../data/models/ai_analysis_model.dart';

// Events
abstract class AiEvent {}

class AnalyzeBreakdown extends AiEvent {
  final String machineId;
  final String? text;
  final List<File>? images;

  AnalyzeBreakdown({
    required this.machineId,
    this.text,
    this.images,
  });
}

class SubmitFeedback extends AiEvent {
  final String analysisId;
  final String feedback;
  final String? actualCause;
  final String? notes;

  SubmitFeedback({
    required this.analysisId,
    required this.feedback,
    this.actualCause,
    this.notes,
  });
}

class LoadAnalysisHistory extends AiEvent {
  final String machineId;

  LoadAnalysisHistory({required this.machineId});
}

class ResetAiState extends AiEvent {}

// States
abstract class AiState {}

class AiInitial extends AiState {}

class AiAnalyzing extends AiState {
  final double progress;

  AiAnalyzing({this.progress = 0.0});
}

class AiResultLoaded extends AiState {
  final AIAnalysisResponse analysis;

  AiResultLoaded({required this.analysis});
}

class AiHistoryLoaded extends AiState {
  final List<AIAnalysisResponse> history;

  AiHistoryLoaded({required this.history});
}

class AiError extends AiState {
  final String message;

  AiError({required this.message});
}

class AiFeedbackSubmitted extends AiState {}

// BLoC
class AiBloc extends Bloc<AiEvent, AiState> {
  final AiRepository _repository;

  AiBloc({required AiRepository repository})
      : _repository = repository,
        super(AiInitial()) {
    on<AnalyzeBreakdown>(_onAnalyzeBreakdown);
    on<SubmitFeedback>(_onSubmitFeedback);
    on<LoadAnalysisHistory>(_onLoadAnalysisHistory);
    on<ResetAiState>(_onResetAiState);
  }

  Future<void> _onAnalyzeBreakdown(
    AnalyzeBreakdown event,
    Emitter<AiState> emit,
  ) async {
    emit(AiAnalyzing(progress: 0.0));

    try {
      // Simulate progress
      await Future.delayed(const Duration(milliseconds: 500));
      emit(AiAnalyzing(progress: 0.3));

      final analysis = await _repository.analyzeBreakdown(
        machineId: event.machineId,
        text: event.text,
        images: event.images,
      );

      emit(AiAnalyzing(progress: 1.0));
      await Future.delayed(const Duration(milliseconds: 300));

      emit(AiResultLoaded(analysis: analysis));
    } catch (e) {
      emit(AiError(message: e.toString()));
    }
  }

  Future<void> _onSubmitFeedback(
    SubmitFeedback event,
    Emitter<AiState> emit,
  ) async {
    try {
      await _repository.submitFeedback(
        analysisId: event.analysisId,
        feedback: event.feedback,
        actualCause: event.actualCause,
        notes: event.notes,
      );
      emit(AiFeedbackSubmitted());
    } catch (e) {
      emit(AiError(message: e.toString()));
    }
  }

  Future<void> _onLoadAnalysisHistory(
    LoadAnalysisHistory event,
    Emitter<AiState> emit,
  ) async {
    try {
      final history = await _repository.getHistory(event.machineId);
      emit(AiHistoryLoaded(history: history));
    } catch (e) {
      emit(AiError(message: e.toString()));
    }
  }

  void _onResetAiState(
    ResetAiState event,
    Emitter<AiState> emit,
  ) {
    emit(AiInitial());
  }
}
