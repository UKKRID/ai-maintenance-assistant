import '../../models/pm_task_model.dart';
import '../../../../services/api/api_client.dart';

class PmTaskRemoteDataSource {
  final ApiClient _apiClient;

  PmTaskRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<PMTaskListResponse> getPmTasks({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? machineId,
    String? assignedTo,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (machineId != null && machineId.isNotEmpty) queryParams['machine_id'] = machineId;
    if (assignedTo != null && assignedTo.isNotEmpty) queryParams['assigned_to'] = assignedTo;
    if (startDate != null && startDate.isNotEmpty) queryParams['start_date'] = startDate;
    if (endDate != null && endDate.isNotEmpty) queryParams['end_date'] = endDate;

    final queryString = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    final response = await _apiClient.get('/api/pm-tasks?$queryString');
    return PMTaskListResponse.fromJson(response);
  }

  Future<PMTaskModel> getPmTask(String pmId) async {
    final response = await _apiClient.get('/api/pm-tasks/$pmId');
    return PMTaskModel.fromJson(response);
  }

  Future<PMTaskModel> createPmTask({
    required String machineId,
    required String title,
    String? description,
    required String scheduledDate,
    String? assignedTo,
    List<Map<String, dynamic>>? checklist,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      '/api/pm-tasks',
      body: {
        'machine_id': machineId,
        'title': title,
        'description': description,
        'scheduled_date': scheduledDate,
        'assigned_to': assignedTo,
        'checklist': checklist,
        'notes': notes,
      },
    );
    return PMTaskModel.fromJson(response);
  }

  Future<PMTaskModel> updatePmTask({
    required String pmId,
    String? title,
    String? description,
    String? scheduledDate,
    String? assignedTo,
    String? status,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (scheduledDate != null) body['scheduled_date'] = scheduledDate;
    if (assignedTo != null) body['assigned_to'] = assignedTo;
    if (status != null) body['status'] = status;
    if (notes != null) body['notes'] = notes;

    final response = await _apiClient.put('/api/pm-tasks/$pmId', body: body);
    return PMTaskModel.fromJson(response);
  }

  Future<PMTaskModel> completePmTask({
    required String pmId,
    String? completedDate,
    String? notes,
  }) async {
    final response = await _apiClient.put(
      '/api/pm-tasks/$pmId/complete',
      body: {
        'completed_date': completedDate,
        'notes': notes,
      },
    );
    return PMTaskModel.fromJson(response);
  }

  Future<PMTaskModel> updateChecklistItem({
    required String pmId,
    required String checklistId,
    required String itemId,
    required bool isCompleted,
  }) async {
    final response = await _apiClient.put(
      '/api/pm-tasks/$pmId/checklist/$checklistId/$itemId',
      body: {'is_completed': isCompleted},
    );
    return PMTaskModel.fromJson(response);
  }

  Future<void> deletePmTask(String pmId) async {
    await _apiClient.post('/api/pm-tasks/$pmId/delete', body: {});
  }
}
