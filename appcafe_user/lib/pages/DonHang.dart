class DonHang {
  String id;
  String tenBan;
  String tenSanPham;
  String size;
  String mucDa;
  int soLuong;
  int tongTien;
  String hinhThuc;
  String hinhAnh;
  String trangThai;

  DonHang({
    required this.id,
    required this.tenBan,
    required this.tenSanPham,
    required this.size,
    required this.mucDa,
    required this.soLuong,
    required this.tongTien,
    required this.hinhThuc,
    required this.hinhAnh,
    required this.trangThai,
  });

  // 🔥 THÊM: Getter để lấy giá đơn vị (Giá 1 ly)
  // Logic: Nếu số lượng > 0 thì chia, ngược lại thì bằng 0 để tránh lỗi chia cho 0
  int get giaDonVi {
    if (soLuong > 0) {
      return (tongTien / soLuong).round();
    }
    return 0;
  }

  factory DonHang.fromFirestore(String id, Map<String, dynamic> data) {
    // 🔥 FIX: Parse soLuong chính xác
    final soLuongRaw = data['soLuong'];
    int soLuongParsed = 0;

    if (soLuongRaw is int) {
      soLuongParsed = soLuongRaw;
    } else if (soLuongRaw is String) {
      soLuongParsed = int.tryParse(soLuongRaw) ?? 0;
    } else if (soLuongRaw is double) {
      soLuongParsed = soLuongRaw.toInt();
    }

    // 🔥 FIX: Parse tongTien chính xác
    final tongTienRaw = data['tongTien'];
    int tongTienParsed = 0;

    if (tongTienRaw is int) {
      tongTienParsed = tongTienRaw;
    } else if (tongTienRaw is String) {
      tongTienParsed = int.tryParse(tongTienRaw) ?? 0;
    } else if (tongTienRaw is double) {
      tongTienParsed = tongTienRaw.toInt();
    }

    print('🔍 DEBUG DonHang.fromFirestore:');
    print('  ID: $id');
    print(
        '  soLuong: $soLuongParsed (raw: $soLuongRaw, type: ${soLuongRaw.runtimeType})');
    print(
        '  tongTien: $tongTienParsed (raw: $tongTienRaw, type: ${tongTienRaw.runtimeType})');

    return DonHang(
      id: id,
      tenBan: data['tenBan'] ?? '',
      tenSanPham: data['tenSanPham'] ?? '',
      size: data['size'] ?? '',
      mucDa: data['mucDa'] ?? '',
      soLuong: soLuongParsed,
      tongTien: tongTienParsed,
      hinhThuc: data['hinhThuc'] ?? '',
      hinhAnh: data['hinhAnh'] ?? '',
      trangThai:
          data['trangThai'] ?? data['trangThaiThanhToan'] ?? 'Chưa thanh toán',
    );
  }
}
