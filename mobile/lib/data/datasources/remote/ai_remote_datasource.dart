import 'dart:io';
import '../models/ai_analysis_model.dart';
import '../../services/api/api_client.dart';

class AiRemoteDataSource {
  final ApiClient _apiClient;

  AiRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<AIAnalysisResponse> analyze({
    required String machineId,
    String? text,
    List<File>? images,
  }) async {
    if (images != null && images.isNotEmpty) {
      return _analyzeWithUpload(
        machineId: machineId,
        text: text,
        images: images,
      );
    } else {
      return _analyzeWithJson(
        machineId: machineId,
        text: text,
      );
    }
  }

  Future<AIAnalysisResponse> _analyzeWithJson({
    required String machineId,
    String? text,
  }) async {
    final response = await _apiClient.post(
      '/api/ai/analyze',
      body: {
        'machine_id': machineId,
        'input_text': text,
      },
    );
    return AIAnalysisResponse.fromJson(response);
  }

  Future<AIAnalysisResponse> _analyzeWithUpload({
    required String machineId,
    String? text,
    required List<File> images,
  }) async {
    final fields = <String, String>{
      'machine_id': machineId,
    };
    if (text != null) {
      fields['input_text'] = text;
    }

    // Upload first image for simplicity
    final response = await _apiClient.uploadFile(
      '/api/ai/analyze/upload',
      fieldName: 'images',
      file: images.first,
      fields: fields,
    );
    return AIAnalysisResponse.fromJson(response);
  }

  Future<AIAnalysisResponse> getAnalysis(String analysisId) async {
    final response = await _apiClient.get('/api/ai/analysis/$analysisId');
    return AIAnalysisResponse.fromJson(response);
  }

  Future<void> submitFeedback({
    required String analysisId,
    required String feedback,
    String? actualCause,
    String? notes,
  }) async {
    await _apiClient.post(
      '/api/ai/feedback',
      body: {
        'analysis_id': analysisId,
        'feedback': feedback,
        'actual_cause': actualCause,
        'notes': notes,
      },
    );
  }

  Future<List<AIAnalysisResponse>> getHistory(
    String machineId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '/api/ai/analysis/history/$machineId?page=$page&limit=$limit',
    );
    final items = response['items'] as List;
    return items.map((item) => AIAnalysisResponse.fromJson(item)).toList();
  }
}
