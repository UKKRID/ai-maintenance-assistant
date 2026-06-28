import '../models/machine_model.dart';
import '../../../services/api/api_client.dart';

class MachineRemoteDataSource {
  final ApiClient _apiClient;

  MachineRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<MachineListResponse> getMachines({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? department,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (department != null && department.isNotEmpty) {
      queryParams['department'] = department;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final response = await _apiClient.get('/api/machines?$queryString');
    return MachineListResponse.fromJson(response);
  }

  Future<MachineModel> getMachine(String machineId) async {
    final response = await _apiClient.get('/api/machines/$machineId');
    return MachineModel.fromJson(response);
  }

  Future<MachineModel> createMachine({
    required String name,
    required String model,
    required String serialNumber,
    required String location,
    String? department,
    required String installDate,
    String status = 'active',
  }) async {
    final response = await _apiClient.post(
      '/api/machines',
      body: {
        'name': name,
        'model': model,
        'serial_number': serialNumber,
        'location': location,
        'department': department,
        'install_date': installDate,
        'status': status,
      },
    );
    return MachineModel.fromJson(response);
  }

  Future<MachineModel> updateMachine({
    required String machineId,
    String? name,
    String? model,
    String? serialNumber,
    String? location,
    String? department,
    String? installDate,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (model != null) body['model'] = model;
    if (serialNumber != null) body['serial_number'] = serialNumber;
    if (location != null) body['location'] = location;
    if (department != null) body['department'] = department;
    if (installDate != null) body['install_date'] = installDate;
    if (status != null) body['status'] = status;

    final response = await _apiClient.put(
      '/api/machines/$machineId',
      body: body,
    );
    return MachineModel.fromJson(response);
  }

  Future<void> deleteMachine(String machineId) async {
    await _apiClient.post('/api/machines/$machineId/delete', body: {});
  }
}
