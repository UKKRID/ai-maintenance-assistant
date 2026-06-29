import '../../models/spare_part_model.dart';
import '../../../../services/api/api_client.dart';

class SparePartRemoteDataSource {
  final ApiClient _apiClient;

  SparePartRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<SparePartListResponse> getSpareParts({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    bool? lowStock,
    bool? isActive,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (lowStock != null) queryParams['low_stock'] = lowStock.toString();
    if (isActive != null) queryParams['is_active'] = isActive.toString();

    final queryString = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    final response = await _apiClient.get('/api/spare-parts?$queryString');
    return SparePartListResponse.fromJson(response);
  }

  Future<SparePartModel> getSparePart(String partId) async {
    final response = await _apiClient.get('/api/spare-parts/$partId');
    return SparePartModel.fromJson(response);
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
    final response = await _apiClient.post(
      '/api/spare-parts',
      body: {
        'name': name,
        'part_number': partNumber,
        'category': category,
        'description': description,
        'unit_price': unitPrice,
        'stock_qty': stockQty,
        'min_stock': minStock,
        'unit': unit,
        'image_url': imageUrl,
      },
    );
    return SparePartModel.fromJson(response);
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
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (partNumber != null) body['part_number'] = partNumber;
    if (category != null) body['category'] = category;
    if (description != null) body['description'] = description;
    if (unitPrice != null) body['unit_price'] = unitPrice;
    if (stockQty != null) body['stock_qty'] = stockQty;
    if (minStock != null) body['min_stock'] = minStock;
    if (unit != null) body['unit'] = unit;
    if (imageUrl != null) body['image_url'] = imageUrl;
    if (isActive != null) body['is_active'] = isActive;

    final response = await _apiClient.put(
      '/api/spare-parts/$partId',
      body: body,
    );
    return SparePartModel.fromJson(response);
  }

  Future<SparePartModel> updateStock({
    required String partId,
    required int quantity,
    String? reason,
  }) async {
    final response = await _apiClient.put(
      '/api/spare-parts/$partId/stock',
      body: {
        'quantity': quantity,
        'reason': reason,
      },
    );
    return SparePartModel.fromJson(response);
  }

  Future<void> deleteSparePart(String partId) async {
    await _apiClient.put(
      '/api/spare-parts/$partId',
      body: {'is_active': false},
    );
  }

  Future<StockSummary> getStockSummary() async {
    final response = await _apiClient.get('/api/spare-parts/stock-summary');
    return StockSummary.fromJson(response);
  }
}
