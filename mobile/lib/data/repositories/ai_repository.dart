import 'dart:io';
import '../datasources/remote/ai_remote_datasource.dart';
import '../models/ai_analysis_model.dart';

class AiRepository {
  final AiRemoteDataSource _remoteDataSource;

  AiRepository({required AiRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<AIAnalysisResponse> analyzeBreakdown({
    required String machineId,
    String? text,
    List<File>? images,
  }) async {
    try {
      return await _remoteDataSource.analyze(
        machineId: machineId,
        text: text,
        images: images,
      );
    } catch (e) {
      throw AiException(message: 'Failed to analyze: ${e.toString()}');
    }
  }

  Future<AIAnalysisResponse> getAnalysis(String analysisId) async {
    try {
      return await _remoteDataSource.getAnalysis(analysisId);
    } catch (e) {
      throw AiException(message: 'Failed to get analysis: ${e.toString()}');
    }
  }

  Future<void> submitFeedback({
    required String analysisId,
    required String feedback,
    String? actualCause,
    String? notes,
  }) async {
    try {
      await _remoteDataSource.submitFeedback(
        analysisId: analysisId,
        feedback: feedback,
        actualCause: actualCause,
        notes: notes,
      );
    } catch (e) {
      throw AiException(message: 'Failed to submit feedback: ${e.toString()}');
    }
  }

  Future<List<AIAnalysisResponse>> getHistory(
    String machineId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _remoteDataSource.getHistory(
        machineId,
        page: page,
        limit: limit,
      );
    } catch (e) {
      throw AiException(message: 'Failed to get history: ${e.toString()}');
    }
  }
}

class AiException implements Exception {
  final String message;

  AiException({required this.message});

  @override
  String toString() => 'AiException: $message';
}
