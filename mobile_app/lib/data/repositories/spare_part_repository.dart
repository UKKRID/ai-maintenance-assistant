import '../datasources/remote/spare_part_remote_datasource.dart';
import '../models/spare_part_model.dart';

class SparePartRepository {
  final SparePartRemoteDataSource _remoteDataSource;

  SparePartRepository({required SparePartRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<SparePartListResponse> getSpareParts({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    bool? lowStock,
    bool? isActive,
  }) async {
    try {
      return await _remoteDataSource.getSpareParts(
        page: page,
        limit: limit,
        search: search,
        category: category,
        lowStock: lowStock,
        isActive: isActive,
      );
    } catch (e) {
      throw SparePartException(message: 'ดึงข้อมูลอะไหล่ไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<SparePartModel> getSparePart(String partId) async {
    try {
      return await _remoteDataSource.getSparePart(partId);
    } catch (e) {
      throw SparePartException(message: 'ดึงข้อมูลอะไหล่ไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<SparePartModel> createSparePart({
    required String name,
    required String partNumber,
    String? category,
    String? description,
    required double unitPrice,
    int stockQty = 0,
    int minStock = 0,
    String unit = 'piece',
    String? imageUrl,
  }) async {
    try {
      return await _remoteDataSource.createSparePart(
        name: name,
        partNumber: partNumber,
        category: category,
        description: description,
        unitPrice: unitPrice,
        stockQty: stockQty,
        minStock: minStock,
        unit: unit,
        imageUrl: imageUrl,
      );
    } catch (e) {
      throw SparePartException(message: 'เพิ่มอะไหล่ไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<SparePartModel> updateSparePart({
    required String partId,
    String? name,
    String? partNumber,
    String? category,
    String? description,
    double? unitPrice,
    int? stockQty,
    int? minStock,
    String? unit,
    String? imageUrl,
    bool? isActive,
  }) async {
    try {
      return await _remoteDataSource.updateSparePart(
        partId: partId,
        name: name,
        partNumber: partNumber,
        category: category,
        description: description,
        unitPrice: unitPrice,
        stockQty: stockQty,
        minStock: minStock,
        unit: unit,
        imageUrl: imageUrl,
        isActive: isActive,
      );
    } catch (e) {
      throw SparePartException(message: 'แก้ไขอะไหล่ไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<SparePartModel> updateStock({
    required String partId,
    required int quantity,
    String? reason,
  }) async {
    try {
      return await _remoteDataSource.updateStock(
        partId: partId,
        quantity: quantity,
        reason: reason,
      );
    } catch (e) {
      throw SparePartException(message: 'อัพเดท stock ไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<void> deleteSparePart(String partId) async {
    try {
      await _remoteDataSource.deleteSparePart(partId);
    } catch (e) {
      throw SparePartException(message: 'ลบอะไหล่ไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<StockSummary> getStockSummary() async {
    try {
      return await _remoteDataSource.getStockSummary();
    } catch (e) {
      throw SparePartException(message: 'ดึงข้อมูล stock summary ไม่สำเร็จ: ${e.toString()}');
    }
  }
}

class SparePartException implements Exception {
  final String message;

  SparePartException({required this.message});

  @override
  String toString() => 'SparePartException: $message';
}
