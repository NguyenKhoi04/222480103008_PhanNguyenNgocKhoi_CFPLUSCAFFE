class Category {
  final int? id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final DateTime? updatedAt;

  Category({
    this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.isActive = true,
    this.updatedAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] ?? '',
      description: map['description'],
      imageUrl: map['image_url'],
      isActive: map['is_active'] ?? true,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
