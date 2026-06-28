import '../datasources/remote/machine_remote_datasource.dart';
import '../models/machine_model.dart';

class MachineRepository {
  final MachineRemoteDataSource _remoteDataSource;

  MachineRepository({required MachineRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<MachineListResponse> getMachines({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? department,
  }) async {
    try {
      return await _remoteDataSource.getMachines(
        page: page,
        limit: limit,
        search: search,
        status: status,
        department: department,
      );
    } catch (e) {
      throw MachineException(message: 'ดึงข้อมูลเครื่องจักรไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<MachineModel> getMachine(String machineId) async {
    try {
      return await _remoteDataSource.getMachine(machineId);
    } catch (e) {
      throw MachineException(message: 'ดึงข้อมูลเครื่องจักรไม่สำเร็จ: ${e.toString()}');
    }
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
    try {
      return await _remoteDataSource.createMachine(
        name: name,
        model: model,
        serialNumber: serialNumber,
        location: location,
        department: department,
        installDate: installDate,
        status: status,
      );
    } catch (e) {
      throw MachineException(message: 'เพิ่มเครื่องจักรไม่สำเร็จ: ${e.toString()}');
    }
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
    try {
      return await _remoteDataSource.updateMachine(
        machineId: machineId,
        name: name,
        model: model,
        serialNumber: serialNumber,
        location: location,
        department: department,
        installDate: installDate,
        status: status,
      );
    } catch (e) {
      throw MachineException(message: 'แก้ไขเครื่องจักรไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<void> deleteMachine(String machineId) async {
    try {
      await _remoteDataSource.deleteMachine(machineId);
    } catch (e) {
      throw MachineException(message: 'ลบเครื่องจักรไม่สำเร็จ: ${e.toString()}');
    }
  }
}

class MachineException implements Exception {
  final String message;

  MachineException({required this.message});

  @override
  String toString() => 'MachineException: $message';
}
