class SparePartModel {
  final String partId;
  final String name;
  final String partNumber;
  final String? category;
  final String? description;
  final double unitPrice;
  final int stockQty;
  final int minStock;
  final String unit;
  final String? imageUrl;
  final bool isActive;
  final String stockStatus;
  final double totalValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  SparePartModel({
    required this.partId,
    required this.name,
    required this.partNumber,
    this.category,
    this.description,
    required this.unitPrice,
    required this.stockQty,
    required this.minStock,
    required this.unit,
    this.imageUrl,
    required this.isActive,
    required this.stockStatus,
    required this.totalValue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SparePartModel.fromJson(Map<String, dynamic> json) {
    return SparePartModel(
      partId: json['part_id'] ?? '',
      name: json['name'] ?? '',
      partNumber: json['part_number'] ?? '',
      category: json['category'],
      description: json['description'],
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      stockQty: json['stock_qty'] ?? 0,
      minStock: json['min_stock'] ?? 0,
      unit: json['unit'] ?? 'piece',
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      stockStatus: json['stock_status'] ?? 'in_stock',
      totalValue: (json['total_value'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get stockStatusLabel {
    switch (stockStatus) {
      case 'in_stock': return 'In Stock';
      case 'low_stock': return 'Low Stock';
      case 'out_of_stock': return 'Out of Stock';
      default: return stockStatus;
    }
  }

  String get unitPriceLabel => '฿${unitPrice.toStringAsFixed(0)}';
  String get totalValueLabel => '฿${totalValue.toStringAsFixed(0)}';
}

class SparePartListResponse {
  final List<SparePartModel> items;
  final int total;
  final int page;
  final int limit;

  SparePartListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory SparePartListResponse.fromJson(Map<String, dynamic> json) {
    return SparePartListResponse(
      items: (json['items'] as List).map((item) => SparePartModel.fromJson(item)).toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
    );
  }
}

class StockSummary {
  final int totalParts;
  final double totalValue;
  final int lowStockCount;
  final int outOfStockCount;

  StockSummary({
    required this.totalParts,
    required this.totalValue,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  factory StockSummary.fromJson(Map<String, dynamic> json) {
    return StockSummary(
      totalParts: json['total_parts'] ?? 0,
      totalValue: (json['total_value'] ?? 0).toDouble(),
      lowStockCount: json['low_stock_count'] ?? 0,
      outOfStockCount: json['out_of_stock_count'] ?? 0,
    );
  }
}
