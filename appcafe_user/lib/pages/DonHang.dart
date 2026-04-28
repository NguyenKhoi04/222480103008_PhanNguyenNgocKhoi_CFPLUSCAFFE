class DonHang {
  String id;
  String tenBan;
  String tenSanPham;
  String size;
  String mucDa;
  int soLuong;
  int tongTien;
  String ghiChu;
  String hinhThuc;
  String hinhAnh;
  String trangThai;

  DonHang({
    required this.id,
    required this.tenBan,
    required this.tenSanPham,
    required this.size,
    required this.mucDa,
    required this.ghiChu,
    required this.soLuong,
    required this.tongTien,
    required this.hinhThuc,
    required this.hinhAnh,
    required this.trangThai,
  });

  // Giá 1 sản phẩm
  int get giaDonVi {
    if (soLuong > 0) {
      return (tongTien / soLuong).round();
    }
    return 0;
  }

  // ==========================
  // Parse số an toàn
  // ==========================
  static int _parseInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.toInt();

    if (value is num) return value.toInt();

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  // ==========================
  // Từ Supabase
  // ==========================
  factory DonHang.fromSupabase(
    Map<String, dynamic> data,
  ) {
    final soLuongParsed =
        _parseInt(data['quantity']);

    final tongTienParsed =
        _parseInt(
      data['total_amount'],
    );

    return DonHang(
      id: data['id'].toString(),

      // FK table_id
      tenBan:
          data['tables']?['table_name'] ??
              '---',

      // FK product_id
      tenSanPham:
          data['products']?['name'] ??
              '',

      size: data['size'] ?? '',

      mucDa:
          data['ice_level'] ?? '',

      soLuong: soLuongParsed,

      tongTien: tongTienParsed,

      hinhThuc:
          data['note'] ?? '',

      ghiChu:
          data['note'] ?? '',

      hinhAnh:
          data['products']
                  ?['image_url'] ??
              '',

      trangThai:
          data['payment_status'] ??
              'unpaid',
    );
  }

  // ==========================
  // JSON Insert / Update
  // ==========================
  Map<String, dynamic> toMap() {
    return {
      'table_id': tenBan,
      'size': size,
      'ice_level': mucDa,
      'quantity': soLuong,
      'total_amount': tongTien,
      'note': hinhThuc,
      'payment_status': trangThai,
    };
  }
}



// class DonHang {
//   String id;
//   String tenBan;
//   String tenSanPham;
//   String size;
//   String mucDa;
//   int soLuong;
//   int tongTien;
//   String hinhThuc;
//   String hinhAnh;
//   String trangThai;

//   DonHang({
//     required this.id,
//     required this.tenBan,
//     required this.tenSanPham,
//     required this.size,
//     required this.mucDa,
//     required this.soLuong,
//     required this.tongTien,
//     required this.hinhThuc,
//     required this.hinhAnh,
//     required this.trangThai,
//   });

//   // 🔥 THÊM: Getter để lấy giá đơn vị (Giá 1 ly)
//   // Logic: Nếu số lượng > 0 thì chia, ngược lại thì bằng 0 để tránh lỗi chia cho 0
//   int get giaDonVi {
//     if (soLuong > 0) {
//       return (tongTien / soLuong).round();
//     }
//     return 0;
//   }

//   factory DonHang.fromFirestore(String id, Map<String, dynamic> data) {
//     // 🔥 FIX: Parse soLuong chính xác
//     final soLuongRaw = data['soLuong'];
//     int soLuongParsed = 0;

//     if (soLuongRaw is int) {
//       soLuongParsed = soLuongRaw;
//     } else if (soLuongRaw is String) {
//       soLuongParsed = int.tryParse(soLuongRaw) ?? 0;
//     } else if (soLuongRaw is double) {
//       soLuongParsed = soLuongRaw.toInt();
//     }

//     // 🔥 FIX: Parse tongTien chính xác
//     final tongTienRaw = data['tongTien'];
//     int tongTienParsed = 0;

//     if (tongTienRaw is int) {
//       tongTienParsed = tongTienRaw;
//     } else if (tongTienRaw is String) {
//       tongTienParsed = int.tryParse(tongTienRaw) ?? 0;
//     } else if (tongTienRaw is double) {
//       tongTienParsed = tongTienRaw.toInt();
//     }

//     print('🔍 DEBUG DonHang.fromFirestore:');
//     print('  ID: $id');
//     print(
//         '  soLuong: $soLuongParsed (raw: $soLuongRaw, type: ${soLuongRaw.runtimeType})');
//     print(
//         '  tongTien: $tongTienParsed (raw: $tongTienRaw, type: ${tongTienRaw.runtimeType})');

//     return DonHang(
//       id: id,
//       tenBan: data['tenBan'] ?? '',
//       tenSanPham: data['tenSanPham'] ?? '',
//       size: data['size'] ?? '',
//       mucDa: data['mucDa'] ?? '',
//       soLuong: soLuongParsed,
//       tongTien: tongTienParsed,
//       hinhThuc: data['hinhThuc'] ?? '',
//       hinhAnh: data['hinhAnh'] ?? '',
//       trangThai:
//           data['trangThai'] ?? data['trangThaiThanhToan'] ?? 'Chưa thanh toán',
//     );
//   }
// }
