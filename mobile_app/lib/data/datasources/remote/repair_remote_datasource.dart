import '../../models/repair_model.dart';
import '../../../../services/api/api_client.dart';

class RepairRemoteDataSource {
  final ApiClient _apiClient;

  RepairRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<RepairListResponse> getRepairs({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? priority,
    String? machineId,
    String? assignedTo,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (priority != null && priority.isNotEmpty) queryParams['priority'] = priority;
    if (machineId != null && machineId.isNotEmpty) queryParams['machine_id'] = machineId;
    if (assignedTo != null && assignedTo.isNotEmpty) queryParams['assigned_to'] = assignedTo;

    final queryString = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    final response = await _apiClient.get('/api/repairs?$queryString');
    return RepairListResponse.fromJson(response);
  }

  Future<RepairModel> getRepair(String repairId) async {
    final response = await _apiClient.get('/api/repairs/$repairId');
    return RepairModel.fromJson(response);
  }

  Future<RepairModel> createRepair({
    required String machineId,
    required String title,
    String? description,
    String priority = 'medium',
    int? estimatedTime,
    double? estimatedCost,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      '/api/repairs',
      body: {
        'machine_id': machineId,
        'title': title,
        'description': description,
        'priority': priority,
        'estimated_time': estimatedTime,
        'estimated_cost': estimatedCost,
        'notes': notes,
      },
    );
    return RepairModel.fromJson(response);
  }

  Future<RepairModel> assignRepair({
    required String repairId,
    required String assignedTo,
  }) async {
    final response = await _apiClient.put(
      '/api/repairs/$repairId/assign',
      body: {'assigned_to': assignedTo},
    );
    return RepairModel.fromJson(response);
  }

  Future<RepairModel> updateStatus({
    required String repairId,
    required String status,
    String? notes,
  }) async {
    final response = await _apiClient.put(
      '/api/repairs/$repairId/status',
      body: {
        'status': status,
        'notes': notes,
      },
    );
    return RepairModel.fromJson(response);
  }

  Future<RepairModel> completeRepair({
    required String repairId,
    int? actualTime,
    double? actualCost,
    String? notes,
  }) async {
    final response = await _apiClient.put(
      '/api/repairs/$repairId/complete',
      body: {
        'actual_time': actualTime,
        'actual_cost': actualCost,
        'notes': notes,
      },
    );
    return RepairModel.fromJson(response);
  }
}
