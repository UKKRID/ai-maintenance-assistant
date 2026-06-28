import '../datasources/remote/repair_remote_datasource.dart';
import '../models/repair_model.dart';

class RepairRepository {
  final RepairRemoteDataSource _remoteDataSource;

  RepairRepository({required RepairRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<RepairListResponse> getRepairs({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? priority,
    String? machineId,
    String? assignedTo,
  }) async {
    try {
      return await _remoteDataSource.getRepairs(
        page: page,
        limit: limit,
        search: search,
        status: status,
        priority: priority,
        machineId: machineId,
        assignedTo: assignedTo,
      );
    } catch (e) {
      throw RepairException(message: 'ดึงข้อมูลงานซ่อมไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<RepairModel> getRepair(String repairId) async {
    try {
      return await _remoteDataSource.getRepair(repairId);
    } catch (e) {
      throw RepairException(message: 'ดึงข้อมูลงานซ่อมไม่สำเร็จ: ${e.toString()}');
    }
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
    try {
      return await _remoteDataSource.createRepair(
        machineId: machineId,
        title: title,
        description: description,
        priority: priority,
        estimatedTime: estimatedTime,
        estimatedCost: estimatedCost,
        notes: notes,
      );
    } catch (e) {
      throw RepairException(message: 'สร้างงานซ่อมไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<RepairModel> assignRepair({
    required String repairId,
    required String assignedTo,
  }) async {
    try {
      return await _remoteDataSource.assignRepair(
        repairId: repairId,
        assignedTo: assignedTo,
      );
    } catch (e) {
      throw RepairException(message: 'มอบหมายงานไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<RepairModel> updateStatus({
    required String repairId,
    required String status,
    String? notes,
  }) async {
    try {
      return await _remoteDataSource.updateStatus(
        repairId: repairId,
        status: status,
        notes: notes,
      );
    } catch (e) {
      throw RepairException(message: 'อัพเดทสถานะไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<RepairModel> completeRepair({
    required String repairId,
    int? actualTime,
    double? actualCost,
    String? notes,
  }) async {
    try {
      return await _remoteDataSource.completeRepair(
        repairId: repairId,
        actualTime: actualTime,
        actualCost: actualCost,
        notes: notes,
      );
    } catch (e) {
      throw RepairException(message: 'เสร็จสิ้นงานไม่สำเร็จ: ${e.toString()}');
    }
  }
}

class RepairException implements Exception {
  final String message;

  RepairException({required this.message});

  @override
  String toString() => 'RepairException: $message';
}
