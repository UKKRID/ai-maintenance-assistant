abstract class SparePartEvent {}

class LoadSpareParts extends SparePartEvent {
  final int page;
  final int limit;
  final String? search;
  final String? category;
  final bool? lowStock;

  LoadSpareParts({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.category,
    this.lowStock,
  });
}

class LoadSparePartDetail extends SparePartEvent {
  final String partId;

  LoadSparePartDetail({required this.partId});
}

class CreateSparePart extends SparePartEvent {
  final String name;
  final String partNumber;
  final String? category;
  final String? description;
  final double unitPrice;
  final int stockQty;
  final int minStock;
  final String unit;
  final String? imageUrl;

  CreateSparePart({
    required this.name,
    required this.partNumber,
    this.category,
    this.description,
    required this.unitPrice,
    this.stockQty = 0,
    this.minStock = 0,
    this.unit = 'piece',
    this.imageUrl,
  });
}

class UpdateSparePart extends SparePartEvent {
  final String partId;
  final String? name;
  final String? partNumber;
  final String? category;
  final String? description;
  final double? unitPrice;
  final int? stockQty;
  final int? minStock;
  final String? unit;
  final String? imageUrl;
  final bool? isActive;

  UpdateSparePart({
    required this.partId,
    this.name,
    this.partNumber,
    this.category,
    this.description,
    this.unitPrice,
    this.stockQty,
    this.minStock,
    this.unit,
    this.imageUrl,
    this.isActive,
  });
}

class UpdateStock extends SparePartEvent {
  final String partId;
  final int quantity;
  final String? reason;

  UpdateStock({
    required this.partId,
    required this.quantity,
    this.reason,
  });
}

class DeleteSparePart extends SparePartEvent {
  final String partId;

  DeleteSparePart({required this.partId});
}

class LoadStockSummary extends SparePartEvent {}

class SearchSpareParts extends SparePartEvent {
  final String query;

  SearchSpareParts({required this.query});
}
