class Inventory {
  final int? id;
  final String itemName;
  final String? unit;
  final double quantityInStock;
  final double minStockLevel;
  final double? costPerUnit;
  final String? supplierInfo;
  final DateTime? lastReorderDate;
  final DateTime? updatedAt;

  Inventory({
    this.id,
    required this.itemName,
    this.unit,
    this.quantityInStock = 0,
    this.minStockLevel = 5,
    this.costPerUnit,
    this.supplierInfo,
    this.lastReorderDate,
    this.updatedAt,
  });

  // factory Inventory.fromMap(Map<String, dynamic> map) {
  //   return Inventory(
  //     id: map['id'],
  //     itemName: map['item_name'] ?? '',
  //     unit: map['unit'],
  //     quantityInStock: (map['quantity_in_stock'] ?? 0).toDouble(),
  //     minStockLevel: (map['min_stock_level'] ?? 5).toDouble(),
  //     costPerUnit: map['cost_per_unit']?.toDouble(),
  //     supplierInfo: map['supplier_info'],
  //     lastReorderDate: map['last_reorder_date'] != null
  //         ? DateTime.parse(map['last_reorder_date'])
  //         : null,
  //     updatedAt: map['updated_at'] != null
  //         ? DateTime.parse(map['updated_at'])
  //         : null,
  //   );
  // }

  // factory Inventory.fromMap(Map<String, dynamic> map) {
  //   return Inventory(
  //     id: map['id'],
  //     itemName: map['item_name'] ?? '',
  //     unit: map['unit'],
  //     quantityInStock: (map['quantity_in_stock'] ?? 0).toDouble(),
  //     minStockLevel: (map['min_stock_level'] ?? 5).toDouble(),
  //     costPerUnit: map['cost_per_unit']?.toDouble(),
  //     supplierInfo: map['supplier_info'],
  //     lastReorderDate: map['last_reorder_date'] != null
  //         ? DateTime.parse(map['last_reorder_date'])
  //         : null,
  //     updatedAt: map['updated_at'] != null
  //         ? DateTime.parse(map['updated_at'])
  //         : null,
  //   );
  // }

  factory Inventory.fromMap(Map<String, dynamic> map) {
    return Inventory(
      id: map['id'] is String ? int.tryParse(map['id']) : map['id'] as int?,
      itemName: map['item_name'] ?? '',
      unit: map['unit'],
      quantityInStock: map['quantity_in_stock'] is String
          ? double.tryParse(map['quantity_in_stock']) ?? 0
          : (map['quantity_in_stock'] as num?)?.toDouble() ?? 0,
      minStockLevel: map['min_stock_level'] is String
          ? double.tryParse(map['min_stock_level']) ?? 5
          : (map['min_stock_level'] as num?)?.toDouble() ?? 5,
      costPerUnit: map['cost_per_unit'] is String
          ? double.tryParse(map['cost_per_unit'])
          : (map['cost_per_unit'] as num?)?.toDouble(),
      supplierInfo: map['supplier_info'],
      lastReorderDate: map['last_reorder_date'] != null
          ? (map['last_reorder_date'] is DateTime
                ? map['last_reorder_date']
                : DateTime.tryParse(map['last_reorder_date'].toString()))
          : null,
      updatedAt: map['updated_at'] != null
          ? (map['updated_at'] is DateTime
                ? map['updated_at']
                : DateTime.tryParse(map['updated_at'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_name': itemName,
      'unit': unit,
      'quantity_in_stock': quantityInStock,
      'min_stock_level': minStockLevel,
      'cost_per_unit': costPerUnit,
      'supplier_info': supplierInfo,
      'last_reorder_date': lastReorderDate?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
