class ProductRecipe {
  final int? id;
  final int productId;
  final int inventoryId;
  final double amountNeeded;
  final DateTime? updatedAt;

  ProductRecipe({
    this.id,
    required this.productId,
    required this.inventoryId,
    required this.amountNeeded,
    this.updatedAt,
  });

  // factory ProductRecipe.fromMap(Map<String, dynamic> map) {
  //   return ProductRecipe(
  //     id: map['id'],
  //     productId: map['product_id'],
  //     inventoryId: map['inventory_id'],
  //     amountNeeded: (map['amount_needed'] ?? 0).toDouble(),
  //     updatedAt: map['updated_at'] != null
  //         ? DateTime.parse(map['updated_at'])
  //         : null,
  //   );
  // }
  factory ProductRecipe.fromMap(Map<String, dynamic> map) {
    return ProductRecipe(
      id: map['id'] is String ? int.tryParse(map['id']) : map['id'] as int?,
      productId:
          (map['product_id'] is String
              ? int.tryParse(map['product_id'])
              : map['product_id'] as int?) ??
          0,
      inventoryId:
          (map['inventory_id'] is String
              ? int.tryParse(map['inventory_id'])
              : map['inventory_id'] as int?) ??
          0,
      amountNeeded:
          (map['amount_needed'] is String
              ? double.tryParse(map['amount_needed'])
              : (map['amount_needed'] as num?)?.toDouble()) ??
          0.0,
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
      'product_id': productId,
      'inventory_id': inventoryId,
      'amount_needed': amountNeeded,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
