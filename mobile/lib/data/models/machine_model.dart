class MachineModel {
  final String machineId;
  final String name;
  final String model;
  final String serialNumber;
  final String location;
  final String? department;
  final String installDate;
  final String status;
  final String? qrCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  MachineModel({
    required this.machineId,
    required this.name,
    required this.model,
    required this.serialNumber,
    required this.location,
    this.department,
    required this.installDate,
    required this.status,
    this.qrCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) {
    return MachineModel(
      machineId: json['machine_id'] ?? '',
      name: json['name'] ?? '',
      model: json['model'] ?? '',
      serialNumber: json['serial_number'] ?? '',
      location: json['location'] ?? '',
      department: json['department'],
      installDate: json['install_date'] ?? '',
      status: json['status'] ?? 'active',
      qrCode: json['qr_code'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'machine_id': machineId,
      'name': name,
      'model': model,
      'serial_number': serialNumber,
      'location': location,
      'department': department,
      'install_date': installDate,
      'status': status,
      'qr_code': qrCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'under_repair':
        return 'Under Repair';
      case 'disposed':
        return 'Disposed';
      default:
        return status;
    }
  }
}

class MachineListResponse {
  final List<MachineModel> items;
  final int total;
  final int page;
  final int limit;

  MachineListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory MachineListResponse.fromJson(Map<String, dynamic> json) {
    return MachineListResponse(
      items: (json['items'] as List)
          .map((item) => MachineModel.fromJson(item))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
    );
  }
}
