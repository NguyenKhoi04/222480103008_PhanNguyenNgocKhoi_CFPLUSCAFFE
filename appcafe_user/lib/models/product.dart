class Product {
  final int? id;
  final String name;
  final double basePrice;
  final String? imageUrl;
  final int? categoryId;
  final int? discountId;
  final double? finalPrice;
  final String? description;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    required this.basePrice,
    this.imageUrl,
    this.categoryId,
    this.discountId,
    this.finalPrice,
    this.description,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] ?? '',
      basePrice: (map['base_price'] ?? 0).toDouble(),
      imageUrl: map['image_url'],
      categoryId: map['category_id'] as int?,
      discountId: map['discount_id'] as int?,
      finalPrice: map['final_price']?.toDouble(),
      description: map['description'],
      isAvailable: map['is_available'] ?? true,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'base_price': basePrice,
      'image_url': imageUrl,
      'category_id': categoryId,
      'discount_id': discountId,
      'final_price': finalPrice,
      'description': description,
      'is_available': isAvailable,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    double? basePrice,
    String? imageUrl,
    int? categoryId,
    int? discountId,
    double? finalPrice,
    String? description,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      basePrice: basePrice ?? this.basePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      discountId: discountId ?? this.discountId,
      finalPrice: finalPrice ?? this.finalPrice,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
