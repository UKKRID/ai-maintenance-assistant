abstract class MachineEvent {}

class LoadMachines extends MachineEvent {
  final int page;
  final int limit;
  final String? search;
  final String? status;
  final String? department;

  LoadMachines({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.status,
    this.department,
  });
}

class LoadMachineDetail extends MachineEvent {
  final String machineId;

  LoadMachineDetail({required this.machineId});
}

class CreateMachine extends MachineEvent {
  final String name;
  final String model;
  final String serialNumber;
  final String location;
  final String? department;
  final String installDate;
  final String status;
  final String? imageUrl;

  CreateMachine({
    required this.name,
    required this.model,
    required this.serialNumber,
    required this.location,
    this.department,
    required this.installDate,
    this.status = 'active',
    this.imageUrl,
  });
}

class UpdateMachine extends MachineEvent {
  final String machineId;
  final String? name;
  final String? model;
  final String? serialNumber;
  final String? location;
  final String? department;
  final String? installDate;
  final String? status;
  final String? imageUrl;

  UpdateMachine({
    required this.machineId,
    this.name,
    this.model,
    this.serialNumber,
    this.location,
    this.department,
    this.installDate,
    this.status,
    this.imageUrl,
  });
}

class DeleteMachine extends MachineEvent {
  final String machineId;

  DeleteMachine({required this.machineId});
}

class SearchMachines extends MachineEvent {
  final String query;

  SearchMachines({required this.query});
}
