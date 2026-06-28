import '../datasources/remote/pm_task_remote_datasource.dart';
import '../models/pm_task_model.dart';

class PmTaskRepository {
  final PmTaskRemoteDataSource _remoteDataSource;

  PmTaskRepository({required PmTaskRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

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
    try {
      return await _remoteDataSource.getPmTasks(
        page: page,
        limit: limit,
        search: search,
        status: status,
        machineId: machineId,
        assignedTo: assignedTo,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw PmTaskException(message: 'ดึงข้อมูล PM ไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<PMTaskModel> getPmTask(String pmId) async {
    try {
      return await _remoteDataSource.getPmTask(pmId);
    } catch (e) {
      throw PmTaskException(message: 'ดึงข้อมูล PM ไม่สำเร็จ: ${e.toString()}');
    }
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
    try {
      return await _remoteDataSource.createPmTask(
        machineId: machineId,
        title: title,
        description: description,
        scheduledDate: scheduledDate,
        assignedTo: assignedTo,
        checklist: checklist,
        notes: notes,
      );
    } catch (e) {
      throw PmTaskException(message: 'สร้างงาน PM ไม่สำเร็จ: ${e.toString()}');
    }
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
    try {
      return await _remoteDataSource.updatePmTask(
        pmId: pmId,
        title: title,
        description: description,
        scheduledDate: scheduledDate,
        assignedTo: assignedTo,
        status: status,
        notes: notes,
      );
    } catch (e) {
      throw PmTaskException(message: 'แก้ไขงาน PM ไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<PMTaskModel> completePmTask({
    required String pmId,
    String? completedDate,
    String? notes,
  }) async {
    try {
      return await _remoteDataSource.completePmTask(
        pmId: pmId,
        completedDate: completedDate,
        notes: notes,
      );
    } catch (e) {
      throw PmTaskException(message: 'เสร็จสิ้นงาน PM ไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<PMTaskModel> updateChecklistItem({
    required String pmId,
    required String checklistId,
    required String itemId,
    required bool isCompleted,
  }) async {
    try {
      return await _remoteDataSource.updateChecklistItem(
        pmId: pmId,
        checklistId: checklistId,
        itemId: itemId,
        isCompleted: isCompleted,
      );
    } catch (e) {
      throw PmTaskException(message: 'อัพเดท Checklist ไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<void> deletePmTask(String pmId) async {
    try {
      await _remoteDataSource.deletePmTask(pmId);
    } catch (e) {
      throw PmTaskException(message: 'ลบงาน PM ไม่สำเร็จ: ${e.toString()}');
    }
  }
}

class PmTaskException implements Exception {
  final String message;

  PmTaskException({required this.message});

  @override
  String toString() => 'PmTaskException: $message';
}
