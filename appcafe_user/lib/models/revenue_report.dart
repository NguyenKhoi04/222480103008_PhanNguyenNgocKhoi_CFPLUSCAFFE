// Import thư viện cloud_firestore để sử dụng kiểu dữ liệu Timestamp
import 'package:cloud_firestore/cloud_firestore.dart';
class RevenueReport {
  final int? id;
  final DateTime reportDate;
  final int totalOrders;
  final double grossRevenue;
  final double totalCost;
  final double netProfit;
  final int? bestSellingProductId;
  final String? aiPredictionNote;
  final DateTime? updatedAt;

  RevenueReport({
    this.id,
    required this.reportDate,
    this.totalOrders = 0,
    this.grossRevenue = 0,
    this.totalCost = 0,
    this.netProfit = 0,
    this.bestSellingProductId,
    this.aiPredictionNote,
    this.updatedAt,
  });

  // factory RevenueReport.fromMap(Map<String, dynamic> map) {
  //   return RevenueReport(
  //     id: map['id'],
  //     reportDate: DateTime.parse(map['report_date']),
  //     totalOrders: map['total_orders'] ?? 0,
  //     grossRevenue: (map['gross_revenue'] ?? 0).toDouble(),
  //     totalCost: (map['total_cost'] ?? 0).toDouble(),
  //     netProfit: (map['net_profit'] ?? 0).toDouble(),
  //     bestSellingProductId: map['best_selling_product_id'],
  //     aiPredictionNote: map['ai_prediction_note'],
  //     updatedAt: map['updated_at'] != null
  //         ? DateTime.parse(map['updated_at'])
  //         : null,
  //   );
  // }



factory RevenueReport.fromMap(Map<String, dynamic> map) {
  // Hàm helper để xử lý chuyển đổi Timestamp/String sang DateTime
  DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate(); // Xử lý nếu là Timestamp của Firebase
    if (value is String) return DateTime.tryParse(value); // Xử lý nếu là String ISO
    if (value is DateTime) return value;
    return null;
  }

  return RevenueReport(
    id: map['id'] is String ? int.tryParse(map['id']) : map['id'] as int?,
    
    // Sửa lỗi tại đây
    reportDate: parseDateTime(map['report_date']) ?? DateTime.now(), 
    
    totalOrders: map['total_orders'] ?? 0,
    grossRevenue: (map['gross_revenue'] ?? 0).toDouble(),
    totalCost: (map['total_cost'] ?? 0).toDouble(),
    netProfit: (map['net_profit'] ?? 0).toDouble(),
    
    bestSellingProductId: map['best_selling_product_id'] is String
        ? int.tryParse(map['best_selling_product_id'])
        : map['best_selling_product_id'] as int?,
        
    aiPredictionNote: map['ai_prediction_note'] as String?,
    
    // Sửa lỗi tại đây
    updatedAt: parseDateTime(map['updated_at']),
  );
}
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'report_date': reportDate.toIso8601String().split('T')[0], // Date only
      'total_orders': totalOrders,
      'gross_revenue': grossRevenue,
      'total_cost': totalCost,
      'net_profit': netProfit,
      'best_selling_product_id': bestSellingProductId,
      'ai_prediction_note': aiPredictionNote,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
