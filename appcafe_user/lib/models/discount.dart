class Discount {
  final int? id;
  final String code;
  final double discountPercent;
  final String? description;
  final String? qrCode;
  final double? minOrderAmount;
  final double? maxDiscount;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Discount({
    this.id,
    required this.code,
    required this.discountPercent,
    this.description,
    this.qrCode,
    this.minOrderAmount,
    this.maxDiscount,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Discount.fromMap(Map<String, dynamic> map) {
    return Discount(
      id: map['id'] as int?,
      code: map['code'] ?? '',
      discountPercent: (map['discount_percent'] ?? 0).toDouble(),
      description: map['description'],
      qrCode: map['qr_code'],
      minOrderAmount: map['min_order_amount']?.toDouble(),
      maxDiscount: map['max_discount']?.toDouble(),
      startDate: map['start_date'] != null
          ? DateTime.tryParse(map['start_date'].toString())
          : null,
      endDate: map['end_date'] != null
          ? DateTime.tryParse(map['end_date'].toString())
          : null,
      isActive: map['is_active'] ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'discount_percent': discountPercent,
      'description': description,
      'qr_code': qrCode,
      'min_order_amount': minOrderAmount,
      'max_discount': maxDiscount,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
    };
  }

  bool get isValid {
    final now = DateTime.now();
    if (!isActive) return false;
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  double calculateDiscount(double orderAmount) {
    if (!isValid) return 0;
    if (minOrderAmount != null && orderAmount < minOrderAmount!) return 0;

    double discount = orderAmount * (discountPercent / 100);
    if (maxDiscount != null && discount > maxDiscount!) {
      discount = maxDiscount!;
    }
    return discount;
  }

  Discount copyWith({
    int? id,
    String? code,
    double? discountPercent,
    String? description,
    String? qrCode,
    double? minOrderAmount,
    double? maxDiscount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Discount(
      id: id ?? this.id,
      code: code ?? this.code,
      discountPercent: discountPercent ?? this.discountPercent,
      description: description ?? this.description,
      qrCode: qrCode ?? this.qrCode,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
